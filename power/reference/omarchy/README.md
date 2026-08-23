# Omarchy 参考文件

以下脚本来自本机安装的 Omarchy（读取时位于 `/usr/bin/`），这里只保留快照：

- `omarchy-hibernation-setup`：创建 Btrfs swapfile，写入 fstab、resume hook、
  Limine `resume=`/`resume_offset=` 和 s2idle RTC alarm，并重建 initramfs/UKI。
- `omarchy-hibernation-available`：检查 hibernation 支持、非 zram swap 大小和
  `omarchy_resume.conf`。
- `omarchy-hibernation-remove`：删除 Omarchy 创建的 swapfile、resume 配置并重建镜像。

这些脚本依赖 Omarchy、Limine、Btrfs 和 `run0`/`sudo` 等环境。其他设备应先阅读
并按自己的启动器、文件系统和 swap 方案改写，不要盲目执行。
