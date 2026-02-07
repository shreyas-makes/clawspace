# Share Mattermost With Susmeet (Tailscale Access)

Use this guide to let Susmeet access your no-domain Mattermost safely over Tailscale.

## 1) What Susmeet Needs

- A Tailscale account (same tailnet as your VPS, or an accepted shared-device invite)
- Tailscale app installed on laptop/phone

## 2) Join The Tailnet

Ask Susmeet to:
1. Install Tailscale.
2. Sign in with the invited account.
3. Confirm device appears in your Tailscale admin.

## 3) Mattermost URL To Use

Use this URL:

```text
http://100.76.251.80:8065
```

This is your VPS Tailscale IP.

## 4) Login Credentials

On VPS, credentials are stored in:

```bash
~/apps/clawspace/docs/runtime-secrets.txt
```

Current intended users:
- `shreyas`
- `susmeet`

Share Susmeet's password from that file via a secure channel (not public chat).

## 5) Required Firewall Rule (Run Once On VPS)

If Susmeet cannot open the URL, run this on VPS as root:

```bash
sudo ufw allow proto tcp from 100.64.0.0/10 to any port 8065 comment 'tailscale-mm'
sudo ufw reload
sudo ufw status numbered
```

Note: this allows Mattermost only from Tailscale subnet, not public internet.

## 6) Verify Access

From Susmeet device (on Tailscale):
- Open `http://100.76.251.80:8065`
- Log in as `susmeet`
- Open channel `agent-hq`

## 7) OpenClaw Access Policy

OpenClaw allowlist is set to:
- `@shreyas`
- `@susmeet`

Only these two users are allowed for agent trigger policy.

## 8) If Access Fails

1. Check Mattermost is up:
```bash
cd ~/apps/clawspace
docker compose -f iteration2/docker-compose.yml --env-file iteration2/.env ps
curl -sf http://127.0.0.1:8065/api/v4/system/ping
```

2. Confirm Tailscale is connected on VPS:
```bash
tailscale status
```

3. Recheck UFW rule in step 5.
