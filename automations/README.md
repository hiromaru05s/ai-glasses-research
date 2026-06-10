# Automation Setup

This directory contains the tracked automation assets needed to recreate the Codex scheduled-task setup on another machine.

## Included

- `.codex/config.toml`
  Project-scoped Codex sandbox defaults. This repo enables `workspace-write` plus outbound network access so scheduled runs can reach GitHub for `git pull` / `git push` and fetch web sources without needing a full-access sandbox.
- `glass-market-daily/automation.toml.template`
  Current daily automation definition tracked in Git. The install script replaces `__REPO_PATH__` with the local repository path.
- `glass-market-daily/memory.seed.md`
  Seed memory with durable operating rules. Runtime-only history should stay in the local Codex automation memory file.
- `install-glass-market-daily.sh`
  Installs or refreshes the local Codex automation files under `$CODEX_HOME/automations/glass-market-daily/`.

## Install On A New Mac

From the repository root:

```bash
bash automations/install-glass-market-daily.sh
```

This will:

1. create `$CODEX_HOME/automations/glass-market-daily/`
2. generate `automation.toml` with the current repo path as `cwd`
3. create `memory.md` from the tracked seed if it does not already exist

Codex also loads the repo's tracked `.codex/config.toml` when the project is trusted. If Codex was already open when you cloned or updated the repo, restart the app once before relying on scheduled `git pull` / `git push`.

## Refresh After Repo Changes

If the tracked automation definition changes, rerun:

```bash
bash automations/install-glass-market-daily.sh --force-memory
```

Use `--force-memory` only when you want to replace the local automation memory with the tracked seed.
