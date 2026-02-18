# MCP 多模态自动化工作区

[English](README.md)

## 概述

本项目围绕 **Model Context Protocol (MCP)** 构建了一套完整的多模态工程自动化框架。其核心思路是将"**外部现成 MCP 服务 / 插件**"与"**自研 MCP 工具服务器**"在同一工作区内协同运行：

- **外部层**：通过 `.vscode/mcp.json` 集中声明 Playwright、GitHub、Blender-MCP、FreeCAD-MCP、Godot-MCP、MATLAB 官方 MCP 等第三方 MCP 服务，各服务按 stdio 或 HTTP 方式接入，由 VS Code Copilot Agent 统一调度。
- **自研层**：`omni_mcp.py` 以单文件形式实现 48 个工具（15 个模块），覆盖从办公文档、图像处理、视频转码到 3D 建模、科学计算的完整能力栈。

两层协同后，LLM Agent 可在一次对话中完成"获取数据→生成报表→渲染 3D 场景→导出视频→部署游戏"等端到端工作流，所有调用均通过标准 MCP 协议完成，具备可复现性。

> ⭐ **测试报告入口**：[`mcp_test/FINAL_REPORT.md`](mcp_test/FINAL_REPORT.md)  
> 📋 **运行日志入口**：[`mcp_test/logs/run_log.md`](mcp_test/logs/run_log.md)

---

## 项目亮点

| 条目 | 说明 |
|------|------|
| **核心服务** | `omni_mcp.py` — 48 个 MCP 工具，单文件实现，stdio 模式运行 |
| **展示版本** | `omni_mcp_academic.py` — 行为一致的学术展示副本，附加注释与文档字符串 |
| **接入中枢** | `.vscode/mcp.json` — 7 项服务的统一注册（详见[插件接入指南](#33-外部-mcp-服务逐项配置)） |
| **测试闭环** | `mcp_test/` — 输入、输出、日志与报告，48 项工具 100% 通过 |
| **辅助脚本** | `render_formulas.py` + `replace_formulas.py` — 学术 PPT 公式渲染流水线 |

---

## 模块能力矩阵

| 模块 | 工具数 | 覆盖能力 |
|------|-------:|----------|
| PPTX | 3 | 新建（标题/内容/图片/样式）、读取幻灯片结构、编辑（文本/备注/布局） |
| DOCX | 3 | 新建（段落/表格/图片/列表）、读取、查找替换 |
| XLSX | 4 | 新建工作簿（多工作表）、读取、追加写入、嵌入图表 |
| PDF | 6 | 生成（支持中文字体级联注册）、读取、合并、拆分、水印、转 PNG |
| IMAGE | 5 | 创建画布、元信息读取、处理流水线（resize/crop/filter/text 等 pipeline）、格式转换、多图合成（grid/horizontal/vertical） |
| BLENDER | 3 | Python 脚本执行、场景结构查询、EEVEE/Cycles 渲染输出 |
| SVG | 1 | 基于文本描述生成矢量图 |
| CHART | 2 | 单图绘制 + 多子图仪表板（支持 bar/line/scatter/pie/area） |
| MATLAB | 2 | 表达式求值、.m 脚本执行（含 GBK 编码兼容） |
| FFMPEG | 6 | 媒体探测、转码、时间段剪辑、帧截图、GIF 生成、自定义参数执行 |
| GIMP | 2 | Script-Fu 批处理（gimp-console 无头模式）、Python-Fu 脚本 |
| INKSCAPE | 2 | Inkscape Actions 命令执行、SVG→PNG/PDF 格式转换 |
| FREECAD | 2 | FreeCADCmd 脚本执行、参数化零件建模与 STEP 导出 |
| GODOT | 3 | GDScript 项目执行、场景运行（含超时容错）、导出为可执行文件 |
| UTILS | 10 | 文件读/写/复制/移动/删除/列表/打开、Shell 命令执行、Python 执行、系统信息收集 |

---

## 系统架构

```
┌─────────────────────────────────────────────────────┐
│                VS Code Copilot Agent                │
│             (LLM ↔ Tool Dispatcher)                 │
└──────────┬──────────────────────────┬───────────────┘
           │ stdio                    │ stdio / HTTP
           ▼                          ▼
┌─────────────────────┐  ┌──────────────────────────┐
│    omni-mcp         │  │   External MCP Services   │
│  (omni_mcp.py)      │  │  ┌─────────────────────┐  │
│                     │  │  │ playwright (npx)    │  │
│  48 tools across    │  │  ├─────────────────────┤  │
│  15 modules         │  │  │ github (HTTP API)   │  │
│                     │  │  ├─────────────────────┤  │
│  Office / Image /   │  │  │ blender-mcp (uvx)   │  │
│  Media / CAD /      │  │  ├─────────────────────┤  │
│  Chart / Utils      │  │  │ freecad-mcp (uvx)   │  │
│                     │  │  ├─────────────────────┤  │
│                     │  │  │ godot-mcp (npx)     │  │
│                     │  │  ├─────────────────────┤  │
│                     │  │  │ matlab (Go binary)  │  │
│                     │  │  └─────────────────────┘  │
└─────────────────────┘  └──────────────────────────┘
           │                          │
           ▼                          ▼
┌─────────────────────────────────────────────────────┐
│              Local Executables & Runtimes            │
│  Blender · MATLAB · FFmpeg · GIMP · Inkscape ·      │
│  FreeCAD · Godot · Python · Node.js                 │
└─────────────────────────────────────────────────────┘
```

**调度流程**：Agent 接收用户意图 → 选择工具 → 通过 MCP stdio/HTTP 协议调用对应服务 → 服务内部调用本地可执行文件 → 返回 JSON 结果或生成产物文件。

---

## 详细使用步骤

### 3.1 环境准备

#### Python 依赖

```bash
pip install mcp python-pptx python-docx openpyxl pymupdf Pillow matplotlib numpy reportlab
```

#### 外部软件

下表列出经过完整测试的版本组合。不要求全部安装——未安装的模块在调用时会返回明确的缺失提示。

| 软件 | 测试版本 | 用途 | 安装建议 |
|------|----------|------|----------|
| **Blender** | 4.x | 3D 场景脚本、渲染 | [blender.org](https://www.blender.org/download/) |
| **MATLAB** | R2024b+ | 科学计算、信号处理、绘图 | MathWorks 官方安装 |
| **FFmpeg** | 7.x | 视频转码、剪辑、GIF | `winget install FFmpeg` 或手动下载 |
| **GIMP** | 3.0.8 | 图像批处理 | [gimp.org](https://www.gimp.org/downloads/)，需含 gimp-console |
| **Inkscape** | 1.4.2 | SVG 编辑与格式转换 | [inkscape.org](https://inkscape.org/release/) |
| **FreeCAD** | 1.0+ | 参数化 CAD 建模 | [freecad.org](https://www.freecad.org/downloads.php) |
| **Godot** | 4.6.1 | 游戏项目执行与导出 | [godotengine.org](https://godotengine.org/download/) |
| **Node.js** | 18+ | 运行 npx 启动的外部 MCP | [nodejs.org](https://nodejs.org/) |
| **uv** | 0.4+ | 运行 uvx 启动的外部 MCP | `pip install uv` 或 `winget install astral-sh.uv` |

#### 包管理器前置检查

外部 MCP 服务依赖 `npx`（Node.js）或 `uvx`（uv）拉起，请先确认：

```powershell
# 检查 Node.js / npm / npx
node -v          # 预期: v18.x 或更高
npx --version    # 预期: 10.x 或更高

# 检查 uv / uvx
uv --version     # 预期: 0.4.x 或更高
uvx --version    # 预期: 同上（uvx 是 uv 的子命令）
```

若 `npx` 不可用，需先安装 Node.js；若 `uvx` 不可用，需先安装 `uv`。

### 3.2 omni-mcp 服务端路径配置

打开 `omni_mcp.py`（或 `omni_mcp_academic.py`），顶部 `CONFIG` 区域声明了各外部可执行文件的路径常量。服务器启动时会通过 `_find()` 函数在常见安装位置自动搜索，但建议手动核实：

```python
# ========== CONFIG ==========
BLENDER  = r"D:\Blender\blender.exe"
MATLAB   = _find(r"C:\Program Files\MATLAB\*\bin\matlab.exe",
                 r"D:\MATLAB\*\bin\matlab.exe") or "matlab"
FFMPEG   = _find(r"C:\Users\*\...\*ffmpeg*\ffmpeg*.exe") or "ffmpeg"
GIMP     = _find(r"D:\GIMP*\bin\gimp-console-*.exe", ...) or "gimp"
INKSCAPE = _find(r"D:\Inkscape*\bin\inkscape.exe", ...) or "inkscape"
FREECAD  = _find(r"D:\FreeCAD*\bin\FreeCADCmd.exe", ...) or "FreeCADCmd"
GODOT    = _find(r"D:\Godot*\Godot*.exe", ...) or "godot"
```

> **注意**：GIMP 必须指向 `gimp-console-*.exe` 而非 `gimp-*.exe`（GUI 版本），否则批处理模式会因 GUI 初始化超时。详见测试报告中 D-02 缺陷记录。

### 3.3 外部 MCP 服务逐项配置

`mcp.json` 中注册了 7 项服务。以下逐项说明各服务的作用、启动方式、前置条件及验证方法。

#### 3.3.1 Playwright（浏览器自动化）

```jsonc
"playwright": {
  "command": "cmd",
  "args": ["/c", "npx", "@playwright/mcp@latest"],
  "type": "stdio"
}
```

- **作用**：提供无头浏览器操控能力（页面导航、元素点击、截图、表单填写等），用于网页数据采集或 UI 自动化测试。
- **前置条件**：Node.js 18+ 已安装，首次运行时 npx 会自动下载 `@playwright/mcp` 包。
- **浏览器安装**：首次使用前需安装浏览器内核：
  ```powershell
  npx playwright install chromium
  ```
- **验证方式**：在 Copilot Chat 中调用 `browser_navigate` 工具访问任意 URL，确认返回页面快照。

#### 3.3.2 GitHub（代码仓库与 Issue 管理）

```jsonc
"github": {
  "type": "http",
  "url": "https://api.githubcopilot.com/mcp/",
  "headers": {
    "Authorization": "Bearer ${env:GITHUB_TOKEN}"
  }
}
```

- **作用**：提供 GitHub 仓库操作能力（Issue 读写、PR 创建与审阅、文件内容获取、分支管理等）。
- **前置条件**：需要有效的 GitHub Token。如果在 VS Code 中已登录 GitHub Copilot，`${env:GITHUB_TOKEN}` 会由 VS Code 自动注入，无需手动设置环境变量。
- **验证方式**：调用 `get_me` 工具查看当前认证用户身份。

#### 3.3.3 Blender-MCP（3D 场景实时控制）

```jsonc
"blender-mcp": {
  "command": "cmd",
  "args": ["/c", "uvx", "blender-mcp"],
  "type": "stdio"
}
```

- **作用**：通过 WebSocket 连接已运行的 Blender 实例，实现场景查询、Python 脚本注入执行、视口截图等实时操控，适合交互式 3D 建模场景。
- **与 omni-mcp 的区别**：omni-mcp 的 `blender_exec` 是以 CLI 无头方式启动 Blender 执行脚本后退出，适合批量渲染；blender-mcp 是连接已打开的 Blender GUI 进行实时操作。
- **前置条件**：
  1. `uv` 已安装（`uvx` 为其子命令）。
  2. Blender 中需安装 **blender-mcp addon**：
     - 下载 addon 文件：`pip download blender-mcp --no-deps -d .` 后解压，或从 [GitHub 仓库](https://github.com/ahujasid/blender-mcp) 获取 `addon.py`。
     - 在 Blender 中：Edit → Preferences → Add-ons → Install from Disk → 选择 `addon.py`。
     - 勾选启用后，3D Viewport 侧边栏会出现 "BlenderMCP" 面板，点击 **Start MCP Server** 启动 WebSocket 端口（默认 9876）。
  3. Blender 保持运行状态。
- **验证方式**：调用 `get_scene_info` 工具，应返回当前 Blender 场景的对象列表、材质等信息。

#### 3.3.4 FreeCAD-MCP（参数化 CAD 实时控制）

```jsonc
"freecad-mcp": {
  "command": "cmd",
  "args": ["/c", "uvx", "freecad-mcp"],
  "type": "stdio"
}
```

- **作用**：通过 RPC 连接已运行的 FreeCAD 实例，实现文档创建、零件建模、视图截取等实时 CAD 操控。
- **与 omni-mcp 的区别**：omni-mcp 的 `freecad_exec` 通过 FreeCADCmd 命令行执行脚本；freecad-mcp 通过 RPC 实时连接 FreeCAD GUI，支持交互式建模与即时预览。
- **前置条件**：
  1. `uv` 已安装。
  2. FreeCAD 中需安装 **freecad-mcp 宏**：
     - 在 FreeCAD 中：Macro → Macros → 创建新宏 `freecad_mcp_server.py`。
     - 在宏内粘贴 [freecad-mcp 仓库](https://github.com/soetji/freecad-mcp) 发布的服务端脚本。
     - 运行该宏后 FreeCAD 会在 `localhost:9875` 启动 RPC 服务。
  3. FreeCAD 保持运行状态，宏处于激活状态。
- **验证方式**：调用 `list_documents` 工具或 `create_document` 工具，确认返回正常文档列表。

#### 3.3.5 Godot-MCP（游戏引擎项目操作）

```jsonc
"godot-mcp": {
  "command": "cmd",
  "args": ["/c", "npx", "-y", "@satelliteoflove/godot-mcp"],
  "type": "stdio"
}
```

- **作用**：提供 Godot 项目的场景管理、节点操作、GDScript 执行等能力，用于游戏开发辅助。
- **前置条件**：
  1. Node.js 18+ 已安装。
  2. Godot 4.x 已安装（需要版本 ≥ 4.0 支持 GDScript 2.0 语法）。
  3. 首次运行时 npx 会自动安装 `@satelliteoflove/godot-mcp`（`-y` 参数跳过确认）。
- **注意事项**：导出为可执行文件时需要提前在 Godot Editor 中下载对应平台的导出模板（Editor → Manage Export Templates）。
- **验证方式**：在已有 Godot 项目目录下调用 `get_scene_info` 或 `list_nodes` 类工具。

#### 3.3.6 MATLAB 官方 MCP（MathWorks 出品）

```jsonc
"matlab": {
  "command": "D:\\MCP\\matlab-mcp-core-server.exe",
  "args": [
    "--initial-working-folder=D:\\MCP\\mcp_test\\outputs",
    "--matlab-display-mode=nodesktop",
    "--disable-telemetry=true"
  ],
  "type": "stdio"
}
```

- **项目地址**：[matlab/matlab-mcp-core-server](https://github.com/matlab/matlab-mcp-core-server)（170★，Go 编写，MathWorks 官方维护）
- **作用**：启动/退出 MATLAB、执行代码、运行 `.m` 文件、运行测试、静态代码分析（checkcode）、检测已安装 Toolbox。
- **与 omni-mcp 的区别**：omni-mcp 的 `matlab_eval` / `matlab_exec` 通过命令行调用 `matlab -batch`，每次调用冷启动一个 MATLAB 进程；MATLAB 官方 MCP 保持一个**持久化 MATLAB 会话**，支持变量持久化和 `nodesktop` 无头模式，执行效率显著更高。
- **前置条件**：
  1. MATLAB R2020b+ 已安装且 `matlab` 已加入系统 PATH。
  2. 下载 [v0.5.0 Windows 二进制](https://github.com/matlab/matlab-mcp-core-server/releases/download/v0.5.0/matlab-mcp-core-server-win64.exe) 放置于 `D:\MCP\matlab-mcp-core-server.exe`。
- **验证方式**：调用 `detect_matlab_toolboxes` 或 `evaluate_matlab_code`（代码 `disp('hello')`），应返回正常输出。

#### 3.3.7 omni-mcp（自研工具服务器）

```jsonc
"omni-mcp": {
  "command": "python",
  "args": ["d:\\omni_mcp.py"],
  "type": "stdio"
}
```

- **作用**：本项目的核心，提供全部 48 个自研工具（详见上方能力矩阵）。
- **前置条件**：Python 3.10+ 及所有 pip 依赖已安装。
- **切换版本**：如需使用学术展示版，将 args 改为 `["d:\\MCP\\omni_mcp_academic.py"]`。
- **验证方式**：调用 `system_info` 工具，应返回操作系统、内存、Python 版本及各外部工具的可用性检测结果。

### 3.4 完整 mcp.json 参考

```jsonc
{
  "servers": {
    "playwright": {
      "command": "cmd",
      "args": ["/c", "npx", "@playwright/mcp@latest"],
      "type": "stdio"
    },
    "github": {
      "type": "http",
      "url": "https://api.githubcopilot.com/mcp/",
      "headers": {
        "Authorization": "Bearer ${env:GITHUB_TOKEN}"
      }
    },
    "blender-mcp": {
      "command": "cmd",
      "args": ["/c", "uvx", "blender-mcp"],
      "type": "stdio"
    },
    "freecad-mcp": {
      "command": "cmd",
      "args": ["/c", "uvx", "freecad-mcp"],
      "type": "stdio"
    },
    "godot-mcp": {
      "command": "cmd",
      "args": ["/c", "npx", "-y", "@satelliteoflove/godot-mcp"],
      "type": "stdio"
    },
    "omni-mcp": {
      "command": "python",
      "args": ["d:\\omni_mcp.py"],
      "type": "stdio"
    },
    "matlab": {
      "command": "D:\\MCP\\matlab-mcp-core-server.exe",
      "args": [
        "--initial-working-folder=D:\\MCP\\mcp_test\\outputs",
        "--matlab-display-mode=nodesktop",
        "--disable-telemetry=true"
      ],
      "type": "stdio"
    }
  },
  "inputs": []
}
```

### 3.5 冒烟测试（建议按模块分步执行）

配置完成后建议按以下顺序做冒烟测试，逐层验证依赖链：

| 步骤 | 调用工具 | 验证目标 |
|------|----------|----------|
| 1 | `system_info` | omni-mcp 启动正常，外部工具路径检测 |
| 2 | `file_write` → `file_read` | 基础文件 I/O，工作目录可写 |
| 3 | `xlsx_create` → `xlsx_read` | Office 文档生成链路 |
| 4 | `ffmpeg_info` | 多媒体工具链可用性 |
| 5 | `img_create` → `img_info` | 图像处理链路 |
| 6 | `blender_render` 或 `get_scene_info` (blender-mcp) | 3D 渲染链路 |
| 7 | `matlab_eval` (omni-mcp) | 科学计算链路（命令行模式） |
| 8 | `evaluate_matlab_code` (matlab 官方 MCP) | MATLAB 持久会话模式 |
| 9 | `gimp_exec` | GIMP 批处理链路 |

冒烟测试通过后，可参考 `mcp_test/` 下的输入数据和运行日志进行更完整的功能回归。

### 3.6 参考现有测试资产

| 资源 | 路径 | 说明 |
|------|------|------|
| 测试报告 | `mcp_test/FINAL_REPORT.md` | 48 项工具的完整测试记录，含 11 个缺陷的根因分析 |
| 运行日志 | `mcp_test/logs/run_log.md` | 按时间序的逐工具调用日志 |
| 测试输入 | `mcp_test/inputs/` | JSON 数据、压缩参数等预置输入 |
| 测试产物 | `mcp_test/outputs/` | 全部生成文件（PPTX/DOCX/PDF/PNG/STEP/EXE 等） |

---

## 已知局限性与技术债务

### 4.1 工具深度不均衡

各模块已覆盖面较广，但部分工具仍以"常用路径优先"为原则实现。对于高级格式控制（如 PPTX 母版定制、PDF 表单字段操作）或行业特定流程，当前实现不够完整。

### 4.2 参数范式不统一

部分接口（如 `xlsx_create`）要求 `writes: [{"range":"A1:G18","values":[...]}]` 这种 JSON 嵌套结构，另一些工具使用扁平化标量参数。这种不一致性增加了调用方的学习成本和参数拼接出错概率。在测试过程中曾多次因参数格式问题触发静默失败。

### 4.3 输入校验与错误语义粗粒度

目前多数工具以通用异常回传为主，缺少统一的错误码体系、字段级校验和可诊断性强的错误上下文。例如 `pdf_create` 传入错误的 content 格式时不会报错，而是生成空白 PDF。

### 4.4 外部依赖强、环境敏感

Blender、GIMP、FreeCAD、Godot 等工具受版本、插件装载状态、操作系统语言环境影响明显。同一参数配置在不同机器上可能表现不一致——例如 MATLAB 在中文 Windows 下输出 GBK 编码，GIMP 3.0 更改了批处理启动方式。测试中记录的 11 个缺陷中有 7 个与此类环境耦合相关。

### 4.5 单文件架构的可维护性压力

`omni_mcp.py` 约 1400 行，将 48 个工具、配置常量、辅助函数集中于同一文件。这在原型阶段便于快速迭代，但随着工具数量增长，代码导航、多人协作和单元测试隔离的成本会持续上升。

### 4.6 跨平台适配不足

当前路径常量、进程创建标志（`CREATE_NO_WINDOW`）、编码处理等逻辑明显基于 Windows 假设。Linux / macOS 的开箱兼容性需要额外适配层。

---

## 发展路线建议

| 优先级 | 方向 | 具体措施 |
|--------|------|----------|
| P0 | **模块化重构** | 按领域拆分为 `office/`、`media/`、`cad/`、`utils/` 子包，各模块独立注册 |
| P0 | **统一参数 Schema** | 引入 Pydantic 做强类型校验与自动文档生成，消除 JSON 字符串传参歧义 |
| P1 | **标准化错误体系** | 定义统一错误码（工具不可用 / 参数非法 / 运行时异常）+ 结构化诊断上下文 |
| P1 | **长任务异步化** | 对渲染、转码、导出任务引入任务队列与进度查询 API |
| P2 | **自动化测试** | 建立分层测试：单元测试 + 工具冒烟 + 端到端回归 |
| P2 | **插件化扩展** | 从硬编码工具注册演进为外部包按规范接入的插件机制 |
| P3 | **跨平台适配** | 抽象路径解析与进程管理层，测试 Linux / macOS 兼容性 |
| P3 | **文档工程化** | 提供按模块的最小可运行示例、参数模板与故障排查手册 |

---

## 仓库结构

```text
MCP/
├── .vscode/
│   └── mcp.json                  # MCP 服务注册中枢
├── omni_mcp.py                   # 自研 MCP 服务器（48 工具，主运行文件，不含在仓库中）
├── omni_mcp_academic.py          # 学术展示版（行为一致，含详细注释）
├── render_formulas.py            # LaTeX 公式渲染脚本
├── replace_formulas.py           # PPT 公式替换脚本
├── MCP_Academic_Ultimate.pptx    # 学术演示 PPT
├── assets/
│   ├── formulas/                 # 渲染后的公式图片
│   ├── charts/                   # 图表素材
│   └── diagrams/                 # 架构图
├── mcp_test/
│   ├── FINAL_REPORT.md           # 测试总报告（48 项工具 + 11 缺陷分析）
│   ├── logs/
│   │   └── run_log.md            # 逐工具执行日志
│   ├── inputs/                   # 测试输入数据
│   └── outputs/                  # 测试产物（PPTX/DOCX/PDF/PNG/STEP/EXE 等）
│       └── godot_game_pro/       # Godot Roguelite 游戏完整项目
└── CyberMoto/                    # 附属项目
```

---

## 许可与声明

本项目为个人研究性质的工程实践，旨在验证 MCP 协议在多模态工具编排中的可行性。代码和文档仅供学术交流参考。
