-- =====================================================
-- ADS层：边境管控信息表 DDL定义
-- 表名：ads_border_control
-- 功能：为边境管控业务提供出入境人员管理信息
-- 说明：涵盖出入境记录、边境活动、异常行为等信息
-- =====================================================

DROP TABLE IF EXISTS ads_border_control;

CREATE TABLE IF NOT EXISTS ads_border_control (
    -- 基础标识信息
    record_id             STRING   COMMENT '记录唯一标识',
    person_id             STRING   COMMENT '人员ID(关联人口基础表)',
    id_card               STRING   COMMENT '身份证号码',
    person_name           STRING   COMMENT '姓名',
    
    -- 出入境基本信息
    entry_exit_type       STRING   COMMENT '出入境类型(入境/出境)',
    crossing_time         STRING   COMMENT '通关时间',
    border_port           STRING   COMMENT '口岸名称',
    port_code             STRING   COMMENT '口岸代码',
    
    -- 证件信息
    document_type         STRING   COMMENT '证件类型',
    document_number       STRING   COMMENT '证件号码',
    document_country      STRING   COMMENT '证件签发国家',
    document_expire_date  STRING   COMMENT '证件有效期',
    
    -- 目的地信息
    destination_country   STRING   COMMENT '目的地国家',
    destination_city      STRING   COMMENT '目的地城市',
    visit_purpose         STRING   COMMENT '访问目的',
    stay_duration         STRING   COMMENT '预计停留时间',
    
    -- 交通工具信息
    transport_type        STRING   COMMENT '交通工具类型',
    transport_number      STRING   COMMENT '交通工具编号',
    seat_number           STRING   COMMENT '座位号',
    
    -- 边境活动信息
    activity_type         STRING   COMMENT '活动类型',
    activity_location     STRING   COMMENT '活动地点',
    activity_time         STRING   COMMENT '活动时间',
    activity_frequency    INT      COMMENT '活动频次',
    
    -- 风险评估
    risk_level            STRING   COMMENT '风险等级',
    risk_factors          STRING   COMMENT '风险因素',
    alert_status          STRING   COMMENT '预警状态',
    
    -- 检查结果
    inspection_result     STRING   COMMENT '检查结果',
    inspection_officer    STRING   COMMENT '检查人员',
    inspection_time       STRING   COMMENT '检查时间',
    
    -- 异常情况
    abnormal_behavior     STRING   COMMENT '异常行为',
    suspicious_items      STRING   COMMENT '可疑物品',
    violation_record      STRING   COMMENT '违规记录',
    
    -- 关联人员
    companion_count       INT      COMMENT '同行人员数量',
    companion_info        STRING   COMMENT '同行人员信息',
    
    -- 车辆信息
    vehicle_number        STRING   COMMENT '车辆号牌',
    vehicle_type          STRING   COMMENT '车辆类型',
    vehicle_owner         STRING   COMMENT '车主姓名',
    
    -- 住宿信息
    accommodation_type    STRING   COMMENT '住宿类型',
    accommodation_address STRING   COMMENT '住宿地址',
    check_in_time         STRING   COMMENT '入住时间',
    check_out_time        STRING   COMMENT '退房时间',
    
    -- 联系信息
    contact_phone         STRING   COMMENT '联系电话',
    emergency_contact     STRING   COMMENT '紧急联系人',
    local_contact         STRING   COMMENT '境内联系人',
    
    -- 历史记录
    previous_entries      INT      COMMENT '历史入境次数',
    last_entry_time       STRING   COMMENT '上次入境时间',
    total_stay_days       INT      COMMENT '累计停留天数',
    
    -- 管控措施
    control_measures      STRING   COMMENT '管控措施',
    restriction_reason    STRING   COMMENT '限制原因',
    special_attention     BOOLEAN  COMMENT '是否特别关注',
    
    -- 数据来源
    data_source           STRING   COMMENT '数据来源',
    source_system         STRING   COMMENT '来源系统',
    
    -- 特殊标识
    is_blacklist          BOOLEAN  COMMENT '是否黑名单人员',
    is_terrorist_suspect  BOOLEAN  COMMENT '是否涉恐嫌疑人',
    is_smuggling_suspect  BOOLEAN  COMMENT '是否偷渡嫌疑人',
    is_frequent_crosser   BOOLEAN  COMMENT '是否频繁出入境',
    
    -- 备注信息
    remarks               STRING   COMMENT '备注信息',
    
    -- ETL处理信息
    create_time           TIMESTAMP COMMENT '数据创建时间',
    update_time           TIMESTAMP COMMENT '数据更新时间'
) 
COMMENT '边境管控信息表'
TBLPROPERTIES ('ads.table.type'='border_control');
