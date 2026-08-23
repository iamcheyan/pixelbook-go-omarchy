#!/usr/bin/env bash
set -euo pipefail

run0 --pipe rm -f \
  /etc/systemd/logind.conf.d/60-pixelbook-lid.conf \
  /etc/systemd/sleep.conf.d/60-pixelbook-hibernate.conf
run0 --pipe systemctl reload systemd-logind

echo "已删除本仓库的睡眠/休眠策略；systemd 将使用其他 drop-in 或默认配置。"
