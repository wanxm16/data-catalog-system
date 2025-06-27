import os
import pandas as pd
import hashlib
from datetime import datetime
from typing import List, Dict, Optional
from utils.sql_parser import SQLParser
from models.schemas import (
    TableInfo, TableDetail, CatalogInfo, FieldInfo, 
    TableLayer, CatalogStatus, SourceTableInfo
)

class TableService:
    """表服务类，负责表信息管理和编目数据持久化"""
    
    def __init__(self, data_dir: str = "../data"):
        self.data_dir = data_dir
        self.catalog_file = os.path.join(data_dir, "data_catalog.csv")
        self.sql_parser = SQLParser(data_dir)
        
        # 创建目录
        os.makedirs(data_dir, exist_ok=True)
        
        # 初始化CSV文件
        self._init_catalog_csv()
    
    def _init_catalog_csv(self):
        """初始化编目CSV文件"""
        if not os.path.exists(self.catalog_file):
            # 创建空的DataFrame并保存
            columns = [
                'table_hash', 'table_name_en', 'resource_name', 'resource_summary',
                'resource_format', 'domain_category', 'organization_name', 
                'irs_system_name', 'layer', 'is_processed', 'source_tables',
                'processing_logic', 'fields_json', 'create_time', 'update_time'
            ]
            df = pd.DataFrame(columns=columns)
            df.to_csv(self.catalog_file, index=False, encoding='utf-8-sig')
    
    def get_table_hash(self, table_name: str) -> str:
        """生成表名的哈希值作为主键"""
        return hashlib.md5(table_name.encode('utf-8')).hexdigest()
    
    def get_all_tables(self) -> List[TableInfo]:
        """获取所有表信息列表"""
        tables = []
        catalog_df = self._load_catalog_df()
        
        # 获取所有DDL文件
        ddl_files = self.sql_parser.get_all_ddl_files()
        
        for file_path in ddl_files:
            table_data = self.sql_parser.parse_ddl_file(file_path)
            if table_data:
                table_name = table_data['table_name']
                table_hash = self.get_table_hash(table_name)
                
                # 检查编目状态
                is_cataloged = not catalog_df[catalog_df['table_hash'] == table_hash].empty
                catalog_status = CatalogStatus.CATALOGED if is_cataloged else CatalogStatus.NOT_CATALOGED
                
                # 检查是否有ETL文件
                has_etl = self.sql_parser.has_etl_file(table_name)
                
                tables.append(TableInfo(
                    table_name_en=table_name,
                    table_name_cn=table_data['table_comment'],
                    layer=table_data['layer'],
                    catalog_status=catalog_status,
                    field_count=len(table_data['fields']),
                    has_etl=has_etl
                ))
        
        return tables
    
    def get_table_detail(self, table_name: str) -> Optional[TableDetail]:
        """获取表详细信息"""
        # 找到对应的DDL文件
        ddl_files = self.sql_parser.get_all_ddl_files()
        
        for file_path in ddl_files:
            if os.path.basename(file_path).replace('.sql', '') == table_name:
                table_data = self.sql_parser.parse_ddl_file(file_path)
                if table_data:
                    return TableDetail(
                        table_name_en=table_name,
                        table_name_cn=table_data['table_comment'],
                        layer=table_data['layer'],
                        fields=table_data['fields'],
                        create_sql=table_data['sql_content']
                    )
        
        return None
    
    def _load_catalog_df(self) -> pd.DataFrame:
        """加载编目CSV文件"""
        try:
            return pd.read_csv(self.catalog_file, encoding='utf-8-sig')
        except:
            return pd.DataFrame()
    
    def is_table_cataloged(self, table_name: str) -> bool:
        """检查表是否已编目"""
        catalog_df = self._load_catalog_df()
        table_hash = self.get_table_hash(table_name)
        return not catalog_df[catalog_df['table_hash'] == table_hash].empty
    
    def get_catalog_info(self, table_name: str) -> Optional[CatalogInfo]:
        """获取表的编目信息"""
        catalog_df = self._load_catalog_df()
        table_hash = self.get_table_hash(table_name)
        
        row = catalog_df[catalog_df['table_hash'] == table_hash]
        if row.empty:
            return None
        
        row = row.iloc[0]
        
        # 解析字段信息JSON
        fields = []
        if pd.notna(row['fields_json']):
            import json
            try:
                fields_data = json.loads(row['fields_json'])
                fields = [FieldInfo(**field) for field in fields_data]
            except:
                pass
        
        # 解析来源表信息
        source_tables = []
        if pd.notna(row['source_tables']) and row['source_tables']:
            try:
                import json
                source_data = json.loads(row['source_tables'])
                source_tables = [SourceTableInfo(**table) for table in source_data]
            except:
                pass
        
        return CatalogInfo(
            table_name_en=row['table_name_en'],
            resource_name=row['resource_name'],
            resource_summary=row['resource_summary'],
            resource_format=row['resource_format'],
            domain_category=row['domain_category'],
            organization_name=row['organization_name'],
            irs_system_name=row['irs_system_name'],
            layer=TableLayer(row['layer']),
            fields=fields,
            is_processed=bool(row['is_processed']),
            source_tables=source_tables if source_tables else None,
            processing_logic=row['processing_logic'] if pd.notna(row['processing_logic']) else None,
            create_time=row['create_time'] if pd.notna(row['create_time']) else None,
            update_time=row['update_time'] if pd.notna(row['update_time']) else None
        )
    
    def save_catalog_info(self, catalog_info: CatalogInfo) -> bool:
        """保存编目信息到CSV文件"""
        try:
            catalog_df = self._load_catalog_df()
            table_hash = self.get_table_hash(catalog_info.table_name_en)
            
            # 准备数据行
            import json
            
            # 序列化字段信息
            fields_json = json.dumps([field.dict() for field in catalog_info.fields], ensure_ascii=False)
            
            # 序列化来源表信息
            source_tables_json = ""
            if catalog_info.source_tables:
                source_tables_json = json.dumps([table.dict() for table in catalog_info.source_tables], ensure_ascii=False)
            
            row_data = {
                'table_hash': table_hash,
                'table_name_en': catalog_info.table_name_en,
                'resource_name': catalog_info.resource_name,
                'resource_summary': catalog_info.resource_summary,
                'resource_format': catalog_info.resource_format,
                'domain_category': catalog_info.domain_category.value,
                'organization_name': catalog_info.organization_name,
                'irs_system_name': catalog_info.irs_system_name,
                'layer': catalog_info.layer.value,
                'is_processed': catalog_info.is_processed,
                'source_tables': source_tables_json,
                'processing_logic': catalog_info.processing_logic or "",
                'fields_json': fields_json,
                'create_time': catalog_info.create_time or datetime.now().isoformat(),
                'update_time': datetime.now().isoformat()
            }
            
            # 检查是否已存在记录
            existing_row = catalog_df[catalog_df['table_hash'] == table_hash]
            
            if not existing_row.empty:
                # 更新现有记录
                for col, value in row_data.items():
                    catalog_df.loc[catalog_df['table_hash'] == table_hash, col] = value
            else:
                # 添加新记录
                new_row = pd.DataFrame([row_data])
                catalog_df = pd.concat([catalog_df, new_row], ignore_index=True)
            
            # 保存到文件
            catalog_df.to_csv(self.catalog_file, index=False, encoding='utf-8-sig')
            return True
            
        except Exception as e:
            print(f"保存编目信息失败: {str(e)}")
            return False
    
    def get_source_table_info(self, table_name: str) -> Optional[SourceTableInfo]:
        """根据表名获取来源表信息（用于ETL依赖分析）"""
        table_detail = self.get_table_detail(table_name)
        if table_detail:
            return SourceTableInfo(
                table_name_en=table_name,
                table_name_cn=table_detail.table_name_cn
            )
        return None
    
    def get_etl_info(self, table_name: str) -> Optional[Dict]:
        """获取表的ETL信息"""
        etl_file_path = self.sql_parser.get_etl_file_path(table_name)
        if etl_file_path:
            return self.sql_parser.parse_etl_file(etl_file_path)
        return None 