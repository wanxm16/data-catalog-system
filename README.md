# 新疆公安数据智能分析平台

基于AI的公安数据智能分析平台，支持数据目录编目、RAG智能问答、案件分解和统计分析，为新疆公安厅案件大队提供数据管理与分析支撑。

## 🚀 一键启动

### 快速启动
```bash
# 启动前后端服务（首次运行会自动安装依赖）
./start.sh

# 停止所有服务
./stop.sh
```

### 启动脚本功能
- ✅ **智能检测**：自动检测运行中的服务，避免冲突
- ✅ **环境检查**：自动检查Python、Node.js、pnpm等依赖
- ✅ **依赖缓存**：智能缓存依赖，第二次启动更快
- ✅ **配置向导**：交互式配置OpenAI API Key，可跳过
- ✅ **健康监控**：实时监控服务状态，异常自动恢复
- ✅ **完整清理**：停止脚本彻底清理进程和端口占用
- ✅ **可视化反馈**：彩色日志和进度提示

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
- 🏷️ 分层标识（ODS/DWD/ADS/STG）

### 2. 智能编目
- 🤖 AI自动生成编目信息
- 📄 ETL脚本智能解析，识别来源表和业务逻辑
- ✏️ 手动编辑和完善编目内容
- 💾 编目数据持久化存储

### 3. RAG智能问答
- 💬 基于编目信息的智能问答
- 🔗 向量数据库支持相似度搜索
- 📚 引用来源追踪
- 🎯 支持字段查询、表关系查询、业务逻辑查询
- 🔍 混合搜索：向量相似度 + 关键词匹配

### 4. 案件分解助手 🆕
- 🎯 **智能分解**：AI自动将案件目标分解为多个逻辑步骤
- 📝 **SQL生成**：为每个步骤自动生成对应的SQL查询语句
- 🔗 **步骤关联**：确保步骤间的逻辑递进关系
- 🛠️ **通用设计**：使用伪表名和伪字段，便于后续替换
- ⏰ **时间函数**：支持NOW()、DATE_SUB()等标准时间函数
- 📊 **可视化展示**：步骤化界面，SQL语法高亮显示

### 5. 统计分析
- 📈 编目进度统计
- 🏗️ 分层统计（ODS/DWD/ADS/STG）
- 📊 向量数据库状态监控
- 🔄 数据同步功能

## 🛠️ 技术架构

### 后端技术栈
- **框架**: FastAPI
- **AI模型**: OpenAI GPT-4o
- **向量数据库**: scikit-learn + SentenceTransformers
- **数据存储**: CSV文件持久化
- **文件监听**: watchdog
- **环境管理**: python-dotenv

### 前端技术栈  
- **框架**: React + TypeScript
- **UI组件**: Ant Design
- **路由**: React Router
- **HTTP客户端**: Axios
- **构建工具**: Create React App

## 📁 项目结构

```
公安/
├── start.sh              # 🚀 优化的一键启动脚本
├── stop.sh               # 🛑 智能停止脚本
├── backend/              # 后端服务
│   ├── main.py           # FastAPI主程序
│   ├── services/         # 业务服务
│   │   ├── ai_service.py      # AI编目 + 案件分解服务
│   │   ├── rag_service.py     # RAG问答服务
│   │   └── table_service.py   # 表管理服务
│   ├── models/           # 数据模型
│   │   └── schemas.py    # Pydantic数据模型
│   ├── .env              # OpenAI API Key配置
│   └── requirements.txt  # Python依赖
├── frontend/             # 前端应用
│   ├── src/              # 源代码
│   │   ├── components/   # React组件
│   │   │   ├── TableList.tsx     # 数据资源列表
│   │   │   ├── ChatInterface.tsx # 智能问答界面  
│   │   │   ├── Statistics.tsx    # 统计信息
│   │   │   ├── CaseAnalysis.tsx  # 案件分解界面 🆕
│   │   │   └── CatalogForm.tsx   # 编目表单
│   │   ├── services/     # API服务
│   │   │   └── api.ts    # API接口封装
│   │   └── types/        # TypeScript类型定义
│   └── package.json      # Node.js依赖
├── data/                 # 数据文件
│   ├── data_catalog.csv  # 编目数据存储
│   ├── DDL/             # 数据表DDL文件（410个）
│   └── ETL/             # ETL脚本文件
├── vector_db/           # 向量数据库文件
│   ├── documents.json   # 文档数据
│   ├── embeddings.npy   # 向量数据
│   └── nn_model.pkl     # 最近邻模型
└── 案件分解需求.md      # 案件分解功能需求文档
```

## ⚙️ 配置说明

### OpenAI API Key配置
首次启动时会提示配置OpenAI API Key（支持跳过）：
```bash
# 方式1：启动时交互配置
./start.sh
# 根据提示输入API Key，或直接回车跳过

# 方式2：手动创建.env文件
echo "OPENAI_API_KEY=your-api-key-here" > backend/.env
```

### 环境要求
- **Python**: 3.8+
- **Node.js**: 16+
- **pnpm**: 最新版本（脚本会自动安装）
- **系统**: macOS/Linux/Windows WSL

## 🎯 使用流程

### 1. 系统启动
```bash
./start.sh
```
脚本会自动：
- 检查并安装依赖
- 配置OpenAI API Key（可选）
- 启动前后端服务
- 验证服务健康状态

### 2. 数据表编目
- 访问 http://localhost:3000
- 进入"数据资源"页面
- 选择数据表点击"编目"
- AI自动生成编目信息（包含来源表解析）
- 手动完善并保存

### 3. 案件分解 🆕
- 进入"案件分解"页面
- 输入案件目标描述（如："乌鲁木齐疑似高风险偷渡人员"）
- 点击"开始分解"或"使用示例"
- 查看AI生成的分析步骤和SQL语句
- 复制SQL用于数据分析

### 4. 智能问答
- 进入"智能问答"页面
- 询问关于数据表、字段、来源表、业务逻辑等问题
- 支持中文自然语言查询

### 5. 同步向量数据库
- 进入"统计信息"页面
- 点击"同步向量数据库"按钮
- 确保编目数据已同步到问答系统

### 6. 系统停止
```bash
./stop.sh
```
脚本会彻底清理：
- 所有相关进程
- 端口占用
- 临时文件

## 🔧 故障排除

### 常见问题

1. **端口被占用**
   ```bash
   ./stop.sh  # 智能清理所有进程和端口
   ./start.sh # 重新启动
   ```

2. **依赖安装失败**
   ```bash
   # 清理并重新安装后端依赖
   cd backend
   rm -rf venv .deps_installed
   source venv/bin/activate
   pip install -r requirements.txt
   
   # 清理并重新安装前端依赖
   cd ../frontend
   rm -rf node_modules
   pnpm install
   ```

3. **OpenAI API问题**
   - 检查 `backend/.env` 文件是否存在
   - 确认API Key有效性和余额
   - 测试API Key是否有GPT-4o访问权限

4. **案件分解失败**
   - 确认OpenAI API Key配置正确
   - 检查网络连接
   - 查看后端日志：`tail -f backend.log`

### 日志查看
```bash
# 查看后端日志
tail -f backend.log

# 查看前端日志  
tail -f frontend.log

# 实时查看所有日志（启动后自动显示）
./start.sh  # 会自动显示实时日志
```

### 性能优化
- 首次启动较慢（需安装依赖），后续启动很快
- 向量数据库在内存中，重启后需重新加载
- 大量编目数据建议定期备份 `data/data_catalog.csv`

## 📊 系统状态

- **数据表总数**: 410个
- **支持数据分层**: ODS/DWD/ADS/STG
- **AI模型**: GPT-4o (编目 + 案件分解)
- **向量模型**: all-MiniLM-L6-v2
- **编目字段**: 15个核心字段（表名、资源名称、摘要、来源表、业务逻辑等）
- **案件分解**: 支持5-8步逻辑分解，自动生成SQL

## 🎉 特色功能

- ✨ **一键启动**: 零配置快速启动，智能依赖管理
- 🤖 **智能编目**: AI自动解析ETL脚本生成编目信息  
- 🔍 **混合搜索**: 向量相似度 + 关键词匹配
- 📱 **响应式UI**: 支持不同屏幕尺寸，现代化设计
- 🔄 **实时同步**: 编目数据自动同步到向量数据库
- 📈 **可视化统计**: 丰富的数据统计和进度展示
- 🎯 **案件分解**: AI驱动的案件分析和SQL生成 🆕
- 🛡️ **稳定运行**: 智能监控和自动恢复机制
- 🚀 **快速部署**: 优化的启动脚本，依赖缓存加速

---

## 💡 使用提示

- **首次使用**：运行 `./start.sh` 会自动设置环境，建议准备好OpenAI API Key
- **日常使用**：`./start.sh` 启动，`./stop.sh` 停止，简单高效
- **案件分解**：支持复杂案件目标，AI会自动分解为可执行的分析步骤
- **问答功能**：编目数据越多，问答效果越好，建议先编目后使用
- **数据备份**：重要编目数据存储在 `data/data_catalog.csv`，建议定期备份

## 🤝 贡献指南

欢迎提交Issue和Pull Request来改进系统功能！

---

**🎊 祝您使用愉快！如有问题请查看故障排除部分或提交Issue。** 