#!/usr/bin/env bash
set -euo pipefail

# Compatibility entry point. The canonical implementation now lives in power/.
repo_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
exec "$repo_dir/power/install-power-policy.sh" "$@"
