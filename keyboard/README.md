# Pixelbook Go 顶排按键

Pixelbook Go（Atlas）的 ChromeOS 顶排动作键顺序为：

`上一页 → 刷新 → 全屏 → Overview → 亮度− → 亮度＋ → 播放/暂停 → 静音 → 音量− → 音量＋`

Google 官方将它们标为 F1–F10 的对应动作键；最右侧另有独立电源键。本机 Linux 内核将 AT 键盘原始顶排暴露为 F1–F10，因此使用 keyd 将浏览器、亮度和媒体动作恢复为 Linux 输入事件。F3（全屏）和 F4（Omarchy Overview）由 Hyprland 绑定处理。

## 已安装位置

- 仓库模板：`keyboard/pixelbook-atlas.conf`
- 本机配置：`/etc/keyd/pixelbook-atlas.conf`
- Hyprland 用户绑定：`~/.config/hypr/bindings.lua`

重新安装模板：

```bash
./scripts/install-pixelbook-keyboard.sh
```

安装后可用 `keyd check` 检查语法，`keyd monitor` 观察按键事件；不会修改电源键映射。

参考：<https://support.google.com/pixelbook/answer/7504061>

另外，本机按用户要求将 Tab 下方的 Search/Launcher 键恢复为 Caps Lock，并将左 Alt 左侧的左 Ctrl 改为 Win/Super。
