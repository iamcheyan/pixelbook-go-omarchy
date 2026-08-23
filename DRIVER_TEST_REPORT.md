# Pixelbook Go（Google Atlas）Omarchy 驱动测试报告

测试时间：2026-08-23（Asia/Tokyo）  
系统：Omarchy 4.0.0-1（Arch Linux）  
内核：`7.1.8-arch1-3`  
机型：Google Atlas（Pixelbook Go），BIOS `MrChromebox-2503.0`

## 结论摘要

本次启动中，没有发现“完全没有驱动绑定”的主要硬件。显示、无线网络、蓝牙、触摸板/触摸屏、摄像头、音频、内置存储和电池/充电均能看到对应设备节点或工作状态。

需要处理的异常有两项：

1. `i915` 显卡驱动虽然能驱动内屏和 Hyprland，但内核日志反复出现 `drm_WARN_ON(intel_cdclk_clock_changed(...))`，本次启动统计 484 次，属于“部分有效/存在稳定性风险”。
2. `snd_soc_avs` 请求 `intel/avs/hda-8086280b-tplg.bin` 失败（错误 -2）。I2S 扬声器、耳机、DMIC 和 HDMI 仍然枚举成功；UCM 修复后内置扬声器播放链路可打开，但 HDA/AVS 拓扑警告仍需后续跟进。

## 驱动与功能判定

| 硬件/功能 | 内核驱动 | 证据 | 判定 |
|---|---|---|---|
| Intel UHD Graphics 615 / 内屏 | `i915` | PCI 设备绑定 `i915`；`/sys/class/drm/card1-eDP-1` 为 `connected`；Hyprland 报告 eDP-1 `1920x1080@60.03Hz` | 部分有效：能显示，但有大量 i915 电源/时钟警告 |
| Wi‑Fi | `iwlwifi` / `iwlmvm` | `wlp1s0` 为 `up`，已连接 SSID `C40FA623BF09-5G`，5 GHz / 160 MHz，发射功率 22 dBm | 有效 |
| 蓝牙 | `btusb` / `btintel` / `btmtk` | `rfkill` 未软/硬屏蔽；`bluetoothctl show` 显示控制器已 `Powered: yes`、`PowerState: on`、可配对 | 有效（未做外部设备配对吞吐测试） |
| 内置扬声器/耳机/麦克风/HDMI 音频 | `snd_soc_avs` 及 `snd_soc_*` | `/proc/asound/cards` 有 MAX98373、DA7219、HDMI、DMIC、PROBE；UCM 修复后默认输出为 `HiFi__Speaker__sink`，`speaker-test` 可打开播放流 | 修复后有效（仍有 AVS HDA topology 警告） |
| 内置摄像头 | `ipu3_cio2` + `ipu3_imgu` | `/dev/video0`–`/dev/video13`、`/dev/media0`/`media1` 存在；`v4l2-ctl` 报告 `Video Capture Multiplanar`，`/dev/video10` 显示 `camera: ok` | 有效（已验证 V4L2 节点；未拍摄样张） |
| 键盘 | `atkbd`/标准输入栈 | `/dev/input/event2`，名称 `AT Translated Set 2 keyboard` | 有效 |
| 触摸板 | `i2c_hid` / `i2c_hid_acpi` | `ACPI0C50:01 04F3:30C5 Touchpad`，`event5`，mouse 节点存在 | 有效 |
| 触摸屏/数字笔接口 | `i2c_hid` | `ACPI0C50:00 0483:1058`，`event6`，绝对坐标能力存在 | 已枚举/基本有效（未进行手写压力测试） |
| 电池、充电、键盘背光 | ChromeOS EC 驱动栈 | `BAT0` present、capacity 100、Charging；`CROS_USBPD_CHARGER0` online；`chromeos::kbd_backlight` 存在 | 有效（背光当前亮度为 0，仅证明接口存在） |
| 背光 | `i915`/`intel_backlight` | `/sys/class/backlight/intel_backlight`，最大值 937，当前值 468 | 有效 |
| 内置 eMMC | `sdhci-pci` / `mmc_block` | `mmcblk0` 116.5G，根文件系统从其加密分区挂载；`mmcblk0boot0/1` 存在 | 有效 |
| 传感器/ChromeOS EC | `cros_ec_*`、`acpi_als` | 相关模块已加载，光照/EC 传感器模块存在 | 已枚举；未做数值变化测试 |
| Thunderbolt/USB-C 控制器 | `thunderbolt`、`xhci_hcd`、`dwc3_pci` | 对应内核模块已加载，USB 输入接收器正常枚举 | 已枚举；未插拔外设做完整热插拔测试 |

## “无效”项目

本次没有足够证据判定某个硬件驱动完全失效。以下两项属于明确的异常/不完整状态，应优先跟进：

- **i915 显示电源管理异常**：日志中反复出现 `drm_WARN_ON(intel_cdclk_clock_changed(...))`，且内核被标记为 `Tainted: W C`。目前画面仍正常，因此判定为“部分有效”，不是黑屏或驱动未加载。
- **AVS HDA 拓扑固件缺失**：`snd_soc_avs` 报 `Direct firmware load for intel/avs/hda-8086280b-tplg.bin failed -2`。已安装 `sof-firmware`，但当前固件目录未找到该精确文件名；I2S/DMIC/HDMI ALSA 设备仍存在。

## 实际音频测试（2026-08-23，修复前）

应用户反馈“音频可能不能用”，进行了实际播放和录音测试：

- `wpctl status`：PipeWire、WirePlumber 均运行；默认输出为 `alsa_output.platform-avs_max98373.18.auto.stereo-fallback`（内置扬声器），默认输入为 DA7219。
- `speaker-test -D default -t sine -f 440 -c 2`：成功打开 48 kHz/S16_LE 双声道播放流并显示 Front Left/Front Right；测试进程由超时结束，未出现设备打开失败。
- `arecord -D default -f S16_LE -r 48000 -c 2 -d 3`：成功生成 3 秒、576044 字节 WAV；DMIC 设备同样能成功录音。
- `hw:0,0` 直接打开时返回 `Device or resource busy`，原因是 PipeWire 已占用该硬件，这是共享设备占用，不是驱动不存在。
- PipeWire 软件音量为 69%，但 ALSA 硬件混音器读数为：`DSP = 0%`、`Left Speaker = 0%`、`Right Speaker = 0%`；`Left Spk`/`Right Spk` 开关为 on。这说明当前最可能的问题是 AVS/功放拓扑初始化后的硬件增益仍为 0，软件音量无法单独解决。

因此，当前音频判定从“设备枚举正常”修正为：**播放链路可打开、录音链路有效，但内置扬声器实际输出很可能无声；优先处理 AVS/MAX98373 拓扑/硬件混音器初始化。**

### 已应用的修复

参考 `pixelbook-fedora` 历史提交 `960767b`，发现发行版已有 Atlas UCM 文件但没有匹配当前声卡长名称。已在用户目录配置 `audio/atlas-ucm2/` 覆盖：

- 增加 `AVS I2S MAX98373` 的 UCM 匹配入口；
- 将 Atlas 扬声器 PCM 从 `hw:${CardId},1` 修正为本机实际存在的 `hw:${CardId},0`；
- 通过 `~/.config/environment.d/20-atlas-audio.conf` 让 PipeWire/WirePlumber 使用该 UCM；
- 重启用户态音频服务并将 `alsa_output.platform-avs_max98373.18.auto.HiFi__Speaker__sink` 设为默认输出。

修复后观察到 UCM 专用扬声器节点出现，`Left/Right Spk`、`DHT`、`BDE`、`VI Sense` 均为 `on`，播放测试流可以成功打开。详细说明和回滚方法见 [audio/README.md](audio/README.md)。

### 修复后当前状态

UCM 覆盖加载后，默认输出为 `alsa_output.platform-avs_max98373.18.auto.HiFi__Speaker__sink`，`PlaybackPCM` 为 `_ucm0001.hw:MAX98373,0`，功放相关开关均为 `on`。这次修复不安装未知固件、不修改 `/usr/share/alsa`；已将当前状态判定更新为“播放链路有效，拓扑警告待跟进”。

## 建议的后续验证

1. 先保存 `journalctl -b -k`，升级到下一版 Omarchy/Arch 内核后复测 i915 警告数量；不要在未备份和未确认的情况下添加 `i915` 内核参数。
2. 复核 `sof-firmware` 与当前内核 AVS 拓扑文件的匹配关系，重点确认 `hda-8086280b-tplg.bin` 是否应由发行版提供或由该机型使用其它拓扑替代。
3. 在真实桌面会话中播放扬声器测试音、插拔耳机、录制 DMIC 和打开摄像头应用；本报告的音频/摄像头结论主要依据设备枚举和 V4L2/ALSA 能力查询。
4. 如需判定触摸屏、蓝牙和 USB-C 的完整功能，应进行实际触摸事件、蓝牙配对/传输和 USB-C 外设热插拔测试。

## 复现用只读命令

```bash
lspci -nnk
cat /proc/asound/cards
arecord -l; aplay -l
wpctl status
v4l2-ctl --list-devices
iw dev
rfkill list
hyprctl monitors
journalctl -b -k --no-pager
```
