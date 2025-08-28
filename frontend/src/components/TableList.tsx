import React, { useState, useEffect } from 'react';
import { 
  Table, 
  Button, 
  Tag, 
  Space, 
  Drawer, 
  Descriptions, 
  Card, 
  message, 
  Modal,
  Spin,
  Input,
  Select
} from 'antd';
import { 
  EyeOutlined, 
  EditOutlined, 
  SearchOutlined, 
  ReloadOutlined 
} from '@ant-design/icons';
import type { ColumnsType } from 'antd/es/table';

import { TableInfo, TableDetail, TableLayer, CatalogStatus } from '../types';
import ApiService from '../services/api';
import TableDetailView from './TableDetailView';
import CatalogForm from './CatalogForm';

const { Search } = Input;
const { Option } = Select;

const TableList: React.FC = () => {
  const [tables, setTables] = useState<TableInfo[]>([]);
  const [loading, setLoading] = useState(false);
  const [searchText, setSearchText] = useState('');
  const [layerFilter, setLayerFilter] = useState<string>('');
  const [statusFilter, setStatusFilter] = useState<string>('');
  
  // 详情抽屉相关状态
  const [detailVisible, setDetailVisible] = useState(false);
  const [selectedTable, setSelectedTable] = useState<string>('');
  const [tableDetail, setTableDetail] = useState<TableDetail | null>(null);
  const [detailLoading, setDetailLoading] = useState(false);
  
  // 编目抽屉相关状态
  const [catalogVisible, setCatalogVisible] = useState(false);
  const [catalogTable, setCatalogTable] = useState<string>('');

  // 获取表数据
  const fetchTables = async () => {
    setLoading(true);
    try {
      const data = await ApiService.getTables();
      setTables(data);
      message.success(`成功加载 ${data.length} 个数据表`);
    } catch (error) {
      message.error(`加载表数据失败: ${error}`);
    } finally {
      setLoading(false);
    }
  };

  // 初始化数据
  useEffect(() => {
    fetchTables();
  }, []);

  // 显示表详情
  const showTableDetail = async (tableName: string) => {
    setSelectedTable(tableName);
    setDetailVisible(true);
    setDetailLoading(true);
    
    try {
      const detail = await ApiService.getTableDetail(tableName);
      setTableDetail(detail);
    } catch (error) {
      message.error(`获取表详情失败: ${error}`);
    } finally {
      setDetailLoading(false);
    }
  };

  // 显示编目表单
  const showCatalogForm = (tableName: string) => {
    setCatalogTable(tableName);
    setCatalogVisible(true);
  };

  // 编目成功回调
  const handleCatalogSuccess = () => {
    setCatalogVisible(false);
    fetchTables(); // 重新加载表数据以更新状态
    message.success('编目信息保存成功！');
  };

  // 获取分层标签颜色
  const getLayerColor = (layer: TableLayer): string => {
    const colorMap = {
      [TableLayer.STG]: 'default',
      [TableLayer.ODS]: 'blue',
      [TableLayer.DWD]: 'green', 
      [TableLayer.ADS]: 'orange',
      [TableLayer.UNKNOWN]: 'gray'
    };
    return colorMap[layer] || 'gray';
  };

  // 获取状态标签颜色
  const getStatusColor = (status: CatalogStatus): string => {
    return status === CatalogStatus.CATALOGED ? 'success' : 'warning';
  };

  // 过滤表数据
  const filteredTables = tables.filter(table => {
    const matchSearch = table.table_name_en.toLowerCase().includes(searchText.toLowerCase()) ||
                       table.table_name_cn.includes(searchText);
    const matchLayer = !layerFilter || table.layer === layerFilter;
    const matchStatus = !statusFilter || table.catalog_status === statusFilter;
    
    return matchSearch && matchLayer && matchStatus;
  });

  // 表格列定义
  const columns: ColumnsType<TableInfo> = [
    {
      title: '表英文名',
      dataIndex: 'table_name_en',
      key: 'table_name_en',
      width: 250,
      sorter: (a, b) => a.table_name_en.localeCompare(b.table_name_en),
      render: (text: string) => (
        <code style={{ fontSize: '12px' }}>{text}</code>
      )
    },
    {
      title: '表中文名',
      dataIndex: 'table_name_cn',
      key: 'table_name_cn',
      width: 200,
      ellipsis: true,
      sorter: (a, b) => a.table_name_cn.localeCompare(b.table_name_cn)
    },
    {
      title: '数据分层',
      dataIndex: 'layer',
      key: 'layer',
      width: 100,
      render: (layer: TableLayer) => (
        <Tag color={getLayerColor(layer)}>{layer}</Tag>
      ),
      filters: Object.values(TableLayer).map(layer => ({
        text: layer,
        value: layer
      })),
      onFilter: (value, record) => record.layer === value
    },
    {
      title: '字段数量',
      dataIndex: 'field_count',
      key: 'field_count',
      width: 100,
      sorter: (a, b) => a.field_count - b.field_count,
      render: (count: number) => (
        <span style={{ color: '#1890ff' }}>{count}</span>
      )
    },
    {
      title: 'ETL',
      dataIndex: 'has_etl',
      key: 'has_etl',
      width: 80,
      render: (hasEtl: boolean) => (
        <Tag color={hasEtl ? 'success' : 'default'}>
          {hasEtl ? '有' : '无'}
        </Tag>
      )
    },
    {
      title: '编目状态',
      dataIndex: 'catalog_status',
      key: 'catalog_status',
      width: 100,
      render: (status: CatalogStatus) => (
        <Tag color={getStatusColor(status)}>{status}</Tag>
      ),
      filters: Object.values(CatalogStatus).map(status => ({
        text: status,
        value: status
      })),
      onFilter: (value, record) => record.catalog_status === value
    },
    {
      title: '操作',
      key: 'action',
      width: 180,
      render: (_, record) => (
        <Space size="small">
          <Button
            type="text"
            size="small"
            icon={<EyeOutlined />}
            onClick={() => showTableDetail(record.table_name_en)}
          >
            详情
          </Button>
          <Button
            type="text"
            size="small"
            icon={<EditOutlined />}
            onClick={() => showCatalogForm(record.table_name_en)}
          >
            数据说明书
          </Button>
        </Space>
      )
    }
  ];

  return (
    <div>
      {/* 搜索和过滤器 */}
      <Card size="small" style={{ marginBottom: 16 }}>
        <Space wrap>
          <Search
            placeholder="搜索表名..."
            allowClear
            style={{ width: 200 }}
            onSearch={setSearchText}
            onChange={(e) => setSearchText(e.target.value)}
          />
          <Select
            placeholder="数据分层"
            allowClear
            style={{ width: 120 }}
            value={layerFilter}
            onChange={setLayerFilter}
          >
            {Object.values(TableLayer).map(layer => (
              <Option key={layer} value={layer}>{layer}</Option>
            ))}
          </Select>
          <Select
            placeholder="编目状态"
            allowClear
            style={{ width: 120 }}
            value={statusFilter}
            onChange={setStatusFilter}
          >
            {Object.values(CatalogStatus).map(status => (
              <Option key={status} value={status}>{status}</Option>
            ))}
          </Select>
          <Button 
            icon={<ReloadOutlined />}
            onClick={fetchTables}
            loading={loading}
          >
            刷新
          </Button>
        </Space>
      </Card>

      {/* 数据表格 */}
      <Table
        columns={columns}
        dataSource={filteredTables}
        rowKey="table_name_en"
        loading={loading}
        pagination={{
          total: filteredTables.length,
          pageSize: 20,
          showTotal: (total, range) => 
            `第 ${range[0]}-${range[1]} 条，共 ${total} 条数据`,
          showSizeChanger: true,
          showQuickJumper: true
        }}
        size="small"
        scroll={{ x: 1100 }}
      />

      {/* 表详情抽屉 */}
      <Drawer
        title={`表详情 - ${selectedTable}`}
        width={800}
        onClose={() => setDetailVisible(false)}
        open={detailVisible}
        destroyOnClose
      >
        {detailLoading ? (
          <div style={{ textAlign: 'center', padding: '50px 0' }}>
            <Spin size="large" />
          </div>
        ) : tableDetail ? (
          <TableDetailView tableDetail={tableDetail} />
        ) : null}
      </Drawer>

      {/* 编目表单抽屉 */}
      <Drawer
        title={`编目表信息 - ${catalogTable}`}
        width={900}
        onClose={() => setCatalogVisible(false)}
        open={catalogVisible}
        destroyOnClose
      >
        <CatalogForm
          tableName={catalogTable}
          onSuccess={handleCatalogSuccess}
          onCancel={() => setCatalogVisible(false)}
        />
      </Drawer>
    </div>
  );
};

export default TableList; 