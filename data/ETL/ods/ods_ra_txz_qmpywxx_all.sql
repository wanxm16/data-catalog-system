--汽车零部件企业业务信息
INSERT OVERWRITE TABLE ods_ra_txz_qmpywxx_all
SELECT  t1.id    --'ID'
        ,t1.company_id    --'企业ID'
        ,t2.uniform_code AS uniscid
        ,t1.company_name    --'企业名称'
        ,t1.project_name    --'产品名称'
        ,t1.latest_financing_round    --'最新融资'
        ,t1.establish_time    --'成立时间'
        ,t1.affiliated_adr    --'所属地'
        ,t1.project_des    --'产品介绍'
        ,t1.version_flag    --'版本号'
FROM    stg_ra_txz_qmpywxx_all t1
LEFT JOIN ods_ra_txz_qmpgsxx_all t2 ON t2.company_id=t1.company_id
WHERE t2.company_id IS NOT NULL
;