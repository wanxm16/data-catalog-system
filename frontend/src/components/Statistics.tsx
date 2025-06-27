import React, { useState, useEffect } from 'react';
import {
  Card,
  Row,
  Col,
  Statistic,
  Progress,
  Table,
  Tag,
  Alert,
  Typography,
  Space,
  Button
} from 'antd';
import {
  DatabaseOutlined,
  CheckCircleOutlined,
  ClockCircleOutlined,
  BarChartOutlined,
  ReloadOutlined,
  CloudOutlined
} from '@ant-design/icons';
import type { ColumnsType } from 'antd/es/table';

import { SystemStatistics, TableInfo, TableLayer, CatalogStatus } from '../types';
import ApiService from '../services/api';

const { Title, Text } = Typography;

interface LayerStatistics {
  layer: string;
  total: number;
  cataloged: number;
  progress: number;
}

const Statistics: React.FC = () => {
  const [statistics, setStatistics] = useState<SystemStatistics | null>(null);
  const [tables, setTables] = useState<TableInfo[]>([]);
  const [loading, setLoading] = useState(false);
  const [refreshingVectorDB, setRefreshingVectorDB] = useState(false);
  const [layerStats, setLayerStats] = useState<LayerStatistics[]>([]);

  // 获取统计数据
  const fetchStatistics = async () => {
    setLoading(true);
    try {
      const [statsData, tablesData] = await Promise.all([
        ApiService.getStatistics(),
        ApiService.getTables()
      ]);

      setStatistics(statsData);
      setTables(tablesData);

      // 计算分层统计
      const layerMap = new Map<string, { total: number; cataloged: number }>();
      
      tablesData.forEach(table => {
        const layer = table.layer;
        if (!layerMap.has(layer)) {
          layerMap.set(layer, { total: 0, cataloged: 0 });
        }
        
        const stats = layerMap.get(layer)!;
        stats.total += 1;
        if (table.catalog_status === CatalogStatus.CATALOGED) {
          stats.cataloged += 1;
        }
      });

      const layerStatistics: LayerStatistics[] = Array.from(layerMap.entries()).map(([layer, stats]) => ({
        layer,
        total: stats.total,
        cataloged: stats.cataloged,
        progress: stats.total > 0 ? Math.round((stats.cataloged / stats.total) * 100) : 0
      }));

      setLayerStats(layerStatistics);
      
    } catch (error) {
      console.error('获取统计数据失败:', error);
    } finally {
      setLoading(false);
    }
  };

  // 刷新向量数据库
  const refreshVectorDatabase = async () => {
    setRefreshingVectorDB(true);
    try {
      const result = await ApiService.refreshVectorDB();
      if (result.success) {
        // 刷新成功后，重新获取统计信息
        await fetchStatistics();
        console.log('向量数据库刷新成功:', result.message);
      } else {
        console.error('向量数据库刷新失败');
      }
    } catch (error) {
      console.error('向量数据库刷新失败:', error);
    } finally {
      setRefreshingVectorDB(false);
    }
  };

  useEffect(() => {
    fetchStatistics();
  }, []);

  // 分层统计表格列定义
  const layerColumns: ColumnsType<LayerStatistics> = [
    {
      title: '数据分层',
      dataIndex: 'layer',
      key: 'layer',
      render: (layer: string) => {
        const getLayerColor = (layer: string): string => {
          const colorMap: Record<string, string> = {
            'STG': 'default',
            'ODS': 'blue',
            'DWD': 'green',
            'ADS': 'orange',
            'UNKNOWN': 'gray'
          };
          return colorMap[layer] || 'gray';
        };
        
        return <Tag color={getLayerColor(layer)}>{layer}</Tag>;
      }
    },
    {
      title: '总表数',
      dataIndex: 'total',
      key: 'total',
      align: 'center',
      render: (total: number) => (
        <Text strong style={{ color: '#1890ff' }}>{total}</Text>
      )
    },
    {
      title: '已编目',
      dataIndex: 'cataloged',
      key: 'cataloged',
      align: 'center',
      render: (cataloged: number) => (
        <Text style={{ color: '#52c41a' }}>{cataloged}</Text>
      )
    },
    {
      title: '编目进度',
      dataIndex: 'progress',
      key: 'progress',
      align: 'center',
      render: (progress: number) => (
        <Progress 
          percent={progress} 
          size="small" 
          style={{ width: 100 }}
          strokeColor={progress === 100 ? '#52c41a' : '#1890ff'}
        />
      )
    }
  ];

  if (!statistics) {
    return <div>加载中...</div>;
  }

  return (
    <div>
      {/* 页面标题 */}
      <div style={{ marginBottom: 24 }}>
        <Title level={3} style={{ margin: 0 }}>
          <BarChartOutlined /> 系统统计
        </Title>
        <Text type="secondary">数据目录编目系统运行状态和统计信息</Text>
      </div>

      {/* 刷新按钮 */}
      <div style={{ marginBottom: 16, textAlign: 'right' }}>
        <Space>
          <Button 
            icon={<ReloadOutlined />}
            onClick={fetchStatistics}
            loading={loading}
          >
            刷新数据
          </Button>
          <Button 
            type="primary"
            icon={<CloudOutlined />}
            onClick={refreshVectorDatabase}
            loading={refreshingVectorDB}
          >
            同步向量数据库
          </Button>
        </Space>
      </div>



      {/* 总体统计卡片 */}
      <Row gutter={16} style={{ marginBottom: 24 }}>
        <Col xs={24} sm={12} md={6}>
          <Card>
            <Statistic
              title="数据表总数"
              value={statistics.total_tables}
              prefix={<DatabaseOutlined style={{ color: '#1890ff' }} />}
              valueStyle={{ color: '#1890ff' }}
            />
          </Card>
        </Col>
        
        <Col xs={24} sm={12} md={6}>
          <Card>
            <Statistic
              title="已编目表数"
              value={statistics.cataloged_tables}
              prefix={<CheckCircleOutlined style={{ color: '#52c41a' }} />}
              valueStyle={{ color: '#52c41a' }}
            />
          </Card>
        </Col>
        
        <Col xs={24} sm={12} md={6}>
          <Card>
            <Statistic
              title="未编目表数"
              value={statistics.uncataloged_tables}
              prefix={<ClockCircleOutlined style={{ color: '#faad14' }} />}
              valueStyle={{ color: '#faad14' }}
            />
          </Card>
        </Col>
        
        <Col xs={24} sm={12} md={6}>
          <Card>
            <Statistic
              title="向量文档数"
              value={statistics.vector_db_documents}
              prefix={<CloudOutlined style={{ color: '#722ed1' }} />}
              valueStyle={{ color: '#722ed1' }}
            />
          </Card>
        </Col>
      </Row>

      {/* 编目进度 */}
      <Row gutter={16} style={{ marginBottom: 24 }}>
        <Col span={24}>
          <Card title="整体编目进度">
            <div style={{ padding: '20px 0' }}>
              <Progress
                percent={statistics.catalog_progress}
                strokeWidth={12}
                status={statistics.catalog_progress === 100 ? 'success' : 'active'}
                format={(percent) => `${percent}%`}
              />
              <div style={{ 
                textAlign: 'center', 
                marginTop: 16,
                fontSize: '16px'
              }}>
                <Text strong>
                  已完成 {statistics.cataloged_tables} / {statistics.total_tables} 个数据表的编目
                </Text>
              </div>
            </div>
          </Card>
        </Col>
      </Row>

      {/* 分层统计 */}
      <Row gutter={16} style={{ marginBottom: 24 }}>
        <Col span={24}>
          <Card title="分层编目统计">
            <Table
              columns={layerColumns}
              dataSource={layerStats}
              rowKey="layer"
              pagination={false}
              size="small"
            />
          </Card>
        </Col>
      </Row>

      {/* 系统信息 */}
      <Row gutter={16}>
        <Col span={24}>
          <Card title="系统信息">
            <Row gutter={16}>
              <Col xs={24} md={12}>
                <Space direction="vertical" style={{ width: '100%' }}>
                  <div>
                    <Text strong>最后更新时间：</Text>
                    <Text>{new Date(statistics.last_update).toLocaleString()}</Text>
                  </div>
                  <div>
                    <Text strong>系统状态：</Text>
                    <Tag color="success">正常运行</Tag>
                  </div>
                </Space>
              </Col>
              <Col xs={24} md={12}>
                <Space direction="vertical" style={{ width: '100%' }}>
                  <div>
                    <Text strong>向量数据库：</Text>
                    <Tag color="processing">FAISS</Tag>
                  </div>
                  <div>
                    <Text strong>AI模型：</Text>
                    <Tag color="gold">GPT-4</Tag>
                  </div>
                </Space>
              </Col>
            </Row>
          </Card>
        </Col>
      </Row>

      {/* 使用提示 */}
      <Alert
        message="使用提示"
        description={
          <div>
            <p>• 编目进度会实时更新，当您完成表的编目后，统计数据会自动刷新</p>
            <p>• 向量数据库文档数量反映了可用于智能问答的数据资源数量</p>
            <p>• 建议优先完成核心业务表（DWD、ADS层）的编目工作</p>
          </div>
        }
        type="info"
        showIcon
        style={{ marginTop: 24 }}
      />
    </div>
  );
};

export default Statistics; 