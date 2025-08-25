import React, { useState, useEffect } from 'react';
import {
  Card,
  Table,
  Button,
  Modal,
  Form,
  Input,
  Select,
  Space,
  Popconfirm,
  message,
  Tag,
  Typography,
  Empty,
  Tooltip,
  InputNumber,
  Spin,
  Alert,
  Row,
  Col
} from 'antd';
import {
  PlusOutlined,
  EditOutlined,
  DeleteOutlined,
  SearchOutlined,
  ApiOutlined,
  CheckCircleOutlined,
  CloseCircleOutlined,
  LoadingOutlined,
  DatabaseOutlined
} from '@ant-design/icons';

const { Title, Text } = Typography;
const { Option } = Select;
const { Password } = Input;

interface DataSource {
  id: number;
  name: string;
  type: string;
  connectionType: string;
  host: string;
  port: number;
  database: string;
  driverUrl: string;
  username: string;
  password: string;
  status: 'connected' | 'disconnected' | 'error';
  created_at: string;
  updated_at: string;
}

const DataSourceManagement: React.FC = () => {
  const [dataSources, setDataSources] = useState<DataSource[]>([]);
  const [loading, setLoading] = useState(false);
  const [modalVisible, setModalVisible] = useState(false);
  const [editingSource, setEditingSource] = useState<DataSource | null>(null);
  const [searchText, setSearchText] = useState('');
  const [testing, setTesting] = useState(false);
  const [form] = Form.useForm();

  // 监听表单字段变化，自动生成DRIVER URL
  const handleFormValuesChange = (changedValues: any, allValues: any) => {
    if ('host' in changedValues || 'port' in changedValues || 'database' in changedValues) {
      const { host, port, database } = allValues;
      if (host && port && database) {
        const driverUrl = `jdbc:odps:${host}:${port}?project=${database}&charset=UTF-8`;
        form.setFieldsValue({ driverUrl });
      } else if (!host && !port && !database) {
        form.setFieldsValue({ driverUrl: '' });
      }
    }
  };

  // 模拟数据
  useEffect(() => {
    loadDataSources();
  }, []);

  const loadDataSources = () => {
    setLoading(true);
    // 模拟加载数据
    setTimeout(() => {
      setDataSources([
        {
          id: 1,
          name: "生产环境ODPS",
          type: "ODPS",
          connectionType: "JDBC连接",
          host: "192.168.1.1",
          port: 1000,
          database: "prod_db",
          driverUrl: "jdbc:odps:?project=prod&charset=UTF-8",
          username: "admin",
          password: "******",
          status: "connected",
          created_at: "2024-12-27",
          updated_at: "2024-12-27"
        },
        {
          id: 2,
          name: "测试环境ODPS",
          type: "ODPS",
          connectionType: "JDBC连接",
          host: "10.0.0.1",
          port: 1000,
          database: "test_db",
          driverUrl: "jdbc:odps:?project=test&charset=UTF-8",
          username: "test_user",
          password: "******",
          status: "disconnected",
          created_at: "2024-12-27",
          updated_at: "2024-12-27"
        }
      ]);
      setLoading(false);
    }, 500);
  };

  const handleAdd = () => {
    setEditingSource(null);
    form.resetFields();
    form.setFieldsValue({
      connectionType: 'JDBC连接',
      type: 'ODPS',
      port: 1000
    });
    setModalVisible(true);
  };

  const handleEdit = (record: DataSource) => {
    setEditingSource(record);
    form.setFieldsValue({
      ...record,
      password: '' // 不显示真实密码
    });
    setModalVisible(true);
  };

  const handleDelete = (id: number) => {
    setDataSources(dataSources.filter(source => source.id !== id));
    message.success('删除成功');
  };

  const handleTestConnection = () => {
    form.validateFields(['host', 'port', 'database', 'username', 'password']).then(values => {
      setTesting(true);
      // 模拟测试连接
      setTimeout(() => {
        setTesting(false);
        message.success('连接测试成功！');
      }, 2000);
    }).catch(() => {
      message.error('请填写必要的连接信息');
    });
  };

  const handleModalOk = () => {
    form.validateFields().then(values => {
      if (editingSource) {
        // 编辑
        setDataSources(dataSources.map(source => 
          source.id === editingSource.id 
            ? { 
                ...source, 
                ...values, 
                password: values.password || source.password, // 如果没有输入新密码，保留原密码
                updated_at: new Date().toISOString().split('T')[0] 
              }
            : source
        ));
        message.success('更新成功');
      } else {
        // 新增
        const newSource: DataSource = {
          id: Math.max(...dataSources.map(s => s.id), 0) + 1,
          ...values,
          name: values.name || `${values.type}_${values.database}`,
          status: 'disconnected',
          created_at: new Date().toISOString().split('T')[0],
          updated_at: new Date().toISOString().split('T')[0]
        };
        setDataSources([...dataSources, newSource]);
        message.success('添加成功');
      }
      setModalVisible(false);
      form.resetFields();
    });
  };

  const filteredSources = dataSources.filter(source =>
    source.name.toLowerCase().includes(searchText.toLowerCase()) ||
    source.type.toLowerCase().includes(searchText.toLowerCase()) ||
    source.database.toLowerCase().includes(searchText.toLowerCase()) ||
    source.host.toLowerCase().includes(searchText.toLowerCase())
  );

  const columns = [
    {
      title: '数据源名称',
      dataIndex: 'name',
      key: 'name',
      width: '25%',
      render: (text: string) => <Text strong>{text}</Text>
    },
    {
      title: '类型',
      dataIndex: 'type',
      key: 'type',
      width: '10%',
      render: (type: string) => (
        <Tag color="blue" icon={<DatabaseOutlined />}>{type}</Tag>
      )
    },
    {
      title: '主机地址',
      dataIndex: 'host',
      key: 'host',
      width: '20%'
    },
    {
      title: '数据库',
      dataIndex: 'database',
      key: 'database',
      width: '20%'
    },
    {
      title: '状态',
      dataIndex: 'status',
      key: 'status',
      width: '15%',
      render: (status: string) => {
        const config = {
          connected: { color: 'green', icon: <CheckCircleOutlined />, text: '已连接' },
          disconnected: { color: 'default', icon: <CloseCircleOutlined />, text: '未连接' },
          error: { color: 'red', icon: <CloseCircleOutlined />, text: '连接失败' }
        };
        const { color, icon, text } = config[status as keyof typeof config];
        return <Tag color={color} icon={icon}>{text}</Tag>;
      }
    },
    {
      title: '操作',
      key: 'action',
      width: '10%',
      fixed: 'right' as const,
      render: (_: any, record: DataSource) => (
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
              title="确定要删除这个数据源吗？"
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
            <ApiOutlined />
            <span>数据源管理</span>
          </Space>
        }
        extra={
          <Space>
            <Input.Search
              placeholder="搜索数据源名称、类型或地址"
              allowClear
              style={{ width: 300 }}
              prefix={<SearchOutlined />}
              onChange={(e) => setSearchText(e.target.value)}
            />
            <Button type="primary" icon={<PlusOutlined />} onClick={handleAdd}>
              添加数据源
            </Button>
          </Space>
        }
      >
        <Table
          columns={columns}
          dataSource={filteredSources}
          rowKey="id"
          loading={loading}
          scroll={{ x: 1000 }}
          pagination={{
            pageSize: 10,
            showTotal: (total) => `共 ${total} 条记录`
          }}
          locale={{
            emptyText: <Empty description="暂无数据源" />
          }}
        />
      </Card>

      <Modal
        title={editingSource ? '编辑数据源' : '添加数据源'}
        open={modalVisible}
        onOk={handleModalOk}
        onCancel={() => {
          setModalVisible(false);
          form.resetFields();
        }}
        width={600}
        footer={[
          <Button
            key="test"
            type="default"
            icon={testing ? <LoadingOutlined /> : <DatabaseOutlined />}
            onClick={handleTestConnection}
            disabled={testing}
          >
            {testing ? '测试中...' : '连接测试'}
          </Button>,
          <Button key="cancel" onClick={() => {
            setModalVisible(false);
            form.resetFields();
          }}>
            取消
          </Button>,
          <Button key="submit" type="primary" onClick={handleModalOk}>
            确定
          </Button>
        ]}
      >
        <Form
          form={form}
          layout="vertical"
          requiredMark={false}
          onValuesChange={handleFormValuesChange}
        >
          <Form.Item
            name="name"
            label="数据源名称"
          >
            <Input placeholder="请输入数据源名称（可选）" />
          </Form.Item>



          <Form.Item
            name="connectionType"
            label={
              <Space>
                <span style={{ color: '#ff4d4f' }}>*</span>
                <span>连接方式</span>
              </Space>
            }
            rules={[{ required: true, message: '请选择连接方式' }]}
          >
            <Select placeholder="请选择连接方式">
              <Option value="JDBC连接">JDBC连接</Option>
              <Option value="ODBC连接">ODBC连接</Option>
            </Select>
          </Form.Item>

          <Form.Item
            name="type"
            label={
              <Space>
                <span style={{ color: '#ff4d4f' }}>*</span>
                <span>数据源类型</span>
              </Space>
            }
            rules={[{ required: true, message: '请选择数据源类型' }]}
          >
            <Select placeholder="请选择数据源类型">
              <Option value="ODPS">ODPS</Option>
              <Option value="MySQL" disabled>MySQL（暂不支持）</Option>
              <Option value="PostgreSQL" disabled>PostgreSQL（暂不支持）</Option>
              <Option value="Oracle" disabled>Oracle（暂不支持）</Option>
            </Select>
          </Form.Item>

          <Row gutter={16}>
            <Col span={16}>
              <Form.Item
                name="host"
                label={
                  <Space>
                    <span style={{ color: '#ff4d4f' }}>*</span>
                    <span>主机地址</span>
                  </Space>
                }
                rules={[{ required: true, message: '请输入主机地址' }]}
              >
                <Input placeholder="192.168.1.1" />
              </Form.Item>
            </Col>
            <Col span={8}>
              <Form.Item
                name="port"
                label={
                  <Space>
                    <span style={{ color: '#ff4d4f' }}>*</span>
                    <span>端口号</span>
                  </Space>
                }
                rules={[{ required: true, message: '请输入端口号' }]}
              >
                <InputNumber min={1} max={65535} style={{ width: '100%' }} placeholder="1000" />
              </Form.Item>
            </Col>
          </Row>

          <Form.Item
            name="database"
            label={
              <Space>
                <span style={{ color: '#ff4d4f' }}>*</span>
                <span>数据库</span>
              </Space>
            }
            rules={[{ required: true, message: '请输入数据库' }]}
          >
            <Input placeholder="请输入数据库" />
          </Form.Item>

          <Form.Item
            name="driverUrl"
            label="DRIVER URL"
          >
            <Input 
              placeholder="自动根据主机地址、端口号和数据库生成" 
              readOnly
              style={{ backgroundColor: '#f5f5f5' }}
            />
          </Form.Item>

          <Form.Item
            name="username"
            label={
              <Space>
                <span style={{ color: '#ff4d4f' }}>*</span>
                <span>账号</span>
              </Space>
            }
            rules={[{ required: true, message: '请输入账号' }]}
          >
            <Input placeholder="请输入账号" />
          </Form.Item>

          <Form.Item
            name="password"
            label={
              <Space>
                {!editingSource && <span style={{ color: '#ff4d4f' }}>*</span>}
                <span>密码</span>
              </Space>
            }
            rules={[
              { required: !editingSource, message: '请输入密码' }
            ]}
            extra={editingSource ? "留空表示不修改密码" : undefined}
          >
            <Password placeholder="请输入密码" />
          </Form.Item>
        </Form>
      </Modal>
    </div>
  );
};

export default DataSourceManagement;
