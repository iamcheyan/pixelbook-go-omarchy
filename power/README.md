# 睡眠与休眠配置

这个目录收集 Pixelbook Go/Omarchy 当前使用的电源策略，以及 Omarchy 和
systemd 的相关实现，供本机安装和其他设备移植参考。

## 目录结构

```text
power/
├── install-power-policy.sh       # 安装本仓库的 lid/sleep 策略
├── uninstall-power-policy.sh     # 删除本仓库安装的 drop-in
├── systemd/logind/               # 合盖行为
├── systemd/sleep/                # suspend-then-hibernate 延迟
├── systemd/system-sleep/         # 可选的休眠前 hook
└── reference/
    ├── omarchy/                  # Omarchy 休眠脚本的本机参考副本
    └── systemd/                  # systemd 服务定义的参考副本
```

`reference/` 中的文件是上游/系统文件的快照，用于理解实现，不应直接复制到
`/usr/bin` 或 `/usr/lib/systemd/system` 覆盖发行版文件。Omarchy 更新或 systemd
升级后，参考副本可能需要重新同步。

## 当前 Atlas 策略

- 合盖后进入 `suspend-then-hibernate`。
- 睡眠持续 `24h` 后进入 Hibernate/ACPI S4。
- 电池和外接电源都使用同一策略。
- 电源键保持系统默认行为。

安装前请确认设备已经由 Omarchy 完成休眠准备（swap、`resume` initramfs hook
和启动参数）。在 Omarchy 上可以先运行：

```bash
omarchy hibernation setup
```

如果设备没有 Omarchy，应按照 `reference/omarchy/omarchy-hibernation-setup`
的思路为 systemd 配置足够大的 swap、initramfs `resume` hook，以及正确的
`resume=`/`resume_offset=` 启动参数。不同文件系统、启动器和 swap 类型不能
直接照搬 Pixelbook 的参数。

## 安装和回滚

```bash
./power/install-power-policy.sh
./power/uninstall-power-policy.sh
```

安装脚本只写入 `/etc/systemd/logind.conf.d/60-pixelbook-lid.conf` 和
`/etc/systemd/sleep.conf.d/60-pixelbook-hibernate.conf`，然后重新加载
`systemd-logind`。它不会执行 suspend、hibernate、reboot 或 shutdown。

可用以下命令检查最终配置：

```bash
loginctl show-logind \
  -p HandleLidSwitch -p HandleLidSwitchExternalPower -p HandleLidSwitchDocked
systemd-analyze cat-config systemd/sleep.conf
```

### 适配其他设备

1. 检查 `/sys/power/image_size`、`/sys/power/state` 和 `/sys/power/mem_sleep`。
2. 先完成该设备自己的 hibernation setup，并确认 `systemctl hibernate` 能恢复。
3. 根据设备需求修改 `systemd/logind/*.conf` 和 `systemd/sleep/*.conf` 的文件名与策略。
4. 只有确认固件支持后，才考虑 `deep`、RTC alarm 或设备专用的 sleep hook。
5. 安装后先读取配置和日志，再单独测试普通睡眠、唤醒、合盖和自动休眠。

## 实现链路

Omarchy 菜单调用 `systemctl hibernate`；systemd 再调用
`systemd-hibernate.service`/`systemd-suspend-then-hibernate.service`，最终由
内核把内存镜像写入 swap 并进入 ACPI S4。下次启动时 initramfs 的 `resume`
hook 根据 `resume=` 和 `resume_offset=` 在图形驱动加载前恢复内存镜像。

`HibernateDelaySec=24h` 只控制 suspend-then-hibernate 的等待时间，并不负责创建
swap 或配置恢复参数。
