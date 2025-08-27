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
          name: "涉恐人员排查流程",
          category: "反恐防范",
          description: "基于多维度数据对涉恐人员进行识别和排查，提升反恐工作效率",
          preconditions: [
            "人员基础信息已完善",
            "出入境记录已同步",
            "通信数据已接入"
          ],
          steps: [
            {
              order: 1,
              description: "提取目标区域人员基础信息",
              tables: ["ads_population_base", "ads_id_card_info"]
            },
            {
              order: 2,
              description: "分析异常出入境记录",
              tables: ["ads_entry_exit_record", "ads_border_control"]
            },
            {
              order: 3,
              description: "关联通信行为分析",
              tables: ["ads_communication_record", "ads_contact_network"]
            },
            {
              order: 4,
              description: "综合评估涉恐风险等级",
              tables: []
            },
            {
              order: 5,
              description: "生成重点关注人员名单",
              tables: ["ads_key_personnel"]
            }
          ],
          outputs: [
            "涉恐风险人员清单",
            "风险等级评估报告",
            "重点监控建议"
          ],
          notes: "涉恐排查需严格按照相关法律法规执行，确保数据安全",
          created_at: "2024-12-27",
          updated_at: "2024-12-27"
        },
        {
          id: 2,
          name: "偷渡人员识别分析",
          category: "边境管控",
          description: "通过行为轨迹、社会关系等数据识别潜在偷渡人员",
          preconditions: [
            "边境地区人员信息已更新",
            "车辆通行记录已同步",
            "住宿登记信息已接入"
          ],
          steps: [
            {
              order: 1,
              description: "筛选边境地区活动人员",
              tables: ["ads_population_location", "ads_border_area"]
            },
            {
              order: 2,
              description: "分析异常车辆交易记录",
              tables: ["ads_vehicle_trade", "ads_vehicle_info"]
            },
            {
              order: 3,
              description: "检查住宿登记异常",
              tables: ["ads_accommodation_record"]
            },
            {
              order: 4,
              description: "关联犯罪前科记录",
              tables: ["ads_criminal_record"]
            },
            {
              order: 5,
              description: "综合研判偷渡风险",
              tables: []
            }
          ],
          outputs: [
            "疑似偷渡人员名单",
            "风险区域分布图",
            "预警处置建议"
          ],
          notes: "需结合实地核查验证分析结果，避免误判",
          created_at: "2024-12-27",
          updated_at: "2024-12-27"
        },
        {
          id: 3,
          name: "案件串并分析流程",
          category: "刑侦分析",
          description: "通过案件特征、作案手法、时空关系等要素进行案件串并分析",
          preconditions: [
            "案件基本信息已录入",
            "现场勘查数据已整理",
            "嫌疑人信息已收集"
          ],
          steps: [
            {
              order: 1,
              description: "提取案件基本特征",
              tables: ["ads_case_info", "ads_case_scene"]
            },
            {
              order: 2,
              description: "分析作案手法相似性",
              tables: ["ads_crime_method", "ads_evidence_info"]
            },
            {
              order: 3,
              description: "计算时空关联度",
              tables: ["ads_case_location", "ads_time_analysis"]
            },
            {
              order: 4,
              description: "嫌疑人关系网络分析",
              tables: ["ads_suspect_info", "ads_social_relation"]
            },
            {
              order: 5,
              description: "生成串并建议",
              tables: []
            }
          ],
          outputs: [
            "串并案件组合",
            "相似度评分",
            "侦查方向建议"
          ],
          notes: "串并分析需要专业刑侦人员参与，AI分析仅作为辅助",
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
      title: '案例库名称',
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
              title="确定要删除这个案例库吗？"
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
            <span>案例库</span>
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
              placeholder="搜索案例库名称或描述"
              allowClear
              style={{ width: 300 }}
              prefix={<SearchOutlined />}
              onChange={(e) => setSearchText(e.target.value)}
            />
            <Button type="primary" icon={<PlusOutlined />} onClick={handleAdd}>
              添加案例库
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
            emptyText: <Empty description="暂无案例库数据" />
          }}
        />
      </Card>

      {/* 编辑/新增弹窗 */}
      <Modal
        title={editingItem ? '编辑案例库' : '添加案例库'}
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
                label="案例库名称"
                rules={[{ required: true, message: '请输入案例库名称' }]}
              >
                <Input placeholder="请输入案例库名称" />
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
            <TextArea rows={2} placeholder="简要描述案例库的目的和作用" />
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
        title="案例库详情"
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
