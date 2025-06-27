-- =====================================================
-- ADS层：企业信息应用表 DDL定义
-- 表名：ads_enterprise_info
-- 功能：为应用层提供统一的企业信息视图
-- 说明：表结构基于 dwd_qy_main1，增加ETL处理字段
-- =====================================================

DROP TABLE IF EXISTS ads_enterprise_info;

CREATE TABLE IF NOT EXISTS ads_enterprise_info (
    -- 基础标识信息
    pripid                STRING   COMMENT '主体身份代码',
    uniscid               STRING   COMMENT '统一社会信用代码',
    regno                 STRING   COMMENT '注册号',
    entname               STRING   COMMENT '企业名称',
    
    -- 企业分类信息
    reporttype_cn         STRING   COMMENT '企业类型名称',
    reporttype_code       STRING   COMMENT '企业类型代码',
    industryphy_cn        STRING   COMMENT '行业门类名称',
    industryphy_code      STRING   COMMENT '行业门类代码',
    industryco_cn         STRING   COMMENT '行业名称',
    industryco_code       STRING   COMMENT '行业代码',
    
    -- 时间信息
    estdate               STRING   COMMENT '成立日期',
    apprdate              STRING   COMMENT '核准日期',
    
    -- 注册资本信息
    regcap                STRING   COMMENT '注册资本',
    regcapcur             STRING   COMMENT '注册资本币种',
    
    -- 地址信息
    dom                   STRING   COMMENT '注册地址',
    domdistrict           STRING   COMMENT '行政区划代码',
    dom_street            STRING   COMMENT '归属乡镇街道',
    dom_village           STRING   COMMENT '归属村居社区',
    
    -- 经营场所信息
    oploc                 STRING   COMMENT '经营场所',
    oplocdistrict         STRING   COMMENT '经营场所行政区划代码',
    oploc_street          STRING   COMMENT '经营场所乡镇街道',
    oploc_village         STRING   COMMENT '经营场所村居社区',
    
    -- 经营期限与范围
    opfrom                STRING   COMMENT '经营(驻在)期限自',
    opto                  STRING   COMMENT '经营(驻在)期限至',
    opscope               STRING   COMMENT '经营范围',
    
    -- 生产经营地信息
    proloc                STRING   COMMENT '生产经营地',
    proloc_street         STRING   COMMENT '生产地乡镇街道',
    proloc_village        STRING   COMMENT '生产地村居社区',
    yiedistrict           STRING   COMMENT '生产经营地行政代码',
    
    -- 法定代表人信息
    lerep_name            STRING   COMMENT '法定代表人',
    country_cn            STRING   COMMENT '国籍名称',
    country_code          STRING   COMMENT '国籍代码',
    certype_cn            STRING   COMMENT '证件类型名称',
    certype_code          STRING   COMMENT '证件类型代码',
    cerno                 STRING   COMMENT '身份证件号码',
    
    -- 联系信息
    tel                   STRING   COMMENT '联系电话',
    email                 STRING   COMMENT '电子邮件地址',
    
    -- 状态信息
    regstate              STRING   COMMENT '状态',
    revdate               STRING   COMMENT '吊销时间',
    revdecno              STRING   COMMENT '吊销处罚文号',
    revbasis              STRING   COMMENT '吊销原因',
    revauth               STRING   COMMENT '吊照处罚实施机关',
    candate               STRING   COMMENT '注销时间',
    canrea_cn             STRING   COMMENT '注销原因中文',
    canrea_code           STRING   COMMENT '注销原因代码',
    
    -- 小微企业信息
    xwstate               STRING   COMMENT '小微企业状态代码',
    xwsort_cn             STRING   COMMENT '小微企业分类名称',
    xw_addtime            STRING   COMMENT '加入时间',
    xw_remtime            STRING   COMMENT '退出时间',
    xw_remreason          STRING   COMMENT '退出原因',
    
    -- 标识位信息
    web_bit               STRING   COMMENT '互联网监管',
    above_bit             STRING   COMMENT '规上规下',
    above_year            STRING   COMMENT '规上年份',
    stock_bit             STRING   COMMENT '上市企业',
    stock_name            STRING   COMMENT '股票名称',
    stock_code            STRING   COMMENT '股票代码',
    stock_date            STRING   COMMENT '上市时间',
    stock_address         STRING   COMMENT '上市交易所',
    stock_text            STRING   COMMENT '简介描述',
    
    -- 转型信息
    ind_to_ent            STRING   COMMENT '是否个转企',
    ind_to_ent2           STRING   COMMENT '是否个转企二次转型',
    compform              STRING   COMMENT '个体户组成形式',
    
    -- 管理信息
    regorg                STRING   COMMENT '企业登记机关',
    localadm              STRING   COMMENT '管辖单位代码',
    localadm_cn           STRING   COMMENT '管辖单位名称',
    laiyuan               STRING   COMMENT '合表来源',
    
    -- ETL处理信息
    create_time           TIMESTAMP COMMENT '数据创建时间',
    update_time           TIMESTAMP COMMENT '数据更新时间'
) 
COMMENT '企业信息应用表'
TBLPROPERTIES ('ads.table.type'='enterprise_info');