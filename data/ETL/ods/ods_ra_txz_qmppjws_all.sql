--汽车零部件企业裁判文书信息
INSERT OVERWRITE TABLE ods_ra_txz_qmppjws_all
SELECT  t1.id    --'ID'
        ,t1.company_id    --'企业ID'
        ,t2.uniform_code AS uniscid
        ,t1.company_name    --'企业名称'
        ,t1.case_name    --'案件名称'
        ,t1.case_cause    --'案由'
        ,t1.case_date    --'案件日期'
        ,t1.case_role    --'案件身份'
        ,t1.case_code    --'案号'
        ,t1.version_flag    --'版本号'
FROM    (
            SELECT  *
                    ,ROW_NUMBER() OVER(PARTITION BY company_id,case_code ORDER BY COALESCE(case_date,GETDATE()),id) AS rn
            FROM    stg_ra_txz_qmppjws_all
        ) t1
LEFT JOIN ods_ra_txz_qmpgsxx_all t2 ON t2.company_id=t1.company_id
WHERE   t2.company_id IS NOT NULL
AND     t1.rn = 1
;