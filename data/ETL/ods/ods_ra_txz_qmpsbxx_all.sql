--汽车零部件企业商标信息
INSERT OVERWRITE TABLE ods_ra_txz_qmpsbxx_all
SELECT  t1.id    --'ID'
        ,t1.company_id    --'企业ID'
        ,t2.uniform_code AS uniscid
        ,t1.company_name    --'企业名称'
        ,t1.mark_name    --'商标名称'
        ,t1.mark_pic    --'商标图案'
        ,t1.intl_classification    --'国际分类'
        ,t1.apply_date    --'申请日期'
        ,t1.STATUS    --'商标状态'
        ,t1.version_flag    --'版本号'
FROM    (
            SELECT  *
                    ,ROW_NUMBER() OVER(PARTITION BY company_id,mark_name,intl_classification ORDER BY COALESCE(apply_date,GETDATE()),id) AS rn
            FROM    stg_ra_txz_qmpsbxx_all
        ) t1
LEFT JOIN ods_ra_txz_qmpgsxx_all t2 ON t2.company_id=t1.company_id
WHERE   t2.company_id IS NOT NULL
AND     t1.rn = 1
;