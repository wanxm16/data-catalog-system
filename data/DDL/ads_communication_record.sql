-- =====================================================
-- ADS层：通信记录表 DDL定义
-- 表名：ads_communication_record
-- 功能：为公安业务提供通信行为分析数据
-- 说明：涵盖通话、短信等通信记录信息
-- =====================================================

DROP TABLE IF EXISTS ads_communication_record;

CREATE TABLE IF NOT EXISTS ads_communication_record (
    -- 基础标识信息
    record_id             STRING   COMMENT '记录唯一标识',
    person_id             STRING   COMMENT '人员ID(关联人口基础表)',
    caller_id             STRING   COMMENT '主叫方ID',
    callee_id             STRING   COMMENT '被叫方ID',
    
    -- 通信基本信息
    communication_type    STRING   COMMENT '通信类型(语音/短信/数据)',
    caller_number         STRING   COMMENT '主叫号码',
    callee_number         STRING   COMMENT '被叫号码',
    
    -- 时间信息
    start_time            STRING   COMMENT '开始时间',
    end_time              STRING   COMMENT '结束时间',
    duration              INT      COMMENT '通话时长(秒)',
    
    -- 位置信息
    caller_location       STRING   COMMENT '主叫方位置',
    callee_location       STRING   COMMENT '被叫方位置',
    caller_base_station   STRING   COMMENT '主叫基站',
    callee_base_station   STRING   COMMENT '被叫基站',
    
    -- 设备信息
    caller_imei           STRING   COMMENT '主叫设备IMEI',
    callee_imei           STRING   COMMENT '被叫设备IMEI',
    caller_device_type    STRING   COMMENT '主叫设备类型',
    callee_device_type    STRING   COMMENT '被叫设备类型',
    
    -- 运营商信息
    caller_operator       STRING   COMMENT '主叫运营商',
    callee_operator       STRING   COMMENT '被叫运营商',
    
    -- 通信内容(加密存储)
    content_summary       STRING   COMMENT '内容摘要',
    keyword_flags         STRING   COMMENT '关键词标识',
    sensitive_level       STRING   COMMENT '敏感等级',
    
    -- 频次统计
    daily_call_count      INT      COMMENT '当日通话次数',
    monthly_call_count    INT      COMMENT '当月通话次数',
    contact_frequency     STRING   COMMENT '联系频率',
    
    -- 行为分析
    call_pattern          STRING   COMMENT '通话模式',
    time_pattern          STRING   COMMENT '时间规律',
    abnormal_flag         BOOLEAN  COMMENT '是否异常通信',
    
    -- 关联分析
    related_persons       STRING   COMMENT '关联人员',
    group_communication   BOOLEAN  COMMENT '是否群体通信',
    
    -- 案件关联
    related_case_id       STRING   COMMENT '关联案件ID',
    evidence_flag         BOOLEAN  COMMENT '是否作为证据',
    
    -- 监控信息
    monitor_reason        STRING   COMMENT '监控原因',
    monitor_authority     STRING   COMMENT '监控授权',
    monitor_start_date    STRING   COMMENT '监控开始日期',
    monitor_end_date      STRING   COMMENT '监控结束日期',
    
    -- 风险评估
    risk_score            DECIMAL(5,2) COMMENT '风险评分',
    risk_factors          STRING   COMMENT '风险因素',
    
    -- 数据来源
    data_source           STRING   COMMENT '数据来源',
    source_system         STRING   COMMENT '来源系统',
    
    -- 特殊标识
    is_international      BOOLEAN  COMMENT '是否国际通信',
    is_encrypted          BOOLEAN  COMMENT '是否加密通信',
    is_suspicious         BOOLEAN  COMMENT '是否可疑通信',
    
    -- 备注信息
    remarks               STRING   COMMENT '备注信息',
    
    -- ETL处理信息
    create_time           TIMESTAMP COMMENT '数据创建时间',
    update_time           TIMESTAMP COMMENT '数据更新时间'
) 
COMMENT '通信记录表'
TBLPROPERTIES ('ads.table.type'='communication_record');
