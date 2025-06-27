--省市回流_工业企业安全在线企业综合风险信息
INSERT OVERWRITE TABLE ods_ra_yjj_gyqyaqzhfx_df
SELECT  ent_id    --'企业标识'
        ,ent_name    --'企业名称'
        ,ent_unified_code    --'统一社会信用代码'
        ,stat_date    --'统计日期'
        ,hundred_risk_score    --'折百风险值'
        ,risk_level    --'风险等级'
        ,city_name    --'城市'
        ,county_name    --'区县'
        ,town_name    --'乡镇'
FROM    stg_ra_yjj_gyqyaqzhfx_df
WHERE   actived = 1
;