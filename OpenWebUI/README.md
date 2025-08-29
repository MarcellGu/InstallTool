# OpenWebUI-Local-Installer

一个轻量级的命令行工具，用于自动化安装和配置 Open WebUI。本工具提供完整的依赖检查、环境配置和本地服务器启动功能。

## ⚠️ 注意事项

- **仅支持 Ubuntu 系统**
- **其他设备尚未经过验证**
- **运行前请备份重要数据**

## 功能特性

- 🚀 自动化安装部署
- 🔄 系统依赖自动管理
- ⚙️ Node.js 和 Python 环境配置
- 🌐 内置代理设置支持
- 🛠 服务进程管理
- 📡 Nginx 配置支持
- 🔒 SSL 证书管理

## 系统要求

- Ubuntu 操作系统
- 管理员权限
- 稳定的网络连接

## 安装使用

### 基础安装

```bash
./OpenWebUI.sh install
```

### 更新系统

```bash
./OpenWebUI.sh update
```

### 移除安装

```bash
./OpenWebUI.sh remove all    # 移除所有内容
./OpenWebUI.sh remove nginx  # 仅移除 nginx 配置
./OpenWebUI.sh remove service # 仅移除服务
```

## 配置说明

默认配置：

- 安装目录：`/opt/OpenWebUI`
- 服务端口：3000
- Node.js 版本：22
- 支持代理配置

## 目录结构

```
.
├── OpenWebUI.sh      # 主程序入口
├── lib/             # 核心功能模块
│   ├── 00-config    # 全局配置
│   ├── 01-message   # 消息处理
│   ├── ...
│   └── args         # 参数解析
```

## 常见问题

1. 如果安装过程中遇到网络问题，请检查代理设置
2. 确保系统已安装基本的编译工具（build-essential）
3. 安装过程需要以root用户运行 **⚠️ sudo执行是不行的**
