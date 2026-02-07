# Iteration 2 Deployment Reference (Live)

This is the current no-domain deployment state and login guide for your VPS.

## VPS + Stack

- VPS SSH: `deploy@100.76.251.80`
- App root on VPS: `~/apps/clawspace`
- Mattermost URL (server-local): `http://127.0.0.1:8065`
- Mattermost URL (Tailscale-share): `http://100.76.251.80:8065`
- Compose file: `~/apps/clawspace/iteration2/docker-compose.yml`
- Env file: `~/apps/clawspace/iteration2/.env`

## Login From Your Laptop

1. Start SSH tunnel (optional for private local access):

```bash
ssh -L 8065:127.0.0.1:8065 deploy@100.76.251.80
```

2. Open Mattermost in browser:
- Tunnel mode: `http://localhost:8065`
- Tailscale mode: `http://100.76.251.80:8065`

## Where Credentials Are Stored

On VPS:

- App/account credentials: `~/apps/clawspace/docs/runtime-secrets.txt`
- Generated bootstrap credentials: `~/apps/clawspace/docs/generated-credentials.txt`
- OpenClaw gateway token: `~/apps/clawspace/docs/gateway-token.txt`

To view them:

```bash
ssh deploy@100.76.251.80
sed -n '1,220p' ~/apps/clawspace/docs/runtime-secrets.txt
```

## Current Users

- Admin: `clawadmin` (admin account)
- Humans: `shreyas`, `susmeet`
- Bot: `clawbot`
- Placeholder users `human1` and `human2` were removed.

## OpenClaw Runtime

- OpenClaw installed via user-space Node (`nvm`, Node 22)
- Config file: `~/.openclaw/openclaw.json`
- Allowlist: `@shreyas`, `@susmeet`

## Verify Deployment

On VPS:

```bash
cd ~/apps/clawspace
docker compose -f iteration2/docker-compose.yml --env-file iteration2/.env ps
curl -sf http://127.0.0.1:8065/api/v4/system/ping | jq .
```

Expected: `"status": "OK"`

Verify heartbeat send through OpenClaw:

```bash
export NVM_DIR="$HOME/.nvm"
. "$NVM_DIR/nvm.sh"
nvm use 22 >/dev/null
TOKEN=$(grep '^OPENCLAW_GATEWAY_TOKEN=' ~/apps/clawspace/docs/gateway-token.txt | cut -d= -f2-)
CH_ID=$(grep '^MM_CHANNEL_ID=' ~/apps/clawspace/docs/runtime-secrets.txt | cut -d= -f2-)
OPENCLAW_GATEWAY_TOKEN="$TOKEN" openclaw message send --channel mattermost --target "$CH_ID" --message "[agent_heartbeat] manual check" --json
```

## Tailscale Sharing With Susmeet

See:

- `docs/share-with-susmeet-tailscale.md`

Important: if Susmeet cannot connect, run UFW rule from that doc to allow Tailscale subnet to `8065`.

## Current Security Mode

- No-domain mode
- Mattermost exposed on `8065` for Tailscale sharing
- Signup remains disabled:
  - `MM_ENABLE_USER_CREATION=false`
  - `MM_ENABLE_SIGNUP_WITH_EMAIL=false`

## Known Limits In No-Domain Mode

- Core chat + bot + heartbeat works.
- Mobile push reliability is limited until public HTTPS domain is set up.
