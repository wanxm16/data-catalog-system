import React, { useState } from 'react';
import { Card, Input, Button, Steps, Typography, Alert, Spin, message, Row, Col, Space, Modal, Form, Popconfirm, List } from 'antd';
import { PlayCircleOutlined, FileTextOutlined, EditOutlined, DeleteOutlined, PlusOutlined, CheckOutlined, CodeOutlined, ReloadOutlined } from '@ant-design/icons';
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
  const [stage, setStage] = useState<'input' | 'clarification' | 'steps' | 'result'>('input');
  
  // 澄清相关状态
  const [needsClarification, setNeedsClarification] = useState(false);
  const [clarificationMessage, setClarificationMessage] = useState('');
  const [clarificationResponse, setClarificationResponse] = useState('');
  const [originalDescription, setOriginalDescription] = useState('');

  // 第一步：分析案件描述清晰度
  const handleDecomposeSteps = async () => {
    if (!caseDescription.trim()) {
      message.warning('请输入案件目标描述');
      return;
    }

    setLoading(true);
    try {
      // 先分析清晰度
      const clarityResponse = await ApiService.analyzeCaseClarity(caseDescription);
      
      if (clarityResponse.success && clarityResponse.data) {
        const { is_clear, clarification_questions } = clarityResponse.data;
        
        if (is_clear) {
          // 描述清晰，直接进行分解
          await performCaseDecomposition(caseDescription);
        } else {
          // 描述不清晰，需要澄清
          setOriginalDescription(caseDescription);
          // 将澄清问题组合成自然对话文本
          const questionsText = clarification_questions?.map((q: string, i: number) => `${i + 1}. ${q}`).join('\n\n') || '';
          setClarificationMessage(`为了更准确地分析您的案件，请提供以下信息：\n\n${questionsText}\n\n请在下方详细回答这些问题：`);
          setClarificationResponse('');
          setNeedsClarification(true);
          setStage('clarification');
          message.info('案件描述需要进一步澄清，请在对话框中详细说明');
        }
      } else {
        message.error(clarityResponse.message || '案件清晰度分析失败');
      }
    } catch (error) {
      console.error('案件清晰度分析失败:', error);
      message.error('案件清晰度分析失败，请重试');
    } finally {
      setLoading(false);
    }
  };

  // 执行案件分解
  const performCaseDecomposition = async (description: string) => {
    try {
      const response = await ApiService.decomposeCase(description);
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
    }
  };

  // 第二步：为调整后的步骤生成SQL
  const handleGenerateSQL = async () => {
    // 检查是否是本地示例
    if (originalDescription === '分析高风险人员' && steps.length > 0) {
      handleLocalExampleSQL();
      return;
    }

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

  // 处理本地示例的SQL生成
  const handleLocalExampleSQL = () => {
    const mockStepsWithSQL = [
      {
        step_number: 1,
        description: '提取乌鲁木齐市常住人口管理中重点关注人员基础信息',
        sql: `-- 步骤1：提取乌鲁木齐市重点人员基础信息
SELECT 
    person_id,
    person_name,
    id_card,
    gender,
    age,
    ethnic,
    address,
    phone_number,
    risk_level
FROM ads_population_base 
WHERE city = '乌鲁木齐市' 
    AND risk_level IN ('高风险', '中风险')
    AND status = '在册';`,
        isEditing: false
      },
      {
        step_number: 2,
        description: '基于步骤1结果，筛选最近6个月有异常出入境记录的人员',
        sql: `-- 步骤2：筛选有异常出入境记录的人员
SELECT DISTINCT
    p.person_id,
    p.person_name,
    p.id_card,
    COUNT(b.border_record_id) as border_count
FROM (步骤1结果) p
INNER JOIN ads_border_control b ON p.person_id = b.person_id
WHERE b.cross_time >= DATE_SUB(NOW(), INTERVAL 6 MONTH)
    AND b.abnormal_flag = 1
GROUP BY p.person_id, p.person_name, p.id_card
HAVING border_count >= 2;`,
        isEditing: false
      },
      {
        step_number: 3,
        description: '基于步骤2结果，关联最近6个月内去过云南、广西等边境省份的人员',
        sql: `-- 步骤3：关联去过边境省份的人员
SELECT DISTINCT
    p.person_id,
    p.person_name,
    p.id_card,
    p.border_count,
    STRING_AGG(DISTINCT t.destination_province, ',') as visited_provinces
FROM (步骤2结果) p
INNER JOIN ads_travel_record t ON p.person_id = t.person_id
WHERE t.travel_date >= DATE_SUB(NOW(), INTERVAL 6 MONTH)
    AND t.destination_province IN ('云南省', '广西壮族自治区', '西藏自治区')
GROUP BY p.person_id, p.person_name, p.id_card, p.border_count;`,
        isEditing: false
      },
      {
        step_number: 4,
        description: '基于步骤3结果，提取20-40岁年龄段的成年男性人员',
        sql: `-- 步骤4：筛选20-40岁成年男性
SELECT 
    p.person_id,
    p.person_name,
    p.id_card,
    p.border_count,
    p.visited_provinces,
    YEAR(NOW()) - YEAR(STR_TO_DATE(SUBSTRING(p.id_card, 7, 8), '%Y%m%d')) as age,
    CASE WHEN SUBSTRING(p.id_card, 17, 1) % 2 = 1 THEN '男' ELSE '女' END as gender
FROM (步骤3结果) p
WHERE (YEAR(NOW()) - YEAR(STR_TO_DATE(SUBSTRING(p.id_card, 7, 8), '%Y%m%d'))) BETWEEN 20 AND 40
    AND SUBSTRING(p.id_card, 17, 1) % 2 = 1;`,
        isEditing: false
      },
      {
        step_number: 5,
        description: '基于步骤4结果，标注人员风险等级和预警状态',
        sql: `-- 步骤5：标注风险等级和预警状态
SELECT 
    *,
    CASE 
        WHEN border_count >= 5 AND visited_provinces LIKE '%云南省%' THEN '极高风险'
        WHEN border_count >= 3 AND visited_provinces LIKE '%广西%' THEN '高风险'
        WHEN border_count >= 2 THEN '中风险'
        ELSE '低风险'
    END as final_risk_level,
    CASE 
        WHEN border_count >= 3 THEN '红色预警'
        WHEN border_count >= 2 THEN '橙色预警'
        ELSE '黄色预警'
    END as alert_level,
    NOW() as analysis_time
FROM (步骤4结果);`,
        isEditing: false
      },
      {
        step_number: 6,
        description: '基于步骤5结果，生成高风险人员名单和风险评估报告',
        sql: `-- 步骤6：生成最终高风险人员名单
SELECT 
    person_id,
    person_name,
    id_card,
    age,
    border_count,
    visited_provinces,
    final_risk_level,
    alert_level,
    analysis_time,
    CONCAT('该人员最近6个月内有', border_count, '次异常出入境记录，曾前往', visited_provinces, '等边境省份，风险等级：', final_risk_level) as risk_summary
FROM (步骤5结果)
WHERE final_risk_level IN ('极高风险', '高风险')
ORDER BY 
    CASE final_risk_level 
        WHEN '极高风险' THEN 1 
        WHEN '高风险' THEN 2 
        ELSE 3 
    END,
    border_count DESC;`,
        isEditing: false
      }
    ];

    setSteps(mockStepsWithSQL);
    setSqlGenerated(true);
    setStage('result');
    message.success('本地示例：SQL代码生成完成');
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

  // 处理澄清回答
  const handleClarificationSubmit = async () => {
    if (!clarificationResponse.trim()) {
      message.warning('请提供澄清信息');
      return;
    }

    // 检查是否是本地示例
    if (originalDescription === '分析高风险人员' && needsClarification) {
      handleLocalExampleClarification();
      return;
    }

    setLoading(true);
    try {
      // 将用户的回答作为单个字符串传递
      const response = await ApiService.decomposeWithClarification(
        originalDescription,
        [clarificationResponse]
      );
      
      if (response.success && response.data) {
        const decomposedSteps = response.data.steps.map((step: AnalysisStep) => ({
          ...step,
          isEditing: false
        }));
        setSteps(decomposedSteps);
        setSummary(response.data.summary || '');
        setStage('steps');
        setSqlGenerated(false);
        setNeedsClarification(false);
        message.success('基于澄清信息的案件分解完成，您可以编辑步骤');
      } else {
        message.error(response.message || '基于澄清信息的案件分解失败');
      }
    } catch (error) {
      console.error('基于澄清信息的案件分解失败:', error);
      message.error('基于澄清信息的案件分解失败，请重试');
    } finally {
      setLoading(false);
    }
  };

  // 处理本地示例的澄清回答
  const handleLocalExampleClarification = () => {
    // 模拟分解步骤
    const mockSteps = [
      {
        step_number: 1,
        description: '提取乌鲁木齐市常住人口管理中重点关注人员基础信息',
        isEditing: false
      },
      {
        step_number: 2,
        description: '基于步骤1结果，筛选最近6个月有异常出入境记录的人员',
        isEditing: false
      },
      {
        step_number: 3,
        description: '基于步骤2结果，关联最近6个月内去过云南、广西等边境省份的人员',
        isEditing: false
      },
      {
        step_number: 4,
        description: '基于步骤3结果，提取20-40岁年龄段的成年男性人员',
        isEditing: false
      },
      {
        step_number: 5,
        description: '基于步骤4结果，标注人员风险等级和预警状态',
        isEditing: false
      },
      {
        step_number: 6,
        description: '基于步骤5结果，生成高风险人员名单和风险评估报告',
        isEditing: false
      }
    ];

    const mockSummary = '基于用户澄清的信息，本案件分析聚焦于乌鲁木齐市20-40岁成年男性中，最近6个月有异常出入境记录且去过边境省份的重点人员，通过多维度数据关联分析，识别潜在高风险人员并进行风险评估。';

    setSteps(mockSteps);
    setSummary(mockSummary);
    setStage('steps');
    setSqlGenerated(false);
    setNeedsClarification(false);
    message.success('本地示例：基于澄清信息的案件分解完成，您可以编辑步骤');
  };

  // 重新开始
  const handleRestart = () => {
    setCaseDescription('');
    setSteps([]);
    setSummary('');
    setSqlGenerated(false);
    setStage('input');
    setNeedsClarification(false);
    setClarificationMessage('');
    setClarificationResponse('');
    setOriginalDescription('');
  };

  const handleExample = () => {
    setCaseDescription('分析高风险人员');
  };

  // 使用本地示例（不调用API）
  const handleLocalExample = () => {
    setCaseDescription('分析高风险人员');
    setOriginalDescription('分析高风险人员');
    
    // 模拟澄清问题
    const mockClarificationMessage = `为了更准确地分析您的案件，请提供以下信息：

1. 请明确具体的地理范围，是针对乌鲁木齐市还是整个新疆地区？

2. 请说明目标时间范围，是最近一个月、三个月还是一年内的数据？

3. 请具体说明要识别的人员特征，比如年龄段、民族、职业等？

4. 请明确分析目的，是进行风险评估、实时监控还是历史排查？

请在下方详细回答这些问题：`;

    setClarificationMessage(mockClarificationMessage);
    setClarificationResponse('');
    setNeedsClarification(true);
    setStage('clarification');
    message.info('这是一个本地示例，展示澄清对话功能');
  };

  return (
    <div>
      <Title level={2}>案件分解助手</Title>

      {/* 阶段1：输入案件描述 */}
      {stage === 'input' && (
        <Row gutter={24}>
          <Col span={24}>
            <Card title="案件目标描述" style={{ marginBottom: 24 }}>
              <TextArea
                placeholder="请描述您的案件分析目标，例如：分析高风险人员（系统会自动判断是否需要澄清）"
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
                  onClick={handleLocalExample}
                >
                  澄清对话示例
                </Button>
              </div>
            </Card>
          </Col>
        </Row>
      )}

      {/* 阶段2：澄清问题 */}
      {stage === 'clarification' && (
        <Row gutter={24}>
          <Col span={24}>
            <Card title="智能澄清对话" style={{ marginBottom: 24 }}>
              <div style={{ marginBottom: 16 }}>
                <Text strong>原始描述：</Text>
                <Text type="secondary" style={{ marginLeft: 8, fontStyle: 'italic' }}>"{originalDescription}"</Text>
              </div>

              {/* AI助手消息 */}
              <div style={{ 
                backgroundColor: '#f6f8fa', 
                padding: '16px', 
                borderRadius: '8px', 
                marginBottom: '16px',
                border: '1px solid #e1e4e8'
              }}>
                <div style={{ display: 'flex', alignItems: 'center', marginBottom: '8px' }}>
                  <span style={{ 
                    backgroundColor: '#1890ff', 
                    color: 'white', 
                    padding: '4px 8px', 
                    borderRadius: '12px', 
                    fontSize: '12px',
                    marginRight: '8px'
                  }}>
                    AI助手
                  </span>
                </div>
                <Text style={{ whiteSpace: 'pre-line', lineHeight: '1.6' }}>
                  {clarificationMessage}
                </Text>
              </div>

              {/* 用户回复区域 */}
              <div style={{ marginBottom: '16px' }}>
                <Text strong style={{ display: 'block', marginBottom: '8px' }}>
                  您的回复：
                </Text>
                <TextArea
                  placeholder="请在此详细回答上述问题，可以自由组织语言..."
                  value={clarificationResponse}
                  onChange={(e) => setClarificationResponse(e.target.value)}
                  rows={6}
                  style={{ 
                    fontSize: '14px',
                    lineHeight: '1.6'
                  }}
                />
              </div>

              <div style={{ display: 'flex', gap: 12 }}>
                <Button 
                  type="primary" 
                  icon={<CheckOutlined />}
                  onClick={handleClarificationSubmit}
                  loading={loading}
                  disabled={!clarificationResponse.trim()}
                >
                  提交回复
                </Button>
                <Button 
                  icon={<ReloadOutlined />}
                  onClick={handleRestart}
                >
                  重新开始
                </Button>
              </div>
            </Card>
          </Col>
        </Row>
      )}

      {/* 阶段3：编辑步骤 */}
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