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
  Tooltip
} from 'antd';
import {
  PlusOutlined,
  EditOutlined,
  DeleteOutlined,
  SearchOutlined,
  FileTextOutlined
} from '@ant-design/icons';

const { Title, Text } = Typography;
const { TextArea } = Input;

interface Term {
  id: number;
  term: string;
  explanation: string;
  category: string;
  created_at: string;
  updated_at: string;
}

const TermExplanation: React.FC = () => {
  const [terms, setTerms] = useState<Term[]>([]);
  const [loading, setLoading] = useState(false);
  const [modalVisible, setModalVisible] = useState(false);
  const [editingTerm, setEditingTerm] = useState<Term | null>(null);
  const [searchText, setSearchText] = useState('');
  const [form] = Form.useForm();

  // 模拟数据
  useEffect(() => {
    loadTerms();
  }, []);

  const loadTerms = () => {
    setLoading(true);
    // 模拟加载数据
    setTimeout(() => {
      setTerms([
        {
          id: 1,
          term: "DWD层",
          explanation: "数据仓库明细层（Data Warehouse Detail），是对ODS层数据进行清洗、标准化、维度建模后的明细数据层。",
          category: "数据仓库",
          created_at: "2024-12-27",
          updated_at: "2024-12-27"
        },
        {
          id: 2,
          term: "ODS层",
          explanation: "操作数据存储层（Operational Data Store），是数据仓库源系统数据的临时存储区域，保持源系统数据原貌。",
          category: "数据仓库",
          created_at: "2024-12-27",
          updated_at: "2024-12-27"
        },
        {
          id: 3,
          term: "ADS层",
          explanation: "应用数据服务层（Application Data Service），是面向业务定制的应用数据层，直接提供给业务查询使用。",
          category: "数据仓库",
          created_at: "2024-12-27",
          updated_at: "2024-12-27"
        }
      ]);
      setLoading(false);
    }, 500);
  };

  const handleAdd = () => {
    setEditingTerm(null);
    form.resetFields();
    setModalVisible(true);
  };

  const handleEdit = (record: Term) => {
    setEditingTerm(record);
    form.setFieldsValue(record);
    setModalVisible(true);
  };

  const handleDelete = (id: number) => {
    // 模拟删除
    setTerms(terms.filter(term => term.id !== id));
    message.success('删除成功');
  };

  const handleModalOk = () => {
    form.validateFields().then(values => {
      if (editingTerm) {
        // 编辑
        setTerms(terms.map(term => 
          term.id === editingTerm.id 
            ? { ...term, ...values, updated_at: new Date().toISOString().split('T')[0] }
            : term
        ));
        message.success('更新成功');
      } else {
        // 新增
        const newTerm: Term = {
          id: Math.max(...terms.map(t => t.id), 0) + 1,
          ...values,
          created_at: new Date().toISOString().split('T')[0],
          updated_at: new Date().toISOString().split('T')[0]
        };
        setTerms([...terms, newTerm]);
        message.success('添加成功');
      }
      setModalVisible(false);
      form.resetFields();
    });
  };

  const filteredTerms = terms.filter(term =>
    term.term.toLowerCase().includes(searchText.toLowerCase()) ||
    term.explanation.toLowerCase().includes(searchText.toLowerCase()) ||
    term.category.toLowerCase().includes(searchText.toLowerCase())
  );

  const columns = [
    {
      title: '术语',
      dataIndex: 'term',
      key: 'term',
      width: '20%',
      render: (text: string) => <Text strong>{text}</Text>
    },
    {
      title: '解释',
      dataIndex: 'explanation',
      key: 'explanation',
      width: '50%'
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
      title: '操作',
      key: 'action',
      width: 100,
      fixed: 'right' as const,
      render: (_: any, record: Term) => (
        <Space size="small">
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
              title="确定要删除这个术语吗？"
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
            <FileTextOutlined />
            <span>术语解释管理</span>
          </Space>
        }
        extra={
          <Space>
            <Input.Search
              placeholder="搜索术语、解释或分类"
              allowClear
              style={{ width: 300 }}
              prefix={<SearchOutlined />}
              onChange={(e) => setSearchText(e.target.value)}
            />
            <Button type="primary" icon={<PlusOutlined />} onClick={handleAdd}>
              添加术语
            </Button>
          </Space>
        }
      >
        <Table
          columns={columns}
          dataSource={filteredTerms}
          rowKey="id"
          loading={loading}
          scroll={{ x: 800 }}
          pagination={{
            pageSize: 10,
            showTotal: (total) => `共 ${total} 条记录`
          }}
          locale={{
            emptyText: <Empty description="暂无术语数据" />
          }}
        />
      </Card>

      <Modal
        title={editingTerm ? '编辑术语' : '添加术语'}
        open={modalVisible}
        onOk={handleModalOk}
        onCancel={() => {
          setModalVisible(false);
          form.resetFields();
        }}
        width={600}
      >
        <Form
          form={form}
          layout="vertical"
          requiredMark={false}
        >
          <Form.Item
            name="term"
            label="术语"
            rules={[{ required: true, message: '请输入术语' }]}
          >
            <Input placeholder="请输入术语名称" />
          </Form.Item>
          <Form.Item
            name="explanation"
            label="解释"
            rules={[{ required: true, message: '请输入术语解释' }]}
          >
            <TextArea
              rows={4}
              placeholder="请输入术语的详细解释"
            />
          </Form.Item>
          <Form.Item
            name="category"
            label="分类"
            rules={[{ required: true, message: '请输入术语分类' }]}
          >
            <Input placeholder="如：数据仓库、业务术语、技术术语等" />
          </Form.Item>
        </Form>
      </Modal>
    </div>
  );
};

export default TermExplanation;
