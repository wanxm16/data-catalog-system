import React from 'react';
import { Descriptions, Table, Tag, Typography, Card } from 'antd';
import { TableDetail, FieldInfo, TableLayer } from '../types';
import type { ColumnsType } from 'antd/es/table';

const { Text, Paragraph } = Typography;

interface Props {
  tableDetail: TableDetail;
}

const TableDetailView: React.FC<Props> = ({ tableDetail }) => {
  // 字段表格列定义
  const fieldColumns: ColumnsType<FieldInfo> = [
    {
      title: '字段英文名',
      dataIndex: 'field_name_en',
      key: 'field_name_en',
      width: 200,
      render: (text: string) => <Text code>{text}</Text>
    },
    {
      title: '字段中文名',
      dataIndex: 'field_name_cn',
      key: 'field_name_cn',
      ellipsis: true
    },
    {
      title: '数据类型',
      dataIndex: 'field_type',
      key: 'field_type',
      width: 150,
      render: (text: string) => <Tag color="blue">{text}</Tag>
    },
    {
      title: '是否可空',
      dataIndex: 'is_nullable',
      key: 'is_nullable',
      width: 100,
      render: (nullable: boolean) => (
        <Tag color={nullable ? 'default' : 'error'}>
          {nullable ? '可空' : '不可空'}
        </Tag>
      )
    }
  ];

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

  return (
    <div>
      {/* 基本信息 */}
      <Card title="基本信息" size="small" style={{ marginBottom: 16 }}>
        <Descriptions column={2} size="small">
          <Descriptions.Item label="表英文名">
            <Text code>{tableDetail.table_name_en}</Text>
          </Descriptions.Item>
          <Descriptions.Item label="表中文名">
            {tableDetail.table_name_cn}
          </Descriptions.Item>
          <Descriptions.Item label="数据分层">
            <Tag color={getLayerColor(tableDetail.layer)}>
              {tableDetail.layer}
            </Tag>
          </Descriptions.Item>
          <Descriptions.Item label="字段数量">
            <Text strong style={{ color: '#1890ff' }}>
              {tableDetail.fields.length}
            </Text>
          </Descriptions.Item>
        </Descriptions>
      </Card>

      {/* 字段信息 */}
      <Card title="字段信息" size="small" style={{ marginBottom: 16 }}>
        <Table
          columns={fieldColumns}
          dataSource={tableDetail.fields}
          rowKey="field_name_en"
          pagination={{
            pageSize: 10,
            showTotal: (total, range) => 
              `第 ${range[0]}-${range[1]} 条，共 ${total} 个字段`,
            showSizeChanger: true
          }}
          size="small"
          scroll={{ x: 600 }}
        />
      </Card>

      {/* SQL脚本 */}
      <Card title="建表脚本" size="small">
        <Paragraph>
          <pre style={{ 
            background: '#f6f8fa',
            padding: '16px',
            borderRadius: '6px',
            fontSize: '12px',
            lineHeight: '1.4',
            overflow: 'auto',
            maxHeight: '400px'
          }}>
            {tableDetail.create_sql}
          </pre>
        </Paragraph>
      </Card>
    </div>
  );
};

export default TableDetailView; 