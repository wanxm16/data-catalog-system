--汽车零部件企业其他风险信息
INSERT OVERWRITE TABLE ods_ra_txz_qmpqtfx_all
SELECT  t1.id    --'ID'
        ,t1.company_id    --'企业ID'
        ,t2.uniform_code AS uniscid
        ,t1.company_name    --'企业名称'
        ,t1.statis_date    --'计算日期'
        ,t1.un_operation    --'经营异常'
        ,t1.illegal    --'严重违法'
        ,t1.pledge    --'股权出质'
        ,t1.judicial_case    --'司法案件'
        ,t1.mortgage    --'动产抵押'
        ,t1.executee    --'被执行人'
        ,t1.limit_cons    --'限制高消费'
        ,t1.final_case    --'终本案件'
        ,t1.version_flag    --'版本号'
FROM    stg_ra_txz_qmpqtfx_all t1
LEFT JOIN ods_ra_txz_qmpgsxx_all t2 ON t2.company_id=t1.company_id
WHERE t2.company_id IS NOT NULL
;