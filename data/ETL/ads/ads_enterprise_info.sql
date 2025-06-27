-- =====================================================
-- ADS层：企业信息应用表 ETL脚本
-- 表名：ads_enterprise_info
-- 数据源：dwd_qy_main1 (企业主体表-底数合表)
-- 功能：为应用层提供统一的企业信息视图
-- 说明：假设目标表已通过DDL脚本创建
-- =====================================================

-- 清空目标表数据（保留表结构）
TRUNCATE TABLE ads_enterprise_info;

-- 插入企业信息数据
INSERT INTO ads_enterprise_info (
        -- 基础标识信息
        pripid,
        uniscid,
        regno,
        entname,
        
        -- 企业分类信息
        reporttype_cn,
        reporttype_code,
        industryphy_cn,
        industryphy_code,
        industryco_cn,
        industryco_code,
        
        -- 时间信息
        estdate,
        apprdate,
        
        -- 注册资本信息
        regcap,
        regcapcur,
        
        -- 地址信息
        dom,
        domdistrict,
        dom_street,
        dom_village,
        
        -- 经营场所信息
        oploc,
        oplocdistrict,
        oploc_street,
        oploc_village,
        
        -- 经营期限与范围
        opfrom,
        opto,
        opscope,
        
        -- 生产经营地信息
        proloc,
        proloc_street,
        proloc_village,
        yiedistrict,
        
        -- 法定代表人信息
        lerep_name,
        country_cn,
        country_code,
        certype_cn,
        certype_code,
        cerno,
        
        -- 联系信息
        tel,
        email,
        
        -- 状态信息
        regstate,
        revdate,
        revdecno,
        revbasis,
        revauth,
        candate,
        canrea_cn,
        canrea_code,
        
        -- 小微企业信息
        xwstate,
        xwsort_cn,
        xw_addtime,
        xw_remtime,
        xw_remreason,
        
        -- 标识位信息
        web_bit,
        above_bit,
        above_year,
        stock_bit,
        stock_name,
        stock_code,
        stock_date,
        stock_address,
        stock_text,
        
        -- 转型信息
        ind_to_ent,
        ind_to_ent2,
        compform,
        
        -- 管理信息
        regorg,
        localadm,
        localadm_cn,
        laiyuan,
        
        -- ETL处理信息
        create_time,
        update_time
)
SELECT  
        -- 基础标识信息
        pripid,                   -- 主体身份代码
        uniscid,                  -- 统一社会信用代码
        regno,                    -- 注册号
        entname,                  -- 企业名称
        
        -- 企业分类信息
        reporttype_cn,            -- 企业类型名称
        reporttype_code,          -- 企业类型代码
        industryphy_cn,           -- 行业门类名称
        industryphy_code,         -- 行业门类代码
        industryco_cn,            -- 行业名称
        industryco_code,          -- 行业代码
        
        -- 时间信息
        estdate,                  -- 成立日期
        apprdate,                 -- 核准日期
        
        -- 注册资本信息
        regcap,                   -- 注册资本
        regcapcur,                -- 注册资本币种
        
        -- 地址信息
        dom,                      -- 注册地址
        domdistrict,              -- 行政区划代码
        dom_street,               -- 归属乡镇街道
        dom_village,              -- 归属村居社区
        
        -- 经营场所信息
        oploc,                    -- 经营场所
        oplocdistrict,            -- 经营场所行政区划代码
        oploc_street,             -- 经营场所乡镇街道
        oploc_village,            -- 经营场所村居社区
        
        -- 经营期限与范围
        opfrom,                   -- 经营(驻在)期限自
        opto,                     -- 经营(驻在)期限至
        opscope,                  -- 经营范围
        
        -- 生产经营地信息
        proloc,                   -- 生产经营地
        proloc_street,            -- 生产地乡镇街道
        proloc_village,           -- 生产地村居社区
        yiedistrict,              -- 生产经营地行政代码
        
        -- 法定代表人信息
        lerep_name,               -- 法定代表人
        country_cn,               -- 国籍名称
        country_code,             -- 国籍代码
        certype_cn,               -- 证件类型名称
        certype_code,             -- 证件类型代码
        cerno,                    -- 身份证件号码
        
        -- 联系信息
        tel,                      -- 联系电话
        email,                    -- 电子邮件地址
        
        -- 状态信息
        regstate,                 -- 状态
        revdate,                  -- 吊销时间
        revdecno,                 -- 吊销处罚文号
        revbasis,                 -- 吊销原因
        revauth,                  -- 吊照处罚实施机关
        candate,                  -- 注销时间
        canrea_cn,                -- 注销原因中文
        canrea_code,              -- 注销原因代码
        
        -- 小微企业信息
        xwstate,                  -- 小微企业状态代码
        xwsort_cn,                -- 小微企业分类名称
        xw_addtime,               -- 加入时间
        xw_remtime,               -- 退出时间
        xw_remreason,             -- 退出原因
        
        -- 标识位信息
        web_bit,                  -- 互联网监管
        above_bit,                -- 规上规下
        above_year,               -- 规上年份
        stock_bit,                -- 上市企业
        stock_name,               -- 股票名称
        stock_code,               -- 股票代码
        stock_date,               -- 上市时间
        stock_address,            -- 上市交易所
        stock_text,               -- 简介描述
        
        -- 转型信息
        ind_to_ent,               -- 是否个转企
        ind_to_ent2,              -- 是否个转企二次转型
        compform,                 -- 个体户组成形式
        
        -- 管理信息
        regorg,                   -- 企业登记机关
        localadm,                 -- 管辖单位代码
        localadm_cn,              -- 管辖单位名称
        laiyuan,                  -- 合表来源
        
        -- ETL处理信息
        CURRENT_TIMESTAMP(),      -- 数据创建时间
        CURRENT_TIMESTAMP()       -- 数据更新时间
        
FROM dwd_qy_main1
WHERE 1=1
    -- 数据质量过滤条件
    AND (pripid IS NOT NULL OR uniscid IS NOT NULL OR regno IS NOT NULL)  -- 至少有一个主键标识
    AND LENGTH(TRIM(COALESCE(entname,''))) > 0                             -- 企业名称不能为空
; 