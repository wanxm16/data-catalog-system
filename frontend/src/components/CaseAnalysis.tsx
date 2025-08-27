import React, { useState } from 'react';
import { Card, Input, Button, Steps, Typography, Alert, Spin, message, Row, Col, Space, Modal, Form, Popconfirm, List } from 'antd';
import { PlayCircleOutlined, FileTextOutlined, EditOutlined, DeleteOutlined, PlusOutlined, CheckOutlined, CodeOutlined } from '@ant-design/icons';
import { ApiService } from '../services/api';
import { AnalysisStep, AnalysisResult } from '../types';

const { TextArea } = Input;
const { Title, Paragraph, Text } = Typography;
const { Step } = Steps;

interface EditableStep {
  step_number: number;
  description: string;
  sql?: string;
  isEditing?: boolean;
}

const CaseAnalysis: React.FC = () => {
  const [loading, setLoading] = useState(false);
  const [caseDescription, setCaseDescription] = useState('');
  const [steps, setSteps] = useState<EditableStep[]>([]);
  const [editingStep, setEditingStep] = useState<number | null>(null);
  const [editingText, setEditingText] = useState('');
  const [showAddStep, setShowAddStep] = useState(false);
  const [newStepText, setNewStepText] = useState('');
  const [summary, setSummary] = useState('');
  const [sqlGenerated, setSqlGenerated] = useState(false);
  const [stage, setStage] = useState<'input' | 'steps' | 'result'>('input');

  // 第一步：分解案件步骤（不生成SQL）
  const handleDecomposeSteps = async () => {
    if (!caseDescription.trim()) {
      message.warning('请输入案件目标描述');
      return;
    }

    setLoading(true);
    try {
      const response = await ApiService.decomposeCase(caseDescription);
      if (response.success && response.data) {
        const decomposedSteps = response.data.steps.map((step: AnalysisStep) => ({
          ...step,
          isEditing: false
        }));
        setSteps(decomposedSteps);
        setSummary(response.data.summary || '');
        setStage('steps');
        setSqlGenerated(false);
        message.success('案件步骤分解完成，您可以编辑步骤');
      } else {
        message.error(response.message || '案件步骤分解失败');
      }
    } catch (error) {
      console.error('案件步骤分解失败:', error);
      message.error('案件步骤分解失败，请重试');
    } finally {
      setLoading(false);
    }
  };

  // 第二步：为调整后的步骤生成SQL
  const handleGenerateSQL = async () => {
    setLoading(true);
    try {
      const stepsToGenerate = steps.map(({ step_number, description }) => ({
        step_number,
        description
        // sql字段现在是可选的，不需要传递
      }));
      
      const response = await ApiService.generateSQL(stepsToGenerate);
      if (response.success && response.data) {
        const stepsWithSQL = response.data.steps.map((step: AnalysisStep) => ({
          ...step,
          isEditing: false
        }));
        setSteps(stepsWithSQL);
        setSummary(response.data.summary || '');
        setSqlGenerated(true);
        setStage('result');
        message.success('SQL生成完成');
      } else {
        message.error(response.message || 'SQL生成失败');
      }
    } catch (error) {
      console.error('SQL生成失败:', error);
      message.error('SQL生成失败，请重试');
    } finally {
      setLoading(false);
    }
  };

  // 编辑步骤
  const handleEditStep = (stepNumber: number) => {
    const step = steps.find(s => s.step_number === stepNumber);
    if (step) {
      setEditingStep(stepNumber);
      setEditingText(step.description);
    }
  };

  // 保存编辑
  const handleSaveEdit = () => {
    if (editingStep !== null && editingText.trim()) {
      setSteps(steps.map(step => 
        step.step_number === editingStep 
          ? { ...step, description: editingText }
          : step
      ));
      setEditingStep(null);
      setEditingText('');
      message.success('步骤已更新');
    }
  };

  // 取消编辑
  const handleCancelEdit = () => {
    setEditingStep(null);
    setEditingText('');
  };

  // 删除步骤
  const handleDeleteStep = (stepNumber: number) => {
    const newSteps = steps
      .filter(step => step.step_number !== stepNumber)
      .map((step, index) => ({ ...step, step_number: index + 1 }));
    setSteps(newSteps);
    message.success('步骤已删除');
  };

  // 添加新步骤
  const handleAddStep = () => {
    if (newStepText.trim()) {
      const newStep: EditableStep = {
        step_number: steps.length + 1,
        description: newStepText,
        isEditing: false
      };
      setSteps([...steps, newStep]);
      setNewStepText('');
      setShowAddStep(false);
      message.success('步骤已添加');
    }
  };

  // 重新开始
  const handleRestart = () => {
    setCaseDescription('');
    setSteps([]);
    setSummary('');
    setSqlGenerated(false);
    setStage('input');
  };

  const handleExample = () => {
    setCaseDescription('乌鲁木齐疑似高风险偷渡人员');
  };

  return (
    <div>
      <Title level={2}>案件分解助手</Title>
      <Paragraph type="secondary">
        基于AI技术，分步骤进行案件分解：先分解为逻辑步骤，支持人工调整，然后生成对应的SQL查询语句。
      </Paragraph>

      {/* 阶段1：输入案件描述 */}
      {stage === 'input' && (
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
                  onClick={handleDecomposeSteps}
                  loading={loading}
                >
                  分解步骤
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
      )}

      {/* 阶段2：编辑步骤 */}
      {stage === 'steps' && !sqlGenerated && (
        <Row gutter={24}>
          <Col span={24}>
            <Card 
              title="步骤编辑" 
              extra={
                <Space>
                  <Button onClick={handleRestart}>重新开始</Button>
                  <Button 
                    type="primary" 
                    icon={<CodeOutlined />}
                    onClick={handleGenerateSQL}
                    loading={loading}
                  >
                    生成SQL
                  </Button>
                </Space>
              }
              style={{ marginBottom: 24 }}
            >
              {summary && (
                <Alert
                  message="分析总结"
                  description={summary}
                  type="info"
                  showIcon
                  style={{ marginBottom: 24 }}
                />
              )}

              <List
                dataSource={steps}
                renderItem={(step) => (
                  <List.Item
                    actions={
                      editingStep === step.step_number ? [
                        <Button 
                          type="primary" 
                          size="small" 
                          icon={<CheckOutlined />}
                          onClick={handleSaveEdit}
                        >
                          保存
                        </Button>,
                        <Button 
                          size="small"
                          onClick={handleCancelEdit}
                        >
                          取消
                        </Button>
                      ] : [
                        <Button 
                          type="text" 
                          icon={<EditOutlined />}
                          onClick={() => handleEditStep(step.step_number)}
                        >
                          编辑
                        </Button>,
                        <Popconfirm
                          title="确定删除这个步骤吗？"
                          onConfirm={() => handleDeleteStep(step.step_number)}
                        >
                          <Button 
                            type="text" 
                            danger
                            icon={<DeleteOutlined />}
                          >
                            删除
                          </Button>
                        </Popconfirm>
                      ]
                    }
                  >
                    <List.Item.Meta
                      title={`步骤 ${step.step_number}`}
                      description={
                        editingStep === step.step_number ? (
                          <TextArea
                            value={editingText}
                            onChange={(e) => setEditingText(e.target.value)}
                            autoSize={{ minRows: 2, maxRows: 4 }}
                          />
                        ) : (
                          step.description
                        )
                      }
                    />
                  </List.Item>
                )}
              />

              {!showAddStep ? (
                <Button 
                  type="dashed" 
                  icon={<PlusOutlined />}
                  onClick={() => setShowAddStep(true)}
                  style={{ marginTop: 16, width: '100%' }}
                >
                  添加新步骤
                </Button>
              ) : (
                <Card size="small" style={{ marginTop: 16 }}>
                  <TextArea
                    placeholder="请输入新步骤的描述"
                    value={newStepText}
                    onChange={(e) => setNewStepText(e.target.value)}
                    autoSize={{ minRows: 2, maxRows: 4 }}
                    style={{ marginBottom: 8 }}
                  />
                  <Space>
                    <Button 
                      type="primary" 
                      size="small"
                      onClick={handleAddStep}
                    >
                      添加
                    </Button>
                    <Button 
                      size="small"
                      onClick={() => {
                        setShowAddStep(false);
                        setNewStepText('');
                      }}
                    >
                      取消
                    </Button>
                  </Space>
                </Card>
              )}
            </Card>
          </Col>
        </Row>
      )}

      {/* 阶段3：显示结果 */}
      {stage === 'result' && sqlGenerated && (
        <Row gutter={24}>
          <Col span={24}>
            <Card 
              title="分析结果" 
              extra={
                <Button onClick={handleRestart}>重新分析</Button>
              }
              style={{ marginBottom: 24 }}
            >
              {summary && (
                <Alert
                  message="分析总结"
                  description={summary}
                  type="info"
                  showIcon
                  style={{ marginBottom: 24 }}
                />
              )}

              <Steps direction="vertical" size="small">
                {steps.map((step) => (
                  <Step
                    key={step.step_number}
                    title={`步骤 ${step.step_number}`}
                    description={
                      <div>
                        <Paragraph style={{ marginBottom: 12 }}>
                          <Text strong>{step.description}</Text>
                        </Paragraph>
                        {step.sql && (
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
                        )}
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

      {loading && (
        <Card>
          <div style={{ textAlign: 'center', padding: '40px 0' }}>
            <Spin size="large" />
            <div style={{ marginTop: 16 }}>
              <Text>{sqlGenerated ? '正在生成SQL语句...' : '正在分析案件目标，分解步骤...'}</Text>
            </div>
          </div>
        </Card>
      )}

      <Card title="使用说明" type="inner">
        <div style={{ fontSize: '14px' }}>
          <h4>📌 交互式分解流程</h4>
          <ol>
            <li><strong>输入案件描述</strong>：描述您的案件分析目标</li>
            <li><strong>AI分解步骤</strong>：系统自动将案件目标分解为逻辑步骤</li>
            <li><strong>人工调整</strong>：您可以编辑、删除或添加新的步骤</li>
            <li><strong>生成SQL</strong>：确认步骤后，系统为每个步骤生成SQL查询语句</li>
          </ol>
          
          <h4>🔧 编辑功能</h4>
          <ul>
            <li>点击"编辑"按钮修改步骤描述</li>
            <li>点击"删除"按钮移除不需要的步骤</li>
            <li>点击"添加新步骤"增加自定义步骤</li>
            <li>步骤编号会自动重新排序</li>
          </ul>
          
          <h4>🔍 注意事项</h4>
          <ul>
            <li>步骤调整完成后才能生成SQL</li>
            <li>SQL中使用伪字段名和伪表名，方便后续字段替换</li>
            <li>保持步骤之间的逻辑递进关系</li>
          </ul>
        </div>
      </Card>
    </div>
  );
};

export default CaseAnalysis;