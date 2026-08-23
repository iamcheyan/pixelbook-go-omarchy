# Pixelbook Go 顶排按键

Pixelbook Go（Atlas）的 ChromeOS 顶排动作键顺序为：

`上一页 → 刷新 → 全屏 → Overview → 亮度− → 亮度＋ → 播放/暂停 → 静音 → 音量− → 音量＋`

Google 官方将它们标为 F1–F10 的对应动作键；最右侧另有独立电源键。本机 Linux 内核将 AT 键盘原始顶排暴露为 F1–F10，因此使用 keyd 将浏览器、亮度和媒体动作恢复为 Linux 输入事件。按用户习惯，F3 由 Hyprland 绑定为截图，F4 绑定为 Omarchy 主菜单。

## 已安装位置

- 仓库模板：`keyboard/pixelbook-atlas.conf`
- 仓库 hwdb：`keyboard/61-atlas-keyboard.hwdb`
- Hyprland 片段：`keyboard/hyprland-bindings.lua`
- 本机配置：`/etc/keyd/pixelbook-atlas.conf`
- 本机 hwdb：`/etc/udev/hwdb.d/61-atlas-keyboard.hwdb`
- Hyprland 用户绑定：`~/.config/hypr/bindings.lua`

重新安装模板：

```bash
./scripts/install-pixelbook-keyboard.sh
```

安装后可用 `keyd check` 检查语法，`keyd monitor` 观察按键事件；hwdb 负责 Assistant/Search 这种普通 keyd 看不到的扫描码。不会修改电源键映射。

参考：<https://support.google.com/pixelbook/answer/7504061>

另外，本机按用户要求将 A 左侧的 Search/Launcher 键设置为：单独按下通过 F24 触发 `voxtype record toggle`；当前先保持已验证的直接 F24 路径，组合 Ctrl 行为待单键语音恢复后再单独处理。左下区域保持 `Ctrl → Assistant → Alt`。

Assistant 的底层扫描码方案参考 Fedora 项目的 Chromebook hwdb，以及 Atlas 专用资料：`d8 → leftmeta`、`db → capslock`。这类键在 hwdb 之前不会出现在普通 XKB/keyd 监听中。
