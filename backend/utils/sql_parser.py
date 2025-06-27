import re
import os
import sqlparse
from typing import List, Dict, Tuple, Optional
from models.schemas import FieldInfo, TableLayer, SourceTableInfo

class SQLParser:
    """SQL解析器，用于解析DDL和ETL文件"""
    
    def __init__(self, data_dir: str = "data"):
        self.data_dir = data_dir
        self.ddl_dir = os.path.join(data_dir, "DDL")
        self.etl_dir = os.path.join(data_dir, "ETL")
    
    def get_table_layer(self, table_name: str) -> TableLayer:
        """根据表名前缀判断数据分层"""
        table_name_lower = table_name.lower()
        if table_name_lower.startswith('stg_'):
            return TableLayer.STG
        elif table_name_lower.startswith('ods_'):
            return TableLayer.ODS
        elif table_name_lower.startswith('dwd_'):
            return TableLayer.DWD
        elif table_name_lower.startswith('ads_'):
            return TableLayer.ADS
        else:
            return TableLayer.UNKNOWN
    
    def parse_ddl_file(self, file_path: str) -> Dict:
        """
        解析DDL文件，提取表信息和字段信息
        
        Returns:
            Dict包含: table_name, table_comment, fields, sql_content
        """
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                sql_content = f.read()
            
            # 获取表名（从文件名）
            table_name = os.path.basename(file_path).replace('.sql', '')
            
            # 解析表注释
            table_comment = self._extract_table_comment(sql_content)
            
            # 解析字段信息
            fields = self._extract_fields(sql_content)
            
            return {
                'table_name': table_name,
                'table_comment': table_comment,
                'fields': fields,
                'sql_content': sql_content,
                'layer': self.get_table_layer(table_name)
            }
            
        except Exception as e:
            print(f"解析DDL文件失败 {file_path}: {str(e)}")
            return None
    
    def _extract_table_comment(self, sql_content: str) -> str:
        """提取表注释"""
        # 方法1: 从TBLPROPERTIES中提取（最常见的格式）
        # 匹配: TBLPROPERTIES ('comment'='表注释')
        tbl_props_patterns = [
            r"TBLPROPERTIES\s*\(\s*['\"]comment['\"]=['\"]([^'\"]*)['\"]",
            r"TBLPROPERTIES\s*\(\s*comment=['\"]([^'\"]*)['\"]",
            r"comment['\"]=['\"]([^'\"]*)['\"]"
        ]
        
        for pattern in tbl_props_patterns:
            match = re.search(pattern, sql_content, re.IGNORECASE | re.DOTALL)
            if match:
                comment = match.group(1).strip()
                if comment and comment != "":
                    return comment
        
        # 方法2: 从CREATE TABLE语句后的COMMENT提取
        create_comment_pattern = r"CREATE\s+TABLE[^(]*\([^)]*\)\s*COMMENT\s+['\"]([^'\"]*)['\"]"
        match = re.search(create_comment_pattern, sql_content, re.IGNORECASE | re.DOTALL)
        if match:
            return match.group(1).strip()
        
        # 方法3: 从注释行中提取
        comment_lines = re.findall(r"--\s*(.+)", sql_content)
        for line in comment_lines:
            line = line.strip()
            # 找到包含表描述的注释
            if any(keyword in line for keyword in ['表名：', '功能：', '说明：', '用途：']):
                # 提取冒号后的内容
                if '：' in line:
                    return line.split('：', 1)[1].strip()
                elif ':' in line:
                    return line.split(':', 1)[1].strip()
                else:
                    return line
        
        return "未找到表注释"
    
    def _extract_fields(self, sql_content: str) -> List[FieldInfo]:
        """提取字段信息"""
        fields = []
        
        # 使用正则表达式匹配字段定义
        # 匹配模式: field_name TYPE COMMENT 'comment'
        field_pattern = r"(\w+)\s+(\w+(?:\([^)]*\))?)\s+COMMENT\s+['\"]([^'\"]*)['\"]"
        
        matches = re.findall(field_pattern, sql_content, re.IGNORECASE)
        
        for match in matches:
            field_name, field_type, field_comment = match
            
            # 过滤掉CREATE、TABLE等关键字
            if field_name.upper() in ['CREATE', 'TABLE', 'IF', 'NOT', 'EXISTS']:
                continue
                
            fields.append(FieldInfo(
                field_name_en=field_name,
                field_name_cn=field_comment,
                field_type=field_type,
                is_nullable=True  # 默认可空
            ))
        
        return fields
    
    def parse_etl_file(self, file_path: str) -> Dict:
        """
        解析ETL文件，提取依赖表和加工逻辑
        
        Returns:
            Dict包含: table_name, source_tables, processing_logic, sql_content
        """
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                sql_content = f.read()
            
            # 获取表名
            table_name = os.path.basename(file_path).replace('.sql', '')
            
            # 提取依赖表
            source_tables = self._extract_source_tables(sql_content)
            
            # 提取加工逻辑
            processing_logic = self._extract_processing_logic(sql_content)
            
            return {
                'table_name': table_name,
                'source_tables': source_tables,
                'processing_logic': processing_logic,
                'sql_content': sql_content
            }
            
        except Exception as e:
            print(f"解析ETL文件失败 {file_path}: {str(e)}")
            return None
    
    def _extract_source_tables(self, sql_content: str) -> List[str]:
        """提取SQL中的依赖表名"""
        source_tables = []
        
        # 使用sqlparse解析SQL
        try:
            parsed = sqlparse.parse(sql_content)[0]
            tokens = [token for token in parsed.flatten() if token.ttype is None]
            
            from_found = False
            join_found = False
            
            for i, token in enumerate(tokens):
                token_upper = str(token).upper().strip()
                
                # 检测FROM子句
                if token_upper == 'FROM':
                    from_found = True
                    continue
                elif token_upper in ('JOIN', 'LEFT JOIN', 'RIGHT JOIN', 'INNER JOIN', 'OUTER JOIN'):
                    join_found = True
                    continue
                
                # 如果在FROM或JOIN之后，获取表名
                if (from_found or join_found) and token_upper not in ('LEFT', 'RIGHT', 'INNER', 'OUTER', 'ON', 'WHERE'):
                    # 过滤SQL关键字和标点符号
                    if (len(token_upper) > 2 and 
                        not token_upper.startswith('(') and 
                        not token_upper.endswith(')') and
                        token_upper not in ('SELECT', 'WHERE', 'GROUP', 'ORDER', 'HAVING')):
                        
                        # 清理表名（去除别名）
                        table_name = token_upper.split()[0].strip(',')
                        if table_name and table_name not in source_tables:
                            source_tables.append(table_name.lower())
                    
                    from_found = False
                    join_found = False
        
        except Exception as e:
            # 如果sqlparse失败，使用正则表达式
            source_tables = self._extract_tables_with_regex(sql_content)
        
        return source_tables
    
    def _extract_tables_with_regex(self, sql_content: str) -> List[str]:
        """使用正则表达式提取表名"""
        source_tables = []
        
        # FROM table_name
        from_pattern = r"FROM\s+(\w+)"
        matches = re.findall(from_pattern, sql_content, re.IGNORECASE)
        source_tables.extend([match.lower() for match in matches])
        
        # JOIN table_name
        join_pattern = r"JOIN\s+(\w+)"
        matches = re.findall(join_pattern, sql_content, re.IGNORECASE)
        source_tables.extend([match.lower() for match in matches])
        
        return list(set(source_tables))  # 去重
    
    def _extract_processing_logic(self, sql_content: str) -> str:
        """提取加工逻辑描述"""
        # 从注释中提取业务逻辑说明
        comment_lines = re.findall(r"--\s*(.+)", sql_content)
        
        logic_keywords = ['功能', '逻辑', '说明', '业务', '加工', '处理']
        logic_descriptions = []
        
        for line in comment_lines:
            if any(keyword in line for keyword in logic_keywords):
                logic_descriptions.append(line.strip())
        
        if logic_descriptions:
            return '; '.join(logic_descriptions)
        
        # 如果没有找到注释说明，分析SQL结构
        sql_upper = sql_content.upper()
        
        logic_parts = []
        
        if 'JOIN' in sql_upper:
            logic_parts.append("多表关联")
        if 'GROUP BY' in sql_upper:
            logic_parts.append("数据聚合")
        if 'WHERE' in sql_upper:
            logic_parts.append("数据过滤")
        if 'CASE WHEN' in sql_upper:
            logic_parts.append("条件转换")
        if 'SUM(' in sql_upper or 'COUNT(' in sql_upper or 'AVG(' in sql_upper:
            logic_parts.append("统计计算")
        
        return "、".join(logic_parts) if logic_parts else "数据加工处理"
    
    def get_all_ddl_files(self) -> List[str]:
        """获取所有DDL文件路径"""
        ddl_files = []
        if os.path.exists(self.ddl_dir):
            for file in os.listdir(self.ddl_dir):
                if file.endswith('.sql'):
                    ddl_files.append(os.path.join(self.ddl_dir, file))
        return ddl_files
    
    def get_etl_file_path(self, table_name: str) -> Optional[str]:
        """根据表名查找对应的ETL文件"""
        # 在各个ETL子目录中查找
        for root, dirs, files in os.walk(self.etl_dir):
            for file in files:
                if file == f"{table_name}.sql":
                    return os.path.join(root, file)
        return None
    
    def has_etl_file(self, table_name: str) -> bool:
        """检查表是否有对应的ETL文件"""
        return self.get_etl_file_path(table_name) is not None 