import React from 'react';
import { BrowserRouter as Router, Routes, Route, useNavigate, useLocation } from 'react-router-dom';
import { ConfigProvider, Layout, Menu, Breadcrumb } from 'antd';
import { DatabaseOutlined, MessageOutlined, BarChartOutlined, FlagOutlined, LineChartOutlined, BookOutlined, FileTextOutlined, SyncOutlined, ContainerOutlined, BulbOutlined, ApiOutlined } from '@ant-design/icons';
import zhCN from 'antd/locale/zh_CN';

import TableList from './components/TableList';
import ChatInterface from './components/ChatInterface';
import Statistics from './components/Statistics';
import CaseAnalysis from './components/CaseAnalysis';
// import ChatBI from './components/ChatBI';
import TermExplanation from './components/TermExplanation';
import SynonymLibrary from './components/SynonymLibrary';
import CaseLibrary from './components/CaseLibrary';
import BusinessLogic from './components/BusinessLogic';
import DataSourceManagement from './components/DataSourceManagement';

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
      key: 'datasource',
      icon: <ApiOutlined />,
      label: '数据源管理',
      path: '/datasource'
    },
    {
      key: 'chat',
      icon: <MessageOutlined />,
      label: '智能问答',
      path: '/chat'
    },
    // {
    //   key: 'chatbi',
    //   icon: <LineChartOutlined />,
    //   label: 'ChatBI',
    //   path: '/chatbi'
    // },
    {
      key: 'case-analysis',
      icon: <FlagOutlined />,
      label: '案件分解',
      path: '/case-analysis'
    },
    {
      key: 'knowledge',
      icon: <BookOutlined />,
      label: '知识库管理',
      children: [
        {
          key: 'term-explanation',
          icon: <FileTextOutlined />,
          label: '术语解释',
          path: '/knowledge/term-explanation'
        },
        {
          key: 'synonym-library',
          icon: <SyncOutlined />,
          label: '同义词库',
          path: '/knowledge/synonym-library'
        },
        {
          key: 'case-library',
          icon: <ContainerOutlined />,
          label: '案例库',
          path: '/knowledge/case-library'
        },
        {
          key: 'business-logic',
          icon: <BulbOutlined />,
          label: '业务逻辑解释',
          path: '/knowledge/business-logic'
        }
      ]
    },
    {
      key: 'statistics',
      icon: <BarChartOutlined />,
      label: '统计信息',
      path: '/statistics'
    }
  ];

  // 根据当前路径获取菜单key
  const getCurrentKey = () => {
    const currentPath = location.pathname;
    // 先查找顶级菜单
    const topItem = menuItems.find(item => item.path === currentPath);
    if (topItem) return topItem.key;
    
    // 查找子菜单
    for (const item of menuItems) {
      if (item.children) {
        const childItem = item.children.find(child => child.path === currentPath);
        if (childItem) return childItem.key;
      }
    }
    return 'tables';
  };

  const getBreadcrumbName = () => {
    const currentPath = location.pathname;
    // 先查找顶级菜单
    const topItem = menuItems.find(item => item.path === currentPath);
    if (topItem) return topItem.label;
    
    // 查找子菜单
    for (const item of menuItems) {
      if (item.children) {
        const childItem = item.children.find(child => child.path === currentPath);
        if (childItem) return `${item.label} / ${childItem.label}`;
      }
    }
    return '数据资源';
  };

  const handleMenuClick = ({ key }: { key: string }) => {
    // 先查找顶级菜单
    const topItem = menuItems.find(item => item.key === key);
    if (topItem && topItem.path) {
      navigate(topItem.path);
      return;
    }
    
    // 查找子菜单
    for (const item of menuItems) {
      if (item.children) {
        const childItem = item.children.find(child => child.key === key);
        if (childItem && childItem.path) {
          navigate(childItem.path);
          return;
        }
      }
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
          items={menuItems}
          onClick={handleMenuClick}
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
              <Route path="/datasource" element={<DataSourceManagement />} />
              <Route path="/chat" element={<ChatInterface />} />
              {/* <Route path="/chatbi" element={<ChatBI />} /> */}
              <Route path="/case-analysis" element={<CaseAnalysis />} />
              <Route path="/knowledge/term-explanation" element={<TermExplanation />} />
              <Route path="/knowledge/synonym-library" element={<SynonymLibrary />} />
              <Route path="/knowledge/case-library" element={<CaseLibrary />} />
              <Route path="/knowledge/business-logic" element={<BusinessLogic />} />
              <Route path="/statistics" element={<Statistics />} />
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