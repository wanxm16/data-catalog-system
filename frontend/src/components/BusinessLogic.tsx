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
  Tree,
  Row,
  Col,
  Divider,
  Steps,
  Tooltip
} from 'antd';
import {
  PlusOutlined,
  EditOutlined,
  DeleteOutlined,
  SearchOutlined,
  BulbOutlined,
  NodeIndexOutlined,
  ArrowRightOutlined
} from '@ant-design/icons';

const { Title, Text, Paragraph } = Typography;
const { TextArea } = Input;
const { Option } = Select;
const { Step } = Steps;

interface BusinessLogicItem {
  id: number;
  name: string;
  category: string;
  description: string;
  preconditions: string[];
  steps: {
    order: number;
    description: string;
    tables?: string[];
  }[];
  outputs: string[];
  notes: string;
  created_at: string;
  updated_at: string;
}

const BusinessLogic: React.FC = () => {
  const [logicItems, setLogicItems] = useState<BusinessLogicItem[]>([]);
  const [loading, setLoading] = useState(false);
  const [modalVisible, setModalVisible] = useState(false);
  const [viewModalVisible, setViewModalVisible] = useState(false);
  const [editingItem, setEditingItem] = useState<BusinessLogicItem | null>(null);
  const [viewingItem, setViewingItem] = useState<BusinessLogicItem | null>(null);
  const [searchText, setSearchText] = useState('');
  const [selectedCategory, setSelectedCategory] = useState<string | undefined>(undefined);
  const [form] = Form.useForm();

  // 模拟数据
  useEffect(() => {
    loadLogicItems();
  }, []);

  const loadLogicItems = () => {
    setLoading(true);
    // 模拟加载数据
    setTimeout(() => {
      setLogicItems([
        {
          id: 1,
          name: "企业风险评估流程",
          category: "风险管理",
          description: "评估企业的综合风险等级，包括法律风险、财务风险、经营风险等多个维度",
          preconditions: [
            "企业基本信息已录入系统",
            "相关处罚、欠税、诉讼等负面信息已更新"
          ],
          steps: [
            {
              order: 1,
              description: "收集企业基本信息",
              tables: ["ads_enterprise_info", "ads_ent_legal_person"]
            },
            {
              order: 2,
              description: "查询企业负面信息",
              tables: ["ads_nagative_penalty_dual", "ads_nagative_tax_arrears", "ads_nagative_bankruptcy"]
            },
            {
              order: 3,
              description: "计算各维度风险分值",
              tables: []
            },
            {
              order: 4,
              description: "综合评估风险等级",
              tables: []
            }
          ],
          outputs: [
            "企业综合风险等级（高/中/低）",
            "各维度风险分值",
            "风险详情报告"
          ],
          notes: "风险评估模型需要定期更新权重参数",
          created_at: "2024-12-27",
          updated_at: "2024-12-27"
        },
        {
          id: 2,
          name: "关联企业查询逻辑",
          category: "关系分析",
          description: "通过股权、高管、法人等多维度关系，查找企业的关联企业网络",
          preconditions: [
            "企业股权信息已更新",
            "高管人员信息已更新"
          ],
          steps: [
            {
              order: 1,
              description: "查询目标企业的股东信息",
              tables: ["ads_ent_shareholder"]
            },
            {
              order: 2,
              description: "查询目标企业的高管信息",
              tables: ["ads_ent_senior_staff"]
            },
            {
              order: 3,
              description: "通过股东和高管查找其他关联企业",
              tables: ["ads_enterprise_info", "ads_people_relation"]
            },
            {
              order: 4,
              description: "构建企业关系图谱",
              tables: []
            }
          ],
          outputs: [
            "直接关联企业列表",
            "间接关联企业列表",
            "企业关系图谱"
          ],
          notes: "关联深度建议不超过3层，避免数据量过大",
          created_at: "2024-12-27",
          updated_at: "2024-12-27"
        }
      ]);
      setLoading(false);
    }, 500);
  };

  const handleAdd = () => {
    setEditingItem(null);
    form.resetFields();
    form.setFieldsValue({
      steps: [{ order: 1, description: '', tables: [] }]
    });
    setModalVisible(true);
  };

  const handleEdit = (record: BusinessLogicItem) => {
    setEditingItem(record);
    form.setFieldsValue({
      ...record,
      preconditions: record.preconditions.join('\n'),
      outputs: record.outputs.join('\n'),
      steps: record.steps.map(step => ({
        ...step,
        tables: step.tables?.join(', ') || ''
      }))
    });
    setModalVisible(true);
  };

  const handleView = (record: BusinessLogicItem) => {
    setViewingItem(record);
    setViewModalVisible(true);
  };

  const handleDelete = (id: number) => {
    setLogicItems(logicItems.filter(item => item.id !== id));
    message.success('删除成功');
  };

  const handleModalOk = () => {
    form.validateFields().then(values => {
      const preconditionsArray = values.preconditions
        .split('\n')
        .filter((s: string) => s.trim().length > 0);
      
      const outputsArray = values.outputs
        .split('\n')
        .filter((s: string) => s.trim().length > 0);

      const stepsArray = values.steps.map((step: any) => ({
        ...step,
        tables: step.tables
          ? step.tables.split(',').map((t: string) => t.trim()).filter((t: string) => t.length > 0)
          : []
      }));

      if (editingItem) {
        // 编辑
        setLogicItems(logicItems.map(item => 
          item.id === editingItem.id 
            ? { 
                ...item, 
                ...values, 
                preconditions: preconditionsArray,
                outputs: outputsArray,
                steps: stepsArray,
                updated_at: new Date().toISOString().split('T')[0] 
              }
            : item
        ));
        message.success('更新成功');
      } else {
        // 新增
        const newItem: BusinessLogicItem = {
          id: Math.max(...logicItems.map(item => item.id), 0) + 1,
          ...values,
          preconditions: preconditionsArray,
          outputs: outputsArray,
          steps: stepsArray,
          created_at: new Date().toISOString().split('T')[0],
          updated_at: new Date().toISOString().split('T')[0]
        };
        setLogicItems([...logicItems, newItem]);
        message.success('添加成功');
      }
      setModalVisible(false);
      form.resetFields();
    });
  };

  const filteredItems = logicItems.filter(item => {
    const matchesSearch = 
      item.name.toLowerCase().includes(searchText.toLowerCase()) ||
      item.description.toLowerCase().includes(searchText.toLowerCase());
    
    const matchesCategory = !selectedCategory || item.category === selectedCategory;
    
    return matchesSearch && matchesCategory;
  });

  const categories = Array.from(new Set(logicItems.map(item => item.category)));

  const columns = [
    {
      title: '业务逻辑名称',
      dataIndex: 'name',
      key: 'name',
      width: '25%',
      render: (text: string) => <Text strong>{text}</Text>
    },
    {
      title: '分类',
      dataIndex: 'category',
      key: 'category',
      width: '15%',
      render: (category: string) => (
        <Tag color="purple">{category}</Tag>
      )
    },
    {
      title: '描述',
      dataIndex: 'description',
      key: 'description',
      width: '35%',
      ellipsis: true
    },
    {
      title: '步骤数',
      dataIndex: 'steps',
      key: 'steps',
      width: '10%',
      render: (steps: any[]) => (
        <Tag color="blue">{steps.length} 步</Tag>
      )
    },
    {
      title: '操作',
      key: 'action',
      width: 150,
      fixed: 'right' as const,
      render: (_: any, record: BusinessLogicItem) => (
        <Space size="small">
          <Tooltip title="查看">
            <Button
              type="text"
              size="small"
              icon={<NodeIndexOutlined />}
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
              title="确定要删除这个业务逻辑吗？"
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
            <BulbOutlined />
            <span>业务逻辑解释</span>
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
              placeholder="搜索业务逻辑名称或描述"
              allowClear
              style={{ width: 300 }}
              prefix={<SearchOutlined />}
              onChange={(e) => setSearchText(e.target.value)}
            />
            <Button type="primary" icon={<PlusOutlined />} onClick={handleAdd}>
              添加业务逻辑
            </Button>
          </Space>
        }
      >
        <Table
          columns={columns}
          dataSource={filteredItems}
          rowKey="id"
          loading={loading}
          scroll={{ x: 1000 }}
          pagination={{
            pageSize: 10,
            showTotal: (total) => `共 ${total} 条记录`
          }}
          locale={{
            emptyText: <Empty description="暂无业务逻辑数据" />
          }}
        />
      </Card>

      {/* 编辑/新增弹窗 */}
      <Modal
        title={editingItem ? '编辑业务逻辑' : '添加业务逻辑'}
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
          <Row gutter={16}>
            <Col span={16}>
              <Form.Item
                name="name"
                label="业务逻辑名称"
                rules={[{ required: true, message: '请输入业务逻辑名称' }]}
              >
                <Input placeholder="请输入业务逻辑名称" />
              </Form.Item>
            </Col>
            <Col span={8}>
              <Form.Item
                name="category"
                label="分类"
                rules={[{ required: true, message: '请输入分类' }]}
              >
                <Input placeholder="如：风险管理、关系分析" />
              </Form.Item>
            </Col>
          </Row>
          
          <Form.Item
            name="description"
            label="描述"
            rules={[{ required: true, message: '请输入描述' }]}
          >
            <TextArea rows={2} placeholder="简要描述业务逻辑的目的和作用" />
          </Form.Item>

          <Form.Item
            name="preconditions"
            label="前置条件"
            rules={[{ required: true, message: '请输入前置条件' }]}
          >
            <TextArea rows={3} placeholder="每行一个前置条件" />
          </Form.Item>

          <Form.Item label="执行步骤">
            <Form.List name="steps">
              {(fields, { add, remove }) => (
                <>
                  {fields.map(({ key, name, ...restField }) => (
                    <Space key={key} style={{ display: 'flex', marginBottom: 8 }} align="baseline">
                      <Form.Item
                        {...restField}
                        name={[name, 'order']}
                        rules={[{ required: true, message: '步骤序号' }]}
                        style={{ width: 80 }}
                      >
                        <Input placeholder="序号" type="number" />
                      </Form.Item>
                      <Form.Item
                        {...restField}
                        name={[name, 'description']}
                        rules={[{ required: true, message: '请输入步骤描述' }]}
                        style={{ width: 300 }}
                      >
                        <Input placeholder="步骤描述" />
                      </Form.Item>
                      <Form.Item
                        {...restField}
                        name={[name, 'tables']}
                        style={{ width: 200 }}
                      >
                        <Input placeholder="涉及的表（逗号分隔）" />
                      </Form.Item>
                      <Button onClick={() => remove(name)} danger>
                        删除
                      </Button>
                    </Space>
                  ))}
                  <Form.Item>
                    <Button type="dashed" onClick={() => add()} block icon={<PlusOutlined />}>
                      添加步骤
                    </Button>
                  </Form.Item>
                </>
              )}
            </Form.List>
          </Form.Item>

          <Form.Item
            name="outputs"
            label="输出结果"
            rules={[{ required: true, message: '请输入输出结果' }]}
          >
            <TextArea rows={3} placeholder="每行一个输出结果" />
          </Form.Item>

          <Form.Item
            name="notes"
            label="注意事项"
          >
            <TextArea rows={2} placeholder="可选，填写使用时的注意事项" />
          </Form.Item>
        </Form>
      </Modal>

      {/* 查看详情弹窗 */}
      <Modal
        title="业务逻辑详情"
        open={viewModalVisible}
        onCancel={() => setViewModalVisible(false)}
        footer={[
          <Button key="close" onClick={() => setViewModalVisible(false)}>
            关闭
          </Button>
        ]}
        width={800}
      >
        {viewingItem && (
          <div>
            <Title level={4}>{viewingItem.name}</Title>
            <Tag color="purple">{viewingItem.category}</Tag>
            
            <Divider />
            
            <div style={{ marginBottom: 16 }}>
              <Text strong>描述：</Text>
              <Paragraph>{viewingItem.description}</Paragraph>
            </div>

            <div style={{ marginBottom: 16 }}>
              <Title level={5}>前置条件</Title>
              <ul>
                {viewingItem.preconditions.map((condition, index) => (
                  <li key={index}>{condition}</li>
                ))}
              </ul>
            </div>

            <div style={{ marginBottom: 16 }}>
              <Title level={5}>执行步骤</Title>
              <Steps direction="vertical" size="small">
                {viewingItem.steps.map((step, index) => (
                  <Step
                    key={index}
                    title={`步骤 ${step.order}: ${step.description}`}
                    description={
                      step.tables && step.tables.length > 0 && (
                        <Space wrap>
                          涉及表：
                          {step.tables.map((table, idx) => (
                            <Tag key={idx} color="blue">{table}</Tag>
                          ))}
                        </Space>
                      )
                    }
                  />
                ))}
              </Steps>
            </div>

            <div style={{ marginBottom: 16 }}>
              <Title level={5}>输出结果</Title>
              <ul>
                {viewingItem.outputs.map((output, index) => (
                  <li key={index}>{output}</li>
                ))}
              </ul>
            </div>

            {viewingItem.notes && (
              <div>
                <Title level={5}>注意事项</Title>
                <Paragraph type="warning">{viewingItem.notes}</Paragraph>
              </div>
            )}
          </div>
        )}
      </Modal>
    </div>
  );
};

export default BusinessLogic;
