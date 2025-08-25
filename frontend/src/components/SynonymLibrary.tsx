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
  Tooltip
} from 'antd';
import {
  PlusOutlined,
  EditOutlined,
  DeleteOutlined,
  SearchOutlined,
  SyncOutlined,
  LinkOutlined
} from '@ant-design/icons';

const { Title, Text } = Typography;
const { TextArea } = Input;

interface SynonymGroup {
  id: number;
  main_word: string;
  synonyms: string[];
  context: string;
  created_at: string;
  updated_at: string;
}

const SynonymLibrary: React.FC = () => {
  const [synonymGroups, setSynonymGroups] = useState<SynonymGroup[]>([]);
  const [loading, setLoading] = useState(false);
  const [modalVisible, setModalVisible] = useState(false);
  const [editingGroup, setEditingGroup] = useState<SynonymGroup | null>(null);
  const [searchText, setSearchText] = useState('');
  const [form] = Form.useForm();

  // 模拟数据
  useEffect(() => {
    loadSynonymGroups();
  }, []);

  const loadSynonymGroups = () => {
    setLoading(true);
    // 模拟加载数据
    setTimeout(() => {
      setSynonymGroups([
        {
          id: 1,
          main_word: "企业",
          synonyms: ["公司", "单位", "组织", "机构", "厂商"],
          context: "业务主体",
          created_at: "2024-12-27",
          updated_at: "2024-12-27"
        },
        {
          id: 2,
          main_word: "法人",
          synonyms: ["法定代表人", "法人代表", "法定代表", "企业法人"],
          context: "法律主体",
          created_at: "2024-12-27",
          updated_at: "2024-12-27"
        },
        {
          id: 3,
          main_word: "处罚",
          synonyms: ["处分", "惩罚", "惩处", "制裁", "处置"],
          context: "执法行为",
          created_at: "2024-12-27",
          updated_at: "2024-12-27"
        }
      ]);
      setLoading(false);
    }, 500);
  };

  const handleAdd = () => {
    setEditingGroup(null);
    form.resetFields();
    setModalVisible(true);
  };

  const handleEdit = (record: SynonymGroup) => {
    setEditingGroup(record);
    form.setFieldsValue({
      ...record,
      synonyms: record.synonyms.join(', ')
    });
    setModalVisible(true);
  };

  const handleDelete = (id: number) => {
    // 模拟删除
    setSynonymGroups(synonymGroups.filter(group => group.id !== id));
    message.success('删除成功');
  };

  const handleModalOk = () => {
    form.validateFields().then(values => {
      const synonymsArray = values.synonyms
        .split(',')
        .map((s: string) => s.trim())
        .filter((s: string) => s.length > 0);

      if (editingGroup) {
        // 编辑
        setSynonymGroups(synonymGroups.map(group => 
          group.id === editingGroup.id 
            ? { 
                ...group, 
                ...values, 
                synonyms: synonymsArray,
                updated_at: new Date().toISOString().split('T')[0] 
              }
            : group
        ));
        message.success('更新成功');
      } else {
        // 新增
        const newGroup: SynonymGroup = {
          id: Math.max(...synonymGroups.map(g => g.id), 0) + 1,
          ...values,
          synonyms: synonymsArray,
          created_at: new Date().toISOString().split('T')[0],
          updated_at: new Date().toISOString().split('T')[0]
        };
        setSynonymGroups([...synonymGroups, newGroup]);
        message.success('添加成功');
      }
      setModalVisible(false);
      form.resetFields();
    });
  };

  const filteredGroups = synonymGroups.filter(group =>
    group.main_word.toLowerCase().includes(searchText.toLowerCase()) ||
    group.synonyms.some(s => s.toLowerCase().includes(searchText.toLowerCase())) ||
    group.context.toLowerCase().includes(searchText.toLowerCase())
  );

  const columns = [
    {
      title: '主词',
      dataIndex: 'main_word',
      key: 'main_word',
      width: '15%',
      render: (text: string) => (
        <Text strong>
          <LinkOutlined /> {text}
        </Text>
      )
    },
    {
      title: '同义词',
      dataIndex: 'synonyms',
      key: 'synonyms',
      width: '50%',
      render: (synonyms: string[]) => (
        <Space wrap>
          {synonyms.map((synonym, index) => (
            <Tag key={index} color="blue">
              {synonym}
            </Tag>
          ))}
        </Space>
      )
    },
    {
      title: '使用场景',
      dataIndex: 'context',
      key: 'context',
      width: '20%',
      render: (context: string) => (
        <Tag color="green">{context}</Tag>
      )
    },
    {
      title: '操作',
      key: 'action',
      width: 100,
      fixed: 'right' as const,
      render: (_: any, record: SynonymGroup) => (
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
              title="确定要删除这组同义词吗？"
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
            <SyncOutlined />
            <span>同义词库管理</span>
          </Space>
        }
        extra={
          <Space>
            <Input.Search
              placeholder="搜索主词、同义词或场景"
              allowClear
              style={{ width: 300 }}
              prefix={<SearchOutlined />}
              onChange={(e) => setSearchText(e.target.value)}
            />
            <Button type="primary" icon={<PlusOutlined />} onClick={handleAdd}>
              添加同义词组
            </Button>
          </Space>
        }
      >
        <Table
          columns={columns}
          dataSource={filteredGroups}
          rowKey="id"
          loading={loading}
          scroll={{ x: 800 }}
          pagination={{
            pageSize: 10,
            showTotal: (total) => `共 ${total} 条记录`
          }}
          locale={{
            emptyText: <Empty description="暂无同义词数据" />
          }}
        />
      </Card>

      <Modal
        title={editingGroup ? '编辑同义词组' : '添加同义词组'}
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
            name="main_word"
            label="主词"
            rules={[{ required: true, message: '请输入主词' }]}
          >
            <Input placeholder="请输入主要词汇" />
          </Form.Item>
          <Form.Item
            name="synonyms"
            label="同义词"
            rules={[{ required: true, message: '请输入同义词' }]}
            extra="多个同义词请用逗号分隔"
          >
            <TextArea
              rows={3}
              placeholder="如：公司, 单位, 组织, 机构"
            />
          </Form.Item>
          <Form.Item
            name="context"
            label="使用场景"
            rules={[{ required: true, message: '请输入使用场景' }]}
          >
            <Input placeholder="如：业务主体、法律用语、技术术语等" />
          </Form.Item>
        </Form>
      </Modal>
    </div>
  );
};

export default SynonymLibrary;
