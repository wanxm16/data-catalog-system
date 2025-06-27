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

log_error() {
    echo -e "${RED}❌ $1${NC}"
}

log_step() {
    echo -e "${BLUE}🔧 $1${NC}"
}

# 清理函数
cleanup() {
    echo ""
    log_warn "正在停止服务..."
    
    # 停止后端服务
    if [ ! -z "$BACKEND_PID" ] && kill -0 $BACKEND_PID 2>/dev/null; then
        log_step "停止后端服务 (PID: $BACKEND_PID)"
        kill $BACKEND_PID
        wait $BACKEND_PID 2>/dev/null
    fi
    
    # 停止前端服务
    if [ ! -z "$FRONTEND_PID" ] && kill -0 $FRONTEND_PID 2>/dev/null; then
        log_step "停止前端服务 (PID: $FRONTEND_PID)"
        kill $FRONTEND_PID
        wait $FRONTEND_PID 2>/dev/null
    fi
    
    # 清理后台进程
    pkill -f "python.*main.py" 2>/dev/null
    pkill -f "pnpm.*start" 2>/dev/null
    
    log_info "所有服务已停止"
    exit 0
}

# 设置信号处理
trap cleanup SIGINT SIGTERM

echo -e "${BLUE}"
echo "🚀 数据目录编目系统启动脚本"
echo "=================================="
echo -e "${NC}"

# 检查环境依赖
log_step "检查环境依赖..."

# 检查Python
if ! command -v python3 &> /dev/null; then
    log_error "Python3 未安装，请先安装Python3"
    exit 1
fi

# 检查Node.js
if ! command -v node &> /dev/null; then
    log_error "Node.js 未安装，请先安装Node.js"
    exit 1
fi

# 检查pnpm
if ! command -v pnpm &> /dev/null; then
    log_warn "pnpm 未安装，正在安装..."
    npm install -g pnpm
    if [ $? -ne 0 ]; then
        log_error "pnpm 安装失败"
        exit 1
    fi
fi

log_info "环境检查完成"

# 创建必要的目录和文件
log_step "准备项目文件..."
mkdir -p vector_db data

# 初始化data_catalog.csv文件
if [ ! -f "data/data_catalog.csv" ]; then
    log_step "创建编目数据文件..."
    cat > data/data_catalog.csv << 'EOF'
table_hash,table_name_en,resource_name,resource_summary,resource_format,domain_category,organization_name,irs_system_name,layer,is_processed,source_tables,processing_logic,fields_json,create_time,update_time
EOF
    log_info "编目数据文件创建完成"
fi

# 检查.env文件
if [ ! -f "backend/.env" ]; then
    log_warn ".env文件不存在，请确保已配置OpenAI API Key"
    read -p "是否现在配置OpenAI API Key? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        read -p "请输入您的OpenAI API Key: " api_key
        echo "OPENAI_API_KEY=$api_key" > backend/.env
        log_info ".env文件创建完成"
    fi
fi

# 安装后端依赖
log_step "检查后端依赖..."
cd backend

if [ ! -d "venv" ]; then
    log_step "创建Python虚拟环境..."
    python3 -m venv venv
    if [ $? -ne 0 ]; then
        log_error "虚拟环境创建失败"
        exit 1
    fi
fi

log_step "安装后端依赖..."
source venv/bin/activate
pip install -r requirements.txt -q
if [ $? -ne 0 ]; then
    log_error "后端依赖安装失败"
    exit 1
fi

log_info "后端依赖检查完成"

# 安装前端依赖
log_step "检查前端依赖..."
cd ../frontend

if [ ! -d "node_modules" ]; then
    log_step "安装前端依赖..."
    pnpm install --silent
    if [ $? -ne 0 ]; then
        log_error "前端依赖安装失败"
        exit 1
    fi
fi

log_info "前端依赖检查完成"

# 启动后端服务
log_step "启动后端服务..."
cd ../backend
source venv/bin/activate

# 清理旧的日志
> ../backend.log

# 后台启动后端
nohup python main.py > ../backend.log 2>&1 &
BACKEND_PID=$!

log_info "后端服务已启动 (PID: $BACKEND_PID)"

# 等待后端启动完成
log_step "等待后端服务启动完成..."
for i in {1..30}; do
    if curl -s http://localhost:8000/api/statistics > /dev/null 2>&1; then
        log_info "后端服务启动成功 (http://localhost:8000)"
        break
    fi
    
    if [ $i -eq 30 ]; then
        log_error "后端服务启动超时，请检查日志"
        echo "最近的错误日志："
        tail -n 10 ../backend.log
        cleanup
        exit 1
    fi
    
    if ! kill -0 $BACKEND_PID 2>/dev/null; then
        log_error "后端服务启动失败，请检查日志"
        echo "错误日志："
        cat ../backend.log
        exit 1
    fi
    
    echo -n "."
    sleep 1
done
echo ""

# 启动前端服务
log_step "启动前端服务..."
cd ../frontend

# 后台启动前端
nohup pnpm start > ../frontend.log 2>&1 &
FRONTEND_PID=$!

log_info "前端服务已启动 (PID: $FRONTEND_PID)"

# 等待前端启动完成
log_step "等待前端服务启动完成..."
for i in {1..60}; do
    if curl -s http://localhost:3000 > /dev/null 2>&1; then
        log_info "前端服务启动成功 (http://localhost:3000)"
        break
    fi
    
    if [ $i -eq 60 ]; then
        log_error "前端服务启动超时"
        cleanup
        exit 1
    fi
    
    if ! kill -0 $FRONTEND_PID 2>/dev/null; then
        log_error "前端服务启动失败，请检查日志"
        echo "错误日志："
        tail -n 20 ../frontend.log
        cleanup
        exit 1
    fi
    
    echo -n "."
    sleep 1
done
echo ""

# 启动成功
echo ""
echo -e "${GREEN}🎉 系统启动成功！${NC}"
echo "=================================="
echo -e "${BLUE}📊 前端地址: ${NC}http://localhost:3000"
echo -e "${BLUE}🔧 后端API: ${NC}http://localhost:8000"
echo -e "${BLUE}📖 API文档: ${NC}http://localhost:8000/docs"
echo ""
echo -e "${BLUE}📋 服务状态:${NC}"
echo "   后端服务 (PID: $BACKEND_PID) - 运行中"
echo "   前端服务 (PID: $FRONTEND_PID) - 运行中"
echo ""
echo -e "${YELLOW}💡 按 Ctrl+C 停止所有服务${NC}"
echo "=================================="

# 实时显示日志
log_step "显示实时日志 (后端 | 前端)..."
echo ""

# 使用tail -f同时显示两个日志文件
tail -f ../backend.log ../frontend.log &
TAIL_PID=$!

# 等待用户中断
while true; do
    # 检查服务是否还在运行
    if ! kill -0 $BACKEND_PID 2>/dev/null; then
        log_error "后端服务已停止"
        break
    fi
    
    if ! kill -0 $FRONTEND_PID 2>/dev/null; then
        log_error "前端服务已停止"
        break
    fi
    
    sleep 5
done

# 停止日志显示
kill $TAIL_PID 2>/dev/null

cleanup 