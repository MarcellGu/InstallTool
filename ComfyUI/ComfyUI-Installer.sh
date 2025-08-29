#!/bin/bash
# ComfyUI 一键安装脚本 by Marcell Gu

set -e

# ================ 全局配置 ================
declare -g HTTP_PROXY='http://127.0.0.1:33210'
declare -g HTTPS_PROXY='http://127.0.0.1:33210'
declare -g COMFYUI_INSTALL_DIR="/opt/ComfyUI"
declare -g COMFYUI_PORT=8188
declare -g COMFYUI_REPO="https://github.com/comfyanonymous/ComfyUI.git"

# ================ 服务配置 ================
declare -g COMFYUI_SERVICE
COMFYUI_SERVICE=$(cat <<EOL
[Unit]
Description=ComfyUI
After=network.target

[Service]
Type=simple
User=root
Group=root
WorkingDirectory=${COMFYUI_INSTALL_DIR}
ExecStart=${COMFYUI_INSTALL_DIR}/.venv/bin/python ${COMFYUI_INSTALL_DIR}/main.py

[Install]
WantedBy=multi-user.target
EOL
)

# ================ Nginx配置 ================
declare -g NGINX_CONF
NGINX_CONF=$(cat <<EOF
server {
  listen 555 ssl;
  server_name chqt.tpddns.cn;

  ssl_certificate /etc/nginx/certs/ComfyUI/cert.crt;
  ssl_certificate_key /etc/nginx/certs/ComfyUI/cert.key;

  ssl_protocols TLSv1.2 TLSv1.3;
  ssl_prefer_server_ciphers on;
  ssl_session_cache shared:SSL:10m;
  ssl_session_timeout 10m;

  location / {
    proxy_pass http://localhost:${COMFYUI_PORT};
    proxy_http_version 1.1;
    proxy_set_header Upgrade \$http_upgrade;
    proxy_set_header Connection "upgrade";
    proxy_set_header Host \$host;
  }
}
EOF
)

# ================ 工具函数 ================
console() {
  local color="$1" level="$2" message="$3"
  printf "\e[${color}m%s\e[0m %s %s\n" "$level" "$(date +'%T')" "$message"
}

info()    { console "34" "[INFO]   " "$1"; }
success() { console "32" "[SUCCESS]" "$1"; }
warning() { console "33" "[WARNING]" "$1"; }
error()   { console "31" "[ERROR]  " "$1"; exit 1; }

check_sudo() {
  if ! sudo -n true 2>/dev/null; then
    error "需要sudo权限，请使用sudo运行或配置免密"
  fi
  success "权限验证通过"
}

confirm() {
  local prompt="$1"
  read -rp "$prompt [Y/N] " response
  [[ "$response" =~ ^[Yy]$ ]]
}

proxy() {
  export http_proxy="${HTTP_PROXY}"
  export https_proxy="${HTTPS_PROXY}"
}

unproxy() {
  unset http_proxy https_proxy all_proxy
}

# ================ Python环境配置 ================
setup_python() {
  proxy
  if command -v pyenv > /dev/null 2>&1; then
    success "pyenv 已安装"
  else
    export PYENV_ROOT="$HOME/.pyenv"
    export PATH="$HOME/.pyenv/bin:$PATH"
    eval "$(pyenv init -)"
    if command -v pyenv > /dev/null 2>&1; then
      success "pyenv 已安装"
    else
      warning "pyenv 未安装"
      if confirm "是否安装 pyenv?"; then
        curl https://pyenv.run | bash || error "pyenv 安装失败"
        success "pyenv 已经安装"
        export PYENV_ROOT="$HOME/.pyenv"
        export PATH="$HOME/.pyenv/bin:$PATH"
        eval "$(pyenv init -)"
      fi
    fi
  fi
  pyenv shell 3.12 || pyenv install 3.12 && pyenv rehash && pyenv shell 3.12
  unproxy
  python -m venv --copies "${COMFYUI_INSTALL_DIR}/.venv"
}

# ================ 安装功能 ================
dependencies_install() {
  info "安装系统依赖..."
  sudo apt update -y
  sudo apt upgrade -y
  sudo apt install git curl build-essential gcc g++ make libreadline-dev libssl-dev \
    libbz2-dev zlib1g-dev libsqlite3-dev liblzma-dev libffi-dev ffmpeg -y
}

clone_repo() {
  info "克隆仓库..."
  proxy
  sudo rm -rf "${COMFYUI_INSTALL_DIR}/source"
  mkdir -p "${COMFYUI_INSTALL_DIR}/source"
  cd "${COMFYUI_INSTALL_DIR}/source"
  git clone ${COMFYUI_REPO}
  unproxy
  sudo cp -r "${COMFYUI_INSTALL_DIR}/source/ComfyUI/." "${COMFYUI_INSTALL_DIR}"
}

comfyui_install() {
  cd "${COMFYUI_INSTALL_DIR}" || exit
  source .venv/bin/activate
  python -m pip install --upgrade pip \
    --extra-index-url https://mirrors.pku.edu.cn/pypi/web/simple \
    --index-url https://mirrors.tuna.tsinghua.edu.cn/pypi/web/simple
  pip config set global.index-url https://mirrors.tuna.tsinghua.edu.cn/pypi/web/simple
  pip config set global.extra-index-url https://mirrors.pku.edu.cn/pypi/web/simple
  pip install -r requirements.txt \
    --extra-index-url https://mirrors.pku.edu.cn/pypi/web/simple \
    --index-url https://mirrors.tuna.tsinghua.edu.cn/pypi/web/simple
  deactivate
}

# ================ 服务设置 ================
setup_service() {
  info "配置系统服务..."
  echo "${COMFYUI_SERVICE}" | sudo tee /etc/systemd/system/comfyui.service > /dev/null
  sudo systemctl daemon-reload
  sudo systemctl enable comfyui
  sudo systemctl start comfyui
  success "ComfyUI 服务已启动"
}

setup_nginx() {
  info "配置 Nginx..."
  sudo mkdir -p /etc/nginx/certs/ComfyUI
  echo "${NGINX_CONF}" | sudo tee /etc/nginx/sites-available/comfyui > /dev/null
  sudo ln -sf /etc/nginx/sites-available/comfyui /etc/nginx/sites-enabled/
  sudo nginx -t && sudo systemctl reload nginx
  success "Nginx 配置完成"
}

uninstall() {
  if [[ -d "${COMFYUI_INSTALL_DIR}" ]]; then
    info "删除旧版本..."
    sudo systemctl stop comfyui || true
    sudo systemctl disable comfyui || true
    sudo rm -f /etc/systemd/system/comfyui.service
    sudo systemctl daemon-reload
    sudo rm -rf "${COMFYUI_INSTALL_DIR}"
  fi
}

install_core() {
  dependencies_install
  clone_repo
  setup_python
  comfyui_install
}

# ================ 主函数 ================
main() {
  info "================开始安装================"
  info "程序安装目录: ${COMFYUI_INSTALL_DIR}"
  check_sudo
  uninstall
  install_core
  setup_nginx
  setup_service
  success "================安装完成================"
}

main "$@"
