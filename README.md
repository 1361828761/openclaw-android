# 统一 AI 平台安装器

<img src="docs/images/openclaw_android.jpg" alt="统一 AI 平台">

![Android 7.0+](https://img.shields.io/badge/Android-7.0%2B-brightgreen)
![Termux](https://img.shields.io/badge/Termux-Required-orange)
![License MIT](https://img.shields.io/github/license/1361828761/openclaw-android)
![GitHub Stars](https://img.shields.io/github/stars/1361828761/openclaw-android)

在 Android (Termux) 上运行 OpenClaw 和 NEW API 的统一安装器。

## 功能特点

- **双平台支持**：可选择安装 OpenClaw、NEW API 或两者同时安装
- **无需完整 Linux**：无需 proot-distro，只安装必要的 glibc 动态链接器
- **存储开销小**：相比完整 Linux 发行版，节省约 1GB 存储空间
- **一键安装**：一条命令自动完成所有配置
- **可选工具**：支持安装多种 AI 工具（code-server、Claude Code、Gemini CLI 等）
- **中文界面**：安装过程全中文提示

## 支持的平台

### OpenClaw

AI Agent 平台，可以调用各种 AI 服务（OpenAI、Claude、Gemini 等）实现自动化任务。

**主要功能：**
- 多 AI 提供商集成（OpenAI、Claude、Gemini 等）
- 插件系统（Skill）扩展功能
- Web UI 控制面板
- 支持浏览器自动化

### NEW API

AI API 聚合工具，统一管理多种 AI API，提供灵活的 API 路由和分发功能。

**主要功能：**
- 多 API 密钥管理
- API 流量分发与负载均衡
- 支持多种 AI 模型
- 简洁的配置管理

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

> 首次运行时可能会要求你选择镜像源。随便选一个就行，地理位置较近的会更快。

### 3. 安装平台

运行以下命令开始安装：

```bash
curl -sL myopenclawhub.com/install | bash && source ~/.bashrc
```

安装过程中会有交互式提示让你选择：

1. **选择平台**：是否安装 OpenClaw？是否安装 NEW API？
2. **可选工具**：
   - tmux（终端复用器）
   - ttyd（网页终端）
   - dufs（文件服务器）
   - android-tools（ADB 工具）
   - Chromium（浏览器自动化，约 400MB）
   - code-server（浏览器 IDE）
   - OpenCode（AI 编程助手）
   - Claude Code CLI
   - Gemini CLI
   - Codex CLI

安装完成后会显示已选择的平台和管理命令。

## 访问服务

### 从手机访问

- **OpenClaw**：在 Termux 中运行 `manage-openclaw start`，然后在浏览器打开显示的地址
- **NEW API**：在 Termux 中运行 `manage-newapi start`，然后在浏览器打开 `http://localhost:3000`

### 从电脑访问

要让电脑也能访问手机上的服务，需要建立 SSH 隧道：

1. **在手机上启动服务**：
   ```bash
   manage-openclaw start
   # 或
   manage-newapi start
   ```

2. **在同一网络的电脑上**打开浏览器：
   - OpenClaw：`http://<手机IP>:8080`
   - NEW API：`http://<手机IP>:3000`

> 获取手机 IP：可以在 Termux 中运行 `ifconfig` 或 `ip addr` 查看

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

卸载过程中会提示是否保留 glibc 组件（如果两个平台都安装了，建议保留）。

## 可选工具

安装过程中可以选择以下工具：

| 工具 | 说明 |
|------|------|
| tmux | 终端复用器，保持后台任务运行 |
| ttyd | 网页终端，可以通过浏览器访问 |
| dufs | 文件服务器，方便传输文件 |
| android-tools | ADB 工具，用于与安卓设备通信 |
| Chromium | 浏览器自动化（约 400MB） |
| code-server | 浏览器 IDE，网页版 VS Code |
| OpenCode | AI 编程助手 |
| Claude Code CLI | Anthropic AI CLI |
| Gemini CLI | Google Gemini CLI |
| Codex CLI | OpenAI Codex CLI |

## 项目结构

```
.
├── install.sh              # 主安装脚本
├── uninstall.sh            # 卸载脚本
├── update-openclaw.sh      # 更新 OpenClaw
├── update-newapi.sh        # 更新 NEW API
├── manage-openclaw.sh      # OpenClaw 管理脚本
├── manage-newapi.sh        # NEW API 管理脚本
├── status-all.sh           # 查看所有平台状态
├── uninstall-openclaw.sh   # 单独卸载 OpenClaw
├── uninstall-newapi.sh     # 单独卸载 NEW API
├── platforms/
│   ├── openclaw/          # OpenClaw 平台文件
│   │   ├── install.sh
│   │   ├── start.sh
│   │   ├── stop.sh
│   │   ├── status.sh
│   │   ├── uninstall.sh
│   │   └── update.sh
│   └── newapi/            # NEW API 平台文件
│       ├── install.sh
│       ├── start.sh
│       ├── stop.sh
│       ├── status.sh
│       ├── uninstall.sh
│       └── update.sh
├── scripts/
│   ├── lib.sh             # 公共函数库
│   ├── install-glibc.sh   # 安装 glibc
│   ├── install-nodejs.sh  # 安装 Node.js
│   └── ...
└── docs/                   # 文档
```

## 数据存储位置

- **OpenClaw**：`~/.openclaw-android/`
- **NEW API**：`~/.newapi-termux/`

## 常见问题

### 安装失败怎么办？

1. 确保 Termux 是从 F-Droid 安装的（不是 Play Store）
2. 确保网络连接稳定
3. 尝试重启 Termux 后重试
4. 如果下载失败，脚本会自动尝试备用镜像

### 无法启动服务？

1. 检查端口是否被占用：`status-all`
2. 查看日志排查问题：`manage-openclaw logs` 或 `manage-newapi logs`
3. 尝试更换端口：`manage-newapi start 8080`

### 如何从电脑访问？

1. 确保手机和电��在同一 WiFi 网络下
2. 获取手机局域网 IP：`ifconfig` 或 `ip addr`
3. 在电脑浏览器打开 `http://<手机IP>:端口`

### 服务在后台运行吗？

默认情况下，服务运行在终端前台。要在后台运行：

1. 使用 tmux（需要安装）：
   ```bash
   tmux new -s openclaw
   manage-openclaw start
   # 按 Ctrl+B 然后按 D 退出 tmux
   ```

2. 重新进入 tmux：
   ```bash
   tmux attach -t openclaw
   ```

### 如何保持服务运行？

Android 可能会在屏幕关闭时杀死后台进程。建议：
- 关闭电池优化（设置 > 应用 > Termux > 电池优化）
- 开启"开发者选项"中的"保持唤醒"
- 详细设置请参考 [保持进程存活指南](docs/disable-phantom-process-killer.md)

## 开发者

- 原作者：AidanPark ([https://github.com/AidanPark/openclaw-android](https://github.com/AidanPark/openclaw-android))
- 修改者：1361828761

## License

MIT License