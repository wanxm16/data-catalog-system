import os
from openai import OpenAI
from typing import Dict, List, Optional
from models.schemas import (
    CatalogInfo, DomainCategory, TableLayer, FieldInfo, SourceTableInfo, 
    CaseAnalysisResponse, AnalysisStep, CaseDecompositionResponse,
    GenerateSQLRequest, GenerateSQLResponse
)
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
    
    def analyze_case(self, case_description: str) -> Optional[CaseAnalysisResponse]:
        """
        分析案件目标并生成分解步骤和SQL
        
        Args:
            case_description: 案件目标描述
            
        Returns:
            CaseAnalysisResponse: 分析结果，包含步骤和SQL
        """
        try:
            print(f"🔍 开始案件分解: {case_description}")
            
            if not self.client:
                error_msg = "OpenAI API Key 未配置，请设置 OPENAI_API_KEY 环境变量"
                print(f"❌ {error_msg}")
                raise Exception(error_msg)
            
            print("✅ OpenAI客户端已就绪")
            
            # 验证API Key格式
            api_key = os.getenv('OPENAI_API_KEY')
            print(f"📋 使用API Key: {api_key[:20]}...")
            
            # 构建案件分解提示词
            prompt = f"""你是一个擅长多步任务分解和结构化SQL生成的大模型办案助手。

请根据以下案件目标描述，自动完成逻辑步骤分解，并针对每个逻辑步骤，生成对应的SQL语句。

【案件目标描述】: {case_description}

【分析要求】：
1. 将案件目标分解为5-8个逻辑步骤
2. 每个步骤应该有清晰的逻辑描述和对应的SQL语句
3. 步骤之间应该有逻辑递进关系
4. SQL中使用伪字段名和伪表名，方便后续做字段替换
5. 时间条件请尽可能用 NOW() 或者 DATE_SUB() 表达
6. 所有字段尽量使用英文名并注释说明含义
7. 不必考虑具体数据库类型，保持语法通用性

请用以下JSON格式返回结果：
{{
  "summary": "案件分析总结，简要说明分析思路和目标",
  "steps": [
    {{
      "step_number": 1,
      "description": "步骤1的逻辑描述",
      "sql": "-- 步骤1对应的SQL代码\\nSELECT..."
    }},
    {{
      "step_number": 2,
      "description": "步骤2的逻辑描述",
      "sql": "-- 步骤2对应的SQL代码\\nSELECT..."
    }}
  ]
}}

【参考示例】：
案件目标：乌鲁木齐疑似高风险偷渡人员

分析步骤示例：
1. 提取乌鲁木齐市常住人口管理中单一民族人员
2. 基于步骤1结果提取最近一个月去过云南省的人员  
3. 基于步骤2结果，关联最近一个月内有二手车交易行为的人员
4. 基于步骤3的结果，提取最近三年有犯罪记录的人员
5. 基于步骤4的结果，标注出人员户籍所属区县

请参考这个示例的分析思路和步骤深度。"""

            print("🤖 正在调用OpenAI API...")
            
            # 调用OpenAI API
            response = self.client.chat.completions.create(
                model="gpt-4o",
                messages=[
                    {"role": "system", "content": "你是一个专业的案件分析助手，擅长将复杂案件目标分解为可执行的分析步骤，并生成对应的SQL查询语句。"},
                    {"role": "user", "content": prompt}
                ],
                temperature=0.3,
                max_tokens=3000
            )
            
            print("✅ OpenAI API调用成功")
            
            ai_response = response.choices[0].message.content
            print(f"📝 AI响应长度: {len(ai_response)} 字符")
            
            # 解析AI返回的JSON
            json_match = re.search(r'\{.*\}', ai_response, re.DOTALL)
            if json_match:
                print("✅ 找到JSON格式响应")
                result = json.loads(json_match.group())
                
                # 构建分析步骤
                steps = []
                if 'steps' in result:
                    for step_data in result['steps']:
                        steps.append(AnalysisStep(
                            step_number=step_data.get('step_number', 0),
                            description=step_data.get('description', ''),
                            sql=step_data.get('sql', '')
                        ))
                
                print(f"✅ 成功解析 {len(steps)} 个分析步骤")
                
                return CaseAnalysisResponse(
                    steps=steps,
                    summary=result.get('summary', '无总结')
                )
            else:
                error_msg = f"AI返回格式错误，无法解析JSON。响应内容: {ai_response[:500]}..."
                print(f"❌ {error_msg}")
                return None
                
        except Exception as e:
            error_msg = f"案件分解失败: {str(e)}"
            print(f"❌ {error_msg}")
            import traceback
            traceback.print_exc()
            return None
    
    def decompose_case_steps(self, case_description: str) -> Optional[CaseDecompositionResponse]:
        """
        分析案件目标并分解为步骤（不生成SQL）
        
        Args:
            case_description: 案件目标描述
            
        Returns:
            CaseDecompositionResponse: 分解的步骤
        """
        try:
            print(f"🔍 开始案件步骤分解: {case_description}")
            
            if not self.client:
                error_msg = "OpenAI API Key 未配置，请设置 OPENAI_API_KEY 环境变量"
                print(f"❌ {error_msg}")
                raise Exception(error_msg)
            
            print("✅ OpenAI客户端已就绪")
            
            # 构建步骤分解提示词
            prompt = f"""你是一个擅长多步任务分解的大模型办案助手。

请根据以下案件目标描述，自动完成逻辑步骤分解。暂时不需要生成SQL。

【案件目标描述】: {case_description}

【分析要求】：
1. 将案件目标分解为5-8个逻辑步骤
2. 每个步骤应该有清晰的逻辑描述
3. 步骤之间应该有逻辑递进关系
4. 步骤描述应该清晰、具体、可执行

请用以下JSON格式返回结果：
{{
  "summary": "案件分析总结，简要说明分析思路和目标",
  "steps": [
    {{
      "step_number": 1,
      "description": "步骤1的逻辑描述"
    }},
    {{
      "step_number": 2,
      "description": "步骤2的逻辑描述"
    }}
  ]
}}

【参考示例】：
案件目标：乌鲁木齐疑似高风险偷渡人员

分析步骤示例：
1. 提取乌鲁木齐市常住人口管理中单一民族人员
2. 基于步骤1结果提取最近一个月去过云南省的人员  
3. 基于步骤2结果，关联最近一个月内有二手车交易行为的人员
4. 基于步骤3的结果，提取最近三年有犯罪记录的人员
5. 基于步骤4的结果，标注出人员户籍所属区县

请参考这个示例的分析思路和步骤深度。"""

            print("🤖 正在调用OpenAI API进行步骤分解...")
            
            # 调用OpenAI API
            response = self.client.chat.completions.create(
                model="gpt-4o",
                messages=[
                    {"role": "system", "content": "你是一个专业的案件分析助手，擅长将复杂案件目标分解为清晰的逻辑步骤。"},
                    {"role": "user", "content": prompt}
                ],
                temperature=0.3,
                max_tokens=2000
            )
            
            print("✅ OpenAI API调用成功")
            
            ai_response = response.choices[0].message.content
            print(f"📝 AI响应长度: {len(ai_response)} 字符")
            
            # 解析AI返回的JSON
            json_match = re.search(r'\{.*\}', ai_response, re.DOTALL)
            if json_match:
                print("✅ 找到JSON格式响应")
                result = json.loads(json_match.group())
                
                # 构建分析步骤（不包含SQL）
                steps = []
                if 'steps' in result:
                    for step_data in result['steps']:
                        steps.append(AnalysisStep(
                            step_number=step_data.get('step_number', 0),
                            description=step_data.get('description', '')
                        ))
                
                # 创建响应对象
                response = CaseDecompositionResponse(
                    steps=steps,
                    summary=result.get('summary', '案件分解分析')
                )
                
                print(f"✅ 步骤分解完成，共{len(steps)}个步骤")
                return response
                
            else:
                error_msg = "未能从AI响应中解析出有效的JSON格式"
                print(f"❌ {error_msg}")
                print(f"原始响应: {ai_response[:500]}...")
                return None
                
        except Exception as e:
            error_msg = f"案件步骤分解失败: {str(e)}"
            print(f"❌ {error_msg}")
            import traceback
            traceback.print_exc()
            return None

    def generate_sql_for_steps(self, steps: List[AnalysisStep]) -> Optional[GenerateSQLResponse]:
        """
        根据用户调整后的步骤生成SQL
        
        Args:
            steps: 用户调整后的步骤列表
            
        Returns:
            GenerateSQLResponse: 包含SQL的完整步骤
        """
        try:
            print(f"🔍 开始为{len(steps)}个步骤生成SQL")
            
            if not self.client:
                error_msg = "OpenAI API Key 未配置，请设置 OPENAI_API_KEY 环境变量"
                print(f"❌ {error_msg}")
                raise Exception(error_msg)
            
            # 构建步骤描述
            steps_description = "\n".join([f"{step.step_number}. {step.description}" for step in steps])
            
            # 构建SQL生成提示词
            prompt = f"""你是一个擅长SQL生成的大模型办案助手。

请根据以下已经确定的逻辑步骤，为每个步骤生成对应的SQL语句。

【已确定的逻辑步骤】：
{steps_description}

【SQL生成要求】：
1. 为每个步骤生成对应的SQL语句
2. SQL中使用伪字段名和伪表名，方便后续做字段替换
3. 时间条件请尽可能用 NOW() 或者 DATE_SUB() 表达
4. 所有字段尽量使用英文名并注释说明含义
5. 不必考虑具体数据库类型，保持语法通用性
6. 步骤之间的SQL应该有逻辑关联，后续步骤可以引用前面步骤的结果

请用以下JSON格式返回结果：
{{
  "summary": "SQL生成总结，简要说明各步骤SQL的关联关系",
  "steps": [
    {{
      "step_number": 1,
      "description": "{steps[0].description if steps else '步骤描述'}",
      "sql": "-- 步骤1对应的SQL代码\\nSELECT..."
    }}
  ]
}}"""

            print("🤖 正在调用OpenAI API生成SQL...")
            
            # 调用OpenAI API
            response = self.client.chat.completions.create(
                model="gpt-4o",
                messages=[
                    {"role": "system", "content": "你是一个专业的SQL生成助手，擅长根据业务逻辑步骤生成对应的SQL查询语句。"},
                    {"role": "user", "content": prompt}
                ],
                temperature=0.3,
                max_tokens=3000
            )
            
            print("✅ OpenAI API调用成功")
            
            ai_response = response.choices[0].message.content
            print(f"📝 AI响应长度: {len(ai_response)} 字符")
            
            # 解析AI返回的JSON
            json_match = re.search(r'\{.*\}', ai_response, re.DOTALL)
            if json_match:
                print("✅ 找到JSON格式响应")
                result = json.loads(json_match.group())
                
                # 构建包含SQL的完整步骤
                sql_steps = []
                if 'steps' in result:
                    for i, step in enumerate(steps):
                        # 找到对应的SQL
                        sql = ""
                        for step_data in result['steps']:
                            if step_data.get('step_number', 0) == step.step_number:
                                sql = step_data.get('sql', '')
                                break
                        
                        sql_steps.append(AnalysisStep(
                            step_number=step.step_number,
                            description=step.description,
                            sql=sql
                        ))
                
                # 创建响应对象
                response = GenerateSQLResponse(
                    steps=sql_steps,
                    summary=result.get('summary', 'SQL生成完成')
                )
                
                print(f"✅ SQL生成完成")
                return response
                
            else:
                error_msg = "未能从AI响应中解析出有效的JSON格式"
                print(f"❌ {error_msg}")
                print(f"原始响应: {ai_response[:500]}...")
                return None
                
        except Exception as e:
            error_msg = f"SQL生成失败: {str(e)}"
            print(f"❌ {error_msg}")
            import traceback
            traceback.print_exc()
            return None
    
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
