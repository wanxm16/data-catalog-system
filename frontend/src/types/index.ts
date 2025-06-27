// 表分层枚举
export enum TableLayer {
  STG = "STG",
  ODS = "ODS",
  DWD = "DWD",
  ADS = "ADS",
  UNKNOWN = "UNKNOWN"
}

// 编目状态枚举
export enum CatalogStatus {
  CATALOGED = "已编目",
  NOT_CATALOGED = "未编目"
}

// 重点领域分类枚举
export enum DomainCategory {
  ENTERPRISE = "企业监管",
  POPULATION = "人口管理",
  GEOGRAPHIC = "地理信息",
  FINANCIAL = "金融监管",
  HEALTH = "医疗卫生",
  EDUCATION = "教育管理",
  TRANSPORTATION = "交通运输",
  ENVIRONMENT = "环境保护",
  AGRICULTURE = "农业农村",
  JUSTICE = "司法执法",
  OTHER = "其他"
}

// 字段信息接口
export interface FieldInfo {
  field_name_en: string;    // 字段英文名
  field_name_cn: string;    // 字段中文名
  field_type: string;       // 字段类型
  is_nullable?: boolean;    // 是否可空
  default_value?: string;   // 默认值
}

// 表信息接口
export interface TableInfo {
  table_name_en: string;    // 表英文名
  table_name_cn: string;    // 表中文名
  layer: TableLayer;        // 所在分层
  catalog_status: CatalogStatus;  // 编目状态
  field_count: number;      // 字段数量
  has_etl: boolean;        // 是否有ETL文件
}

// 表详细信息接口
export interface TableDetail {
  table_name_en: string;
  table_name_cn: string;
  layer: TableLayer;
  fields: FieldInfo[];
  create_sql: string;       // 建表SQL
}

// 来源表信息接口
export interface SourceTableInfo {
  table_name_en: string;
  table_name_cn: string;
}

// 编目信息接口
export interface CatalogInfo {
  table_name_en: string;                    // 表英文名称
  resource_name: string;                    // 信息资源名称
  resource_summary: string;                 // 信息资源摘要
  resource_format: string;                  // 信息资源格式
  domain_category: DomainCategory;          // 重点领域分类
  organization_name: string;                // 组织机构名称
  irs_system_name: string;                  // IRS系统名称
  layer: TableLayer;                        // 数据分层
  fields: FieldInfo[];                      // 字段列表
  is_processed: boolean;                    // 是否为加工表
  source_tables?: SourceTableInfo[];       // 来源表列表
  processing_logic?: string;                // 加工逻辑
  create_time?: string;                     // 创建时间
  update_time?: string;                     // 更新时间
}

// API请求接口
export interface CatalogRequest {
  table_name_en: string;
}

export interface CatalogUpdateRequest {
  catalog_info: CatalogInfo;
}

export interface ChatRequest {
  question: string;
}

// API响应接口
export interface ChatResponse {
  answer: string;
  sources: string[];
}

export interface ApiResponse<T = any> {
  success: boolean;
  message: string;
  data?: T;
}

// 统计信息接口
export interface SystemStatistics {
  total_tables: number;
  cataloged_tables: number;
  uncataloged_tables: number;
  catalog_progress: number;
  vector_db_documents: number;
  last_update: string;
} 