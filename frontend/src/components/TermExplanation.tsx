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
          term: "涉恐人员",
          explanation: "指涉嫌参与恐怖主义活动或与恐怖组织有关联的人员，需要重点监控和管理。",
          category: "公安术语",
          created_at: "2024-12-27",
          updated_at: "2024-12-27"
        },
        {
          id: 2,
          term: "重点人员",
          explanation: "指因各种原因需要公安机关重点关注、管控的人员，包括涉恐、涉稳、涉毒等人员。",
          category: "公安术语",
          created_at: "2024-12-27",
          updated_at: "2024-12-27"
        },
        {
          id: 3,
          term: "偷渡人员",
          explanation: "指非法越境进出国（边）境的人员，违反了国家出入境管理法律法规。",
          category: "公安术语",
          created_at: "2024-12-27",
          updated_at: "2024-12-27"
        },
        {
          id: 4,
          term: "三非人员",
          explanation: "指非法入境、非法居留、非法就业的外国人，是出入境管理的重点对象。",
          category: "公安术语",
          created_at: "2024-12-27",
          updated_at: "2024-12-27"
        },
        {
          id: 5,
          term: "实有人口",
          explanation: "指在某一时点实际居住在某地的全部人口，包括户籍人口和流动人口。",
          category: "人口管理",
          created_at: "2024-12-27",
          updated_at: "2024-12-27"
        },
        {
          id: 6,
          term: "流动人口",
          explanation: "指离开户籍所在地到其他地区居住的人口，是人口管理的重要对象。",
          category: "人口管理",
          created_at: "2024-12-27",
          updated_at: "2024-12-27"
        },
        {
          id: 7,
          term: "案件串并",
          explanation: "指将具有关联性的多个案件进行合并侦查，提高办案效率和质量。",
          category: "案件管理",
          created_at: "2024-12-27",
          updated_at: "2024-12-27"
        },
        {
          id: 8,
          term: "预警研判",
          explanation: "基于大数据分析对可能发生的安全风险进行预测和评估，提前采取防范措施。",
          category: "情报分析",
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
