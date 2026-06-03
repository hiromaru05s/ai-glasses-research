#!/usr/bin/env bash

set -euo pipefail

force_memory=0
if [[ "${1-}" == "--force-memory" ]]; then
  force_memory=1
fi

repo_root="$(cd "$(dirname "$0")/.." && pwd)"
codex_home="${CODEX_HOME:-$HOME/.codex}"
target_dir="$codex_home/automations/glass-market-daily"
template_path="$repo_root/automations/glass-market-daily/automation.toml.template"
seed_memory_path="$repo_root/automations/glass-market-daily/memory.seed.md"
target_toml="$target_dir/automation.toml"
target_memory="$target_dir/memory.md"

mkdir -p "$target_dir"

escaped_repo_root=$(printf '%s\n' "$repo_root" | sed 's/[\/&]/\\&/g')
sed "s/__REPO_PATH__/$escaped_repo_root/g" "$template_path" > "$target_toml"

if [[ ! -f "$target_memory" || "$force_memory" -eq 1 ]]; then
  cp "$seed_memory_path" "$target_memory"
fi

echo "Installed glass-market-daily automation to: $target_dir"
