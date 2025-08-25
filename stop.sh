#!/bin/bash

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m'

# 日志函数
log_info() { echo -e "${GREEN}✅ $1${NC}"; }
log_warn() { echo -e "${YELLOW}⚠️  $1${NC}"; }
log_step() { echo -e "${BLUE}🔧 $1${NC}"; }
log_success() { echo -e "${PURPLE}🎉 $1${NC}"; }

# 强制停止进程
force_kill() {
    local name=$1
    local pattern=$2
    local pids=$(pgrep -f "$pattern" 2>/dev/null)
    
    if [ -n "$pids" ]; then
        log_step "停止 $name 服务..."
        echo $pids | xargs kill -TERM 2>/dev/null
        sleep 2
        
        # 检查是否还有残留进程
        local remaining=$(pgrep -f "$pattern" 2>/dev/null)
        if [ -n "$remaining" ]; then
            log_warn "强制停止 $name 服务..."
            echo $remaining | xargs kill -KILL 2>/dev/null
        fi
        
        log_info "$name 服务已停止"
        return 0
    else
        log_warn "未发现运行中的 $name 服务"
        return 1
    fi
}

# 清理端口占用
cleanup_ports() {
    local ports=("8000" "3000")
    local any_killed=false
    
    for port in "${ports[@]}"; do
        local pids=$(lsof -ti:$port 2>/dev/null)
        if [ -n "$pids" ]; then
            log_step "清理端口 $port 占用..."
            echo $pids | xargs kill -KILL 2>/dev/null
            any_killed=true
        fi
    done
    
    if [ "$any_killed" = true ]; then
        log_info "端口清理完成"
    fi
}

# 清理资源
cleanup_resources() {
    # 清理日志文件
    for log_file in backend.log frontend.log; do
        if [ -f "$log_file" ]; then
            > "$log_file"
        fi
    done
    
    # 清理临时文件
    rm -f backend/.deps_installed 2>/dev/null
}

# 检查服务状态
check_services() {
    local running=false
    
    if curl -s http://localhost:8000/api/health >/dev/null 2>&1; then
        echo "🟢 后端服务正在运行"
        running=true
    fi
    
    if curl -s http://localhost:3000 >/dev/null 2>&1; then
        echo "🟢 前端服务正在运行"
        running=true
    fi
    
    if lsof -ti:8000 >/dev/null 2>&1; then
        echo "🟡 端口8000被占用"
        running=true
    fi
    
    if lsof -ti:3000 >/dev/null 2>&1; then
        echo "🟡 端口3000被占用"
        running=true
    fi
    
    if [ "$running" = false ]; then
        echo "🟢 没有发现运行中的服务"
    fi
    
    if [ "$running" = true ]; then
        return 1
    else
        return 0
    fi
}

# 主程序
main() {
    clear
    echo -e "${BLUE}"
    echo "🛑 数据目录编目系统 - 一键停止"
    echo "=================================="
    echo -e "${NC}"
    
    echo "📋 检查当前服务状态："
    if ! check_services; then
        log_success "系统已经停止，无需操作"
        exit 0
    fi
    
    echo ""
    echo "⏳ 正在停止服务..."
    echo ""
    
    # 停止应用服务
    local stopped=false
    force_kill "后端" "python.*main.py" && stopped=true
    force_kill "前端" "pnpm.*start" && stopped=true
    force_kill "React" "react-scripts" && stopped=true
    force_kill "Node" "node.*webpack" && stopped=true
    
    # 清理端口占用
    cleanup_ports
    
    # 清理资源
    log_step "清理系统资源..."
    cleanup_resources
    
    # 最终检查
    echo ""
    log_step "验证服务状态..."
    sleep 2
    
    if ! check_services; then
        echo ""
        log_success "所有服务已成功停止！"
        echo "=================================="
        echo -e "${GREEN}✨ 系统已完全停止${NC}"
        echo -e "${BLUE}🚀 重新启动请运行: ${NC}./start.sh"
    else
        echo ""
        log_warn "部分服务可能仍在运行，请手动检查"
        echo "你可以运行以下命令进行强制清理："
        echo "  sudo lsof -ti:8000,3000 | xargs kill -9"
        exit 1
    fi
    
    echo "=================================="
}

# 运行主程序
main "$@" 