#!/usr/bin/env bash
set -euo pipefail

repo_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
config_file="$repo_dir/keyboard/pixelbook-atlas.conf"

if [[ ! -f "$config_file" ]]; then
  echo "找不到 Pixelbook 键盘配置：$config_file" >&2
  exit 1
fi

keyd check "$config_file"
pkexec install -m 0644 "$config_file" /etc/keyd/pixelbook-atlas.conf
pkexec keyd reload
echo "已安装 Pixelbook Go 顶排按键映射；电源键未修改。"
