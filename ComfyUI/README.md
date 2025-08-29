# ComfyUI-Local-Installer

一个为 Ubuntu 系统设计的 ComfyUI 一键安装工具，提供了简单的安装过程和完整的环境配置。

## ✨ 特性

- 🚀 一键式安装和配置
- 🔒 自动配置 HTTPS 安全访问
- 🛠️ 自动安装系统依赖
- 🐍 Python 环境自动配置（使用 pyenv）
- 🔄 反向代理设置（Nginx）
- 🤖 系统服务配置
- 🌐 内置代理支持
- 🔄 一键更新功能

## 🖥️ 系统要求

- **操作系统**: Ubuntu（或基于 Ubuntu 的发行版）
- **Python**: 自动安装 Python 3.12
- **存储**: 至少 10GB 可用空间
- **内存**: 建议 8GB 以上

## 📦 安装说明

### 快速开始

1. 克隆仓库：
```bash
git clone https://github.com/MarcellGu/ComfyUI-Local-Installer.git
cd ComfyUI-Local-Installer
```

2. 设置执行权限：
```bash
chmod +x ComfyUI-Installer.sh
```

3. 运行安装脚本：
```bash
sudo ./ComfyUI-Installer.sh
```

### 配置说明

安装脚本支持以下配置项（可在脚本开头修改）：

- `COMFYUI_INSTALL_DIR`: 安装目录（默认：/opt/ComfyUI）
- `COMFYUI_PORT`: 服务端口（默认：8188）
- `HTTP_PROXY`: HTTP 代理设置
- `HTTPS_PROXY`: HTTPS 代理设置
- `ALL_PROXY`: SOCKS 代理设置

## 🚀 使用说明

### 服务管理

- 启动服务：`sudo systemctl start comfyui`
- 停止服务：`sudo systemctl stop comfyui`
- 重启服务：`sudo systemctl restart comfyui`
- 查看状态：`sudo systemctl status comfyui`
- 查看日志：`sudo journalctl -u comfyui`

### 访问方式

- **HTTP 访问**: `http://localhost:8188`
- **HTTPS 访问**: `https://your-domain:555`

### 更新 ComfyUI

运行更新脚本：
```bash
sudo ./ComfyUI.sh update
```

## 🔧 目录结构

```
ComfyUI-Local-Installer/
├── ComfyUI-Installer.sh   # 主安装脚本
├── ComfyUI.sh            # 管理脚本
└── lib/                  # 功能模块目录
    ├── 00-config        # 全局配置
    ├── 01-message       # 消息输出
    ├── 02-interactive   # 交互功能
    ├── 03-clean        # 清理功能
    ├── 04-proxy        # 代理设置
    ├── 05-update       # 更新功能
    ├── 11-setup_python # Python环境配置
    ├── 20-install      # 核心安装功能
    ├── 30-service      # 服务配置
    ├── 40-certification # 证书配置
    └── 41-nginx        # Nginx配置
```

## 🤝 贡献

欢迎提交 Issue 和 Pull Request 来帮助改进项目。

## 📝 许可证

本项目采用 MIT 许可证。

## ⚠️ 注意事项

1. 安装过程需要 sudo 权限
2. 请确保系统防火墙允许相关端口访问
3. 如需使用 HTTPS，请确保已准备好相应的 SSL 证书
4. 首次安装可能需要较长时间，请耐心等待

## 🆘 常见问题

### 代理设置
如果需要使用代理，可以在脚本开头修改相关配置：
```bash
HTTP_PROXY='http://127.0.0.1:33210'
HTTPS_PROXY='http://127.0.0.1:33210'
ALL_PROXY='socks5://127.0.0.1:33211'
```

### 安装失败
1. 检查网络连接
2. 确认系统版本兼容性
3. 检查磁盘空间是否充足
4. 查看日志获取详细错误信息
