import React from 'react';
import { BrowserRouter as Router, Routes, Route, useNavigate, useLocation } from 'react-router-dom';
import { ConfigProvider, Layout, Menu, Breadcrumb } from 'antd';
import { DatabaseOutlined, MessageOutlined, BarChartOutlined, FlagOutlined } from '@ant-design/icons';
import zhCN from 'antd/locale/zh_CN';

import TableList from './components/TableList';
import ChatInterface from './components/ChatInterface';
import Statistics from './components/Statistics';
import CaseAnalysis from './components/CaseAnalysis';

import './App.css';

const { Header, Content, Sider } = Layout;

const AppContent: React.FC = () => {
  const navigate = useNavigate();
  const location = useLocation();
  const [collapsed, setCollapsed] = React.useState(false);

  const menuItems = [
    {
      key: 'tables',
      icon: <DatabaseOutlined />,
      label: '数据资源',
      path: '/'
    },
    {
      key: 'chat',
      icon: <MessageOutlined />,
      label: '智能问答',
      path: '/chat'
    },
    {
      key: 'statistics',
      icon: <BarChartOutlined />,
      label: '统计信息',
      path: '/statistics'
    },
    {
      key: 'case-analysis',
      icon: <FlagOutlined />,
      label: '案件分解',
      path: '/case-analysis'
    }
  ];

  // 根据当前路径获取菜单key
  const getCurrentKey = () => {
    const currentPath = location.pathname;
    const item = menuItems.find(item => item.path === currentPath);
    return item?.key || 'tables';
  };

  const getBreadcrumbName = () => {
    const currentPath = location.pathname;
    const item = menuItems.find(item => item.path === currentPath);
    return item?.label || '数据资源';
  };

  const handleMenuClick = (key: string) => {
    const item = menuItems.find(item => item.key === key);
    if (item) {
      navigate(item.path);
    }
  };

  return (
    <Layout style={{ minHeight: '100vh' }}>
      <Sider 
        collapsible 
        collapsed={collapsed} 
        onCollapse={setCollapsed}
        theme="light"
        width={240}
      >
        <div className="logo">
          <h2 style={{ 
            padding: '16px', 
            margin: 0, 
            fontSize: collapsed ? '14px' : '16px',
            textAlign: 'center',
            color: '#1890ff'
          }}>
            {collapsed ? 'DC' : '数据目录'}
          </h2>
        </div>
        <Menu
          theme="light"
          selectedKeys={[getCurrentKey()]}
          mode="inline"
          items={menuItems.map(item => ({
            key: item.key,
            icon: item.icon,
            label: item.label,
            onClick: () => handleMenuClick(item.key)
          }))}
        />
      </Sider>

      <Layout>
        <Header style={{ 
          padding: '0 24px', 
          background: '#fff',
          borderBottom: '1px solid #f0f0f0'
        }}>
          <h1 style={{ 
            margin: 0, 
            fontSize: '20px',
            fontWeight: 500,
            color: '#262626'
          }}>
            数据目录编目系统
          </h1>
        </Header>

        <Content style={{ margin: '0 16px' }}>
          <Breadcrumb 
            style={{ margin: '16px 0' }}
          >
            <Breadcrumb.Item>数据目录编目系统</Breadcrumb.Item>
            <Breadcrumb.Item>{getBreadcrumbName()}</Breadcrumb.Item>
          </Breadcrumb>
          
          <div style={{ 
            padding: 24, 
            minHeight: 360, 
            background: '#fff',
            borderRadius: '8px'
          }}>
            <Routes>
              <Route path="/" element={<TableList />} />
              <Route path="/chat" element={<ChatInterface />} />
              <Route path="/statistics" element={<Statistics />} />
              <Route path="/case-analysis" element={<CaseAnalysis />} />
            </Routes>
          </div>
        </Content>
      </Layout>
    </Layout>
  );
};

const App: React.FC = () => {
  return (
    <ConfigProvider locale={zhCN}>
      <Router>
        <AppContent />
      </Router>
    </ConfigProvider>
  );
};

export default App; 