--汽车零部件企业作品著作权信息
INSERT OVERWRITE TABLE ods_ra_txz_qmpzpzzq_all
SELECT  t1.id    --'ID'
        ,t1.company_id    --'企业ID'
        ,t2.uniform_code AS uniscid
        ,t1.company_name    --'企业名称'
        ,t1.work_name    --'作品名称'
        ,t1.work_cat    --'作品类别'
        ,t1.reg_code    --'登记号'
        ,t1.creation_date    --'创作完成日期'
        ,t1.first_pub_date    --'首次发表日期'
        ,t1.reg_date    --'登记日期'
        ,t1.version_flag    --'版本号'
FROM    (
            SELECT  *
                    ,ROW_NUMBER() OVER(PARTITION BY company_id,work_name ORDER BY reg_date DESC,id DESC) AS rn
            FROM    stg_ra_txz_qmpzpzzq_all
        ) t1
LEFT JOIN ods_ra_txz_qmpgsxx_all t2 ON t2.company_id=t1.company_id
WHERE   t2.company_id IS NOT NULL
AND     t1.rn = 1
;