-- =====================================================
-- ADS层：案件信息表 DDL定义
-- 表名：ads_case_info
-- 功能：为公安业务提供统一的案件信息管理
-- 说明：涵盖刑事案件、治安案件等各类案件信息
-- =====================================================

DROP TABLE IF EXISTS ads_case_info;

CREATE TABLE IF NOT EXISTS ads_case_info (
    -- 基础标识信息
    case_id               STRING   COMMENT '案件唯一标识',
    case_number           STRING   COMMENT '案件编号',
    case_name             STRING   COMMENT '案件名称',
    
    -- 案件分类信息
    case_type             STRING   COMMENT '案件类型(刑事/治安/交通等)',
    case_category         STRING   COMMENT '案件类别',
    crime_type            STRING   COMMENT '罪名/违法行为',
    case_nature           STRING   COMMENT '案件性质',
    
    -- 案件基本信息
    report_time           STRING   COMMENT '报案时间',
    occur_time_start      STRING   COMMENT '案发时间开始',
    occur_time_end        STRING   COMMENT '案发时间结束',
    discover_time         STRING   COMMENT '发现时间',
    
    -- 地点信息
    occur_location        STRING   COMMENT '案发地点',
    occur_district        STRING   COMMENT '案发行政区划',
    occur_police_station  STRING   COMMENT '案发地派出所',
    scene_type            STRING   COMMENT '现场类型',
    
    -- 案件状态
    case_status           STRING   COMMENT '案件状态',
    handle_status         STRING   COMMENT '办理状态',
    solve_status          STRING   COMMENT '破案状态',
    close_status          STRING   COMMENT '结案状态',
    
    -- 办案信息
    accept_unit           STRING   COMMENT '受理单位',
    handle_unit           STRING   COMMENT '办理单位',
    case_handler          STRING   COMMENT '办案人员',
    supervisor            STRING   COMMENT '监督人员',
    
    -- 报案人信息
    reporter_name         STRING   COMMENT '报案人姓名',
    reporter_id_card      STRING   COMMENT '报案人身份证',
    reporter_phone        STRING   COMMENT '报案人电话',
    reporter_address      STRING   COMMENT '报案人地址',
    report_method         STRING   COMMENT '报案方式',
    
    -- 受害人信息
    victim_name           STRING   COMMENT '受害人姓名',
    victim_id_card        STRING   COMMENT '受害人身份证',
    victim_phone          STRING   COMMENT '受害人电话',
    victim_count          INT      COMMENT '受害人数量',
    
    -- 嫌疑人信息
    suspect_count         INT      COMMENT '嫌疑人数量',
    arrest_count          INT      COMMENT '抓获人数',
    
    -- 案件损失
    economic_loss         DECIMAL(15,2) COMMENT '经济损失金额',
    recovered_amount      DECIMAL(15,2) COMMENT '挽回损失金额',
    property_loss         STRING   COMMENT '财产损失描述',
    
    -- 案件描述
    case_summary          STRING   COMMENT '案件简要情况',
    case_detail           STRING   COMMENT '案件详细情况',
    modus_operandi        STRING   COMMENT '作案手法',
    evidence_summary      STRING   COMMENT '证据概要',
    
    -- 关联信息
    related_cases         STRING   COMMENT '关联案件',
    series_case_flag      BOOLEAN  COMMENT '是否系列案件',
    gang_case_flag        BOOLEAN  COMMENT '是否团伙案件',
    
    -- 重要程度
    importance_level      STRING   COMMENT '重要程度',
    influence_level       STRING   COMMENT '影响程度',
    media_attention       BOOLEAN  COMMENT '是否媒体关注',
    
    -- 时间节点
    file_time             STRING   COMMENT '立案时间',
    solve_time            STRING   COMMENT '破案时间',
    close_time            STRING   COMMENT '结案时间',
    
    -- 统计分类
    statistical_category  STRING   COMMENT '统计分类',
    report_category       STRING   COMMENT '上报类别',
    
    -- 特殊标识
    is_major_case         BOOLEAN  COMMENT '是否重大案件',
    is_cross_region       BOOLEAN  COMMENT '是否跨区域案件',
    is_terrorism_related  BOOLEAN  COMMENT '是否涉恐案件',
    is_drug_related       BOOLEAN  COMMENT '是否涉毒案件',
    
    -- 备注信息
    remarks               STRING   COMMENT '备注信息',
    
    -- ETL处理信息
    create_time           TIMESTAMP COMMENT '数据创建时间',
    update_time           TIMESTAMP COMMENT '数据更新时间'
) 
COMMENT '案件信息表'
TBLPROPERTIES ('ads.table.type'='case_info');
