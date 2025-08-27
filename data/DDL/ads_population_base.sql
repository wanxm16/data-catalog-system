-- =====================================================
-- ADS层：人口基础信息表 DDL定义
-- 表名：ads_population_base
-- 功能：为公安业务提供统一的人口基础信息视图
-- 说明：整合户籍、身份证、流动人口等多源数据
-- =====================================================

DROP TABLE IF EXISTS ads_population_base;

CREATE TABLE IF NOT EXISTS ads_population_base (
    -- 基础标识信息
    person_id             STRING   COMMENT '人员唯一标识',
    id_card               STRING   COMMENT '身份证号码',
    person_name           STRING   COMMENT '姓名',
    name_pinyin           STRING   COMMENT '姓名拼音',
    
    -- 基本信息
    gender                STRING   COMMENT '性别',
    birth_date            STRING   COMMENT '出生日期',
    nation                STRING   COMMENT '民族',
    native_place          STRING   COMMENT '籍贯',
    
    -- 户籍信息
    household_type        STRING   COMMENT '户别(家庭户/集体户)',
    household_id          STRING   COMMENT '户号',
    household_relation    STRING   COMMENT '与户主关系',
    register_address      STRING   COMMENT '户籍地址',
    register_district     STRING   COMMENT '户籍行政区划代码',
    register_police_station STRING COMMENT '户籍派出所',
    
    -- 现居住信息
    current_address       STRING   COMMENT '现居住地址',
    current_district      STRING   COMMENT '现居住行政区划代码',
    current_police_station STRING  COMMENT '现居住地派出所',
    residence_type        STRING   COMMENT '居住类型(常住/暂住/流动)',
    
    -- 身份证信息
    id_card_issue_org     STRING   COMMENT '身份证签发机关',
    id_card_issue_date    STRING   COMMENT '身份证签发日期',
    id_card_expire_date   STRING   COMMENT '身份证有效期至',
    
    -- 联系信息
    phone_number          STRING   COMMENT '联系电话',
    emergency_contact     STRING   COMMENT '紧急联系人',
    emergency_phone       STRING   COMMENT '紧急联系电话',
    
    -- 教育职业信息
    education_level       STRING   COMMENT '文化程度',
    occupation            STRING   COMMENT '职业',
    work_unit             STRING   COMMENT '工作单位',
    work_address          STRING   COMMENT '工作地址',
    
    -- 婚姻家庭信息
    marital_status        STRING   COMMENT '婚姻状况',
    spouse_name           STRING   COMMENT '配偶姓名',
    spouse_id_card        STRING   COMMENT '配偶身份证号',
    
    -- 服务管理信息
    service_level         STRING   COMMENT '服务管理等级',
    management_type       STRING   COMMENT '管理类型',
    risk_level            STRING   COMMENT '风险等级',
    
    -- 特殊标识
    is_key_personnel      BOOLEAN  COMMENT '是否重点人员',
    is_floating_population BOOLEAN COMMENT '是否流动人口',
    is_foreign_personnel  BOOLEAN  COMMENT '是否境外人员',
    
    -- 状态信息
    person_status         STRING   COMMENT '人员状态(正常/死亡/失踪等)',
    status_change_date    STRING   COMMENT '状态变更日期',
    status_change_reason  STRING   COMMENT '状态变更原因',
    
    -- 数据来源信息
    data_source           STRING   COMMENT '数据来源',
    source_system         STRING   COMMENT '来源系统',
    
    -- ETL处理信息
    create_time           TIMESTAMP COMMENT '数据创建时间',
    update_time           TIMESTAMP COMMENT '数据更新时间'
) 
COMMENT '人口基础信息表'
TBLPROPERTIES ('ads.table.type'='population_base');
