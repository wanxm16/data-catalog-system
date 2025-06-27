import axios, { AxiosResponse } from 'axios';
import {
  TableInfo,
  TableDetail,
  CatalogInfo,
  CatalogRequest,
  CatalogUpdateRequest,
  ChatRequest,
  ChatResponse,
  ApiResponse,
  SystemStatistics
} from '../types';

// 创建axios实例
const api = axios.create({
  baseURL: 'http://localhost:8000/api',
  timeout: 30000,
  headers: {
    'Content-Type': 'application/json',
  },
});

// 请求拦截器
api.interceptors.request.use(
  (config) => {
    console.log(`发送${config.method?.toUpperCase()}请求到: ${config.url}`);
    return config;
  },
  (error) => {
    console.error('请求错误:', error);
    return Promise.reject(error);
  }
);

// 响应拦截器
api.interceptors.response.use(
  (response) => {
    console.log(`收到响应 ${response.status}: ${response.config.url}`);
    return response;
  },
  (error) => {
    console.error('响应错误:', error);
    const message = error.response?.data?.detail || error.message || '请求失败';
    return Promise.reject(new Error(message));
  }
);

// API服务类
export class ApiService {
  
  /**
   * 获取所有表信息
   */
  static async getTables(): Promise<TableInfo[]> {
    const response: AxiosResponse<TableInfo[]> = await api.get('/tables');
    return response.data;
  }

  /**
   * 获取表详细信息
   * @param tableName 表名
   */
  static async getTableDetail(tableName: string): Promise<TableDetail> {
    const response: AxiosResponse<TableDetail> = await api.get(`/tables/${tableName}`);
    return response.data;
  }

  /**
   * 生成编目信息（AI自动生成）
   * @param tableName 表名
   */
  static async generateCatalog(tableName: string): Promise<ApiResponse<CatalogInfo>> {
    const request: CatalogRequest = { table_name_en: tableName };
    const response: AxiosResponse<ApiResponse<CatalogInfo>> = await api.post('/catalog/generate', request);
    return response.data;
  }

  /**
   * 获取编目信息
   * @param tableName 表名
   */
  static async getCatalogInfo(tableName: string): Promise<ApiResponse<CatalogInfo>> {
    const response: AxiosResponse<ApiResponse<CatalogInfo>> = await api.get(`/catalog/${tableName}`);
    return response.data;
  }

  /**
   * 保存编目信息
   * @param catalogInfo 编目信息
   */
  static async saveCatalogInfo(catalogInfo: CatalogInfo): Promise<ApiResponse> {
    const request: CatalogUpdateRequest = { catalog_info: catalogInfo };
    const response: AxiosResponse<ApiResponse> = await api.post('/catalog/save', request);
    return response.data;
  }

  /**
   * 智能问答
   * @param question 问题
   */
  static async chat(question: string): Promise<ChatResponse> {
    const request: ChatRequest = { question };
    const response: AxiosResponse<ChatResponse> = await api.post('/chat', request);
    return response.data;
  }

  /**
   * 获取系统统计信息
   */
  static async getStatistics(): Promise<SystemStatistics> {
    const response: AxiosResponse<ApiResponse<SystemStatistics>> = await api.get('/statistics');
    if (!response.data.data) {
      throw new Error('获取统计信息失败');
    }
    return response.data.data;
  }

  /**
   * 刷新向量数据库
   */
  static async refreshVectorDB(): Promise<ApiResponse> {
    const response: AxiosResponse<ApiResponse> = await api.post('/vector-db/refresh');
    return response.data;
  }

  /**
   * 健康检查
   */
  static async healthCheck(): Promise<any> {
    const response: AxiosResponse<any> = await api.get('/health');
    return response.data;
  }
}

export default ApiService; 