import React, { useState, useEffect } from 'react';
import {
  Form,
  Input,
  Select,
  Button,
  Space,
  Card,
  Table,
  message,
  Spin,
  Alert,
  Tag,
  Typography,
  Divider
} from 'antd';
import { 
  RobotOutlined, 
  SaveOutlined, 
  ReloadOutlined,
  PlusOutlined,
  DeleteOutlined
} from '@ant-design/icons';
import type { ColumnsType } from 'antd/es/table';

import { 
  CatalogInfo, 
  DomainCategory, 
  FieldInfo, 
  SourceTableInfo,
  TableLayer 
} from '../types';
import ApiService from '../services/api';

const { TextArea } = Input;
const { Option } = Select;
const { Text } = Typography;

interface Props {
  tableName: string;
  onSuccess: () => void;
  onCancel: () => void;
}

const CatalogForm: React.FC<Props> = ({ tableName, onSuccess, onCancel }) => {
  const [form] = Form.useForm();
  const [loading, setLoading] = useState(false);
  const [generating, setGenerating] = useState(false);
  const [catalogInfo, setCatalogInfo] = useState<CatalogInfo | null>(null);
  const [fields, setFields] = useState<FieldInfo[]>([]);

  // 初始化 - 尝试获取已有编目信息或生成新的
  useEffect(() => {
    initializeCatalog();
  }, [tableName]);

  const initializeCatalog = async () => {
    setLoading(true);
    try {
      // 先尝试获取已有编目信息
      const existingResult = await ApiService.getCatalogInfo(tableName);
      
      if (existingResult.success && existingResult.data) {
        // 如果已有编目信息，加载它
        const catalog = existingResult.data;
        setCatalogInfo(catalog);
        setFields(catalog.fields);
        
        // 填充表单
        form.setFieldsValue({
          resource_name: catalog.resource_name,
          resource_summary: catalog.resource_summary,
          domain_category: catalog.domain_category,
          organization_name: catalog.organization_name,
          irs_system_name: catalog.irs_system_name,
          processing_logic: catalog.processing_logic
        });
        
        message.info('已加载现有编目信息');
      } else {
        // 如果没有编目信息，自动生成
        await generateCatalog();
      }
    } catch (error) {
      message.error(`初始化失败: ${error}`);
    } finally {
      setLoading(false);
    }
  };

  // AI生成编目信息
  const generateCatalog = async () => {
    setGenerating(true);
    try {
      const result = await ApiService.generateCatalog(tableName);
      
      if (result.success && result.data) {
        const catalog = result.data;
        setCatalogInfo(catalog);
        setFields(catalog.fields);
        
        // 填充表单
        form.setFieldsValue({
          resource_name: catalog.resource_name,
          resource_summary: catalog.resource_summary,
          domain_category: catalog.domain_category,
          organization_name: catalog.organization_name,
          irs_system_name: catalog.irs_system_name,
          processing_logic: catalog.processing_logic
        });
        
        message.success('AI生成编目信息成功！');
      } else {
        message.warning(result.message || 'AI生成失败');
      }
    } catch (error) {
      message.error(`AI生成失败: ${error}`);
    } finally {
      setGenerating(false);
    }
  };

  // 保存编目信息
  const handleSave = async () => {
    try {
      const values = await form.validateFields();
      
      if (!catalogInfo) {
        message.error('编目信息不完整');
        return;
      }

      const updatedCatalog: CatalogInfo = {
        ...catalogInfo,
        resource_name: values.resource_name,
        resource_summary: values.resource_summary,
        domain_category: values.domain_category,
        organization_name: values.organization_name,
        irs_system_name: values.irs_system_name,
        processing_logic: values.processing_logic,
        fields: fields
      };

      setLoading(true);
      const result = await ApiService.saveCatalogInfo(updatedCatalog);
      
      if (result.success) {
        message.success('编目信息保存成功！');
        onSuccess();
      } else {
        message.error(result.message || '保存失败');
      }
    } catch (error) {
      message.error(`保存失败: ${error}`);
    } finally {
      setLoading(false);
    }
  };

  // 字段表格列定义
  const fieldColumns: ColumnsType<FieldInfo> = [
    {
      title: '字段英文名',
      dataIndex: 'field_name_en',
      key: 'field_name_en',
      width: 180,
      render: (text: string) => <Text code>{text}</Text>
    },
    {
      title: '字段中文名',
      dataIndex: 'field_name_cn',
      key: 'field_name_cn',
      render: (text: string, record: FieldInfo, index: number) => (
        <Input
          value={text}
          onChange={(e) => {
            const newFields = [...fields];
            newFields[index].field_name_cn = e.target.value;
            setFields(newFields);
          }}
          size="small"
        />
      )
    },
    {
      title: '数据类型',
      dataIndex: 'field_type',
      key: 'field_type',
      width: 120,
      render: (text: string) => <Tag color="blue">{text}</Tag>
    }
  ];

  if (loading && !catalogInfo) {
    return (
      <div style={{ textAlign: 'center', padding: '50px 0' }}>
        <Spin size="large" />
        <p style={{ marginTop: 16 }}>正在加载编目信息...</p>
      </div>
    );
  }

  return (
    <div>
      {/* AI生成提示 */}
      <Alert
        message="智能编目"
        description="系统已自动分析表结构并生成编目信息，您可以直接保存或进行调整。"
        type="info"
        showIcon
        style={{ marginBottom: 16 }}
        action={
          <Button
            size="small"
            icon={<RobotOutlined />}
            onClick={generateCatalog}
            loading={generating}
          >
            重新生成
          </Button>
        }
      />

      <Form
        form={form}
        layout="vertical"
        onFinish={handleSave}
      >
        {/* 基础信息 */}
        <Card title="基础信息" size="small" style={{ marginBottom: 16 }}>
          <Form.Item
            label="信息资源名称"
            name="resource_name"
            rules={[{ required: true, message: '请输入资源名称' }]}
          >
            <Input placeholder="表的中文名称" />
          </Form.Item>

          <Form.Item
            label="信息资源摘要"
            name="resource_summary"
            rules={[{ required: true, message: '请输入资源摘要' }]}
          >
            <TextArea 
              rows={3} 
              placeholder="一句话概括表的功能和用途"
              showCount
              maxLength={200}
            />
          </Form.Item>

          <Form.Item
            label="重点领域分类"
            name="domain_category"
            rules={[{ required: true, message: '请选择领域分类' }]}
          >
            <Select placeholder="选择所属业务领域">
              {Object.values(DomainCategory).map(category => (
                <Option key={category} value={category}>{category}</Option>
              ))}
            </Select>
          </Form.Item>

          <Form.Item
            label="组织机构名称"
            name="organization_name"
            rules={[{ required: true, message: '请输入组织机构名称' }]}
          >
            <Input placeholder="所属局委办名称" />
          </Form.Item>

          <Form.Item
            label="IRS系统名称"
            name="irs_system_name"
            rules={[{ required: true, message: '请输入系统名称' }]}
          >
            <Input placeholder="所属业务系统名称" />
          </Form.Item>

          {catalogInfo?.is_processed && (
            <Form.Item
              label="加工逻辑"
              name="processing_logic"
            >
              <TextArea 
                rows={3} 
                placeholder="描述数据加工的业务逻辑"
                showCount
                maxLength={500}
              />
            </Form.Item>
          )}
        </Card>

        {/* 字段信息 */}
        <Card title="字段信息" size="small" style={{ marginBottom: 16 }}>
          <Table
            columns={fieldColumns}
            dataSource={fields}
            rowKey="field_name_en"
            pagination={{
              pageSize: 10,
              showTotal: (total) => `共 ${total} 个字段`
            }}
            size="small"
            scroll={{ x: 600 }}
          />
        </Card>

        {/* 加工信息 */}
        {catalogInfo?.is_processed && catalogInfo.source_tables && (
          <Card title="依赖信息" size="small" style={{ marginBottom: 16 }}>
            <div>
              <Text strong>来源表：</Text>
              <div style={{ marginTop: 8 }}>
                {catalogInfo.source_tables.map((table, index) => (
                  <Tag key={index} color="processing" style={{ marginBottom: 4 }}>
                    {table.table_name_en}
                    {table.table_name_cn && ` (${table.table_name_cn})`}
                  </Tag>
                ))}
              </div>
            </div>
          </Card>
        )}

        {/* 操作按钮 */}
        <div style={{ textAlign: 'right' }}>
          <Space>
            <Button onClick={onCancel}>
              取消
            </Button>
            <Button
              type="primary"
              icon={<SaveOutlined />}
              onClick={handleSave}
              loading={loading}
            >
              保存编目信息
            </Button>
          </Space>
        </div>
      </Form>
    </div>
  );
};

export default CatalogForm; 