#!/bin/bash

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 日志函数
log_info() {
    echo -e "${GREEN}✅ $1${NC}"
}

log_warn() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

log_step() {
    echo -e "${BLUE}🔧 $1${NC}"
}

echo -e "${BLUE}"
echo "🛑 停止数据目录编目系统"
echo "========================"
echo -e "${NC}"

# 停止后端服务（Python）
log_step "停止后端服务..."
backend_pids=$(pgrep -f "python.*main.py")
if [ ! -z "$backend_pids" ]; then
    echo "发现后端进程: $backend_pids"
    for pid in $backend_pids; do
        log_step "停止后端进程 (PID: $pid)"
        kill $pid
        sleep 2
        if kill -0 $pid 2>/dev/null; then
            log_warn "强制停止后端进程 (PID: $pid)"
            kill -9 $pid
        fi
    done
    log_info "后端服务已停止"
else
    log_warn "未找到运行中的后端服务"
fi

# 停止前端服务（pnpm）
log_step "停止前端服务..."
frontend_pids=$(pgrep -f "pnpm.*start")
if [ ! -z "$frontend_pids" ]; then
    echo "发现前端进程: $frontend_pids"
    for pid in $frontend_pids; do
        log_step "停止前端进程 (PID: $pid)"
        kill $pid
        sleep 2
        if kill -0 $pid 2>/dev/null; then
            log_warn "强制停止前端进程 (PID: $pid)"
            kill -9 $pid
        fi
    done
    log_info "前端服务已停止"
else
    log_warn "未找到运行中的前端服务"
fi

# 停止Node.js进程（React开发服务器）
log_step "清理Node.js进程..."
node_pids=$(pgrep -f "react-scripts.*start")
if [ ! -z "$node_pids" ]; then
    echo "发现React进程: $node_pids"
    for pid in $node_pids; do
        log_step "停止React进程 (PID: $pid)"
        kill $pid
        sleep 1
        if kill -0 $pid 2>/dev/null; then
            kill -9 $pid
        fi
    done
    log_info "Node.js进程已清理"
fi

# 清理可能的端口占用
log_step "检查端口占用..."

# 检查8000端口（后端）
backend_port=$(lsof -ti:8000)
if [ ! -z "$backend_port" ]; then
    log_step "清理8000端口占用 (PID: $backend_port)"
    kill $backend_port 2>/dev/null
fi

# 检查3000端口（前端）
frontend_port=$(lsof -ti:3000)
if [ ! -z "$frontend_port" ]; then
    log_step "清理3000端口占用 (PID: $frontend_port)"
    kill $frontend_port 2>/dev/null
fi

# 清理日志文件锁定
log_step "清理日志文件..."
if [ -f "backend.log" ]; then
    > backend.log
fi
if [ -f "frontend.log" ]; then
    > frontend.log
fi

echo ""
log_info "所有服务已停止！"
echo -e "${BLUE}========================${NC}"
echo "如需重新启动，请运行: ./start.sh"
echo "" 