import pandas as pd
import json
import os
from typing import Dict, List, Any, Optional
import openai
from dotenv import load_dotenv
import matplotlib.pyplot as plt
import seaborn as sns
import io
import base64
from datetime import datetime

load_dotenv()

class ChatBIService:
    def __init__(self):
        self.client = openai.OpenAI(api_key=os.getenv('OPENAI_API_KEY'))
        # 使用绝对路径，从services目录向上找到项目根目录
        service_dir = os.path.dirname(os.path.abspath(__file__))
        project_root = os.path.dirname(service_dir)  # backend目录
        project_root = os.path.dirname(project_root)  # 项目根目录
        self.data_dir = os.path.join(project_root, "data", "BI")
        self.available_files = self._scan_data_files()
        
        # 设置中文字体
        plt.rcParams['font.sans-serif'] = ['SimHei', 'Arial Unicode MS', 'DejaVu Sans']
        plt.rcParams['axes.unicode_minus'] = False
        
    def _scan_data_files(self) -> List[Dict[str, Any]]:
        """扫描数据目录下的CSV文件"""
        files = []
        data_path = self.data_dir
        
        if not os.path.exists(data_path):
            return files
            
        for filename in os.listdir(data_path):
            if filename.endswith('.csv'):
                try:
                    file_path = os.path.join(data_path, filename)
                    # 先尝试读取文件获取基本信息
                    df = pd.read_csv(file_path, nrows=5)
                    
                    files.append({
                        'filename': filename,
                        'display_name': filename.replace('.csv', ''),
                        'rows': len(pd.read_csv(file_path)),
                        'columns': len(df.columns),
                        'size': os.path.getsize(file_path)
                    })
                except Exception as e:
                    print(f"读取文件 {filename} 时出错: {e}")
                    
        return files
    
    def get_available_files(self) -> List[Dict[str, Any]]:
        """获取可用的数据文件列表"""
        return self.available_files
    
    def _load_data_with_proper_columns(self, filename: str) -> pd.DataFrame:
        """加载数据并修复列名"""
        file_path = os.path.join(self.data_dir, filename)
        
        if filename == "销售数据集.csv":
            # 为销售数据定义正确的列名
            df = pd.read_csv(file_path)
            df.columns = ['ID', '日期', '性别', '年龄', '品类', '数量', '单价', '总金额']
            
            # 数据类型转换
            df['日期'] = pd.to_datetime(df['日期'], format='%d/%m/%y')
            df['年龄'] = pd.to_numeric(df['年龄'])
            df['数量'] = pd.to_numeric(df['数量'])
            df['单价'] = pd.to_numeric(df['单价'])
            df['总金额'] = pd.to_numeric(df['总金额'])
            
        elif filename == "犯罪数据.csv":
            # 为犯罪数据定义正确的列名
            df = pd.read_csv(file_path)
            df.columns = ['案件状态', '处理结果', '嫌疑人种族', '嫌疑人性别', '嫌疑人年龄', 
                         '受害者性别', '受害者年龄', '案件严重程度', '案件类型', '犯罪类别',
                         '发生时间', '备注']
        else:
            # 对于其他文件，保持原样
            df = pd.read_csv(file_path)
            
        return df
    
    def analyze_data(self, filename: str, question: str) -> Dict[str, Any]:
        """分析数据并回答问题"""
        try:
            # 加载数据
            df = self._load_data_with_proper_columns(filename)
            
            # 生成数据概览
            data_summary = self._generate_data_summary(df)
            
            # 使用AI分析问题
            analysis_result = self._analyze_with_ai(df, question, data_summary)
            
            return {
                'success': True,
                'data': analysis_result,
                'dataset_info': {
                    'filename': filename,
                    'rows': len(df),
                    'columns': list(df.columns)
                }
            }
            
        except Exception as e:
            return {
                'success': False,
                'error': str(e)
            }
    
    def _generate_data_summary(self, df: pd.DataFrame) -> str:
        """生成数据概览"""
        summary = f"数据集包含 {len(df)} 行数据，{len(df.columns)} 个字段。\n\n"
        summary += "字段信息：\n"
        
        for col in df.columns:
            dtype = str(df[col].dtype)
            non_null_count = df[col].count()
            
            if df[col].dtype in ['object']:
                unique_values = df[col].nunique()
                sample_values = df[col].dropna().unique()[:5].tolist()
                summary += f"- {col}: 文本类型，{non_null_count} 个非空值，{unique_values} 个唯一值"
                if sample_values:
                    summary += f"，示例值: {sample_values}"
                summary += "\n"
            elif df[col].dtype in ['int64', 'float64']:
                min_val = df[col].min()
                max_val = df[col].max()
                mean_val = df[col].mean()
                summary += f"- {col}: 数值类型，{non_null_count} 个非空值，范围: {min_val:.2f} - {max_val:.2f}，平均值: {mean_val:.2f}\n"
            else:
                summary += f"- {col}: {dtype} 类型，{non_null_count} 个非空值\n"
                
        return summary
    
    def _analyze_with_ai(self, df: pd.DataFrame, question: str, data_summary: str) -> Dict[str, Any]:
        """使用AI分析数据"""
        
        # 构建提示词
        prompt = f"""
你是一个数据分析专家。请根据以下数据集回答用户的问题。

数据集信息：
{data_summary}

用户问题：{question}

请根据数据集的实际情况回答问题。如果需要计算或统计，请提供具体的数值结果。
如果问题涉及比较、排序、分组等操作，请提供详细的分析结果。

请按以下格式回答：
1. 分析方法：说明你将如何分析这个问题
2. 计算过程：如果需要计算，说明计算步骤
3. 结果：提供具体的数据结果
4. 可视化建议：建议用什么类型的图表展示结果（柱状图、饼图、折线图等）

如果数据集中没有相关数据来回答这个问题，请明确说明。
"""

        try:
            response = self.client.chat.completions.create(
                model="gpt-4o",
                messages=[
                    {"role": "system", "content": "你是一个专业的数据分析师，擅长分析数据并提供准确的统计结果。"},
                    {"role": "user", "content": prompt}
                ],
                temperature=0.1
            )
            
            ai_analysis = response.choices[0].message.content
            
            # 尝试执行实际的数据分析
            actual_result = self._execute_analysis(df, question)
            
            # 尝试生成可视化
            chart_data = self._generate_visualization(df, question, actual_result)
            
            return {
                'ai_analysis': ai_analysis,
                'actual_result': actual_result,
                'chart': chart_data,
                'question': question
            }
            
        except Exception as e:
            return {
                'ai_analysis': f"AI分析时出错: {str(e)}",
                'actual_result': None,
                'chart': None,
                'question': question
            }
    
    def _execute_analysis(self, df: pd.DataFrame, question: str) -> Optional[Dict[str, Any]]:
        """执行实际的数据分析"""
        try:
            question_lower = question.lower()
            
            # 销售数据相关分析
            if '销售' in question or '消费' in question:
                if '男女' in question and ('对比' in question or '比较' in question):
                    # 男女消费金额对比
                    result = df.groupby('性别')['总金额'].agg(['sum', 'mean', 'count']).to_dict()
                    return {
                        'type': 'gender_comparison',
                        'data': result,
                        'description': '男女消费金额对比分析'
                    }
                
                elif '女性' in question and '品类' in question:
                    # 女性在不同品类中的消费分布
                    female_data = df[df['性别'] == 'Female']
                    result = female_data.groupby('品类')['总金额'].sum().to_dict()
                    return {
                        'type': 'female_category_distribution',
                        'data': result,
                        'description': '女性在不同品类中的消费金额分布'
                    }
                
                elif '最高' in question and '品类' in question:
                    # 消费金额最高的品类
                    result = df.groupby('品类')['总金额'].sum().sort_values(ascending=False).head(5).to_dict()
                    return {
                        'type': 'top_categories',
                        'data': result,
                        'description': '消费金额最高的5个品类'
                    }
            
            # 犯罪数据相关分析
            elif '案件' in question or '犯罪' in question or 'closed' in question_lower or 'open' in question_lower or '嫌疑人' in question or '受害者' in question:
                if ('closed' in question_lower and 'open' in question_lower) or ('案件' in question and ('状态' in question or '数量' in question)):
                    # 案件状态分布分析
                    if '案件状态' in df.columns:
                        result = df['案件状态'].value_counts().to_dict()
                        return {
                            'type': 'case_status_distribution',
                            'data': result,
                            'description': 'Closed与Open案件数量对比'
                        }
                
                elif '性别' in question and ('嫌疑人' in question or '分布' in question):
                    # 嫌疑人性别分布
                    if '嫌疑人性别' in df.columns:
                        result = df['嫌疑人性别'].value_counts().to_dict()
                        return {
                            'type': 'suspect_gender_distribution',
                            'data': result,
                            'description': '嫌疑人性别分布'
                        }
                
                elif '年龄' in question and ('分布' in question or '统计' in question):
                    # 嫌疑人年龄分布
                    if '嫌疑人年龄' in df.columns:
                        # 按年龄段分组
                        df['年龄段'] = pd.cut(df['嫌疑人年龄'], bins=[0, 18, 30, 45, 60, 100], labels=['未成年', '青年', '中年', '中老年', '老年'])
                        result = df['年龄段'].value_counts().to_dict()
                        return {
                            'type': 'age_distribution',
                            'data': result,
                            'description': '嫌疑人年龄段分布'
                        }
                
                elif '类型' in question or '类别' in question:
                    # 犯罪类型分布
                    if '犯罪类别' in df.columns:
                        result = df['犯罪类别'].value_counts().head(10).to_dict()
                        return {
                            'type': 'crime_type_distribution',
                            'data': result,
                            'description': '主要犯罪类型分布(前10名)'
                        }
            
            # 通用统计分析
            if '统计' in question or '分布' in question:
                numeric_cols = df.select_dtypes(include=['int64', 'float64']).columns
                if len(numeric_cols) > 0:
                    result = df[numeric_cols].describe().to_dict()
                    return {
                        'type': 'statistics',
                        'data': result,
                        'description': '数值字段统计信息'
                    }
            
            return None
            
        except Exception as e:
            print(f"执行分析时出错: {e}")
            return None
    
    def _generate_visualization(self, df: pd.DataFrame, question: str, analysis_result: Optional[Dict]) -> Optional[Dict]:
        """生成可视化图表"""
        if not analysis_result or not analysis_result.get('data'):
            return None
            
        try:
            plt.figure(figsize=(8, 5))
            
            if analysis_result['type'] == 'gender_comparison':
                # 男女消费对比柱状图
                data = analysis_result['data']['sum']
                genders = list(data.keys())
                amounts = list(data.values())
                
                plt.bar(genders, amounts, color=['skyblue', 'pink'])
                plt.title('男女消费金额对比')
                plt.xlabel('性别')
                plt.ylabel('总消费金额')
                plt.grid(axis='y', alpha=0.3)
                
            elif analysis_result['type'] == 'female_category_distribution':
                # 女性品类消费饼图
                data = analysis_result['data']
                categories = list(data.keys())
                amounts = list(data.values())
                
                plt.pie(amounts, labels=categories, autopct='%1.1f%%', startangle=90)
                plt.title('女性在不同品类中的消费分布')
                
            elif analysis_result['type'] == 'top_categories':
                # 最高消费品类柱状图
                data = analysis_result['data']
                categories = list(data.keys())
                amounts = list(data.values())
                
                plt.bar(categories, amounts, color='lightcoral')
                plt.title('消费金额最高的5个品类')
                plt.xlabel('品类')
                plt.ylabel('总消费金额')
                plt.xticks(rotation=45)
                plt.grid(axis='y', alpha=0.3)
                
            elif analysis_result['type'] == 'case_status_distribution':
                # 案件状态分布柱状图
                data = analysis_result['data']
                statuses = list(data.keys())
                counts = list(data.values())
                
                colors = ['#FF6B6B', '#4ECDC4', '#45B7D1', '#96CEB4']
                plt.bar(statuses, counts, color=colors[:len(statuses)])
                plt.title('案件状态分布')
                plt.xlabel('案件状态')
                plt.ylabel('案件数量')
                plt.grid(axis='y', alpha=0.3)
                
            elif analysis_result['type'] == 'suspect_gender_distribution':
                # 嫌疑人性别分布饼图
                data = analysis_result['data']
                genders = list(data.keys())
                counts = list(data.values())
                
                colors = ['#FF9999', '#66B2FF', '#99FF99', '#FFCC99']
                plt.pie(counts, labels=genders, autopct='%1.1f%%', startangle=90, colors=colors[:len(genders)])
                plt.title('嫌疑人性别分布')
                
            elif analysis_result['type'] == 'age_distribution':
                # 年龄段分布柱状图
                data = analysis_result['data']
                age_groups = list(data.keys())
                counts = list(data.values())
                
                plt.bar(age_groups, counts, color='lightblue')
                plt.title('嫌疑人年龄段分布')
                plt.xlabel('年龄段')
                plt.ylabel('人数')
                plt.xticks(rotation=45)
                plt.grid(axis='y', alpha=0.3)
                
            elif analysis_result['type'] == 'crime_type_distribution':
                # 犯罪类型分布横向柱状图
                data = analysis_result['data']
                crime_types = list(data.keys())
                counts = list(data.values())
                
                plt.barh(crime_types, counts, color='lightgreen')
                plt.title('主要犯罪类型分布')
                plt.xlabel('案件数量')
                plt.ylabel('犯罪类型')
                plt.grid(axis='x', alpha=0.3)
            
            # 保存图表为base64
            buffer = io.BytesIO()
            plt.tight_layout()
            plt.savefig(buffer, format='png', dpi=300, bbox_inches='tight')
            buffer.seek(0)
            
            # 转换为base64字符串
            chart_base64 = base64.b64encode(buffer.getvalue()).decode()
            plt.close()
            
            return {
                'type': 'image',
                'data': f"data:image/png;base64,{chart_base64}",
                'description': analysis_result['description']
            }
            
        except Exception as e:
            print(f"生成可视化时出错: {e}")
            plt.close()
            return None 