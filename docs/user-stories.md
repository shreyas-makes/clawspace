Final Hardened Iteration Prompt Set
Iteration 1: VPS & Hardening (Secure)

Generate a shell script and instructions to:

1. Provision OVHcloud VPS (Ubuntu 24.04).
2. Disable password login and root login for SSH; enforce key-only authentication.
3. Configure SSH to only allow connections from a Tailscale subnet.

5. Install fail2ban and configure it to protect SSH and optionally HTTP endpoints.
6. Enable unattended security upgrades with auto-reboot.
7. Optionally configure swap memory.
8. Include verification commands for SSH, HTTPS, and fail2ban.

User Story: As a developer, I want the VPS hardened so unauthorized access is impossible and the server stays automatically updated for security.

Iteration 3: Workspace Files & Structure

Write a script or instructions to create and secure the agent's persistent workspace:

1. Create /workspace/ folder on the VPS.
2. Create files: WORKING.md, LOG.md, HEARTBEAT.md, SOUL.md.
3. Create config.json for API keys, Git paths, and agent settings (permissions restricted).
4. Create scripts/ folder for helper scripts.
5. Set proper file permissions and ownership to restrict access to the agent user only.

User Story: As a human or agent, I want a structured workspace so task state and logs persist reliably.

Iteration 4: OpenClaw Agent Core

Write Python code to:

1. Initialize an OpenClaw-based agent project.
2. Create folder structure: /agent/, /agent/modules/, /agent/tests/.
3. Implement AgentMemory class to read/write WORKING.md, LOG.md, HEARTBEAT.md, SOUL.md securely.
4. Read credentials from config.json in a secure way.
5. Include unit tests for reading and writing workspace files.

User Story: As a developer, I want persistent agent memory so tasks and history survive restarts.

Iteration 5: Heartbeat & Task Logic

Write Python code to:

1. Configure OpenClaw heartbeat scheduler with a custom heartbeat.prompt summarizing long-horizon tasks.
2. Read WORKING.md and LOG.md to determine task state.
3. Implement decide_next_task() stub to suggest the next task.
4. Update HEARTBEAT.md and LOG.md.
5. Post [agent_heartbeat] messages to Mattermost via OpenClaw plugin.
6. Include unit tests for heartbeat and task decision logic.
7. Implement simple task queue for 2 humans to prevent overwriting tasks.

User Story: As a human, I want periodic heartbeat updates so I can monitor autonomous task progress.

Iteration 6: Scheduler / Cron (Optional)

Write instructions and scripts to:

1. Configure a cron or Python scheduler to run heartbeat every 15 minutes as a fallback.
2. Retry heartbeat up to 3 times on failure.
3. Run as a non-root, least-privileged agent user.
4. Include verification steps to confirm heartbeat executes automatically.

User Story: As a human, I want the agent to progress tasks automatically without exposing root access.

Iteration 7: Git Integration

Write Python code to:

1. Clone repositories using GitPython.
2. Create branches, commit changes, and push to remote.
3. Detect and handle merge conflicts safely.
4. Update WORKING.md with commit status.
5. Store Git credentials securely.
6. Include unit tests for Git operations.

User Story: As a developer, I want the agent to safely manage code so humans can approve merges without conflicts.

Iteration 8: Mobile UX & Notifications

Write code and configuration instructions to:

1. Use OpenClaw Mattermost plugin to send [agent_heartbeat] messages.
2. Ensure mobile push notifications are delivered through Mattermost apps.
3. Format heartbeat messages for readability using Markdown.
4. Ensure mention-triggered or DM-based responses follow configured access policies.
5. Include tests to verify messages and notifications.

User Story: As a human, I want mobile notifications so I can approve tasks quickly on the go.

Iteration 9: Multi-Human Task Workflow (2 Humans + 1 Agent)

Write Python code and configuration to:

1. Ensure both humans in the channel can trigger the agent using mention or prefix commands.
2. Implement a simple task queue in WORKING.md:
   - First-in-first-out execution for agent tasks.
   - Queue new tasks when the agent is busy.
3. Agent executes tasks sequentially, updates LOG.md and HEARTBEAT.md.
4. Posts task confirmations and progress via [agent_heartbeat] messages.
5. Include unit tests to verify task queue and agent behavior for 2 humans.

User Story: As a developer, I want to collaborate with one trusted human and an autonomous agent, so I can build software together while seeing agent progress and approvals in real time on mobile.

Iteration 10: Full MVP Integration

Write a Python script run_agent.py that:

1. Initializes AgentMemory and GitOps.
2. Triggers heartbeats via OpenClaw scheduler.
3. Reads WORKING.md and decides next task.
4. Executes task stub (Codex SDK placeholder).
5. Commits updates and updates WORKING.md.
6. Posts [agent_heartbeat] messages via OpenClaw plugin.
7. Handles task queue for 2 humans.
8. Ensure all network connections go through Tailscale / Cloudflare, no services exposed publicly.
9. Include integration tests simulating a full heartbeat cycle.

User Story: As a human, I want a fully functional autonomous agent MVP so tasks are executed, logged, committed, and communicated via Mattermost mobile securely.
