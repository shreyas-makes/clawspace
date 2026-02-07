
## Product Name (Working)

AgentOS
A mobile-first communication platform for building software with AI agents and a trusted human in the loop.

---

## One-Line Description

AgentOS is a communication-first system where two humans collaborate with a long-running AI agent to build software together, using chat as the control plane and persistent memory as the backbone.

---

## Core Philosophy

Building software alone is cognitively expensive and emotionally isolating.
AgentOS reframes building as a shared, game-like process:

* One trusted human collaborator
* One autonomous AI agent
* Clear state, progress, and memory
* Minimal UI, maximum leverage
* Mobile-first by default

Chat is not an interface bolted on top of tools.
Chat *is* the system.

---

## Target Users

* Indie hackers
* Solo founders with one trusted collaborator
* Small teams experimenting with autonomous agents
* Builders who want async progress without babysitting agents

Non-goals:

* Large enterprise workflows
* Real-time collaborative editing
* General-purpose chat replacement

---

## Core Constraints (MVP)

* Exactly **2 humans + 1 agent** per project
* One agent session per project
* Mobile-first interaction via Mattermost mobile apps
* Low-cost VPS hosting (< $50/month)
* Strong default security posture

---

## High-Level Architecture

```
Humans (Mobile)
   ↓
Mattermost (Self-hosted)
   ↓
OpenClaw Mattermost Plugin
   ↓
OpenClaw Agent Runtime
   ↓
Workspace + Git Repos
```

---

## Key Components

### 1. Mattermost (Communication Layer)

* Channels represent projects
* Threads represent tasks
* Humans interact entirely via Mattermost (desktop or mobile)
* Agent posts structured heartbeat updates
* Push notifications are the primary alert mechanism

Why Mattermost:

* Self-hostable
* Open plugin system
* First-class mobile apps
* No vendor lock-in

Slack is explicitly not used due to:

* API restrictions
* Agent autonomy limits
* Long-horizon task fragility

---

### 2. OpenClaw Agent (Autonomy Layer)

* Single agent per project
* Long-lived session
* Persistent memory via filesystem
* Heartbeat-driven execution model
* Integrated via official Mattermost plugin

Agent responsibilities:

* Read task state
* Decide next actions
* Execute code, research, or writing
* Commit changes
* Report progress back to humans

---

### 3. Persistent Workspace (Memory Layer)

Located at `/workspace/`

| File         | Purpose                           |
| ------------ | --------------------------------- |
| WORKING.md   | Current task state and intent     |
| LOG.md       | Append-only execution log         |
| HEARTBEAT.md | Agent heartbeat checklist         |
| SOUL.md      | Agent role, tone, and constraints |
| config.json  | API keys, repo paths, limits      |

Key principle:

> The agent never “remembers” things implicitly. All state is explicit and inspectable.

---

### 4. Git Integration

* Agent can:

  * Clone repos
  * Create branches
  * Commit changes
  * Push to remote
* Humans approve merges via chat
* No direct auto-merge in MVP

---

### 5. Scheduler / Heartbeats

* Agent wakes every 15 minutes
* Reads WORKING.md
* Executes next safe unit of work
* Writes logs and updates
* Posts `[agent_heartbeat]` message

Failure handling:

* Retries on transient errors
* Never loops endlessly
* Always reports failure states

---

## Interaction Model

### Human → Agent

Humans can:

* Assign tasks via thread messages
* Mention the agent to trigger action
* Comment, clarify, or block progress
* Approve or reject outputs

Humans cannot:

* Directly execute shell commands
* Force unsafe actions
* Bypass agent guardrails

---

### Agent → Human

Agent communicates via structured messages:

```
[agent_heartbeat]
Task: Implement auth middleware
Status: In Progress

Progress:
- Read repo structure
- Drafted middleware skeleton

Next Steps:
1. Add tests
2. Wire into router
3. Commit branch
```

These messages are optimized for mobile reading.

---

## Security Model (Non-Negotiable)

### VPS Hardening

* SSH:

  * Key-only authentication
  * Password login disabled
  * Root login disabled
  * SSH allowed only via Tailscale subnet
* Firewall:

  * UFW enabled
  * Port 22 → Tailscale only
  * Port 443 → Cloudflare IP ranges only
  * All other inbound traffic blocked
* fail2ban enabled
* Unattended upgrades with auto-reboot enabled

Threat model:

* Internet is hostile
* VPS is never directly exposed
* Compromise requires laptop + SSH key + Tailscale

---

## Mobile-First UX

* Mattermost mobile app is the primary interface
* No custom mobile UI in MVP
* Notifications are essential, not optional
* All critical actions possible from phone:

  * Read progress
  * Approve work
  * Assign tasks
  * Stop agent

---

## MVP Success Criteria

The MVP is successful if:

* Two humans can collaborate with one agent
* Agent executes multi-day tasks without losing context
* Humans can manage everything from their phone
* Server remains secure by default
* The system feels alive, not mechanical

---

## Explicit Non-Goals (MVP)

* Multiple agents per project
* Real-time streaming output
* GUI dashboards
* Role-based access control beyond 2 humans
* Agent self-replication or self-modification

---

## Future Extensions (Not MVP)

* Multiple agents per workspace
* Visual task timelines
* Agent “skills” marketplace
* Cross-project memory
* Offline-first mobile UX
* Game-like progression mechanics

---

## Product North Star

> Building software should feel like playing a long, thoughtful game with a trusted friend and a tireless AI companion.

