import os
from dotenv import load_dotenv
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from typing import List
import uvicorn

# 加载环境变量
load_dotenv()

from models.schemas import (
    TableInfo, TableDetail, CatalogRequest, CatalogUpdateRequest,
    ChatRequest, ChatResponse, ApiResponse, CatalogInfo,
    CaseAnalysisRequest, CaseAnalysisResponse,
    CaseDecompositionRequest, CaseDecompositionResponse,
    CaseClarificationRequest, GenerateSQLRequest, GenerateSQLResponse
)
from services.table_service import TableService
from services.ai_service import AIService
from services.rag_service import RAGService
from services.chatbi_service import ChatBIService

# 创建FastAPI应用
app = FastAPI(
    title="数据目录编目系统",
    description="基于AI的数据目录编目和智能问答系统",
    version="1.0.0"
)

# 配置CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:3000"],  # React开发服务器
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# 初始化服务
table_service = TableService()
ai_service = AIService()
rag_service = RAGService()
chatbi_service = ChatBIService()

@app.get("/")
async def root():
    """根路径，返回API状态"""
    return {"message": "数据目录编目系统 API 运行正常", "version": "1.0.0"}

@app.get("/api/tables", response_model=List[TableInfo])
async def get_tables():
    """获取所有表信息列表"""
    try:
        tables = table_service.get_all_tables()
        return tables
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"获取表信息失败: {str(e)}")

@app.get("/api/tables/{table_name}", response_model=TableDetail)
async def get_table_detail(table_name: str):
    """获取表详细信息"""
    try:
        table_detail = table_service.get_table_detail(table_name)
        if table_detail is None:
            raise HTTPException(status_code=404, detail="表不存在")
        return table_detail
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"获取表详情失败: {str(e)}")

@app.post("/api/catalog/generate", response_model=ApiResponse)
async def generate_catalog(request: CatalogRequest):
    """使用AI生成编目信息"""
    try:
        # 检查表是否已经编目
        if table_service.is_table_cataloged(request.table_name_en):
            return ApiResponse(
                success=False,
                message="该表已经编目，请使用更新接口",
                data=None
            )
        
        # 使用AI生成编目信息
        catalog_info = ai_service.generate_catalog_info(request.table_name_en)
        
        if catalog_info is None:
            return ApiResponse(
                success=False,
                message="生成编目信息失败，请检查表是否存在",
                data=None
            )
        
        return ApiResponse(
            success=True,
            message="编目信息生成成功",
            data=catalog_info.dict()
        )
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"生成编目信息失败: {str(e)}")

@app.get("/api/catalog/{table_name}", response_model=ApiResponse)
async def get_catalog_info(table_name: str):
    """获取表的编目信息"""
    try:
        catalog_info = table_service.get_catalog_info(table_name)
        
        if catalog_info is None:
            return ApiResponse(
                success=False,
                message="该表尚未编目",
                data=None
            )
        
        return ApiResponse(
            success=True,
            message="获取编目信息成功",
            data=catalog_info.dict()
        )
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"获取编目信息失败: {str(e)}")

@app.post("/api/catalog/save", response_model=ApiResponse)
async def save_catalog_info(request: CatalogUpdateRequest):
    """保存编目信息"""
    try:
        success = table_service.save_catalog_info(request.catalog_info)
        
        if success:
            return ApiResponse(
                success=True,
                message="编目信息保存成功",
                data=None
            )
        else:
            return ApiResponse(
                success=False,
                message="编目信息保存失败",
                data=None
            )
            
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"保存编目信息失败: {str(e)}")

@app.post("/api/chat", response_model=ChatResponse)
async def chat_with_catalog(request: ChatRequest):
    """智能问答接口"""
    try:
        response = rag_service.chat(request.question)
        return response
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"智能问答失败: {str(e)}")

@app.post("/api/case-analysis", response_model=ApiResponse)
async def analyze_case(request: CaseAnalysisRequest):
    """案件分解接口（保留原有的一步到位接口）"""
    try:
        analysis_result = ai_service.analyze_case(request.case_description)
        
        if analysis_result is None:
            return ApiResponse(
                success=False,
                message="案件分解失败",
                data=None
            )
        
        return ApiResponse(
            success=True,
            message="案件分解成功",
            data=analysis_result.dict()
        )
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"案件分解失败: {str(e)}")

@app.post("/api/case-clarity", response_model=ApiResponse)
async def analyze_case_clarity(request: CaseDecompositionRequest):
    """分析案件描述清晰度接口"""
    try:
        clarity_result = ai_service.analyze_case_clarity(request.case_description)
        
        return ApiResponse(
            success=True,
            message="案件清晰度分析完成",
            data=clarity_result
        )
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"案件清晰度分析失败: {str(e)}")

@app.post("/api/case-decomposition", response_model=ApiResponse)
async def decompose_case(request: CaseDecompositionRequest):
    """案件步骤分解接口（第一步：只分解步骤，不生成SQL）"""
    try:
        decomposition_result = ai_service.decompose_case_steps(request.case_description)
        
        if decomposition_result is None:
            return ApiResponse(
                success=False,
                message="案件步骤分解失败",
                data=None
            )
        
        return ApiResponse(
            success=True,
            message="案件步骤分解成功",
            data=decomposition_result.dict()
        )
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"案件步骤分解失败: {str(e)}")

@app.post("/api/case-clarification", response_model=ApiResponse)
async def decompose_case_with_clarification(request: CaseClarificationRequest):
    """基于澄清回答进行案件分解接口"""
    try:
        decomposition_result = ai_service.decompose_case_with_clarification(
            request.original_description, 
            request.clarification_answers
        )
        
        if decomposition_result is None:
            return ApiResponse(
                success=False,
                message="基于澄清信息的案件分解失败",
                data=None
            )
        
        return ApiResponse(
            success=True,
            message="案件分解成功",
            data=decomposition_result.dict()
        )
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"基于澄清信息的案件分解失败: {str(e)}")

@app.post("/api/generate-sql", response_model=ApiResponse)
async def generate_sql(request: GenerateSQLRequest):
    """SQL生成接口（第二步：根据用户调整后的步骤生成SQL）"""
    try:
        sql_result = ai_service.generate_sql_for_steps(request.steps)
        
        if sql_result is None:
            return ApiResponse(
                success=False,
                message="SQL生成失败",
                data=None
            )
        
        return ApiResponse(
            success=True,
            message="SQL生成成功",
            data=sql_result.dict()
        )
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"SQL生成失败: {str(e)}")

@app.get("/api/statistics")
async def get_statistics():
    """获取系统统计信息"""
    try:
        # 获取表统计
        all_tables = table_service.get_all_tables()
        cataloged_count = len([t for t in all_tables if t.catalog_status.value == "已编目"])
        
        # 获取向量数据库统计
        rag_stats = rag_service.get_statistics()
        
        stats = {
            "total_tables": len(all_tables),
            "cataloged_tables": cataloged_count,
            "uncataloged_tables": len(all_tables) - cataloged_count,
            "catalog_progress": round(cataloged_count / len(all_tables) * 100, 1) if all_tables else 0,
            "vector_db_documents": rag_stats["total_documents"],
            "last_update": rag_stats["last_update"]
        }
        
        return {"success": True, "data": stats}
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"获取统计信息失败: {str(e)}")

@app.post("/api/vector-db/refresh")
async def refresh_vector_db():
    """手动刷新向量数据库"""
    try:
        # 强制更新向量数据库
        rag_service.update_vector_db()
        
        # 获取更新后的统计信息
        rag_stats = rag_service.get_statistics()
        
        return {
            "success": True, 
            "message": f"向量数据库刷新成功，包含 {rag_stats['total_documents']} 个文档",
            "data": {
                "total_documents": rag_stats["total_documents"],
                "last_update": rag_stats["last_update"]
            }
        }
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"刷新向量数据库失败: {str(e)}")

@app.get("/api/chatbi/files")
async def get_chatbi_files():
    """获取可用的数据文件列表"""
    try:
        files = chatbi_service.get_available_files()
        return {
            "success": True,
            "data": files
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"获取数据文件列表失败: {str(e)}")

@app.post("/api/chatbi/analyze")
async def analyze_chatbi_data(request: dict):
    """数据分析接口"""
    try:
        filename = request.get("filename")
        question = request.get("question")
        
        if not filename or not question:
            raise HTTPException(status_code=400, detail="缺少必要参数: filename 或 question")
        
        result = chatbi_service.analyze_data(filename, question)
        return result
        
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"数据分析失败: {str(e)}")

@app.get("/api/health")
async def health_check():
    """健康检查接口"""
    return {
        "status": "healthy",
        "services": {
            "table_service": "running",
            "ai_service": "running", 
            "rag_service": "running",
            "chatbi_service": "running"
        }
    }

if __name__ == "__main__":
    print("🚀 启动数据目录编目系统...")
    print("📊 API文档地址: http://localhost:8000/docs")
    print("🔍 交互式API: http://localhost:8000/redoc")
    
    uvicorn.run(
        "main:app",
        host="0.0.0.0",
        port=8000,
        reload=True,
        log_level="info"
    ) 