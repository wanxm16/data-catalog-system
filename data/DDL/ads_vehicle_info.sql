-- =====================================================
-- ADS层：车辆信息表 DDL定义
-- 表名：ads_vehicle_info
-- 功能：为公安业务提供统一的车辆信息管理
-- 说明：涵盖车辆登记、交易、违章等信息
-- =====================================================

DROP TABLE IF EXISTS ads_vehicle_info;

CREATE TABLE IF NOT EXISTS ads_vehicle_info (
    -- 基础标识信息
    vehicle_id            STRING   COMMENT '车辆唯一标识',
    license_plate         STRING   COMMENT '车牌号码',
    vin_code              STRING   COMMENT '车架号(VIN码)',
    engine_number         STRING   COMMENT '发动机号',
    
    -- 车辆基本信息
    vehicle_type          STRING   COMMENT '车辆类型',
    vehicle_model         STRING   COMMENT '车辆型号',
    brand_name            STRING   COMMENT '品牌名称',
    vehicle_color         STRING   COMMENT '车身颜色',
    
    -- 技术参数
    engine_displacement   STRING   COMMENT '排量',
    fuel_type             STRING   COMMENT '燃料类型',
    transmission_type     STRING   COMMENT '变速器类型',
    drive_type            STRING   COMMENT '驱动方式',
    
    -- 登记信息
    register_date         STRING   COMMENT '初次登记日期',
    register_location     STRING   COMMENT '登记地点',
    register_org          STRING   COMMENT '登记机关',
    
    -- 所有人信息
    owner_name            STRING   COMMENT '所有人姓名',
    owner_id_card         STRING   COMMENT '所有人身份证',
    owner_phone           STRING   COMMENT '所有人电话',
    owner_address         STRING   COMMENT '所有人地址',
    owner_type            STRING   COMMENT '所有人类型(个人/单位)',
    
    -- 使用性质
    use_nature            STRING   COMMENT '使用性质',
    operation_type        STRING   COMMENT '营运类型',
    
    -- 检验信息
    annual_inspection_date STRING  COMMENT '年检到期日',
    last_inspection_date  STRING   COMMENT '上次检验日期',
    inspection_status     STRING   COMMENT '检验状态',
    
    -- 保险信息
    insurance_company     STRING   COMMENT '保险公司',
    insurance_expire_date STRING   COMMENT '保险到期日期',
    insurance_type        STRING   COMMENT '保险类型',
    
    -- 状态信息
    vehicle_status        STRING   COMMENT '车辆状态',
    lock_status           STRING   COMMENT '查封状态',
    mortgage_status       STRING   COMMENT '抵押状态',
    
    -- 交易信息
    last_transfer_date    STRING   COMMENT '最后过户日期',
    transfer_count        INT      COMMENT '过户次数',
    purchase_price        DECIMAL(12,2) COMMENT '购买价格',
    
    -- 违法信息
    violation_count       INT      COMMENT '违法次数',
    unpaid_fine_amount    DECIMAL(10,2) COMMENT '未缴罚款金额',
    last_violation_date   STRING   COMMENT '最后违法日期',
    
    -- 事故信息
    accident_count        INT      COMMENT '事故次数',
    last_accident_date    STRING   COMMENT '最后事故日期',
    
    -- 轨迹信息
    last_seen_location    STRING   COMMENT '最后出现地点',
    last_seen_time        STRING   COMMENT '最后出现时间',
    frequent_areas        STRING   COMMENT '经常活动区域',
    
    -- 关联信息
    related_cases         STRING   COMMENT '关联案件',
    suspicious_activities STRING   COMMENT '可疑活动',
    
    -- 特殊标识
    is_stolen             BOOLEAN  COMMENT '是否被盗车辆',
    is_wanted             BOOLEAN  COMMENT '是否布控车辆',
    is_key_vehicle        BOOLEAN  COMMENT '是否重点车辆',
    is_fake_plate         BOOLEAN  COMMENT '是否套牌车辆',
    
    -- 技术特征
    modification_info     STRING   COMMENT '改装信息',
    special_equipment     STRING   COMMENT '特殊设备',
    
    -- 数据来源
    data_source           STRING   COMMENT '数据来源',
    source_system         STRING   COMMENT '来源系统',
    
    -- 备注信息
    remarks               STRING   COMMENT '备注信息',
    
    -- ETL处理信息
    create_time           TIMESTAMP COMMENT '数据创建时间',
    update_time           TIMESTAMP COMMENT '数据更新时间'
) 
COMMENT '车辆信息表'
TBLPROPERTIES ('ads.table.type'='vehicle_info');
