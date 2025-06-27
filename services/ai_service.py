import os
from openai import OpenAI
from typing import Dict, List, Optional
from models.schemas import CatalogInfo, DomainCategory, TableLayer, FieldInfo, SourceTableInfo
from services.table_service import TableService
import json
import re

class AIService:
    """AI服务类，负责自动生成编目信息"""
    
    def __init__(self):
        # 从环境变量读取OpenAI API Key
        self.openai_api_key = os.getenv('OPENAI_API_KEY')
        if not self.openai_api_key:
            print("警告: OPENAI_API_KEY 环境变量未设置，AI编目功能将不可用")
            print("请参考 env_template.txt 文件配置 OpenAI API Key")
            self.client = None
        else:
            self.client = OpenAI(api_key=self.openai_api_key)
        
        self.table_service = TableService()
    
    def parse_etl_script(self, etl_file_path: str) -> Optional[Dict]:
        """
        使用LLM解析ETL脚本，获取来源表信息和业务逻辑描述
        
        Args:
            etl_file_path: ETL脚本文件路径
            
        Returns:
            Dict包含: source_tables_info, business_logic
        """
        try:
            if not self.client:
                raise Exception("OpenAI API Key 未配置")
            
            # 读取ETL脚本内容
            with open(etl_file_path, 'r', encoding='utf-8') as f:
                etl_content = f.read()
            
            # 构建ETL解析提示词
            prompt = f"""你是个数据治理专家，这个 ETL脚本描述的是公共数据的加工过程，请你仔细阅读这个脚本信息，告诉我
1. 来源表信息，我需要表中文名和表英文名
2. 请从业务人员容易理解的方式，讲述一下这个脚本的加工逻辑，以及加工后的表的作用

ETL脚本内容：
{etl_content}

请用以下JSON格式返回结果：
{{
  "source_tables": [
    {{
      "table_name_en": "来源表英文名",
      "table_name_cn": "来源表中文名或业务描述"
    }}
  ],
  "business_logic": "详细的业务逻辑描述，说明这个脚本的加工过程和加工后表的作用"
}}

注意：
1. 来源表的中文名请根据表名和业务上下文进行合理推测
2. 业务逻辑描述要通俗易懂，避免技术术语，便于业务人员理解
3. 重点说明数据的来源、加工过程和最终用途"""

            # 调用OpenAI API解析ETL
            response = self.client.chat.completions.create(
                model="gpt-4o",
                messages=[
                    {"role": "system", "content": "你是一个数据治理专家，擅长分析ETL脚本并提取业务逻辑。"},
                    {"role": "user", "content": prompt}
                ],
                temperature=0.2,
                max_tokens=1500
            )
            
            ai_response = response.choices[0].message.content
            
            # 解析AI返回的JSON
            json_match = re.search(r'\{.*\}', ai_response, re.DOTALL)
            if json_match:
                result = json.loads(json_match.group())
                return result
            else:
                print(f"AI返回格式错误，无法解析JSON: {ai_response}")
                return None
                
        except Exception as e:
            print(f"ETL脚本解析失败: {str(e)}")
            return None

    def generate_catalog_info(self, table_name: str) -> Optional[CatalogInfo]:
        """
        根据表名自动生成编目信息
        
        Args:
            table_name: 表名
            
        Returns:
            CatalogInfo: 生成的编目信息
        """
        try:
            # 检查API Key是否可用
            if not self.client:
                raise Exception("OpenAI API Key 未配置，请设置 OPENAI_API_KEY 环境变量")
            
            # 获取表的详细信息
            table_detail = self.table_service.get_table_detail(table_name)
            if not table_detail:
                raise Exception(f"表 {table_name} 不存在或无法解析")
            
            # 获取ETL信息（如果存在）
            etl_info = None
            etl_file_path = self.table_service.sql_parser.get_etl_file_path(table_name)
            if etl_file_path:
                # 使用LLM解析ETL脚本
                etl_info = self.parse_etl_script(etl_file_path)
            
            # 构建提示词
            prompt = self._build_analysis_prompt(table_detail, etl_info)
            
            # 调用OpenAI API
            response = self.client.chat.completions.create(
                model="gpt-4o",
                messages=[
                    {"role": "system", "content": "你是一个数据治理专家，擅长分析数据表结构并生成编目信息。请根据提供的表结构信息，生成合适的编目元数据。"},
                    {"role": "user", "content": prompt}
                ],
                temperature=0.3,
                max_tokens=2000
            )
            
            # 解析AI响应
            ai_analysis = response.choices[0].message.content
            
            # 构建编目信息
            catalog_info = self._build_catalog_info(table_detail, etl_info, ai_analysis)
            
            return catalog_info
            
        except Exception as e:
            error_msg = str(e)
            if "OpenAI API Key" in error_msg:
                print(f"AI编目功能需要配置API Key: {error_msg}")
            elif "表" in error_msg and "不存在" in error_msg:
                print(f"表解析失败: {error_msg}")
            else:
                print(f"AI生成编目信息失败: {error_msg}")
            return None
    
    def _build_analysis_prompt(self, table_detail, etl_info) -> str:
        """构建AI分析提示词"""
        prompt = f"""
请分析以下数据表的结构信息，并生成编目元数据：

表名: {table_detail.table_name_en}
表注释: {table_detail.table_name_cn}
数据分层: {table_detail.layer.value}

字段信息:
"""
        
        for field in table_detail.fields:
            prompt += f"- {field.field_name_en} ({field.field_type}): {field.field_name_cn}\n"
        
        if etl_info:
            prompt += f"\n加工信息:\n"
            prompt += f"- 是否为加工表: 是\n"
            if etl_info.get('source_tables'):
                prompt += f"- 来源表信息:\n"
                for source_table in etl_info['source_tables']:
                    prompt += f"  * {source_table['table_name_en']}: {source_table['table_name_cn']}\n"
            prompt += f"- 业务逻辑: {etl_info.get('business_logic', '未知')}\n"
        else:
            prompt += f"\n加工信息:\n- 是否为加工表: 否\n"
        
        prompt += """

请根据以上信息，分析并返回以下内容（用JSON格式）：

{
  "resource_summary": "一句话概括表的功能和用途",
  "domain_category": "选择合适的领域分类: 企业监管|人口管理|地理信息|金融监管|医疗卫生|教育管理|交通运输|环境保护|农业农村|司法执法|其他",
  "organization_name": "根据表名和字段推断所属的局委办名称",
  "irs_system_name": "推断所属的业务系统名称"
}

分析要点:
1. 根据表名前缀(ads/dwd/ods/stg)确定数据分层
2. 根据字段内容判断业务领域
3. 根据表名和字段推断政府部门归属
4. 生成简洁准确的表功能描述
"""
        
        return prompt
    
    def _build_catalog_info(self, table_detail, etl_info, ai_analysis: str) -> CatalogInfo:
        """根据AI分析结果构建编目信息"""
        # 尝试从AI响应中提取JSON
        try:
            # 查找JSON部分
            json_match = re.search(r'\{.*\}', ai_analysis, re.DOTALL)
            if json_match:
                ai_data = json.loads(json_match.group())
            else:
                ai_data = {}
        except:
            ai_data = {}
        
        # 处理来源表信息
        source_tables = None
        if etl_info and etl_info.get('source_tables'):
            source_tables = []
            for source_table_info in etl_info['source_tables']:
                source_tables.append(SourceTableInfo(
                    table_name_en=source_table_info['table_name_en'],
                    table_name_cn=source_table_info['table_name_cn']
                ))
        
        # 处理领域分类
        domain_category = DomainCategory.OTHER
        if 'domain_category' in ai_data:
            category_mapping = {
                "企业监管": DomainCategory.ENTERPRISE,
                "人口管理": DomainCategory.POPULATION,
                "地理信息": DomainCategory.GEOGRAPHIC,
                "金融监管": DomainCategory.FINANCIAL,
                "医疗卫生": DomainCategory.HEALTH,
                "教育管理": DomainCategory.EDUCATION,
                "交通运输": DomainCategory.TRANSPORTATION,
                "环境保护": DomainCategory.ENVIRONMENT,
                "农业农村": DomainCategory.AGRICULTURE,
                "司法执法": DomainCategory.JUSTICE
            }
            domain_category = category_mapping.get(ai_data['domain_category'], DomainCategory.OTHER)
        
        return CatalogInfo(
            table_name_en=table_detail.table_name_en,
            resource_name=table_detail.table_name_cn,
            resource_summary=ai_data.get('resource_summary', f"{table_detail.table_name_cn}相关数据表"),
            resource_format="table",
            domain_category=domain_category,
            organization_name=ai_data.get('organization_name', "未知机构"),
            irs_system_name=ai_data.get('irs_system_name', "业务系统"),
            layer=table_detail.layer,
            fields=table_detail.fields,
            is_processed=etl_info is not None,
            source_tables=source_tables,
            processing_logic=etl_info.get('business_logic') if etl_info else None
        )
    
    def enhance_catalog_summary(self, catalog_info: CatalogInfo) -> str:
        """使用AI增强编目摘要"""
        try:
            prompt = f"""
请为以下数据表生成一个更好的功能摘要：

表名: {catalog_info.table_name_en}
当前摘要: {catalog_info.resource_summary}
领域分类: {catalog_info.domain_category.value}
组织机构: {catalog_info.organization_name}

字段信息:
"""
            
            for field in catalog_info.fields[:10]:  # 只显示前10个字段
                prompt += f"- {field.field_name_en}: {field.field_name_cn}\n"
            
            if catalog_info.is_processed and catalog_info.processing_logic:
                prompt += f"\n业务逻辑: {catalog_info.processing_logic}"
            
            prompt += "\n\n请生成一个简洁、准确、专业的表功能摘要（不超过50字）："
            
            response = self.client.chat.completions.create(
                model="gpt-4o",
                messages=[
                    {"role": "user", "content": prompt}
                ],
                temperature=0.2,
                max_tokens=100
            )
            
            return response.choices[0].message.content.strip()
            
        except Exception as e:
            print(f"AI增强摘要失败: {str(e)}")
            return catalog_info.resource_summary 