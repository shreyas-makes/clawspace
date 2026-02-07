#!/usr/bin/env bash
set -euo pipefail

# =========================
# Config (edit these first)
# =========================
ADMIN_USER="${ADMIN_USER:-deploy}"
ADMIN_PUBKEY="${ADMIN_PUBKEY:-}"           # REQUIRED: ssh-ed25519 AAAA... you@laptop
TAILSCALE_AUTHKEY="${TAILSCALE_AUTHKEY:-}" # Optional but recommended (tskey-...)
TAILSCALE_SSH_SUBNET="${TAILSCALE_SSH_SUBNET:-100.64.0.0/10}"

ENABLE_SWAP="${ENABLE_SWAP:-false}"        # true/false
SWAP_SIZE_GB="${SWAP_SIZE_GB:-4}"

ENABLE_HTTP_FAIL2BAN="${ENABLE_HTTP_FAIL2BAN:-false}" # true if nginx/apache present

if [[ $EUID -ne 0 ]]; then
  echo "Run as root: sudo bash harden-vps.sh"
  exit 1
fi

if [[ -z "$ADMIN_PUBKEY" ]]; then
  echo "Set ADMIN_PUBKEY env var before running."
  echo "Example:"
  echo "  ADMIN_PUBKEY='ssh-ed25519 AAAA... you@host' sudo -E bash harden-vps.sh"
  exit 1
fi

echo "[1/9] Base packages..."
apt-get update
apt-get install -y \
  ca-certificates curl gnupg lsb-release jq \
  ufw fail2ban unattended-upgrades apt-listchanges

echo "[2/9] Create admin user + SSH key..."
if ! id -u "$ADMIN_USER" >/dev/null 2>&1; then
  adduser --disabled-password --gecos "" "$ADMIN_USER"
fi
usermod -aG sudo "$ADMIN_USER"

install -d -m 700 -o "$ADMIN_USER" -g "$ADMIN_USER" "/home/$ADMIN_USER/.ssh"
touch "/home/$ADMIN_USER/.ssh/authorized_keys"
chmod 600 "/home/$ADMIN_USER/.ssh/authorized_keys"
chown "$ADMIN_USER:$ADMIN_USER" "/home/$ADMIN_USER/.ssh/authorized_keys"

if ! grep -qF "$ADMIN_PUBKEY" "/home/$ADMIN_USER/.ssh/authorized_keys"; then
  echo "$ADMIN_PUBKEY" >> "/home/$ADMIN_USER/.ssh/authorized_keys"
fi

echo "[3/9] Install and start Tailscale..."
if ! command -v tailscale >/dev/null 2>&1; then
  curl -fsSL https://tailscale.com/install.sh | sh
fi
systemctl enable --now tailscaled

if [[ -n "$TAILSCALE_AUTHKEY" ]]; then
  tailscale up --authkey="$TAILSCALE_AUTHKEY" --ssh=false
else
  echo "TAILSCALE_AUTHKEY not set. Run 'tailscale up' manually after script."
fi

echo "[4/9] Harden SSH daemon (key-only, no root/password)..."
install -d /etc/ssh/sshd_config.d
cat >/etc/ssh/sshd_config.d/99-hardening.conf <<EOF
PermitRootLogin no
PasswordAuthentication no
KbdInteractiveAuthentication no
ChallengeResponseAuthentication no
PubkeyAuthentication yes
AuthenticationMethods publickey
PermitEmptyPasswords no
UsePAM yes
X11Forwarding no
AllowAgentForwarding no
PermitTunnel no
ClientAliveInterval 300
ClientAliveCountMax 2
AllowUsers ${ADMIN_USER}
EOF

sshd -t
systemctl restart ssh

echo "[5/9] Configure UFW..."
ufw --force reset
ufw default deny incoming
ufw default allow outgoing

# SSH only from Tailscale CGNAT subnet (or your custom tailnet route range)
ufw allow proto tcp from "$TAILSCALE_SSH_SUBNET" to any port 22 comment 'tailscale-ssh'

# HTTPS only from Cloudflare IP ranges
CF_IPV4="$(curl -fsSL https://www.cloudflare.com/ips-v4)"
CF_IPV6="$(curl -fsSL https://www.cloudflare.com/ips-v6)"
while IFS= read -r cidr; do
  [[ -n "$cidr" ]] && ufw allow proto tcp from "$cidr" to any port 443 comment 'cloudflare-https'
done <<<"$CF_IPV4"
while IFS= read -r cidr; do
  [[ -n "$cidr" ]] && ufw allow proto tcp from "$cidr" to any port 443 comment 'cloudflare-https'
done <<<"$CF_IPV6"

ufw --force enable

echo "[6/9] Configure fail2ban..."
cat >/etc/fail2ban/jail.d/sshd.local <<'EOF'
[sshd]
enabled = true
port = ssh
backend = systemd
maxretry = 5
findtime = 10m
bantime = 1h

[recidive]
enabled = true
backend = systemd
logpath = /var/log/fail2ban.log
bantime = 1w
findtime = 1d
maxretry = 5
EOF

if [[ "$ENABLE_HTTP_FAIL2BAN" == "true" ]]; then
  cat >/etc/fail2ban/jail.d/http.local <<'EOF'
[nginx-http-auth]
enabled = true

[nginx-botsearch]
enabled = true
EOF
fi

systemctl enable --now fail2ban
systemctl restart fail2ban

echo "[7/9] Enable unattended security upgrades + auto reboot..."
cat >/etc/apt/apt.conf.d/20auto-upgrades <<'EOF'
APT::Periodic::Update-Package-Lists "1";
APT::Periodic::Unattended-Upgrade "1";
EOF

cat >/etc/apt/apt.conf.d/52unattended-upgrades-local <<'EOF'
Unattended-Upgrade::Automatic-Reboot "true";
Unattended-Upgrade::Automatic-Reboot-Time "03:30";
EOF

dpkg-reconfigure -f noninteractive unattended-upgrades || true
systemctl enable --now unattended-upgrades

echo "[8/9] Optional swap..."
if [[ "$ENABLE_SWAP" == "true" ]]; then
  if ! swapon --show | grep -q '/swapfile'; then
    fallocate -l "${SWAP_SIZE_GB}G" /swapfile
    chmod 600 /swapfile
    mkswap /swapfile
    swapon /swapfile
    grep -q '^/swapfile' /etc/fstab || echo '/swapfile none swap sw 0 0' >> /etc/fstab
  fi
  cat >/etc/sysctl.d/99-swap-tuning.conf <<'EOF'
vm.swappiness=10
vm.vfs_cache_pressure=50
EOF
  sysctl --system
fi

echo "[9/9] Done."
echo
echo "Verification commands:"
echo "  tailscale status"
echo "  ssh -o PreferredAuthentications=password ${ADMIN_USER}@<server-ip>   # should fail"
echo "  ssh ${ADMIN_USER}@<tailscale-ip>                                     # should succeed"
echo "  sudo ufw status numbered"
echo "  sudo fail2ban-client status"
echo "  sudo fail2ban-client status sshd"
echo "  sudo unattended-upgrade --dry-run --debug"
