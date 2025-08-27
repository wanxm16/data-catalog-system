-- =====================================================
-- ADS层：重点人员管理表 DDL定义
-- 表名：ads_key_personnel
-- 功能：为公安业务提供重点人员管理信息
-- 说明：涵盖涉恐、涉稳、涉毒等各类重点人员
-- =====================================================

DROP TABLE IF EXISTS ads_key_personnel;

CREATE TABLE IF NOT EXISTS ads_key_personnel (
    -- 基础标识信息
    key_personnel_id      STRING   COMMENT '重点人员唯一标识',
    person_id             STRING   COMMENT '人员ID(关联人口基础表)',
    id_card               STRING   COMMENT '身份证号码',
    person_name           STRING   COMMENT '姓名',
    
    -- 重点人员分类
    personnel_type        STRING   COMMENT '重点人员类型',
    personnel_subtype     STRING   COMMENT '重点人员子类型',
    risk_category         STRING   COMMENT '风险类别(涉恐/涉稳/涉毒/涉黑等)',
    risk_level            STRING   COMMENT '风险等级(高/中/低)',
    
    -- 管控信息
    control_level         STRING   COMMENT '管控等级',
    control_measures      STRING   COMMENT '管控措施',
    control_start_date    STRING   COMMENT '管控开始日期',
    control_end_date      STRING   COMMENT '管控结束日期',
    control_status        STRING   COMMENT '管控状态(在控/解控/逃脱等)',
    
    -- 认定信息
    identification_basis  STRING   COMMENT '认定依据',
    identification_date   STRING   COMMENT '认定日期',
    identification_org    STRING   COMMENT '认定机关',
    identification_person STRING   COMMENT '认定人',
    
    -- 案件关联信息
    related_case_id       STRING   COMMENT '关联案件编号',
    case_type             STRING   COMMENT '案件类型',
    case_status           STRING   COMMENT '案件状态',
    
    -- 行为特征
    behavior_pattern      STRING   COMMENT '行为模式',
    activity_area         STRING   COMMENT '主要活动区域',
    frequent_locations    STRING   COMMENT '经常出现地点',
    social_relations      STRING   COMMENT '主要社会关系',
    
    -- 危险程度评估
    danger_level          STRING   COMMENT '危险程度',
    violence_tendency     STRING   COMMENT '暴力倾向',
    escape_risk           STRING   COMMENT '逃跑风险',
    recidivism_risk       STRING   COMMENT '再犯风险',
    
    -- 管控责任人
    responsible_unit      STRING   COMMENT '责任单位',
    responsible_person    STRING   COMMENT '责任人',
    contact_phone         STRING   COMMENT '联系电话',
    
    -- 帮教信息
    helper_name           STRING   COMMENT '帮教人员姓名',
    helper_unit           STRING   COMMENT '帮教单位',
    helper_phone          STRING   COMMENT '帮教联系电话',
    help_measures         STRING   COMMENT '帮教措施',
    
    -- 家属信息
    family_contact        STRING   COMMENT '家属联系人',
    family_phone          STRING   COMMENT '家属联系电话',
    family_address        STRING   COMMENT '家属地址',
    
    -- 特殊标识
    is_terrorism_related  BOOLEAN  COMMENT '是否涉恐',
    is_stability_related  BOOLEAN  COMMENT '是否涉稳',
    is_drug_related       BOOLEAN  COMMENT '是否涉毒',
    is_gang_related       BOOLEAN  COMMENT '是否涉黑涉恶',
    is_mental_patient     BOOLEAN  COMMENT '是否精神病患者',
    
    -- 状态变更记录
    status_change_date    STRING   COMMENT '状态变更日期',
    status_change_reason  STRING   COMMENT '状态变更原因',
    status_change_person  STRING   COMMENT '状态变更人',
    
    -- 备注信息
    remarks               STRING   COMMENT '备注信息',
    
    -- ETL处理信息
    create_time           TIMESTAMP COMMENT '数据创建时间',
    update_time           TIMESTAMP COMMENT '数据更新时间'
) 
COMMENT '重点人员管理表'
TBLPROPERTIES ('ads.table.type'='key_personnel');
