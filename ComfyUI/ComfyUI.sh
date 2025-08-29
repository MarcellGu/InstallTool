#!/bin/bash
# ComfyUI 安装脚本 by Marcell Gu

set -e

export COMFYUI_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

for f in $(ls $COMFYUI_ROOT/lib/**-* | sort -n -t- -k1); do
    source "$f" || exit 255
done

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