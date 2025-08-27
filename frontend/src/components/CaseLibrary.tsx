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
          title: "重点人员轨迹分析",
          category: "人员管控",
          description: "分析重点关注人员的活动轨迹和行为模式，识别异常行为",
          scenario: "对涉恐、涉稳等重点人员进行日常监管，及时发现异常活动。",
          solution: "通过整合多源数据，构建人员活动轨迹，结合行为分析模型识别异常。",
          sql_queries: [
            "-- 查询重点人员基本信息",
            "SELECT p.person_name, p.id_card, p.address, k.risk_level",
            "FROM ads_population_base p",
            "JOIN ads_key_personnel k ON p.id = k.person_id",
            "WHERE k.status = 'active'",
            "",
            "-- 查询近期活动轨迹",
            "SELECT t.person_id, t.location, t.timestamp, t.activity_type",
            "FROM ads_person_trajectory t",
            "WHERE t.person_id IN (SELECT person_id FROM ads_key_personnel)",
            "AND t.timestamp >= DATE_SUB(NOW(), INTERVAL 30 DAY)",
            "ORDER BY t.person_id, t.timestamp"
          ],
          tags: ["重点人员", "轨迹分析", "异常检测"],
          created_at: "2024-12-27",
          updated_at: "2024-12-27"
        },
        {
          id: 2,
          title: "边境异常人员识别",
          category: "边境管控",
          description: "识别在边境地区有异常活动的人员，预防偷渡等违法行为",
          scenario: "边境管控部门需要及时发现可能的偷渡人员和组织者。",
          solution: "通过分析边境地区人员流动、车辆交易、住宿等数据，识别异常模式。",
          sql_queries: [
            "-- 查询边境地区异常活动人员",
            "SELECT DISTINCT p.person_name, p.id_card, p.phone",
            "FROM ads_population_base p",
            "JOIN ads_border_activity ba ON p.id = ba.person_id",
            "WHERE ba.activity_date >= DATE_SUB(NOW(), INTERVAL 7 DAY)",
            "AND ba.activity_type IN ('vehicle_trade', 'frequent_crossing')",
            "",
            "-- 关联车辆交易记录",
            "SELECT vt.seller_id, vt.buyer_id, vt.vehicle_type, vt.trade_date",
            "FROM ads_vehicle_trade vt",
            "WHERE vt.trade_location LIKE '%边境%'",
            "AND vt.trade_date >= DATE_SUB(NOW(), INTERVAL 30 DAY)"
          ],
          tags: ["边境管控", "偷渡预防", "异常识别"],
          created_at: "2024-12-27",
          updated_at: "2024-12-27"
        },
        {
          id: 3,
          title: "案件嫌疑人关系网络分析",
          category: "刑侦分析",
          description: "分析案件嫌疑人的社会关系网络，发现潜在共犯和线索",
          scenario: "刑侦部门在办案过程中需要深入了解嫌疑人的社会关系，扩大侦查范围。",
          solution: "通过多维度关系数据构建社会网络图，分析关系强度和影响范围。",
          sql_queries: [
            "-- 查询嫌疑人基本信息",
            "SELECT s.suspect_name, s.id_card, s.case_id, c.case_type",
            "FROM ads_suspect_info s",
            "JOIN ads_case_info c ON s.case_id = c.case_id",
            "WHERE s.suspect_id = ?",
            "",
            "-- 查询社会关系网络",
            "SELECT r.person_a, r.person_b, r.relation_type, r.relation_strength",
            "FROM ads_social_relation r",
            "WHERE r.person_a = ? OR r.person_b = ?",
            "",
            "-- 查询通信联系记录",
            "SELECT cr.caller_id, cr.callee_id, cr.call_duration, cr.call_time",
            "FROM ads_communication_record cr",
            "WHERE (cr.caller_id = ? OR cr.callee_id = ?)",
            "AND cr.call_time >= DATE_SUB(NOW(), INTERVAL 90 DAY)"
          ],
          tags: ["关系网络", "嫌疑人分析", "刑侦辅助"],
          created_at: "2024-12-27",
          updated_at: "2024-12-27"
        },
        {
          id: 4,
          title: "涉恐风险人员预警",
          category: "反恐防范",
          description: "基于多维度数据对涉恐风险人员进行预警分析",
          scenario: "反恐部门需要提前识别和预警可能的涉恐人员，防范恐怖活动。",
          solution: "整合人员信息、出入境记录、通信数据等，建立风险评估模型。",
          sql_queries: [
            "-- 查询高风险地区出入境人员",
            "SELECT p.person_name, p.id_card, e.entry_date, e.exit_date, e.destination",
            "FROM ads_population_base p",
            "JOIN ads_entry_exit_record e ON p.id = e.person_id",
            "WHERE e.destination IN ('高风险国家列表')",
            "AND e.entry_date >= DATE_SUB(NOW(), INTERVAL 365 DAY)",
            "",
            "-- 分析异常通信模式",
            "SELECT cr.person_id, COUNT(*) as call_count, ",
            "       COUNT(DISTINCT cr.callee_id) as contact_count",
            "FROM ads_communication_record cr",
            "WHERE cr.call_time BETWEEN '22:00:00' AND '06:00:00'",
            "GROUP BY cr.person_id",
            "HAVING call_count > 100 OR contact_count > 50"
          ],
          tags: ["涉恐预警", "风险评估", "反恐防范"],
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
      title: '业务逻辑名称',
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
            <ContainerOutlined />
            <span>业务逻辑管理</span>
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
              placeholder="搜索业务逻辑名称、描述或标签"
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
          dataSource={filteredCases}
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
        title={editingCase ? '编辑业务逻辑' : '添加业务逻辑'}
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
            label="业务逻辑名称"
            rules={[{ required: true, message: '请输入业务逻辑名称' }]}
          >
            <Input placeholder="请输入业务逻辑名称" />
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
            rules={[{ required: true, message: '请输入业务逻辑描述' }]}
          >
            <TextArea rows={2} placeholder="简要描述业务逻辑的功能和用途" />
          </Form.Item>
          <Form.Item
            name="scenario"
            label="应用场景"
            rules={[{ required: true, message: '请输入应用场景' }]}
          >
            <TextArea rows={3} placeholder="描述在什么情况下会使用这个业务逻辑" />
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
