#!/usr/bin/env bash
set -euo pipefail

repo_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
logind_file="$repo_dir/power/systemd/logind/60-pixelbook-lid.conf"
sleep_file="$repo_dir/power/systemd/sleep/60-pixelbook-hibernate.conf"

[[ -f "$logind_file" ]] || { echo "找不到 $logind_file" >&2; exit 1; }
[[ -f "$sleep_file" ]] || { echo "找不到 $sleep_file" >&2; exit 1; }

run0 --pipe mkdir -p /etc/systemd/logind.conf.d /etc/systemd/sleep.conf.d
run0 --pipe install -m 0644 "$logind_file" /etc/systemd/logind.conf.d/60-pixelbook-lid.conf
run0 --pipe install -m 0644 "$sleep_file" /etc/systemd/sleep.conf.d/60-pixelbook-hibernate.conf
run0 --pipe systemctl reload systemd-logind

echo "已配置：合盖 suspend-then-hibernate，延迟 24h；电源键未修改。"
