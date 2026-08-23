# `pixelbook-fedora` 与当前 Omarchy/Atlas 的兼容性分析

仓库：`pixelbook-fedora/`  
来源：<https://github.com/jasonmontleon/pixelbook-fedora>  
当前提交：`23ef6ff`（2026-03-24）  
分析对象：Google Pixelbook Go，DMI `Google Atlas`，Omarchy 4.0.0，内核 `7.1.8-arch1-3`。

## 先说结论

这个项目很有参考价值，但**不能直接运行 Ansible playbook，也不能直接安装 Fedora 的 RPM 包或服务**。项目自身明确把目标机器写成 2017 年 Google Pixelbook **EVE**；你的机器识别为 **Atlas（Pixelbook Go）**。两者有相同的 ChromeOS/Intel 驱动体系，但设备名称、音频拓扑、触控设备和桌面输入协议并不完全相同。

可以优先借鉴或移植的内容：

- `pixelbook-aer.service` 的 AER 抑制思路（仅在确认目标 PCI 根端口后再考虑）。
- `99-pixelbook-backlights.rules` 的背光/键盘背光权限思路。
- `61-eve-sensor.hwdb` 的传感器安装矩阵思路，但必须改成 Atlas 的 hwdb 匹配规则并先验证传感器 modalias。
- README 中“从 ChromeOS recovery image 提取音频固件”的思路；文件名不能照抄，必须与当前 `snd_soc_avs` 日志和 Atlas 音频拓扑匹配。

不建议直接使用的内容：

- `ansible/playbook.yml`：只接受 Fedora 且只接受 `ansible_board_name == Eve`，还会升级系统、写入 modprobe 配置、禁用 `cros_ec_typec`、安装/启用服务。
- `pixelbook-display-orientation`、`pixelbook-touchscreen-click`、`pixelbook-acpi`：依赖 `DISPLAY`、`xinput`、`xrandr`、X11 设备名和旧的音频节点名；当前 Omarchy 是 Wayland/Hyprland，当前设备也不是这些脚本写死的 Wacom/EVE 名称。
- `61-eve-keyboard.hwdb`：匹配 `svnGoogle:pnEve`，对当前 `pnAtlas` 不会匹配。
- `50-alsa-config.conf`：只匹配 `kbl_r5514_5663_max`，当前 PipeWire 节点是 `platform-avs_*`；直接安装大概率不产生作用。
- `pixelbook-touchpad.service`：会卸载并重新加载 `i2c_hid_acpi`/`i2c_hid`，属于有状态的系统操作；当前触摸板已经正常枚举，暂时没有使用理由。
- `pixelbook-touchpad-tweak.conf`：是 Xorg 配置，Hyprland/libinput 不读取 `/etc/X11/xorg.conf.d/`。

## 与本机测试结果的逐项对照

| 项目 | 仓库方案 | 当前 Atlas 状态 | 建议 |
|---|---|---|---|
| 音频 | 提取 EVE recovery image 固件，并使用 `pixelbook-wireplumber` | MAX98373、DA7219、DMIC、HDMI 均已枚举；但缺 `intel/avs/hda-8086280b-tplg.bin` | 最值得继续研究；从 Atlas/EVE 对应 recovery image 提取前，先确认文件确实属于该 AVS 设备，保留备份，先做临时测试 |
| 显示背光 | `i915 enable_dpcd_backlight=1` | `intel_backlight` 已存在，最大值 937，当前可读写接口正常 | 不需要照搬；只有实际亮度调节失败时才考虑测试该参数 |
| 键盘热键 | EVE hwdb 将 ChromeOS 特殊按键重新映射 | 当前标准键盘 `AT Translated Set 2 keyboard` 已有 `/dev/input/event2` | 可移植 hwdb 规则，但必须改为 Atlas 匹配；不要直接覆盖系统键位 |
| 键盘背光 | Python `evdev` 监听 Ctrl+Space 写入 `chromeos::kbd_backlight` | 当前 LED 节点存在，最大值 100，当前值 0 | 脚本逻辑可能可移植；需改成 Wayland 快捷键或用户服务，不能直接照搬其权限假设 |
| 触摸板 | 重载 HID 模块的 systemd workaround | 当前 `04F3:30C5 Touchpad` 已有 event/mouse 节点 | 仅在复现“重启后触摸板失效”时测试，不能预防性启用 |
| 触摸屏/手写笔 | `WCOM50C1:00 2D1F:5143` + X11 `xinput` | 当前 event6 名称为 `ACPI0C50:00 0483:1058` | 不能直接使用；需用 libinput/Hyprland 原生坐标变换重新实现 |
| 平板旋转 | `monitor-sensor` + `xrandr`/`xinput` | 仓库脚本是 X11；当前会话是 Hyprland Wayland | 仅借鉴传感器方向映射，不运行原脚本 |
| ACPI | `acpi_listen` + X11 输入开关 + 固定 PulseAudio 节点 | 当前 PipeWire 节点为 `alsa_input.platform-avs_*` / `alsa_output.platform-avs_*` | 不直接使用；耳机插拔应通过 WirePlumber/Wayland 规则处理 |
| AER | 对 PCI `8086:9d10` 写 `CAP_EXP+0x8.w=0xe` | 本机确实有 `00:1c.0` `8086:9d10` 根端口；尚未确认仍有 AER 噪声 | 可作为候选修复；需先记录 AER 日志并单独测试，不能盲目启用 setpci 服务 |
| 传感器安装矩阵 | 只匹配 EVE/MrChromebox DMI | 本机 DMI 是 Atlas | 需要新建 Atlas 专用 hwdb 条目，先确认 `/sys/class/iio` 设备和实际方向 |

## 重要安全提示

README 的安装流程包含解锁 Chromebook、刷写 Coreboot、格式化数据等步骤；这些对已经运行 Omarchy 的机器不是必要步骤，也不应执行。Ansible playbook 还会进行系统更新和 initramfs 修改，本次分析没有运行它。

音频固件属于二进制固件，来源和机型匹配很重要。不要把 README 中的 `9d71-GOOGLE-EVEMAX-0-tplg.bin`、`dsp_fw_C750...bin` 直接重命名成当前缺失文件；应先从目标 recovery image 确认硬件型号、拓扑和许可证，再用临时路径验证。

## 推荐下一步

1. 先从当前启动日志保存完整的 AVS 错误和 ALSA 节点信息。
2. 查找针对 Atlas/Pixelbook Go 的 recovery image，而不是只下载 EVE 镜像；优先确认是否包含 `hda-8086280b-tplg.bin` 或对应 AVS 拓扑。
3. 如果目标是解决音频问题，先只测试固件文件和 UCM/WirePlumber 配置，不安装仓库中的 X11 脚本。
4. 如果目标是修复 i915/AER 日志，再单独建立可回滚的 systemd/setpci 测试，不要与音频改动混在一次重启中。

## 音频修复进展

已按仓库历史提交 `960767b` 的 AVS/UCM 方向完成本机适配：系统已有 Atlas UCM 内容，但当前声卡长名称为 `AVS I2S MAX98373`，且本机播放 PCM 是 `hw:0,0`。用户级覆盖现在提供同名 UCM 匹配并修正 PCM，PipeWire 已生成 `HiFi__Speaker__sink`，且已设为默认输出。详见 [audio/README.md](audio/README.md)。
