# 统一 AI 平台安装器

<img src="docs/images/openclaw_android.jpg" alt="统一 AI 平台">

![Android 7.0+](https://img.shields.io/badge/Android-7.0%2B-brightgreen)
![Termux](https://img.shields.io/badge/Termux-Required-orange)
![License MIT](https://img.shields.io/github/license/1361828761/openclaw-android)

在 Android (Termux) 上运行 OpenClaw 和 NEW API 的统一安装器。

## 功能特点

- **双平台支持**：可选择安装 OpenClaw、NEW API 或两者同时安装
- **无需完整 Linux**：无需 proot-distro，只安装必要的 glibc 动态链接器
- **存储开销小**：相比完整 Linux 发行版，节省约 1GB 存储空间
- **一键安装**：一条命令自动完成所有配置
- **可选工具**：支持安装多种 AI 工具（code-server、Claude Code、Gemini CLI 等）

## 支持的平台

### OpenClaw

AI Agent 平台，可以调用各种 AI 服务（OpenAI、Claude、Gemini 等）实现自动化任务。

### NEW API

AI API 聚合工具，统一管理多种 AI API，提供灵活的 API 路由和分发功能。

## 系统要求

- Android 7.0 或更高版本（推荐 Android 10+）
- 约 1GB 可用存储空间
- Wi-Fi 或移动数据连接

## 快速开始

### 1. 安装 Termux

> **重要提示**：Play Store 版本的 Termux 已停止维护，无法正常使用。必须从 F-Droid 安装。

1. 用手机浏览器打开 [f-droid.org](https://f-droid.org)
2. 搜索 `Termux`，然后点击 **Download APK** 下载并安装

### 2. 初始设置

打开 Termux 应用，粘贴以下命令：

```bash
pkg update -y && pkg install -y curl
```

### 3. 安装平台

运行以下命令开始安装：

```bash
curl -sL myopenclawhub.com/install | bash && source ~/.bashrc
```

安装过程中会有交互式提示让你选择：

1. **选择平台**：是否安装 OpenClaw？是否安装 NEW API？
2. **可选工具**：tmux、ttyd、dufs、android-tools、Chromium、code-server、OpenCode、Claude Code CLI、Gemini CLI、Codex CLI

安装完成后会显示已选择的平台和管理命令。

## 管理命令

### OpenClaw 管理

```bash
manage-openclaw start     # 启动 OpenClaw
manage-openclaw stop      # 停止 OpenClaw
manage-openclaw restart   # 重启 OpenClaw
manage-openclaw status    # 查看状态
manage-openclaw logs      # 查看日志
```

### NEW API 管理

```bash
manage-newapi start [端口]    # 启动 NEW API (默认端口: 3000)
manage-newapi stop            # 停止 NEW API
manage-newapi restart [端口]  # 重启 NEW API
manage-newapi status          # 查看状态
manage-newapi logs            # 查看日志
```

### 查看所有平台状态

```bash
status-all
```

## 更新

### 单独更新 OpenClaw

```bash
update-openclaw.sh
```

### 单独更新 NEW API

```bash
update-newapi.sh
```

## 卸载

### 单独卸载 OpenClaw

```bash
uninstall-openclaw.sh
```

### 单独卸载 NEW API

```bash
uninstall-newapi.sh
```

### 卸载所有

```bash
uninstall.sh
```

## 可选工具

安装过程中可以选择以下工具：

| 工具 | 说明 |
|------|------|
| tmux | 终端复用器 |
| ttyd | 网页终端 |
| dufs | 文件服务器 |
| android-tools | ADB 工具 |
| Chromium | 浏览器自动化（~400MB） |
| code-server | 浏览器 IDE |
| OpenCode | AI 编程助手 |
| Claude Code CLI | Anthropic AI CLI |
| Gemini CLI | Google Gemini CLI |
| Codex CLI | OpenAI Codex CLI |

## 项目结构

```
.
├── install.sh              # 主安装脚本
├── uninstall.sh            # 卸载脚本
├── update-*.sh             # 更新脚本
├── manage-*.sh             # 管理脚本
├── status-all.sh           # 查看所有状态
├── platforms/
│   ├── openclaw/          # OpenClaw 平台
│   └── newapi/            # NEW API 平台
├── scripts/
│   ├── lib.sh             # 公共函数库
│   ├── install-*.sh       # 各种安装脚本
│   └── ...
└── docs/                   # 文档
```

## 常见问题

### 安装失败怎么办？

1. 确保 Termux 是从 F-Droid 安装的（不是 Play Store）
2. 确保网络连接稳定
3. 尝试重启 Termux 后重试

### 无法启动服务？

1. 检查端口是否被占用：`status-all`
2. 查看日志排查问题：`manage-openclaw logs` 或 `manage-newapi logs`

### 如何查看运行状态？

```bash
status-all
```

## 开发者

- 原作者：AidanPark (https://github.com/AidanPark/openclaw-android)
- 修改者：1361828761

## License

MIT License