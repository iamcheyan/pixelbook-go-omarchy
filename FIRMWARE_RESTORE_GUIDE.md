# Pixelbook Go（Atlas）恢复原厂固件与 ChromeOS

本指南记录从 Linux/UEFI 固件返回原生 ChromeOS 的安全路径。它只描述操作，
不会自动刷写固件。Pixelbook Go 的 ChromeOS board name 是 `ATLAS`。

## 先判断当前固件类型

Pixelbook Go 常见有两种 Linux 启动方式：

| 当前状态 | 含义 | 是否需要恢复 BIOS |
|---|---|---|
| `UEFI Full ROM` | MrChromebox UEFI 完全替换了 ChromeOS 固件 | **需要**先恢复 Stock Firmware |
| `Stock Firmware + RW_LEGACY` | 底层仍是原厂固件，只增加 Linux 启动 payload | 通常不需要，直接做 ChromeOS Recovery |

可以先做只读检查：

```bash
sudo dmidecode -s bios-vendor
sudo dmidecode -s bios-version
sudo dmidecode -s product-name
```

也可以从 Linux 运行 MrChromebox Firmware Utility Script，让它自动识别当前固件类型。
不要为了判断类型运行 `flashrom` 写入命令。

## 准备工作

1. 备份 Linux 中需要保留的全部数据。恢复 ChromeOS 通常会重新分区并清空系统盘。
2. 找到之前保存的原始固件备份；它是最可靠的恢复来源，并保留设备原有标识。
3. 如果没有备份，使用针对 Pixelbook Go/`ATLAS` 的 ChromeOS Recovery USB。
4. 接通可靠的 USB-C 电源，避免在刷写过程中断电。
5. 不要使用其他 Chromebook 型号的固件，也不要在固件刷写过程中重启或关机。

## UEFI Full ROM：先恢复 Stock Firmware

从当前 Linux 系统运行官方工具。命令应由普通用户执行，工具内部会在需要时使用
`sudo`；不要先进入 root shell：

```bash
cd
curl -LOf https://mrchromebox.tech/firmware-util.sh
sudo bash firmware-util.sh
```

在菜单中选择：

```text
Restore Stock Firmware
```

然后按提示选择：

1. `Restore from USB backup`：选择以前保存的本机固件备份（优先）；或
2. `Restore from ChromeOS Recovery USB`：从匹配 `ATLAS` 的 Recovery USB 提取原厂固件。

如果工具提示需要关闭硬件写保护，按照 MrChromebox 针对本机型号的说明操作。不要
自行短接、拆焊或执行未经确认的 flashrom 参数。固件刷写失败时，**不要重启**，
先在工具中恢复备份并保存日志。

恢复成功后：

1. 使用工具提供的关机选项完全关机；
2. 插入 ChromeOS Recovery USB；
3. 从 Recovery USB 启动并重新安装 ChromeOS；
4. 首次启动后按需要退出 Developer Mode，恢复原厂启动行为。

MrChromebox 官方说明：Full ROM 会替换原厂固件，恢复 ChromeOS 前必须先恢复
Stock Firmware；该操作有变砖风险，并且受设备 AUE/EOL 状态限制。

## Stock Firmware + RW_LEGACY：通常不刷 BIOS

如果当前只是 RW_LEGACY，底层仍是原厂 ChromeOS 固件。此时通常可以直接：

1. 制作匹配 `ATLAS` 的 ChromeOS Recovery USB；
2. 从 Recovery USB 启动；
3. 执行 ChromeOS Recovery；
4. 恢复 Developer Mode/GBB 设置（如果安装程序或工具提示）。

不要选择 `Restore Stock Firmware`，除非工具明确检测到你运行的是 UEFI Full ROM。

## 验证与回滚

刷写完成后，确认设备能够：

- 显示 ChromeOS Recovery/启动界面；
- 读取 Pixelbook Go 的内部键盘和触摸板；
- 从内部存储正常启动 ChromeOS；
- 正确显示设备型号和网络硬件。

如果刷写过程中出现错误，不要重启或断电。保留工具日志，使用原始固件备份执行
恢复；无法确认固件状态时，先停止操作并寻求 chrultrabook/MrChromebox 支持。

## 官方参考

- [MrChromebox：恢复 Stock ChromeOS Firmware](https://docs.mrchromebox.tech/docs/reverting/flashing-stock.html)
- [MrChromebox：Firmware Utility Script](https://docs.mrchromebox.tech/docs/fwscript)
- [MrChromebox：恢复 ChromeOS 总览](https://docs.mrchromebox.tech/docs/reverting/)
- [MrChromebox：固件写保护](https://docs.mrchromebox.tech/docs/firmware/wp/disabling.html)
