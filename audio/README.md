# Atlas 音频 UCM 修复

此目录是针对当前 Google Atlas/Pixelbook Go 的用户级 UCM 覆盖。修复依据 `pixelbook-fedora` 仓库历史提交 `960767b`（“AVS works, is default, no recovery firmware needed”）。

## 为什么需要覆盖

系统的 `alsa-ucm-conf` 已包含 `Google-Atlas-1.0.conf`，但当前声卡长名称是 `AVS I2S MAX98373`，UCM 默认查找不到对应文件，因此只生成 `stereo-fallback`，不会执行 Atlas 扬声器启用序列。当前 ALSA PCM 也是 `hw:0,0`，而发行版配置的播放节点为 `hw:${CardId},1`。

`setup-atlas-ucm.sh` 会生成 `atlas-ucm2/` 覆盖目录：通过一个同名匹配文件把 Atlas 配置接入当前声卡，并把扬声器 PCM 修正为 `hw:${CardId},0`。其余 UCM 文件使用系统 `alsa-ucm-conf` 的只读链接，不复制或修改系统文件。生成目录已加入 `.gitignore`，不会提交本机绝对路径链接。

## 已启用的用户设置

`~/.config/environment.d/20-atlas-audio.conf` 设置：

```text
ALSA_CONFIG_UCM2=/home/tetsuya/development/pixelbook-go-omarchy/audio/atlas-ucm2
```

在新克隆的工作区先运行：

```bash
./audio/setup-atlas-ucm.sh
```

当前用户会话已重启 PipeWire/WirePlumber，并把 `HiFi__Speaker__sink` 设为默认输出。重启登录会话后，若默认输出没有自动恢复，可运行：

```bash
wpctl status
wpctl set-default <HiFi__Speaker__sink 的 ID>
```

## 验证

```bash
wpctl status -n
pactl get-default-sink
amixer -c 0 sget 'Left Spk'
amixer -c 0 sget 'Right Spk'
speaker-test -D default -t sine -f 440 -c 2 -l 1
```

## 回滚

删除 `~/.config/environment.d/20-atlas-audio.conf` 后重新登录即可停止使用覆盖；再把默认输出切回需要的设备。此修复没有替换 `/usr/share/alsa` 中的发行版文件，也没有安装未知来源的二进制固件。
