import React, { useState, useEffect } from 'react';
import {
  Card,
  Typography,
  Select,
  Input,
  Button,
  List,
  Alert,
  Image,
  Table,
  Space,
  Spin,
  Empty,
  Tag,
  Row,
  Col
} from 'antd';
import {
  MessageOutlined,
  SendOutlined,
  FileTextOutlined,
  BarChartOutlined,
  ReloadOutlined
} from '@ant-design/icons';
import { chatBIAPI } from '../services/api';

const { Title, Text, Paragraph } = Typography;
const { TextArea } = Input;
const { Option } = Select;

interface DataFile {
  filename: string;
  display_name: string;
  rows: number;
  columns: number;
  size: number;
}

interface AnalysisResult {
  ai_analysis: string;
  actual_result?: {
    type: string;
    data: any;
    description: string;
  };
  chart?: {
    type: string;
    data: string;
    description: string;
  };
  question: string;
}

interface ChatMessage {
  id: string;
  type: 'user' | 'assistant';
  content: string;
  analysis?: AnalysisResult;
  timestamp: Date;
}

const ChatBI: React.FC = () => {
  const [files, setFiles] = useState<DataFile[]>([]);
  const [selectedFile, setSelectedFile] = useState<string>('');
  const [messages, setMessages] = useState<ChatMessage[]>([]);
  const [question, setQuestion] = useState('');
  const [loading, setLoading] = useState(false);
  const [loadingFiles, setLoadingFiles] = useState(true);

  // 加载数据文件列表
  useEffect(() => {
    loadDataFiles();
  }, []);

  // 切换数据集时清空对话历史
  useEffect(() => {
    if (selectedFile) {
      setMessages([]);
    }
  }, [selectedFile]);

  const loadDataFiles = async () => {
    try {
      setLoadingFiles(true);
      const response = await chatBIAPI.getFiles();
      if (response.success && response.data) {
        setFiles(response.data);
        if (response.data.length > 0) {
          setSelectedFile(response.data[0].filename);
        }
      }
    } catch (error) {
      console.error('加载数据文件失败:', error);
    } finally {
      setLoadingFiles(false);
    }
  };

  const handleSubmit = async () => {
    if (!question.trim() || !selectedFile) return;

    const userMessage: ChatMessage = {
      id: Date.now().toString(),
      type: 'user',
      content: question,
      timestamp: new Date()
    };

    setMessages(prev => [...prev, userMessage]);
    setLoading(true);
    setQuestion('');

    try {
      const response = await chatBIAPI.analyzeData(selectedFile, question);
      
      const assistantMessage: ChatMessage = {
        id: (Date.now() + 1).toString(),
        type: 'assistant',
        content: response.success 
          ? response.data.ai_analysis 
          : `分析失败: ${response.message}`,
        analysis: response.success ? response.data : undefined,
        timestamp: new Date()
      };

      setMessages(prev => [...prev, assistantMessage]);
    } catch (error) {
      const errorMessage: ChatMessage = {
        id: (Date.now() + 1).toString(),
        type: 'assistant',
        content: `分析失败: ${error}`,
        timestamp: new Date()
      };
      setMessages(prev => [...prev, errorMessage]);
    } finally {
      setLoading(false);
    }
  };

  const handleKeyPress = (e: React.KeyboardEvent) => {
    if (e.key === 'Enter' && !e.shiftKey) {
      e.preventDefault();
      handleSubmit();
    }
  };

  const formatFileSize = (bytes: number): string => {
    if (bytes === 0) return '0 B';
    const k = 1024;
    const sizes = ['B', 'KB', 'MB', 'GB'];
    const i = Math.floor(Math.log(bytes) / Math.log(k));
    return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i];
  };

  const renderAnalysisResult = (analysis: AnalysisResult) => {
    const { actual_result, chart } = analysis;

    return (
      <div style={{ marginTop: 16 }}>
        {/* 显示图表 */}
        {chart && (
          <div style={{ marginBottom: 16 }}>
            <Title level={5}>📊 {chart.description}</Title>
            <Image
              src={chart.data}
              alt={chart.description}
              style={{ maxWidth: '500px', width: '100%', borderRadius: 8 }}
            />
          </div>
        )}

        {/* 显示数据结果 */}
        {actual_result && actual_result.data && (
          <div style={{ marginBottom: 16 }}>
            <Title level={5}>📈 数据结果</Title>
            {renderDataResult(actual_result)}
          </div>
        )}
      </div>
    );
  };

  const renderDataResult = (result: any) => {
    const { type, data, description } = result;

    switch (type) {
      case 'gender_comparison':
        const genderData = [
          { key: '总金额', ...data.sum },
          { key: '平均金额', ...data.mean },
          { key: '交易次数', ...data.count }
        ];
        
        const genderColumns = [
          { title: '指标', dataIndex: 'key', key: 'key' },
          { title: '男性', dataIndex: 'Male', key: 'Male', render: (val: number) => val?.toLocaleString() },
          { title: '女性', dataIndex: 'Female', key: 'Female', render: (val: number) => val?.toLocaleString() }
        ];

        return <Table dataSource={genderData} columns={genderColumns} pagination={false} size="small" />;

      case 'female_category_distribution':
      case 'top_categories':
        const categoryData = Object.entries(data).map(([category, amount], index) => ({
          key: index,
          category,
          amount: amount as number
        }));

        const categoryColumns = [
          { title: '品类', dataIndex: 'category', key: 'category' },
          { title: '金额', dataIndex: 'amount', key: 'amount', render: (val: number) => val?.toLocaleString() }
        ];

        return <Table dataSource={categoryData} columns={categoryColumns} pagination={false} size="small" />;

      case 'case_status_distribution':
        const caseStatusData = Object.entries(data).map(([status, count], index) => ({
          key: index,
          status,
          count: count as number
        }));

        const caseStatusColumns = [
          { title: '案件状态', dataIndex: 'status', key: 'status' },
          { title: '案件数量', dataIndex: 'count', key: 'count', render: (val: number) => val?.toLocaleString() }
        ];

        return <Table dataSource={caseStatusData} columns={caseStatusColumns} pagination={false} size="small" />;

      case 'suspect_gender_distribution':
        const suspectGenderData = Object.entries(data).map(([gender, count], index) => ({
          key: index,
          gender,
          count: count as number
        }));

        const suspectGenderColumns = [
          { title: '性别', dataIndex: 'gender', key: 'gender' },
          { title: '人数', dataIndex: 'count', key: 'count', render: (val: number) => val?.toLocaleString() }
        ];

        return <Table dataSource={suspectGenderData} columns={suspectGenderColumns} pagination={false} size="small" />;

      case 'age_distribution':
        const ageData = Object.entries(data).map(([ageGroup, count], index) => ({
          key: index,
          ageGroup,
          count: count as number
        }));

        const ageColumns = [
          { title: '年龄段', dataIndex: 'ageGroup', key: 'ageGroup' },
          { title: '人数', dataIndex: 'count', key: 'count', render: (val: number) => val?.toLocaleString() }
        ];

        return <Table dataSource={ageData} columns={ageColumns} pagination={false} size="small" />;

      case 'crime_type_distribution':
        const crimeTypeData = Object.entries(data).map(([crimeType, count], index) => ({
          key: index,
          crimeType,
          count: count as number
        }));

        const crimeTypeColumns = [
          { title: '犯罪类型', dataIndex: 'crimeType', key: 'crimeType' },
          { title: '案件数量', dataIndex: 'count', key: 'count', render: (val: number) => val?.toLocaleString() }
        ];

        return <Table dataSource={crimeTypeData} columns={crimeTypeColumns} pagination={false} size="small" />;

      case 'statistics':
        const statsData = Object.entries(data).map(([field, stats], index) => ({
          key: index,
          field,
          ...stats as object
        }));

        const statsColumns = [
          { title: '字段', dataIndex: 'field', key: 'field' },
          { title: '平均值', dataIndex: 'mean', key: 'mean', render: (val: number) => val?.toFixed(2) },
          { title: '最小值', dataIndex: 'min', key: 'min' },
          { title: '最大值', dataIndex: 'max', key: 'max' }
        ];

        return <Table dataSource={statsData} columns={statsColumns} pagination={false} size="small" />;

      default:
        return <pre style={{ fontSize: 12, background: '#f5f5f5', padding: 8, borderRadius: 4 }}>
          {JSON.stringify(data, null, 2)}
        </pre>;
    }
  };

  const currentFile = files.find(f => f.filename === selectedFile);

  return (
    <div style={{ height: '100%', display: 'flex', flexDirection: 'column' }}>
      {/* 文件选择区域 */}
      <Card style={{ marginBottom: 16, flexShrink: 0 }}>
        <Row gutter={16} align="middle">
          <Col span={12}>
            <Space>
              <FileTextOutlined />
              <Text strong>选择数据文件:</Text>
              <Select
                value={selectedFile}
                onChange={setSelectedFile}
                style={{ width: 200 }}
                loading={loadingFiles}
              >
                {files.map(file => (
                  <Option key={file.filename} value={file.filename}>
                    {file.display_name}
                  </Option>
                ))}
              </Select>
              <Button icon={<ReloadOutlined />} onClick={loadDataFiles}>
                刷新
              </Button>
            </Space>
          </Col>
          <Col span={12}>
            {currentFile && (
              <Space>
                <Tag color="blue">{currentFile.rows.toLocaleString()} 行</Tag>
                <Tag color="green">{currentFile.columns} 列</Tag>
                <Tag color="orange">{formatFileSize(currentFile.size)}</Tag>
              </Space>
            )}
          </Col>
        </Row>

        {selectedFile === '销售数据集.csv' && (
          <Alert
            message="示例问题"
            description={
              <div>
                <p>💡 您可以尝试问这些问题：</p>
                <ul>
                  <li>男女消费金额的对比</li>
                  <li>女性在不同品类中的消费金额的分布</li>
                  <li>消费金额最高的5个品类是什么？</li>
                  <li>每个年龄段的平均消费金额</li>
                </ul>
              </div>
            }
            type="info"
            style={{ marginTop: 16 }}
          />
        )}

        {selectedFile === '犯罪数据.csv' && (
          <Alert
            message="示例问题"
            description={
              <div>
                <p>🚔 您可以尝试问这些问题：</p>
                <ul>
                  <li>Closed与Open的案件数是多少</li>
                  <li>嫌疑人性别分布情况</li>
                  <li>嫌疑人年龄分布统计</li>
                  <li>主要犯罪类型有哪些</li>
                </ul>
              </div>
            }
            type="info"
            style={{ marginTop: 16 }}
          />
        )}
      </Card>

      {/* 对话区域 */}
      <Card 
        title={<><MessageOutlined /> ChatBI 数据分析对话</>}
        style={{ flex: 1, display: 'flex', flexDirection: 'column' }}
        bodyStyle={{ flex: 1, display: 'flex', flexDirection: 'column', padding: 0 }}
      >
        {/* 消息列表 */}
        <div style={{ flex: 1, overflow: 'auto', padding: 16 }}>
          {messages.length === 0 ? (
            <Empty 
              image={Empty.PRESENTED_IMAGE_SIMPLE}
              description="开始与您的数据对话吧！"
            />
          ) : (
            <List
              dataSource={messages}
              renderItem={(message) => (
                <List.Item style={{ border: 'none', padding: '8px 0' }}>
                  <div style={{ width: '100%' }}>
                    <div style={{ 
                      display: 'flex', 
                      justifyContent: message.type === 'user' ? 'flex-end' : 'flex-start' 
                    }}>
                      <div style={{
                        maxWidth: '80%',
                        padding: 12,
                        borderRadius: 8,
                        backgroundColor: message.type === 'user' ? '#1890ff' : '#f0f0f0',
                        color: message.type === 'user' ? 'white' : 'black'
                      }}>
                        <div style={{ marginBottom: 4 }}>
                          <Text style={{ 
                            fontSize: 12, 
                            opacity: 0.8,
                            color: message.type === 'user' ? 'rgba(255,255,255,0.8)' : 'rgba(0,0,0,0.6)'
                          }}>
                            {message.type === 'user' ? '您' : 'ChatBI'} • {message.timestamp.toLocaleTimeString()}
                          </Text>
                        </div>
                        <div style={{ whiteSpace: 'pre-wrap' }}>
                          {message.content}
                        </div>
                        {message.analysis && (
                          <div style={{ 
                            marginTop: 8, 
                            padding: 8, 
                            backgroundColor: 'rgba(255,255,255,0.1)',
                            borderRadius: 4
                          }}>
                            {renderAnalysisResult(message.analysis)}
                          </div>
                        )}
                      </div>
                    </div>
                  </div>
                </List.Item>
              )}
            />
          )}
        </div>

        {/* 输入区域 */}
        <div style={{ 
          padding: 16, 
          borderTop: '1px solid #f0f0f0',
          backgroundColor: '#fafafa' 
        }}>
          <Space.Compact style={{ width: '100%' }}>
            <TextArea
              value={question}
              onChange={(e) => setQuestion(e.target.value)}
              onKeyPress={handleKeyPress}
              placeholder={selectedFile ? "请输入您的数据分析问题..." : "请先选择数据文件"}
              autoSize={{ minRows: 1, maxRows: 4 }}
              disabled={!selectedFile || loading}
            />
            <Button
              type="primary"
              icon={loading ? <Spin size="small" /> : <SendOutlined />}
              onClick={handleSubmit}
              disabled={!selectedFile || !question.trim() || loading}
              style={{ height: 'auto' }}
            >
              {loading ? '分析中...' : '发送'}
            </Button>
          </Space.Compact>
        </div>
      </Card>
    </div>
  );
};

export default ChatBI; 