#!/bin/bash
# 主入口脚本

set -e

export OPENWEBUI_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

for f in $(ls $OPENWEBUI_ROOT/lib/**-* | sort -n -t- -k1); do
    source "$f" || exit 255
done

main() {
  # 获取解析结果
  local args_json
  args_json=$("${OPENWEBUI_ROOT}/lib/args" "$@")
  declare -A ARGS=${args_json#*=}

  # 解析参数结果
  local mode="${ARGS[mode]}"
  local action="${ARGS[action]}"

  # 执行模式判断
  case "$mode" in
    install)
      # confirm "请确认你要将OpenWebUI安装到这台服务器上"
      handle_install
      ;;
    update)
      # confirm "请确认你要更新OpenWebUI"
      handle_update
      ;;
    remove)
      stop_services
      case "$action" in
        all)
          # confirm "请确认你要清除所有安装"
          check_sudo
          purge_all
          success "操作完成"
          ;;
        nginx)
          # confirm "请确认你要清除nginx配置文件"
          check_sudo
          remove_nginx
          start_services
          success "操作完成"
          ;;
        service)
          # confirm "请确认你要清除服务文件"
          check_sudo
          remove_services
          success "操作完成"
          ;;
        data)
          check_sudo
          reset_openwebui
          reset_pipelines
          reset_openwebui_data
          reset_pipelines_data
          start_services
          success "操作完成"
          ;;
        pipelines)
          check_sudo
          reset_pipelines
          start_services
          success "操作完成"
          ;;
        *)
          start_services
          show_help
          error "命令无效"
          ;;
      esac
      ;;
    fix)
      case "$action" in
        nginx)
          # confirm "请确认你要重置nginx配置文件"
          check_sudo
          remove_nginx
          setup_nginx
          restart_services
          success "操作完成"
          ;;
        service)
          # confirm "请确认你要重置服务文件"
          check_sudo
          remove_services
          setup_services
          restart_services
          success "操作完成"
          ;;
        *)
          show_help
          error "命令无效"
          ;;
      esac
      ;;
    help)
      show_help
      exit
      ;;
    *)
      show_help
      error "请提供有效参数"
      ;;
  esac
}

show_help() {
  cat << EOF
OpenWebUI 管理工具

用法:
  OpenWebUI [全局选项] <命令>

全局选项:
  -i, --install   执行全新安装
  -u, --update    执行更新安装
  -r, --remove    执行完全卸载
  -f, --fix       进行单项修复 (可用命令:nginx|service)
  -h, --help      显示帮助信息
EOF
}


handle_install() {
  info "================开始安装================"
  check_sudo
  uninstall
  install_core
  setup_services
  setup_nginx
  start_services
  success "================操作完成================"
}

handle_update() {
info "================开始更新================"
  check_sudo
  remove_source
  extract_openwebui
  extract_pipelines
  uninstall
  install_core  
  restore_openwebui  
  restore_pipelines
  setup_services
  setup_nginx
  start_services
  success "================操作完成================"
}

main "$@"