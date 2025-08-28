from pydantic import BaseModel
from typing import List, Optional, Any
from enum import Enum

class TableLayer(str, Enum):
    """表分层枚举"""
    STG = "STG"
    ODS = "ODS" 
    DWD = "DWD"
    ADS = "ADS"
    UNKNOWN = "UNKNOWN"

class CatalogStatus(str, Enum):
    """编目状态枚举"""
    CATALOGED = "已编目"
    NOT_CATALOGED = "未编目"

class DomainCategory(str, Enum):
    """重点领域分类枚举"""
    ENTERPRISE = "企业监管"
    POPULATION = "人口管理"
    GEOGRAPHIC = "地理信息"
    FINANCIAL = "金融监管"
    HEALTH = "医疗卫生"
    EDUCATION = "教育管理"
    TRANSPORTATION = "交通运输"
    ENVIRONMENT = "环境保护"
    AGRICULTURE = "农业农村"
    JUSTICE = "司法执法"
    OTHER = "其他"

class FieldInfo(BaseModel):
    """字段信息模型"""
    field_name_en: str  # 字段英文名
    field_name_cn: str  # 字段中文名  
    field_type: str     # 字段类型
    is_nullable: bool = True  # 是否可空
    default_value: Optional[str] = None  # 默认值

class TableInfo(BaseModel):
    """表信息模型"""
    table_name_en: str  # 表英文名（文件名）
    table_name_cn: str  # 表中文名（注释）
    layer: TableLayer   # 所在分层
    catalog_status: CatalogStatus  # 编目状态
    field_count: int    # 字段数量
    has_etl: bool      # 是否有ETL文件
    
class TableDetail(BaseModel):
    """表详细信息模型"""
    table_name_en: str
    table_name_cn: str
    layer: TableLayer
    fields: List[FieldInfo]
    create_sql: str    # 建表SQL

class SourceTableInfo(BaseModel):
    """来源表信息"""
    table_name_en: str
    table_name_cn: str

class CatalogInfo(BaseModel):
    """编目信息模型"""
    # 基础信息
    table_name_en: str                          # 表英文名称
    resource_name: str                          # 信息资源名称
    resource_summary: str                       # 信息资源摘要
    resource_format: str = "table"             # 信息资源格式
    
    # 分类信息
    domain_category: DomainCategory             # 重点领域分类
    organization_name: str                      # 组织机构名称
    irs_system_name: str                        # IRS系统名称
    
    # 表结构信息
    layer: TableLayer                           # 数据分层
    fields: List[FieldInfo]                     # 字段列表
    
    # 加工信息
    is_processed: bool                          # 是否为加工表
    source_tables: Optional[List[SourceTableInfo]] = None  # 来源表列表
    processing_logic: Optional[str] = None      # 加工逻辑
    
    # 元数据
    create_time: Optional[str] = None           # 创建时间
    update_time: Optional[str] = None           # 更新时间

class CatalogRequest(BaseModel):
    """编目请求模型"""
    table_name_en: str

class CatalogUpdateRequest(BaseModel):
    """编目更新请求模型"""
    catalog_info: CatalogInfo

class ChatRequest(BaseModel):
    """聊天请求模型"""
    question: str
    
class ChatResponse(BaseModel):
    """聊天响应模型"""
    answer: str
    sources: List[str] = []  # 引用的数据源

class AnalysisStep(BaseModel):
    """分析步骤模型"""
    step_number: int
    description: str
    sql: Optional[str] = None  # SQL现在是可选的

class CaseAnalysisResponse(BaseModel):
    """案件分析响应模型"""
    steps: List[AnalysisStep]
    summary: str

class CaseAnalysisRequest(BaseModel):
    """案件分析请求模型"""
    case_description: str

# 步骤分解请求（第一步）
class CaseDecompositionRequest(BaseModel):
    """案件步骤分解请求模型"""
    case_description: str

# 案件澄清请求
class CaseClarificationRequest(BaseModel):
    """案件澄清请求模型"""
    original_description: str
    clarification_answers: List[str]

# 步骤分解响应（第一步）
class CaseDecompositionResponse(BaseModel):
    """案件步骤分解响应模型"""
    steps: List[AnalysisStep]  # 只包含step_number和description，不包含sql
    summary: str

# SQL生成请求（第二步）
class GenerateSQLRequest(BaseModel):
    """SQL生成请求模型"""
    steps: List[AnalysisStep]  # 用户修改后的步骤列表

# SQL生成响应（第二步）  
class GenerateSQLResponse(BaseModel):
    """SQL生成响应模型"""
    steps: List[AnalysisStep]  # 包含完整的step_number, description, sql
    summary: str

class ApiResponse(BaseModel):
    """通用API响应模型"""
    success: bool
    message: str
    data: Optional[Any] = None 