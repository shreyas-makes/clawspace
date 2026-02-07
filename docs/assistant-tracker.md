# Assistant Tracker

This file tracks:
- Mistakes I made while helping you
- Things you prefer (style, process, output)

## How to Use
- Add newest entries at the top of each section.
- Keep entries short and concrete.
- Include date and action taken.

## Mistakes Log

| Date | Mistake | Impact | Fix Applied | Prevention Rule |
|---|---|---|---|---|
| 2026-02-07 | Deployed Mattermost with `MM_SITE_URL` left at `http://127.0.0.1:8065` while sharing access over Tailscale at `http://100.76.251.80:8065` | Remote users can hit redirects/host mismatch and fail to log in reliably | Updated VPS `iteration2/.env` to `MM_SITE_URL=http://100.76.251.80:8065` and restarted Mattermost | For each access mode (localhost, Tailscale IP, domain), set `MM_SITE_URL` to the exact URL users will use before sharing login instructions |
| 2026-02-07 | _None yet_ | n/a | n/a | n/a |

## User Preferences

| Date | Preference You Stated | How I Should Apply It |
|---|---|---|
| 2026-02-07 | You want quick checks for whether sensitive files are committed to git | Run `git ls-files` plus secret-pattern scans and report concrete findings/paths |
| 2026-02-07 | You want explicit guidance on whether to deploy before pushing | Provide a clear “push first vs deploy first” sequence with exact commands and decision points |
| 2026-02-07 | Keep `assistant-tracker.md` inside `docs/` as part of documentation | Maintain a synced copy at `docs/assistant-tracker.md` when updating the tracker |
| 2026-02-07 | Track mistakes and what you like in a file | Keep this file updated during future tasks |
