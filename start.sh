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
log_error() { echo -e "${RED}❌ $1${NC}"; }
log_step() { echo -e "${BLUE}🔧 $1${NC}"; }
log_success() { echo -e "${PURPLE}🎉 $1${NC}"; }

# 清理函数
cleanup() {
    echo ""
    log_warn "正在停止服务..."
    pkill -f "python.*main.py" 2>/dev/null
    pkill -f "pnpm.*start" 2>/dev/null
    pkill -f "react-scripts" 2>/dev/null
    lsof -ti:8000 | xargs kill -9 2>/dev/null
    lsof -ti:3000 | xargs kill -9 2>/dev/null
    log_info "服务已停止"
    exit 0
}

# 信号处理
trap cleanup SIGINT SIGTERM

# 检查是否已有服务运行
check_running_services() {
    if lsof -ti:8000 >/dev/null 2>&1 || lsof -ti:3000 >/dev/null 2>&1; then
        log_warn "检测到服务已在运行，正在停止..."
        ./stop.sh
        sleep 3
    fi
}

# 快速环境检查
check_environment() {
    local missing=()
    command -v python3 >/dev/null || missing+=("Python3")
    command -v node >/dev/null || missing+=("Node.js")
    
    if [ ${#missing[@]} -ne 0 ]; then
        log_error "缺少依赖: ${missing[*]}"
        log_error "请先安装缺少的依赖后重试"
        exit 1
    fi
    
    if ! command -v pnpm >/dev/null; then
        log_step "安装pnpm..."
        npm install -g pnpm >/dev/null 2>&1 || {
            log_error "pnpm安装失败"
            exit 1
        }
    fi
}

# 快速依赖安装
setup_dependencies() {
    # 后端依赖
    cd backend
    if [ ! -d "venv" ]; then
        log_step "创建Python虚拟环境..."
        python3 -m venv venv >/dev/null 2>&1 || {
            log_error "虚拟环境创建失败"
            exit 1
        }
    fi
    
    source venv/bin/activate
    if [ ! -f ".deps_installed" ] || [ "requirements.txt" -nt ".deps_installed" ]; then
        log_step "安装后端依赖..."
        pip install -r requirements.txt -q >/dev/null 2>&1 && touch .deps_installed || {
            log_error "后端依赖安装失败"
            exit 1
        }
    fi
    
    # 前端依赖
    cd ../frontend
    if [ ! -d "node_modules" ] || [ "package.json" -nt "node_modules" ]; then
        log_step "安装前端依赖..."
        pnpm install --silent >/dev/null 2>&1 || {
            log_error "前端依赖安装失败"
            exit 1
        }
    fi
    cd ..
}

# 检查并配置API Key
setup_api_key() {
    if [ ! -f "backend/.env" ]; then
        log_warn "OpenAI API Key未配置"
        echo -n "请输入OpenAI API Key (回车跳过): "
        read -r api_key
        if [ -n "$api_key" ]; then
            echo "OPENAI_API_KEY=$api_key" > backend/.env
            log_info "API Key配置完成"
        else
            log_warn "跳过API Key配置，AI功能将不可用"
        fi
    fi
}

# 启动服务
start_services() {
    # 准备必要目录和文件
    mkdir -p vector_db data
    if [ ! -f "data/data_catalog.csv" ]; then
        echo "table_hash,table_name_en,resource_name,resource_summary,resource_format,domain_category,organization_name,irs_system_name,layer,is_processed,source_tables,processing_logic,fields_json,create_time,update_time" > data/data_catalog.csv
    fi
    
    # 启动后端
    log_step "启动后端服务..."
    cd backend
    source venv/bin/activate
    nohup python main.py >../backend.log 2>&1 &
    BACKEND_PID=$!
    cd ..
    
    # 等待后端启动
    for i in {1..30}; do
        if curl -s http://localhost:8000/api/health >/dev/null 2>&1; then
            log_info "后端服务启动成功 (http://localhost:8000)"
            break
        fi
        [ $i -eq 30 ] && {
            log_error "后端服务启动失败"
            cat backend.log | tail -n 5
            cleanup
            exit 1
        }
        sleep 1
    done
    
    # 启动前端
    log_step "启动前端服务..."
    cd frontend
    nohup pnpm start >../frontend.log 2>&1 &
    FRONTEND_PID=$!
    cd ..
    
    # 等待前端启动
    for i in {1..30}; do
        if curl -s http://localhost:3000 >/dev/null 2>&1; then
            log_info "前端服务启动成功 (http://localhost:3000)"
            break
        fi
        [ $i -eq 30 ] && {
            log_error "前端服务启动失败"
            cat frontend.log | tail -n 5
            cleanup
            exit 1
        }
        sleep 2
    done
}

# 主程序
main() {
    clear
    echo -e "${BLUE}"
    echo "🚀 数据目录编目系统 - 一键启动"
    echo "=================================="
    echo -e "${NC}"
    
    check_running_services
    log_step "检查环境..."
    check_environment
    log_step "准备依赖..."
    setup_dependencies
    setup_api_key
    
    echo ""
    start_services
    
    echo ""
    log_success "系统启动成功！"
    echo "=================================="
    echo -e "${GREEN}🌐 前端访问: ${NC}http://localhost:3000"
    echo -e "${GREEN}🔧 后端API: ${NC}http://localhost:8000"
    echo -e "${GREEN}📖 API文档: ${NC}http://localhost:8000/docs"
    echo -e "${GREEN}📋 案件分解: ${NC}点击左侧'案件分解'菜单"
    echo ""
    echo -e "${YELLOW}💡 按 Ctrl+C 停止服务 | 或运行 ./stop.sh${NC}"
    echo "=================================="
    
    # 简化的日志显示
    echo ""
    log_step "系统运行中，实时状态监控..."
    
    # 监控服务状态
    while true; do
        if ! curl -s http://localhost:8000/api/health >/dev/null 2>&1; then
            log_error "后端服务异常停止"
            break
        fi
        if ! curl -s http://localhost:3000 >/dev/null 2>&1; then
            log_error "前端服务异常停止"
            break
        fi
        sleep 10
    done
    
    cleanup
}

# 运行主程序
main "$@" 