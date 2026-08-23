# 当前状态总览

最后整理：2026-08-23（Asia/Tokyo）

## 已验证并保留

- Intel 显示、Wi‑Fi、蓝牙、摄像头、触摸板、触摸屏接口、电池、背光和 eMMC 已被内核识别。
- Atlas 音频 UCM 覆盖已启用：内置扬声器使用 `HiFi__Speaker__sink`，PCM 修正为 `hw:0,0`，PipeWire 播放测试可以打开。
- Pixelbook Go 顶排 F1–F10 已恢复为 Chromebook 动作键；按用户习惯，F3 是 Omarchy 截图，F4 是 Omarchy 主菜单。
- Assistant 键通过 Atlas hwdb `d8 → leftmeta` 映射为 Win/Super。
- A 左侧 Search 键通过 hwdb `db → capslock`，再由 keyd 的 `overload(control, f24)` 实现：单独按是 `voxtype record toggle`，组合按是 Ctrl。
- 左下区域保持 `Ctrl → Assistant → Alt`；实体 Ctrl 和 Alt 没有重映射。
- 电源键没有加入 keyd/hwdb 映射，也没有执行睡眠、合盖、拔电、重启或关机测试。

## 本机配置位置

- 音频环境：`~/.config/environment.d/20-atlas-audio.conf`
- 音频 UCM 生成目录：`audio/atlas-ucm2/`（已忽略，不提交绝对路径链接）
- 键盘 keyd：`/etc/keyd/pixelbook-atlas.conf`
- 键盘 hwdb：`/etc/udev/hwdb.d/61-atlas-keyboard.hwdb`
- Hyprland 用户绑定：`~/.config/hypr/bindings.lua`

## 已知待跟进

- `i915` 日志仍有 `intel_cdclk_clock_changed` 警告，但当前内屏和 Hyprland 正常。
- `snd_soc_avs` 仍报告缺少 HDA topology 文件；I2S/扬声器、耳机、DMIC 和 HDMI 链路已经可以枚举，UCM 修复后播放链路可打开。
- 睡眠/唤醒、深度睡眠、合盖、电源拔插、蓝牙配对和 USB‑C 热插拔尚未做实际状态变化测试，详见 [POWER_TEST_PLAN.md](POWER_TEST_PLAN.md)。

## 重新安装

```bash
./scripts/install-security-hook.sh
./audio/setup-atlas-ucm.sh
./scripts/install-pixelbook-keyboard.sh
```

安装键盘配置需要 root 授权；脚本不会修改电源键映射。
