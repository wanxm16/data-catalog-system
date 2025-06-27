from dotenv import load_dotenv
load_dotenv()
import os
import json
import hashlib
from typing import List, Dict, Any
from datetime import datetime
import numpy as np
import pandas as pd
from sentence_transformers import SentenceTransformer
from sklearn.neighbors import NearestNeighbors
from sklearn.metrics.pairwise import cosine_distances
from watchdog.observers import Observer
from watchdog.events import FileSystemEventHandler
import openai
from models.schemas import ChatResponse
import logging

# 配置日志
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

class CSVWatcher(FileSystemEventHandler):
    """CSV文件监听器"""
    
    def __init__(self, rag_service):
        self.rag_service = rag_service
        
    def on_modified(self, event):
        if not event.is_directory and event.src_path.endswith('data_catalog.csv'):
            logger.info(f"检测到CSV文件变更: {event.src_path}")
            self.rag_service.update_vector_db()

class RAGService:
    """RAG智能问答服务"""
    
    def __init__(self, data_path: str = "../data", vector_db_path: str = "../vector_db"):
        self.data_path = data_path
        self.vector_db_path = vector_db_path
        self.csv_file = os.path.join(data_path, "data_catalog.csv")
        
        # 确保目录存在
        os.makedirs(vector_db_path, exist_ok=True)
        
        # 初始化嵌入模型
        self.embedding_model = SentenceTransformer('all-MiniLM-L6-v2')
        
        # 初始化OpenAI客户端
        self.openai_client = None
        api_key = os.getenv("OPENAI_API_KEY")
        if api_key:
            self.openai_client = openai.OpenAI(api_key=api_key)
        else:
            logger.warning("OPENAI_API_KEY 环境变量未设置，智能问答功能将受限")
        
        # 初始化向量数据库
        self.documents = []
        self.metadata = []
        self.embeddings = None
        self.nn_model = None
        
        # 加载向量数据库
        self.load_vector_db()
        
        # 启动文件监听器
        self.start_file_watcher()
        
        logger.info(f"向量数据库加载完成，包含 {len(self.documents)} 个文档")
    
    def start_file_watcher(self):
        """启动文件监听器"""
        try:
            self.observer = Observer()
            event_handler = CSVWatcher(self)
            self.observer.schedule(event_handler, self.data_path, recursive=False)
            self.observer.start()
            logger.info("文件监听器已启动，将自动同步编目数据变更")
        except Exception as e:
            logger.error(f"启动文件监听器失败: {e}")
    
    def stop_file_watcher(self):
        """停止文件监听器"""
        if hasattr(self, 'observer'):
            self.observer.stop()
            self.observer.join()
    
    def load_vector_db(self):
        """加载向量数据库"""
        try:
            documents_file = os.path.join(self.vector_db_path, "documents.json")
            embeddings_file = os.path.join(self.vector_db_path, "embeddings.npy")
            nn_model_file = os.path.join(self.vector_db_path, "nn_model.pkl")
            
            if os.path.exists(documents_file) and os.path.exists(embeddings_file):
                # 加载文档和元数据
                with open(documents_file, 'r', encoding='utf-8') as f:
                    data = json.load(f)
                    self.documents = data['documents']
                    self.metadata = data['metadata']
                
                # 加载嵌入向量
                self.embeddings = np.load(embeddings_file)
                
                # 加载或创建最近邻模型
                if os.path.exists(nn_model_file):
                    import pickle
                    with open(nn_model_file, 'rb') as f:
                        self.nn_model = pickle.load(f)
                else:
                    self._build_nn_model()
            else:
                # 首次构建向量数据库
                self.update_vector_db()
                
        except Exception as e:
            logger.error(f"加载向量数据库失败: {e}")
            self.documents = []
            self.metadata = []
            self.embeddings = None
            self.nn_model = None
    
    def _build_nn_model(self):
        """构建最近邻模型"""
        if self.embeddings is not None and len(self.embeddings) > 0:
            self.nn_model = NearestNeighbors(
                n_neighbors=min(5, len(self.embeddings)),
                metric='cosine'
            )
            self.nn_model.fit(self.embeddings)
            
            # 保存模型
            nn_model_file = os.path.join(self.vector_db_path, "nn_model.pkl")
            import pickle
            with open(nn_model_file, 'wb') as f:
                pickle.dump(self.nn_model, f)
    
    def update_vector_db(self):
        """更新向量数据库"""
        try:
            if not os.path.exists(self.csv_file):
                logger.warning(f"CSV文件不存在: {self.csv_file}")
                return
            
            # 读取CSV文件
            df = pd.read_csv(self.csv_file)
            
            # 构建文档
            documents = []
            metadata = []
            
            for _, row in df.iterrows():
                # 构建文档文本
                doc_text = self._build_document_text(row)
                documents.append(doc_text)
                
                # 构建元数据
                meta = {
                    'table_name_en': row['table_name_en'],
                    'resource_name': row['resource_name'],
                    'domain_category': row['domain_category'],
                    'organization_name': row['organization_name'],
                    'layer': row['layer']
                }
                metadata.append(meta)
            
            # 生成嵌入向量
            if documents:
                embeddings = self.embedding_model.encode(documents)
                
                # 保存数据
                self.documents = documents
                self.metadata = metadata
                self.embeddings = embeddings
                
                # 构建最近邻模型
                self._build_nn_model()
                
                # 保存到文件
                self._save_vector_db()
                
                logger.info(f"向量数据库更新完成，包含 {len(documents)} 个文档")
            
        except Exception as e:
            logger.error(f"更新向量数据库失败: {e}")
    
    def _build_document_text(self, row):
        """构建文档文本"""
        try:
            # 解析字段信息
            fields_info = ""
            if pd.notna(row['fields_json']) and row['fields_json']:
                try:
                    fields = json.loads(row['fields_json'])
                    field_names = [f['field_name_cn'] for f in fields if f.get('field_name_cn')]
                    fields_info = ", ".join(field_names)
                except:
                    fields_info = ""
            
            # 解析来源表信息
            source_tables_info = ""
            if pd.notna(row.get('source_tables')) and row['source_tables']:
                try:
                    source_tables = json.loads(row['source_tables'])
                    if source_tables:
                        source_table_names = []
                        for table in source_tables:
                            table_en = table.get('table_name_en', '')
                            table_cn = table.get('table_name_cn', '')
                            if table_en and table_cn:
                                source_table_names.append(f"{table_en}({table_cn})")
                            elif table_en:
                                source_table_names.append(table_en)
                        source_tables_info = ", ".join(source_table_names)
                except:
                    source_tables_info = ""
            
            # 构建文档文本
            doc_text = f"""表名: {row['table_name_en']}
资源名称: {row['resource_name']}
资源摘要: {row['resource_summary']}
数据分层: {row['layer']}
领域分类: {row['domain_category']}
组织机构: {row['organization_name']}
系统名称: {row['irs_system_name']}
字段: {fields_info}"""

            # 添加来源表信息
            if source_tables_info:
                doc_text += f"\n来源表: {source_tables_info}"
            
            # 如果是加工表，添加加工逻辑
            if row.get('is_processed') and pd.notna(row.get('processing_logic')):
                doc_text += f"\n加工逻辑: {row['processing_logic']}"
            
            return doc_text
            
        except Exception as e:
            logger.error(f"构建文档文本失败: {e}")
            return f"表名: {row.get('table_name_en', 'unknown')}"
    
    def _save_vector_db(self):
        """保存向量数据库"""
        try:
            # 保存文档和元数据
            documents_file = os.path.join(self.vector_db_path, "documents.json")
            data = {
                'documents': self.documents,
                'metadata': self.metadata,
                'last_update': datetime.now().isoformat()
            }
            with open(documents_file, 'w', encoding='utf-8') as f:
                json.dump(data, f, ensure_ascii=False, indent=2)
            
            # 保存嵌入向量
            embeddings_file = os.path.join(self.vector_db_path, "embeddings.npy")
            np.save(embeddings_file, self.embeddings)
            
        except Exception as e:
            logger.error(f"保存向量数据库失败: {e}")
    
    def search(self, query: str, top_k: int = 5) -> List[Dict]:
        """
        搜索相关文档 - 混合搜索：向量相似度 + 关键词匹配
        
        Args:
            query: 查询文本
            top_k: 返回结果数量
            
        Returns:
            List[Dict]: 搜索结果列表
        """
        if not self.nn_model or len(self.documents) == 0:
            return []
        
        # 生成查询向量
        query_embedding = self.embedding_model.encode([query])
        
        # 搜索最近邻
        distances, indices = self.nn_model.kneighbors(query_embedding, n_neighbors=min(top_k, len(self.documents)))
        
        results = []
        query_lower = query.lower()
        
        for i, (distance, idx) in enumerate(zip(distances[0], indices[0])):
            # 转换距离为相似度 (cosine distance -> cosine similarity)
            similarity = 1 - distance
            
            # 关键词匹配加权
            doc_text = self.documents[idx].lower()
            table_name = self.metadata[idx]['table_name_en'].lower()
            keyword_boost = 0.0
            
            # 特殊处理：表名精确匹配获得最高权重
            if table_name in query_lower:
                keyword_boost += 1.0  # 表名精确匹配，最高优先级
            
            # 检查精确匹配
            if query_lower in doc_text:
                keyword_boost += 0.3  # 精确匹配加权
            
            # 检查部分匹配
            query_words = query_lower.split()
            for word in query_words:
                if len(word) > 1 and word in doc_text:
                    keyword_boost += 0.1  # 单词匹配加权
            
            # 特殊关键词额外加权
            special_keywords = {
                '公积金': ['公积金', 'gjj'],
                '住房': ['住房', '房屋'],
                '社保': ['社保', '社会保险'],
                '医疗': ['医疗', '医院'],
                '教育': ['教育', '学校'],
                '企业': ['企业', '公司'],
                '环保': ['环保', '环境'],
                '字段': ['字段', 'field', '列', '属性'],
                '表结构': ['表结构', '结构', 'schema']
            }
            
            for key, synonyms in special_keywords.items():
                if key in query_lower:
                    for synonym in synonyms:
                        if synonym in doc_text:
                            keyword_boost += 0.2  # 同义词匹配加权
                            break
            
            # 最终分数 = 向量相似度 + 关键词加权
            final_score = similarity + keyword_boost
            
            if final_score > 0.3:  # 相似度阈值
                results.append({
                    'document': self.documents[idx],
                    'metadata': self.metadata[idx],
                    'score': float(final_score),
                    'vector_score': float(similarity),
                    'keyword_boost': float(keyword_boost),
                    'rank': i + 1
                })
        
        # 按最终分数重新排序
        results.sort(key=lambda x: x['score'], reverse=True)
        
        # 更新排名
        for i, result in enumerate(results):
            result['rank'] = i + 1
        
        return results
    
    def chat(self, question: str) -> ChatResponse:
        """
        智能问答
        
        Args:
            question: 用户问题
            
        Returns:
            ChatResponse: 问答结果
        """
        try:
            # 搜索相关文档
            search_results = self.search(question, top_k=5)
            
            if not search_results:
                return ChatResponse(
                    answer="抱歉，我没有找到相关的数据资源信息。请尝试其他问题或检查编目数据是否完整。",
                    sources=[]
                )
            
            # 如果没有OpenAI客户端，返回基础搜索结果
            if not self.openai_client:
                # 检查是否是字段相关查询
                is_field_query = any(keyword in question.lower() for keyword in ['字段', 'field', '列', '属性', '表结构', '结构'])
                
                # 构建基础回答
                if is_field_query and search_results:
                    # 字段查询的特殊处理
                    top_result = search_results[0]
                    meta = top_result['metadata']
                    doc = top_result['document']
                    
                    answer = f"根据编目信息，{meta['table_name_en']}表的详细信息如下：\n\n"
                    answer += f"📋 **表基本信息**\n"
                    answer += f"- 表名：{meta['table_name_en']}\n"
                    answer += f"- 资源名称：{meta['resource_name']}\n"
                    answer += f"- 领域分类：{meta['domain_category']}\n"
                    answer += f"- 组织机构：{meta['organization_name']}\n"
                    answer += f"- 数据分层：{meta['layer']}\n\n"
                    
                    # 提取字段信息
                    if "字段:" in doc:
                        fields_text = doc.split("字段:")[1].split("\n")[0].strip()
                        if fields_text and fields_text != "":
                            fields_list = [f.strip() for f in fields_text.split(",") if f.strip()]
                            if fields_list:
                                answer += f"📝 **字段信息** (共{len(fields_list)}个字段)：\n"
                                for i, field in enumerate(fields_list, 1):
                                    answer += f"{i}. {field}\n"
                            else:
                                answer += "📝 **字段信息**：暂无详细字段信息\n"
                        else:
                            answer += "📝 **字段信息**：暂无详细字段信息\n"
                    else:
                        answer += "📝 **字段信息**：暂无详细字段信息\n"
                else:
                    # 普通查询的处理
                    answer = f"根据搜索结果，找到以下相关的数据资源：\n\n"
                    for i, result in enumerate(search_results[:3], 1):
                        meta = result['metadata']
                        answer += f"{i}. {meta['table_name_en']}\n   - 资源名称: {meta['resource_name']}\n   - 领域分类: {meta['domain_category']}\n   - 组织机构: {meta['organization_name']}\n\n"
        
                sources = [result['metadata']['table_name_en'] for result in search_results[:3]]
                return ChatResponse(answer=answer, sources=sources)
            
            # 构建上下文
            context = self._build_context(search_results)
            
            # 构建提示词
            prompt = self._build_chat_prompt(question, context)
            
            # 调用OpenAI API
            response = self.openai_client.chat.completions.create(
                model="gpt-4o",
                messages=[
                    {"role": "system", "content": "你是一个数据目录助手，专门帮助用户查询和了解数据资源信息。请根据提供的编目信息，准确回答用户的问题。"},
                    {"role": "user", "content": prompt}
                ],
                temperature=0.2,
                max_tokens=1000
            )
            
            answer = response.choices[0].message.content
            
            # 提取引用来源
            sources = [result['metadata']['table_name_en'] for result in search_results[:3]]
            
            return ChatResponse(answer=answer, sources=sources)
            
        except Exception as e:
            logger.error(f"智能问答失败: {e}")
            return ChatResponse(
                answer=f"抱歉，处理您的问题时发生错误: {str(e)}",
                sources=[]
            )
    
    def _build_context(self, search_results: List[Dict]) -> str:
        """构建上下文"""
        context = "相关数据资源编目信息：\n\n"
        for i, result in enumerate(search_results[:3], 1):
            context += f"文档{i}：\n{result['document']}\n\n"
        
        return context
    
    def _build_chat_prompt(self, question: str, context: str) -> str:
        """构建聊天提示词"""
        prompt = f"""基于以下数据目录编目信息，回答用户的问题。

{context}

用户问题：{question}

请根据提供的编目信息，准确回答用户的问题。如果没有相关信息，请说明没有找到相关的数据资源。"""
        
        return prompt
    
    def get_statistics(self) -> Dict[str, Any]:
        """获取统计信息"""
        return {
            "total_documents": len(self.documents),
            "last_update": datetime.now().isoformat() if self.documents else None
        }
    
    def __del__(self):
        """析构函数"""
        if hasattr(self, 'observer'):
            self.stop_file_watcher()