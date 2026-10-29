# fusion-dotfiles

Dotfiles for Claude Code agents in fusion Coder workspaces. The `fusion`
template clones this repo to `~/.dotfiles` and runs `install` on every
workspace start, after it writes `~/.claude/settings.json`.

`install` does four things, each idempotent:

- **Agent instructions.** Fetches the `pylon` branch of the public
  `kalgynirae/dotfiles` into `~/.cache/agent-instructions`, then copies its
  `agents/AGENTS.md` to `~/.claude/CLAUDE.md`, plus `agents/*.md` and
  `agents/skills/` to `~/.config/agents/`. When GitHub is unreachable, it
  keeps the last copy it installed.
- **Claude settings.** Merges [`claude/settings.json`](claude/settings.json)
  into `~/.claude/settings.json`. It adds `env` keys and appends the status
  hook to each hook event. Everything else, including `model` and
  `permissions.defaultMode`, stays as the template wrote it.
- **Shell.** Adds a line to `~/.bashrc` that sources
  [`shell/rc.bash`](shell/rc.bash).
- **tmux.** Links `~/.tmux.conf` to [`tmux.conf`](tmux.conf).

## Status hook

[`bin/agent-status-hook`](bin/agent-status-hook) keeps `~/.agent-status.md`
honest when a session is waiting on a person. It sets `state: needs-colin`,
a `blocked-on:` reason and a fresh `updated:` when:

| Event | Reason |
|---|---|
| `PermissionRequest` | `waiting at a permission prompt (<tool>)` |
| `PreToolUse` on `AskUserQuestion` | `waiting on a question menu` |
| `Notification` `elicitation_dialog` | `waiting on an MCP input dialog` |
| `Notification` `idle_prompt`, only while `state: working` | `idle at the prompt while state was working` |
| `Notification` `permission_prompt`, if not already marked | `waiting at a permission prompt` |

The next event from the same session and subagent restores the previous
`state:` and `blocked-on:`. That event is any `PreToolUse`, `PostToolUse`,
`PostToolUseFailure`, `Stop` or `SubagentStop`, and a `UserPromptSubmit` or
`SessionEnd` clears the mark for its whole session. If the agent rewrote the
file while it was marked, the hook leaves it alone. The saved state is in
`~/.local/state/agent-status-hook/mark`.

`Notification` `agent_needs_input` is left out on purpose. It is sent by the
`claude agents` view, not by the waiting session. The waiting session has
already marked the file through its own hooks, and a mark owned by the view
session would never be cleared.

## Git credentials

A shell or tmux server started by a one-shot `coder ssh` keeps that session's
`GIT_ASKPASS` and `GIT_SSH_COMMAND`. Both point into a `/tmp/coder.*`
directory that is deleted when the ssh session ends. The shell also keeps a
`GITHUB_TOKEN` minted at login, which expires. `shell/rc.bash`, `tmux.conf`
and the settings `env` replace the first two with the stable `/bin/coder` and
clear `GITHUB_TOKEN`. The box's `gh` wrapper and git credential helper mint a
fresh token on each call.
