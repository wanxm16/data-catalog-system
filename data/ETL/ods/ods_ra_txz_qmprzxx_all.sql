--汽车零部件企业融资信息
INSERT OVERWRITE TABLE ods_ra_txz_qmprzxx_all
SELECT  t1.id    --'ID'
        ,t1.company_id    --'企业ID'
        ,t2.uniform_code AS uniscid
        ,t1.company_name    --'企业名称'
        ,t1.pub_date    --'发布日期'
        ,t1.financing_amount    --'融资金额'
        ,t1.investor    --'投资方'
        ,t1.financing_round    --'融资轮次'
        ,t1.version_flag    --'版本号'
FROM    (
            SELECT  *
                    ,ROW_NUMBER() OVER(PARTITION BY company_id,pub_date,financing_round ORDER BY id DESC) AS rn
            FROM    stg_ra_txz_qmprzxx_all
        ) t1
LEFT JOIN ods_ra_txz_qmpgsxx_all t2 ON t2.company_id=t1.company_id
WHERE   t2.company_id IS NOT NULL
AND     t1.rn = 1
;
