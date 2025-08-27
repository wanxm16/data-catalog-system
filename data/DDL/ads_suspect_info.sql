-- =====================================================
-- ADS层：嫌疑人信息表 DDL定义
-- 表名：ads_suspect_info
-- 功能：为刑侦业务提供嫌疑人信息管理
-- 说明：涵盖案件嫌疑人的基本信息和关联关系
-- =====================================================

DROP TABLE IF EXISTS ads_suspect_info;

CREATE TABLE IF NOT EXISTS ads_suspect_info (
    -- 基础标识信息
    suspect_id            STRING   COMMENT '嫌疑人唯一标识',
    person_id             STRING   COMMENT '人员ID(关联人口基础表)',
    case_id               STRING   COMMENT '案件ID(关联案件信息表)',
    id_card               STRING   COMMENT '身份证号码',
    suspect_name          STRING   COMMENT '嫌疑人姓名',
    
    -- 案件关联信息
    case_number           STRING   COMMENT '案件编号',
    suspect_role          STRING   COMMENT '在案件中的角色',
    involvement_degree    STRING   COMMENT '参与程度',
    crime_charge          STRING   COMMENT '涉嫌罪名',
    
    -- 基本信息
    gender                STRING   COMMENT '性别',
    birth_date            STRING   COMMENT '出生日期',
    nation                STRING   COMMENT '民族',
    education_level       STRING   COMMENT '文化程度',
    occupation            STRING   COMMENT '职业',
    
    -- 地址信息
    household_address     STRING   COMMENT '户籍地址',
    current_address       STRING   COMMENT '现住址',
    work_address          STRING   COMMENT '工作地址',
    
    -- 联系信息
    phone_number          STRING   COMMENT '联系电话',
    emergency_contact     STRING   COMMENT '紧急联系人',
    emergency_phone       STRING   COMMENT '紧急联系电话',
    
    -- 体貌特征
    height                STRING   COMMENT '身高',
    weight                STRING   COMMENT '体重',
    blood_type            STRING   COMMENT '血型',
    physical_features     STRING   COMMENT '体貌特征',
    special_marks         STRING   COMMENT '特殊标记',
    
    -- 犯罪历史
    criminal_record       STRING   COMMENT '犯罪前科',
    previous_cases        STRING   COMMENT '历史案件',
    recidivist_flag       BOOLEAN  COMMENT '是否累犯',
    
    -- 抓捕信息
    arrest_status         STRING   COMMENT '抓捕状态',
    arrest_date           STRING   COMMENT '抓捕日期',
    arrest_location       STRING   COMMENT '抓捕地点',
    arrest_officer        STRING   COMMENT '抓捕人员',
    
    -- 逃跑信息
    escape_flag           BOOLEAN  COMMENT '是否在逃',
    escape_date           STRING   COMMENT '逃跑日期',
    wanted_level          STRING   COMMENT '通缉级别',
    reward_amount         DECIMAL(10,2) COMMENT '悬赏金额',
    
    -- 社会关系
    spouse_name           STRING   COMMENT '配偶姓名',
    spouse_phone          STRING   COMMENT '配偶电话',
    family_members        STRING   COMMENT '家庭成员',
    social_relations      STRING   COMMENT '主要社会关系',
    
    -- 行为特征
    behavior_pattern      STRING   COMMENT '行为模式',
    activity_area         STRING   COMMENT '主要活动区域',
    habits_hobbies        STRING   COMMENT '生活习惯爱好',
    
    -- 危险程度
    danger_level          STRING   COMMENT '危险程度',
    violence_tendency     STRING   COMMENT '暴力倾向',
    weapon_possession     STRING   COMMENT '持有武器情况',
    
    -- 心理状态
    mental_state          STRING   COMMENT '精神状态',
    psychological_profile STRING   COMMENT '心理画像',
    
    -- 经济状况
    economic_status       STRING   COMMENT '经济状况',
    income_source         STRING   COMMENT '收入来源',
    property_status       STRING   COMMENT '财产状况',
    
    -- 技能特长
    special_skills        STRING   COMMENT '特殊技能',
    language_ability      STRING   COMMENT '语言能力',
    
    -- 关联分析
    accomplice_info       STRING   COMMENT '同伙信息',
    victim_relation       STRING   COMMENT '与受害人关系',
    motive_analysis       STRING   COMMENT '作案动机分析',
    
    -- 证据信息
    evidence_summary      STRING   COMMENT '相关证据',
    confession_status     STRING   COMMENT '供述情况',
    
    -- 处理结果
    case_result           STRING   COMMENT '案件处理结果',
    sentence_info         STRING   COMMENT '判决信息',
    
    -- 备注信息
    remarks               STRING   COMMENT '备注信息',
    
    -- ETL处理信息
    create_time           TIMESTAMP COMMENT '数据创建时间',
    update_time           TIMESTAMP COMMENT '数据更新时间'
) 
COMMENT '嫌疑人信息表'
TBLPROPERTIES ('ads.table.type'='suspect_info');
