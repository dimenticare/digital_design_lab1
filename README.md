# FPGA Tetris Game

## 项目简介

本项目使用 Verilog 在 FPGA 上实现俄罗斯方块游戏。系统以 32×16 位图记录游戏区域，实现方块生成、自动下落、左右移动、旋转、碰撞检测、满行消除、分数统计和游戏结束判断。

游戏画面通过 HDMI 输出，当前分数通过四位七段数码管显示；系统同时提供按键控制、LED 状态提示和 UART 位图数据输出。工程基于 Pango Design Suite 2022.1 创建，并保留原生工程结构。

## 主要功能

- 生成多种俄罗斯方块，并支持移动、旋转和加速下落
- 检测游戏区域边界以及方块之间的碰撞
- 完成方块固化、满行消除、分数累计和结束判断
- 支持暂停/继续以及普通、加速两种自动下落速度
- 通过 HDMI、七段数码管、LED 和 UART 输出运行状态
- 提供游戏核心、位图和数码管模块的功能仿真文件

## 按键控制

| 输入 | 功能 |
| --- | --- |
| `keys[0]` | 右移 |
| `keys[1]` | 左移 |
| `keys[2]` | 加速下落 |
| `keys[3]` | 旋转 |
| `keys[4]` | 预留 |
| `keys[5]` | 切换下落速度 |
| `keys[6]` | 暂停/继续 |

## 模块说明

| 文件 | 主要功能 |
| --- | --- |
| `Top.v` | 集成游戏核心、按键、HDMI、UART、LED、数码管和 PLL |
| `Wrapper.v` | 管理游戏状态、下落节拍、速度模式和分数累计 |
| `BlockController.v` | 生成方块并处理下落、移动和旋转操作 |
| `Bitmap.v` | 存储游戏位图并实现碰撞检测、固化、消行和结束判断 |
| `KeyDebounce.v` | 对七路按键输入进行消抖和事件检测 |
| `HdmiWrapper.v` | 读取位图数据并生成 HDMI 游戏画面 |
| `UartWrapper.v` | 将游戏位图按行编码并通过 UART 发送 |
| `SegWrapper.v` | 驱动四位七段数码管显示游戏分数 |

## 工程目录

```text
PDS_Final_Terris/
├── PDS_Final_Terris.pds    # Pango工程文件
├── source/                 # RTL、Testbench和约束文件
│   ├── Top.v               # 综合顶层
│   ├── Wrapper.v
│   ├── Bitmap.v
│   ├── BlockController.v
│   ├── tb_Wrapper.v        # 系统级仿真顶层
│   ├── tb_bitmap.v
│   ├── tb_segwrapper.v
│   └── Top.fdc             # 时钟与引脚约束
├── ipcore/                 # PLL IP配置和生成文件
├── device_map/
│   └── Top.pcf             # 器件映射文件
└── README.md
```

仓库不包含编译、综合、布局布线、时序分析、仿真波形和日志等自动生成目录。

## 开发环境

- Verilog HDL
- Pango Design Suite 2022.1
- Pango PGL22G-6 FPGA（MBG324封装）
- ModelSim
- 50 MHz系统时钟

## 打开工程

1. 下载或克隆仓库。
2. 使用 Pango Design Suite 2022.1 打开 `PDS_Final_Terris.pds`。
3. 以 `source/Top.v` 作为综合顶层，并加载 `source/Top.fdc`。
4. 依次运行编译、综合、器件映射、布局布线和 Bitstream 生成。

## 功能仿真

- `tb_Wrapper.v`：验证游戏核心控制及状态输出
- `tb_bitmap.v`：验证位图更新、碰撞检测和消行逻辑
- `tb_segwrapper.v`：验证七段数码管扫描显示

