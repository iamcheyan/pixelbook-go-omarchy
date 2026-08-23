# Pixelbook Go Omarchy

Google Pixelbook Go（Atlas）运行 Omarchy/Arch Linux 的硬件驱动与本机修复记录。

## 当前状态

主要硬件驱动已经能被内核识别并工作：Intel 显卡、Wi‑Fi、蓝牙、摄像头、键盘、触摸板、触摸屏接口、电池、背光和 eMMC。

音频曾经只能枚举 ALSA 设备但内置扬声器无声。参考 Fedora 项目 `pixelbook-fedora` 的历史提交 `960767b`，本项目现在使用 Atlas 专用的用户级 ALSA UCM 覆盖：

- 为实际声卡长名称 `AVS I2S MAX98373` 增加匹配入口；
- 将扬声器 PCM 修正为本机实际的 `hw:0,0`；
- 启用 MAX98373 的 DHT/BDE/VI Sense 和扬声器开关序列；
- 让 PipeWire/WirePlumber 使用 `HiFi__Speaker__sink` 作为默认输出。

详细说明见 [audio/README.md](audio/README.md)。

## 文档

- [驱动测试报告](DRIVER_TEST_REPORT.md)：硬件、驱动绑定、功能测试和异常日志。
- [Fedora 方案兼容性分析](PIXELBOOK_FEDORA_COMPATIBILITY.md)：哪些内容可移植到 Atlas/Omarchy，哪些 Fedora/X11 方案不应直接使用。
- [音频 UCM 修复说明](audio/README.md)：修复原理、验证和回滚方法。
- [Pixelbook Go 顶排按键映射](keyboard/pixelbook-atlas.conf)：将 F1-F10 恢复为 Chromebook 动作键。
- [键盘映射说明](keyboard/README.md)：官方顺序、安装和验证方法。

## 参考项目

Fedora 参考项目已移到仓库外，避免把上游代码混入本项目：

`../pixelbook-fedora-reference`

来源：<https://github.com/jasonmontleon/pixelbook-fedora>

## 注意

本项目只记录和维护当前 Atlas/Omarchy 的用户级配置，不执行 Fedora Ansible playbook，不刷写固件，也不覆盖 `/usr/share/omarchy/` 或发行版 ALSA 文件。

## 公开仓库安全

仓库包含提交前安全 hook，会检查私钥、GitHub/AWS 令牌、硬编码密码、空白错误和超大文件。首次克隆后运行：

```bash
./scripts/install-security-hook.sh
```

`.gitignore` 已排除环境变量文件、凭据、恢复镜像、固件 dump、日志和生成的 UCM 覆盖目录。公开提交前仍应人工检查 `git diff --cached`。
