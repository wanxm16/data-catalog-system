import React, { useState, useRef, useEffect } from 'react';
import {
  Card,
  Input,
  Button,
  List,
  Typography,
  Space,
  Avatar,
  Tag,
  Alert,
  Spin,
  Empty
} from 'antd';
import {
  SendOutlined,
  RobotOutlined,
  UserOutlined,
  ClearOutlined,
  QuestionCircleOutlined
} from '@ant-design/icons';

import { ChatResponse } from '../types';
import ApiService from '../services/api';

const { TextArea } = Input;
const { Text, Paragraph } = Typography;

interface ChatMessage {
  id: string;
  type: 'user' | 'assistant';
  content: string;
  timestamp: Date;
  sources?: string[];
}

const ChatInterface: React.FC = () => {
  const [messages, setMessages] = useState<ChatMessage[]>([]);
  const [inputValue, setInputValue] = useState('');
  const [loading, setLoading] = useState(false);
  const messagesEndRef = useRef<HTMLDivElement>(null);

  // 预设问题示例
  const exampleQuestions = [
    "有哪些DWD层的数据表？",
    "和企业相关的表有哪些？", 
    "ads_enterprise_info表包含什么字段？",
    "哪些表属于企业监管领域？",
    "有哪些加工表及其来源表？"
  ];

  // 滚动到底部
  const scrollToBottom = () => {
    messagesEndRef.current?.scrollIntoView({ behavior: 'smooth' });
  };

  useEffect(() => {
    scrollToBottom();
  }, [messages]);

  // 发送消息
  const handleSendMessage = async (question?: string) => {
    const messageText = question || inputValue.trim();
    if (!messageText) return;

    // 添加用户消息
    const userMessage: ChatMessage = {
      id: Date.now().toString(),
      type: 'user',
      content: messageText,
      timestamp: new Date()
    };

    setMessages(prev => [...prev, userMessage]);
    setInputValue('');
    setLoading(true);

    try {
      // 调用API
      const response: ChatResponse = await ApiService.chat(messageText);

      // 添加助手回复
      const assistantMessage: ChatMessage = {
        id: (Date.now() + 1).toString(),
        type: 'assistant',
        content: response.answer,
        timestamp: new Date(),
        sources: response.sources
      };

      setMessages(prev => [...prev, assistantMessage]);
    } catch (error) {
      // 添加错误消息
      const errorMessage: ChatMessage = {
        id: (Date.now() + 1).toString(),
        type: 'assistant',
        content: `抱歉，处理您的问题时出现了错误：${error}`,
        timestamp: new Date()
      };

      setMessages(prev => [...prev, errorMessage]);
    } finally {
      setLoading(false);
    }
  };

  // 清空对话
  const clearMessages = () => {
    setMessages([]);
  };

  // 渲染消息
  const renderMessage = (message: ChatMessage) => {
    const isUser = message.type === 'user';
    
    return (
      <div
        key={message.id}
        style={{
          display: 'flex',
          justifyContent: isUser ? 'flex-end' : 'flex-start',
          marginBottom: 16
        }}
      >
        <div style={{ 
          maxWidth: '70%',
          display: 'flex',
          flexDirection: isUser ? 'row-reverse' : 'row',
          alignItems: 'flex-start'
        }}>
          <Avatar
            icon={isUser ? <UserOutlined /> : <RobotOutlined />}
            style={{ 
              backgroundColor: isUser ? '#1890ff' : '#52c41a',
              margin: isUser ? '0 0 0 8px' : '0 8px 0 0'
            }}
          />
          
          <div
            style={{
              backgroundColor: isUser ? '#1890ff' : '#f6f8fa',
              color: isUser ? 'white' : 'black',
              padding: '12px 16px',
              borderRadius: '12px',
              boxShadow: '0 1px 2px rgba(0,0,0,0.1)'
            }}
          >
            <Paragraph 
              style={{ 
                margin: 0, 
                color: isUser ? 'white' : 'inherit',
                whiteSpace: 'pre-wrap'
              }}
            >
              {message.content}
            </Paragraph>
            
            {/* 显示引用来源 */}
            {message.sources && message.sources.length > 0 && (
              <div style={{ marginTop: 8 }}>
                <Text type="secondary" style={{ fontSize: '12px' }}>
                  引用来源：
                </Text>
                <div style={{ marginTop: 4 }}>
                  {message.sources.map((source, index) => (
                    <Tag key={index} style={{ marginBottom: 2, fontSize: '11px' }}>
                      {source}
                    </Tag>
                  ))}
                </div>
              </div>
            )}
            
            {/* 时间戳 */}
            <div style={{ 
              marginTop: 8, 
              fontSize: '11px', 
              opacity: 0.7,
              textAlign: isUser ? 'right' : 'left'
            }}>
              {message.timestamp.toLocaleTimeString()}
            </div>
          </div>
        </div>
      </div>
    );
  };

  return (
    <div style={{ height: '70vh', display: 'flex', flexDirection: 'column' }}>
      {/* 头部说明 */}
      <Alert
        message="智能问答助手"
        description="基于数据目录信息的智能问答，您可以询问关于数据表、字段、分层、业务领域等相关问题。"
        type="info"
        showIcon
        style={{ marginBottom: 16 }}
        action={
          <Button
            size="small"
            icon={<ClearOutlined />}
            onClick={clearMessages}
            disabled={messages.length === 0}
          >
            清空对话
          </Button>
        }
      />

      {/* 消息列表 */}
      <Card 
        style={{ 
          flex: 1, 
          marginBottom: 16,
          overflow: 'hidden',
          display: 'flex',
          flexDirection: 'column'
        }}
        bodyStyle={{ 
          flex: 1, 
          padding: '16px',
          overflow: 'auto',
          display: 'flex',
          flexDirection: 'column'
        }}
      >
        {messages.length === 0 ? (
          <div style={{ 
            flex: 1, 
            display: 'flex', 
            flexDirection: 'column',
            justifyContent: 'center',
            alignItems: 'center' 
          }}>
            <Empty
              image={Empty.PRESENTED_IMAGE_SIMPLE}
              description="开始对话吧！"
            />
            
            {/* 示例问题 */}
            <div style={{ marginTop: 24, textAlign: 'center' }}>
              <Text type="secondary" style={{ marginBottom: 12, display: 'block' }}>
                <QuestionCircleOutlined /> 您可以尝试以下问题：
              </Text>
              <Space direction="vertical" size="small">
                {exampleQuestions.map((question, index) => (
                  <Button
                    key={index}
                    type="link"
                    size="small"
                    onClick={() => handleSendMessage(question)}
                    style={{ height: 'auto', padding: '4px 8px' }}
                  >
                    {question}
                  </Button>
                ))}
              </Space>
            </div>
          </div>
        ) : (
          <div style={{ flex: 1 }}>
            {messages.map(renderMessage)}
            
            {/* 加载指示器 */}
            {loading && (
              <div style={{ 
                display: 'flex', 
                justifyContent: 'flex-start',
                marginBottom: 16 
              }}>
                <div style={{ 
                  display: 'flex',
                  alignItems: 'center'
                }}>
                  <Avatar
                    icon={<RobotOutlined />}
                    style={{ 
                      backgroundColor: '#52c41a',
                      marginRight: 8
                    }}
                  />
                  <div style={{
                    backgroundColor: '#f6f8fa',
                    padding: '12px 16px',
                    borderRadius: '12px',
                    display: 'flex',
                    alignItems: 'center'
                  }}>
                    <Spin size="small" style={{ marginRight: 8 }} />
                    <Text type="secondary">正在思考...</Text>
                  </div>
                </div>
              </div>
            )}
            
            <div ref={messagesEndRef} />
          </div>
        )}
      </Card>

      {/* 输入框 */}
      <Card size="small">
        <Space.Compact style={{ width: '100%' }}>
          <TextArea
            value={inputValue}
            onChange={(e) => setInputValue(e.target.value)}
            placeholder="请输入您的问题..."
            rows={2}
            onPressEnter={(e) => {
              if (!e.shiftKey) {
                e.preventDefault();
                handleSendMessage();
              }
            }}
            style={{ resize: 'none' }}
            disabled={loading}
          />
          <Button
            type="primary"
            icon={<SendOutlined />}
            onClick={() => handleSendMessage()}
            loading={loading}
            disabled={!inputValue.trim()}
            style={{ height: '64px' }}
          >
            发送
          </Button>
        </Space.Compact>
        
        <div style={{ 
          marginTop: 8, 
          fontSize: '12px', 
          color: '#999',
          textAlign: 'center'
        }}>
          按 Enter 发送，Shift + Enter 换行
        </div>
      </Card>
    </div>
  );
};

export default ChatInterface; 