import React, { useState, useEffect } from 'react';
import {
  Card,
  Table,
  Button,
  Modal,
  Form,
  Input,
  Space,
  Popconfirm,
  message,
  Tag,
  Typography,
  Empty,
  Select,
  Collapse,
  Divider,
  Tooltip
} from 'antd';
import {
  PlusOutlined,
  EditOutlined,
  DeleteOutlined,
  SearchOutlined,
  ContainerOutlined,
  EyeOutlined,
  FileTextOutlined
} from '@ant-design/icons';

const { Title, Text, Paragraph } = Typography;
const { TextArea } = Input;
const { Panel } = Collapse;
const { Option } = Select;

interface Case {
  id: number;
  title: string;
  category: string;
  description: string;
  scenario: string;
  solution: string;
  sql_queries: string[];
  tags: string[];
  created_at: string;
  updated_at: string;
}

const CaseLibrary: React.FC = () => {
  const [cases, setCases] = useState<Case[]>([]);
  const [loading, setLoading] = useState(false);
  const [modalVisible, setModalVisible] = useState(false);
  const [viewModalVisible, setViewModalVisible] = useState(false);
  const [editingCase, setEditingCase] = useState<Case | null>(null);
  const [viewingCase, setViewingCase] = useState<Case | null>(null);
  const [searchText, setSearchText] = useState('');
  const [selectedCategory, setSelectedCategory] = useState<string | undefined>(undefined);
  const [form] = Form.useForm();

  // 模拟数据
  useEffect(() => {
    loadCases();
  }, []);

  const loadCases = () => {
    setLoading(true);
    // 模拟加载数据
    setTimeout(() => {
      setCases([
        {
          id: 1,
          title: "查询企业法人信息",
          category: "企业查询",
          description: "根据企业名称或统一社会信用代码查询企业的法定代表人信息",
          scenario: "执法部门需要了解某企业的法定代表人信息，以便进行后续的执法活动。",
          solution: "通过关联企业基本信息表和法人信息表，可以获取完整的企业法人信息。",
          sql_queries: [
            "SELECT e.enterprise_name, e.unified_social_credit_code, p.person_name, p.id_card",
            "FROM ads_enterprise e",
            "JOIN ads_ent_legal_person lp ON e.id = lp.enterprise_id",
            "JOIN ads_people_combined p ON lp.person_id = p.id",
            "WHERE e.enterprise_name LIKE '%目标企业%'"
          ],
          tags: ["企业信息", "法人查询", "关联查询"],
          created_at: "2024-12-27",
          updated_at: "2024-12-27"
        },
        {
          id: 2,
          title: "查询企业处罚记录",
          category: "执法查询",
          description: "查询企业的历史处罚记录，包括环保处罚、税务处罚等",
          scenario: "需要评估企业的合规性，了解其历史违法违规行为。",
          solution: "通过查询多个处罚相关表，汇总企业的所有处罚记录。",
          sql_queries: [
            "-- 环保处罚",
            "SELECT 'environment' as penalty_type, penalty_date, penalty_reason, penalty_amount",
            "FROM ads_nagative_penalty_environment",
            "WHERE enterprise_id = ?",
            "UNION ALL",
            "-- 税务欠税",
            "SELECT 'tax' as penalty_type, arrears_date, arrears_reason, arrears_amount",
            "FROM ads_nagative_tax_arrears",
            "WHERE enterprise_id = ?"
          ],
          tags: ["处罚记录", "合规查询", "联合查询"],
          created_at: "2024-12-27",
          updated_at: "2024-12-27"
        }
      ]);
      setLoading(false);
    }, 500);
  };

  const handleAdd = () => {
    setEditingCase(null);
    form.resetFields();
    setModalVisible(true);
  };

  const handleEdit = (record: Case) => {
    setEditingCase(record);
    form.setFieldsValue({
      ...record,
      sql_queries: record.sql_queries.join('\n'),
      tags: record.tags.join(', ')
    });
    setModalVisible(true);
  };

  const handleView = (record: Case) => {
    setViewingCase(record);
    setViewModalVisible(true);
  };

  const handleDelete = (id: number) => {
    setCases(cases.filter(c => c.id !== id));
    message.success('删除成功');
  };

  const handleModalOk = () => {
    form.validateFields().then(values => {
      const sqlQueriesArray = values.sql_queries
        .split('\n')
        .filter((s: string) => s.trim().length > 0);
      
      const tagsArray = values.tags
        .split(',')
        .map((s: string) => s.trim())
        .filter((s: string) => s.length > 0);

      if (editingCase) {
        // 编辑
        setCases(cases.map(c => 
          c.id === editingCase.id 
            ? { 
                ...c, 
                ...values, 
                sql_queries: sqlQueriesArray,
                tags: tagsArray,
                updated_at: new Date().toISOString().split('T')[0] 
              }
            : c
        ));
        message.success('更新成功');
      } else {
        // 新增
        const newCase: Case = {
          id: Math.max(...cases.map(c => c.id), 0) + 1,
          ...values,
          sql_queries: sqlQueriesArray,
          tags: tagsArray,
          created_at: new Date().toISOString().split('T')[0],
          updated_at: new Date().toISOString().split('T')[0]
        };
        setCases([...cases, newCase]);
        message.success('添加成功');
      }
      setModalVisible(false);
      form.resetFields();
    });
  };

  const filteredCases = cases.filter(c => {
    const matchesSearch = 
      c.title.toLowerCase().includes(searchText.toLowerCase()) ||
      c.description.toLowerCase().includes(searchText.toLowerCase()) ||
      c.tags.some(tag => tag.toLowerCase().includes(searchText.toLowerCase()));
    
    const matchesCategory = !selectedCategory || c.category === selectedCategory;
    
    return matchesSearch && matchesCategory;
  });

  const categories = Array.from(new Set(cases.map(c => c.category)));

  const columns = [
    {
      title: '案例标题',
      dataIndex: 'title',
      key: 'title',
      width: '25%',
      render: (text: string) => <Text strong>{text}</Text>
    },
    {
      title: '分类',
      dataIndex: 'category',
      key: 'category',
      width: '15%',
      render: (category: string) => (
        <Tag color="blue">{category}</Tag>
      )
    },
    {
      title: '描述',
      dataIndex: 'description',
      key: 'description',
      width: '30%',
      ellipsis: true
    },
    {
      title: '标签',
      dataIndex: 'tags',
      key: 'tags',
      width: '20%',
      render: (tags: string[]) => (
        <Space wrap>
          {tags.map((tag, index) => (
            <Tag key={index} color="green">{tag}</Tag>
          ))}
        </Space>
      )
    },
    {
      title: '操作',
      key: 'action',
      width: 150,
      fixed: 'right' as const,
      render: (_: any, record: Case) => (
        <Space size="small">
          <Tooltip title="查看">
            <Button
              type="text"
              size="small"
              icon={<EyeOutlined />}
              onClick={() => handleView(record)}
            />
          </Tooltip>
          <Tooltip title="编辑">
            <Button
              type="text"
              size="small"
              icon={<EditOutlined />}
              onClick={() => handleEdit(record)}
            />
          </Tooltip>
          <Tooltip title="删除">
            <Popconfirm
              title="确定要删除这个案例吗？"
              onConfirm={() => handleDelete(record.id)}
              okText="确定"
              cancelText="取消"
            >
              <Button
                type="text"
                size="small"
                danger
                icon={<DeleteOutlined />}
              />
            </Popconfirm>
          </Tooltip>
        </Space>
      )
    }
  ];

  return (
    <div>
      <Card
        title={
          <Space>
            <ContainerOutlined />
            <span>案例库管理</span>
          </Space>
        }
        extra={
          <Space>
            <Select
              placeholder="选择分类"
              allowClear
              style={{ width: 150 }}
              value={selectedCategory}
              onChange={setSelectedCategory}
            >
              {categories.map(cat => (
                <Option key={cat} value={cat}>{cat}</Option>
              ))}
            </Select>
            <Input.Search
              placeholder="搜索案例标题、描述或标签"
              allowClear
              style={{ width: 300 }}
              prefix={<SearchOutlined />}
              onChange={(e) => setSearchText(e.target.value)}
            />
            <Button type="primary" icon={<PlusOutlined />} onClick={handleAdd}>
              添加案例
            </Button>
          </Space>
        }
      >
        <Table
          columns={columns}
          dataSource={filteredCases}
          rowKey="id"
          loading={loading}
          scroll={{ x: 1000 }}
          pagination={{
            pageSize: 10,
            showTotal: (total) => `共 ${total} 条记录`
          }}
          locale={{
            emptyText: <Empty description="暂无案例数据" />
          }}
        />
      </Card>

      {/* 编辑/新增弹窗 */}
      <Modal
        title={editingCase ? '编辑案例' : '添加案例'}
        open={modalVisible}
        onOk={handleModalOk}
        onCancel={() => {
          setModalVisible(false);
          form.resetFields();
        }}
        width={800}
      >
        <Form
          form={form}
          layout="vertical"
          requiredMark={false}
        >
          <Form.Item
            name="title"
            label="案例标题"
            rules={[{ required: true, message: '请输入案例标题' }]}
          >
            <Input placeholder="请输入案例标题" />
          </Form.Item>
          <Form.Item
            name="category"
            label="分类"
            rules={[{ required: true, message: '请选择或输入分类' }]}
          >
            <Input placeholder="如：企业查询、执法查询、统计分析等" />
          </Form.Item>
          <Form.Item
            name="description"
            label="描述"
            rules={[{ required: true, message: '请输入案例描述' }]}
          >
            <TextArea rows={2} placeholder="简要描述案例的功能和用途" />
          </Form.Item>
          <Form.Item
            name="scenario"
            label="应用场景"
            rules={[{ required: true, message: '请输入应用场景' }]}
          >
            <TextArea rows={3} placeholder="描述在什么情况下会使用这个案例" />
          </Form.Item>
          <Form.Item
            name="solution"
            label="解决方案"
            rules={[{ required: true, message: '请输入解决方案' }]}
          >
            <TextArea rows={3} placeholder="描述如何解决问题的思路和方法" />
          </Form.Item>
          <Form.Item
            name="sql_queries"
            label="SQL查询语句"
            rules={[{ required: true, message: '请输入SQL查询语句' }]}
          >
            <TextArea rows={6} placeholder="输入相关的SQL查询语句，每行一个语句" style={{ fontFamily: 'monospace' }} />
          </Form.Item>
          <Form.Item
            name="tags"
            label="标签"
            extra="多个标签请用逗号分隔"
          >
            <Input placeholder="如：企业信息, 法人查询, 关联查询" />
          </Form.Item>
        </Form>
      </Modal>

      {/* 查看详情弹窗 */}
      <Modal
        title="案例详情"
        open={viewModalVisible}
        onCancel={() => setViewModalVisible(false)}
        footer={[
          <Button key="close" onClick={() => setViewModalVisible(false)}>
            关闭
          </Button>
        ]}
        width={800}
      >
        {viewingCase && (
          <div>
            <Title level={4}>{viewingCase.title}</Title>
            <Space>
              <Tag color="blue">{viewingCase.category}</Tag>
              {viewingCase.tags.map((tag, index) => (
                <Tag key={index} color="green">{tag}</Tag>
              ))}
            </Space>
            
            <Divider />
            
            <div style={{ marginBottom: 16 }}>
              <Text strong>描述：</Text>
              <Paragraph>{viewingCase.description}</Paragraph>
            </div>
            
            <div style={{ marginBottom: 16 }}>
              <Text strong>应用场景：</Text>
              <Paragraph>{viewingCase.scenario}</Paragraph>
            </div>
            
            <div style={{ marginBottom: 16 }}>
              <Text strong>解决方案：</Text>
              <Paragraph>{viewingCase.solution}</Paragraph>
            </div>
            
            <div>
              <Text strong>SQL查询语句：</Text>
              <pre style={{ 
                background: '#f5f5f5', 
                padding: 12, 
                borderRadius: 4, 
                overflow: 'auto',
                marginTop: 8
              }}>
                {viewingCase.sql_queries.join('\n')}
              </pre>
            </div>
          </div>
        )}
      </Modal>
    </div>
  );
};

export default CaseLibrary;
