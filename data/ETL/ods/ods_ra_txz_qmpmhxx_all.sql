--汽车零部件企业门户信息
INSERT OVERWRITE TABLE ods_ra_txz_qmpmhxx_all
SELECT  t1.id    --'ID'
        ,t1.company_id    --'企业ID'
        ,t2.uniform_code AS uniscid
        ,t1.company_name    --'企业名称'
        ,t1.web_name    --'网站名称'
        ,t1.home_url    --'网站地址'
        ,t1.domain_name    --'网站域名'
        ,t1.case_code    --'备案号或许可证号'
        ,t1.version_flag    --'版本号'
FROM    (
            SELECT  *
                    ,ROW_NUMBER() OVER(PARTITION BY company_id,home_url ORDER BY case_code DESC,id DESC) AS rn
            FROM    stg_ra_txz_qmpmhxx_all
        ) t1
LEFT JOIN ods_ra_txz_qmpgsxx_all t2 ON t2.company_id=t1.company_id
WHERE   t2.company_id IS NOT NULL
AND     t1.rn = 1
;