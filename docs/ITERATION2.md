# Iteration 2: Mattermost + OpenClaw Plugin Setup

This doc now supports two tracks:
- Track A (No-domain first): deploy and test using localhost/SSH tunnel or Tailscale IP.
- Track B (Production): add domain + HTTPS + Cloudflare lock-down.

## 1. Prerequisites

- Iteration 1 hardening already applied (`harden-vps.sh`) on Ubuntu 24.04.
- Docker Engine + Docker Compose plugin installed.
- Node.js 22+ available for OpenClaw CLI runtime.

## 2. Deploy Mattermost with Docker Compose

From repo root:

```bash
cp iteration2/.env.example iteration2/.env
mkdir -p iteration2/volumes/{postgres,mattermost/config,mattermost/data,mattermost/logs,mattermost/plugins,mattermost/client/plugins,mattermost/bleve-indexes}
docker compose -f iteration2/docker-compose.yml --env-file iteration2/.env up -d
```

Validate:

```bash
docker compose -f iteration2/docker-compose.yml --env-file iteration2/.env ps
docker compose -f iteration2/docker-compose.yml --env-file iteration2/.env logs --tail=80 mattermost
curl -sf http://127.0.0.1:8065/api/v4/system/ping | jq .
```

Expected: JSON with `"status":"OK"`.

## 3. Access Modes

### Track A: No-domain first (recommended to start)

Default compose binds Mattermost to `127.0.0.1:8065` only.

Access UI using SSH tunnel:

```bash
ssh -L 8065:127.0.0.1:8065 deploy@<tailscale-vps-ip>
```

Then open `http://localhost:8065` on your laptop.

Optional: mobile test over Tailscale (no public domain):
- Put phone on same tailnet.
- Change compose port mapping from `127.0.0.1:${MM_HTTP_BIND_PORT}:8065` to `${MM_HTTP_BIND_PORT}:8065`.
- Restrict UFW to Tailscale subnet on `8065` only.

Example rule:

```bash
sudo ufw allow proto tcp from 100.64.0.0/10 to any port 8065 comment 'tailscale-mm'
```

### Track B: Production domain + Cloudflare

Use reverse proxy + TLS on `443` and Cloudflare proxied DNS.
Set `MM_SITE_URL=https://chat.your-domain.com` and apply Cloudflare allowlist rules for `443`.

## 4. Install and Configure OpenClaw Mattermost

Install CLI:

```bash
npm install -g openclaw@latest
openclaw doctor --fix
```

Create `~/.openclaw/openclaw.json`:

```json
{
  "plugins": {
    "entries": {
      "mattermost": {
        "enabled": true
      }
    }
  },
  "channels": {
    "mattermost": {
      "enabled": true,
      "baseUrl": "http://127.0.0.1:8065",
      "botToken": "REPLACE_WITH_MM_BOT_TOKEN",
      "dmPolicy": "allow",
      "chatmode": "oncall",
      "oncharPrefixes": ["@claw"],
      "groupPolicy": "whitelist",
      "groupAllowFrom": ["@shreyas", "@susmeet"],
      "defaultChannelId": "REPLACE_WITH_CHANNEL_ID"
    }
  },
  "gateway": {
    "mode": "local"
  }
}
```

If OpenClaw runs on another machine, set `baseUrl` to reachable address (Tailscale IP/domain).

Trigger mapping:
- `onmention` -> `chatmode: "oncall"`
- `onmessage` -> `chatmode: "onmessage"`
- `onprefix` -> `chatmode: "onchar"` with `oncharPrefixes`

Start gateway:

```bash
openclaw gateway --verbose
```

## 5. Mattermost Bot + Human Accounts

In Mattermost System Console:
1. Create first admin account during onboarding.
2. Create bot account (example: `claw-bot`) and generate token.
3. Create the two human accounts that are allowed to trigger the agent.
4. Use those handles in `groupAllowFrom` (example: `@shreyas`, `@susmeet`).

## 6. Verification

### 6.1 Core checks

```bash
docker compose -f iteration2/docker-compose.yml --env-file iteration2/.env ps
curl -sf http://127.0.0.1:8065/api/v4/system/ping | jq .
```

### 6.2 Heartbeat check

```bash
openclaw message send \
  --target "channel:REPLACE_WITH_CHANNEL_ID" \
  --message "[agent_heartbeat] Iteration 2 connectivity check"
```

Expected: message appears in channel/thread.

### 6.3 Trigger + policy checks

From allowlisted users:
- `onmention`: `@claw-bot status?`
- `onmessage`: plain message (if `chatmode=onmessage`)
- `onprefix`: `@claw summarize` (if `chatmode=onchar`)

From non-allowlisted user: no execution when `groupPolicy=whitelist`.

### 6.4 Mobile checks

No-domain first:
- Works only if phone can reach the server (Tailscale path).
- In-app URL can be Tailscale IP + port if reachable.

Production domain:
- Use `https://chat.your-domain.com`.
- This is the path for reliable push notifications.

## 7. Important Limitation (No-domain mode)

Without public HTTPS domain, you can validate core chat + plugin behavior, but mobile push notifications may be limited/unreliable depending on your network and push setup.

## 8. Done Criteria

- Mattermost runs via Docker Compose.
- OpenClaw plugin installed and connected.
- Trigger modes (`onmention`, `onmessage`, `onprefix`) validated.
- 2-human allowlist policy validated.
- For production, Cloudflare + UFW restrictions validated.
- `[agent_heartbeat]` visible in channel/thread; push verified in production domain setup.
