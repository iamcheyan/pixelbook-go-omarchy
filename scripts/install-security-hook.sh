#!/usr/bin/env bash
set -euo pipefail

project_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
git -C "$project_dir" config core.hooksPath .githooks
printf '已启用安全 hook：%s\n' "$project_dir/.githooks/pre-commit"
