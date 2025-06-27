# 数据目录编目系统

基于AI的数据目录编目系统，支持智能编目、RAG问答和统计分析。

## 🚀 一键启动

### 快速启动
```bash
# 启动前后端服务
./start.sh

# 停止所有服务
./stop.sh
```

### 启动脚本功能
- ✅ **环境检查**：自动检查Python、Node.js、pnpm等依赖
- ✅ **依赖安装**：自动创建虚拟环境并安装依赖
- ✅ **配置向导**：交互式配置OpenAI API Key
- ✅ **健康检查**：等待服务启动完成并验证
- ✅ **实时日志**：同时显示前后端日志
- ✅ **优雅停止**：Ctrl+C 优雅停止所有服务

### 访问地址
启动成功后可访问：
- 🌐 **前端界面**: http://localhost:3000
- 🔧 **后端API**: http://localhost:8000  
- 📖 **API文档**: http://localhost:8000/docs

## 📋 系统功能

### 1. 数据资源管理
- 📊 数据表列表展示（410个数据表）
- 🔍 搜索和筛选功能
- 📝 表详情查看（字段信息、元数据）

### 2. 智能编目
- 🤖 AI自动生成编目信息
- 📄 ETL脚本解析，识别来源表和业务逻辑
- ✏️ 手动编辑和完善编目内容
- 💾 编目数据持久化

### 3. RAG智能问答
- 💬 基于编目信息的智能问答
- 🔗 向量数据库支持相似度搜索
- 📚 引用来源追踪
- 🎯 支持字段查询、表关系查询等

### 4. 统计分析
- 📈 编目进度统计
- 🏗️ 分层统计（ODS/DWD/ADS）
- 📊 向量数据库状态
- 🔄 数据同步功能

## 🛠️ 技术架构

### 后端技术栈
- **框架**: FastAPI
- **AI模型**: OpenAI GPT-4o
- **向量数据库**: scikit-learn + SentenceTransformers
- **数据存储**: CSV文件持久化
- **文件监听**: watchdog

### 前端技术栈  
- **框架**: React + TypeScript
- **UI组件**: Ant Design
- **路由**: React Router
- **HTTP客户端**: Axios

## 📁 项目结构

```
公安/
├── start.sh              # 🚀 一键启动脚本
├── stop.sh               # 🛑 停止服务脚本
├── backend/              # 后端服务
│   ├── main.py           # FastAPI主程序
│   ├── services/         # 业务服务
│   │   ├── ai_service.py      # AI编目服务
│   │   ├── rag_service.py     # RAG问答服务
│   │   └── table_service.py   # 表管理服务
│   ├── models/           # 数据模型
│   └── requirements.txt  # Python依赖
├── frontend/             # 前端应用
│   ├── src/              # 源代码
│   │   ├── components/   # React组件
│   │   ├── services/     # API服务
│   │   └── types/        # TypeScript类型
│   └── package.json      # Node.js依赖
├── data/                 # 数据文件
│   ├── data_catalog.csv  # 编目数据
│   ├── DDL/             # 数据表DDL文件
│   └── ETL/             # ETL脚本文件
└── vector_db/           # 向量数据库文件
    ├── documents.json   # 文档数据
    ├── embeddings.npy   # 向量数据
    └── nn_model.pkl     # 最近邻模型
```

## ⚙️ 配置说明

### OpenAI API Key配置
首次启动时会提示配置OpenAI API Key：
```bash
# 方式1：启动时交互配置
./start.sh

# 方式2：手动创建.env文件
echo "OPENAI_API_KEY=your-api-key-here" > backend/.env
```

### 环境要求
- **Python**: 3.8+
- **Node.js**: 16+
- **pnpm**: 最新版本
- **系统**: macOS/Linux/Windows WSL

## 🎯 使用流程

1. **启动系统**
   ```bash
   ./start.sh
   ```

2. **编目数据表**
   - 访问 http://localhost:3000
   - 选择数据表点击"编目"
   - AI自动生成编目信息
   - 手动完善并保存

3. **同步向量数据库**
   - 进入"统计信息"页面
   - 点击"同步向量数据库"按钮

4. **智能问答**
   - 进入"智能问答"页面
   - 询问关于数据表、字段、来源表等问题

5. **停止系统**
   ```bash
   ./stop.sh
   ```

## 🔧 故障排除

### 常见问题

1. **端口被占用**
   ```bash
   ./stop.sh  # 清理所有进程和端口
   ./start.sh # 重新启动
   ```

2. **Python模块缺失**
   ```bash
   cd backend
   source venv/bin/activate
   pip install -r requirements.txt
   ```

3. **前端依赖问题**
   ```bash
   cd frontend
   rm -rf node_modules
   pnpm install
   ```

4. **OpenAI API配置**
   - 检查 `backend/.env` 文件是否存在
   - 确认API Key有效性和余额

### 日志查看
```bash
# 查看后端日志
tail -f backend.log

# 查看前端日志  
tail -f frontend.log
```

## 📊 系统状态

- **数据表总数**: 410个
- **支持数据分层**: ODS/DWD/ADS
- **AI模型**: GPT-4o
- **向量模型**: all-MiniLM-L6-v2
- **编目字段**: 15个核心字段（表名、资源名称、摘要、来源表、业务逻辑等）

---

## 🎉 特色功能

- ✨ **一键启动**: 零配置快速启动前后端
- 🤖 **智能编目**: AI自动解析ETL脚本生成编目信息  
- 🔍 **混合搜索**: 向量相似度 + 关键词匹配
- 📱 **响应式UI**: 支持不同屏幕尺寸
- 🔄 **实时同步**: 编目数据自动同步到向量数据库
- 📈 **可视化统计**: 丰富的数据统计和进度展示 