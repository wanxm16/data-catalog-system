import React, { useState } from 'react';
import { Card, Input, Button, Steps, Typography, Alert, Spin, message, Row, Col } from 'antd';
import { PlayCircleOutlined, FileTextOutlined } from '@ant-design/icons';
import { ApiService } from '../services/api';
import { AnalysisStep, AnalysisResult } from '../types';

const { TextArea } = Input;
const { Title, Paragraph, Text } = Typography;
const { Step } = Steps;

const CaseAnalysis: React.FC = () => {
  const [loading, setLoading] = useState(false);
  const [caseDescription, setCaseDescription] = useState('');
  const [result, setResult] = useState<AnalysisResult | null>(null);

  const handleAnalyze = async () => {
    if (!caseDescription.trim()) {
      message.warning('请输入案件目标描述');
      return;
    }

    setLoading(true);
    try {
      const response = await ApiService.analyzeCase(caseDescription);
      setResult(response);
      message.success('案件分解完成');
    } catch (error) {
      console.error('案件分解失败:', error);
      message.error('案件分解失败，请重试');
    } finally {
      setLoading(false);
    }
  };

  const handleExample = () => {
    setCaseDescription('乌鲁木齐疑似高风险偷渡人员');
  };

  return (
    <div>
      <Title level={2}>案件分解助手</Title>
      <Paragraph type="secondary">
        基于AI技术，自动将案件目标分解为多个逻辑步骤，并为每个步骤生成对应的SQL查询语句，帮助数据分析人员快速构建分析流程。
      </Paragraph>

      <Row gutter={24}>
        <Col span={24}>
          <Card title="案件目标描述" style={{ marginBottom: 24 }}>
            <TextArea
              placeholder="请描述您的案件分析目标，例如：乌鲁木齐疑似高风险偷渡人员"
              value={caseDescription}
              onChange={(e) => setCaseDescription(e.target.value)}
              rows={4}
              style={{ marginBottom: 16 }}
            />
            <div style={{ display: 'flex', gap: 12 }}>
              <Button 
                type="primary" 
                icon={<PlayCircleOutlined />}
                onClick={handleAnalyze}
                loading={loading}
              >
                开始分解
              </Button>
              <Button 
                icon={<FileTextOutlined />}
                onClick={handleExample}
              >
                使用示例
              </Button>
            </div>
          </Card>
        </Col>
      </Row>

      {loading && (
        <Card>
          <div style={{ textAlign: 'center', padding: '40px 0' }}>
            <Spin size="large" />
            <div style={{ marginTop: 16 }}>
              <Text>正在分析案件目标，生成分解步骤和SQL语句...</Text>
            </div>
          </div>
        </Card>
      )}

      {result && (
        <Row gutter={24}>
          <Col span={24}>
            <Card title="分析结果" style={{ marginBottom: 24 }}>
              {result.summary && (
                <Alert
                  message="分析总结"
                  description={result.summary}
                  type="info"
                  showIcon
                  style={{ marginBottom: 24 }}
                />
              )}

              <Steps direction="vertical" size="small">
                {result.steps.map((step, index) => (
                  <Step
                    key={step.step_number}
                    title={`步骤 ${step.step_number}`}
                    description={
                      <div>
                        <Paragraph style={{ marginBottom: 12 }}>
                          <Text strong>{step.description}</Text>
                        </Paragraph>
                        <Card 
                          size="small" 
                          title="对应SQL" 
                          style={{ background: '#f8f9fa' }}
                        >
                          <pre style={{ 
                            background: '#2d3748',
                            color: '#e2e8f0',
                            padding: '16px',
                            borderRadius: '6px',
                            fontSize: '13px',
                            lineHeight: '1.4',
                            overflow: 'auto'
                          }}>
                            {step.sql}
                          </pre>
                        </Card>
                      </div>
                    }
                    status="finish"
                  />
                ))}
              </Steps>
            </Card>
          </Col>
        </Row>
      )}

      <Card title="使用说明" type="inner">
        <div style={{ fontSize: '14px' }}>
          <h4>📌 功能介绍</h4>
          <ul>
            <li>输入案件分析目标描述</li>
            <li>AI自动分解为多个逻辑步骤</li>
            <li>为每个步骤生成对应的SQL查询语句</li>
            <li>输出结构化的分析结果</li>
          </ul>
          
          <h4>🔍 注意事项</h4>
          <ul>
            <li>SQL中使用伪字段名和伪表名，方便后续字段替换</li>
            <li>时间条件使用 NOW() 或 DATE_SUB() 表达</li>
            <li>字段名使用英文并包含注释说明</li>
            <li>保持SQL语法通用性，不依赖特定数据库类型</li>
          </ul>
        </div>
      </Card>
    </div>
  );
};

export default CaseAnalysis; 