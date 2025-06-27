--汽车零部件企业软件著作权信息
INSERT OVERWRITE TABLE ods_ra_txz_qmprjzzq_all
SELECT  t1.id    --'主键ID'
        ,t1.company_id    --'企业ID'
        ,t2.uniform_code AS uniscid
        ,t1.company_name    --'企业名称'
        ,t1.software_name    --'软件名称'
        ,t1.software_des    --'软件简介'
        ,t1.version_code    --'版本号代码'
        ,t1.software_classification    --'软件著作分类'
        ,t1.industry_classification    --'行业分类'
        ,t1.reg_date    --'登记日期'
FROM    (
            SELECT  *
                    ,ROW_NUMBER() OVER(PARTITION BY company_id,software_name ORDER BY version_code DESC,reg_date DESC,id DESC) AS rn
            FROM    stg_ra_txz_qmprjzzq_all
        ) t1
LEFT JOIN ods_ra_txz_qmpgsxx_all t2 ON t2.company_id=t1.company_id
WHERE   t2.company_id IS NOT NULL
AND     t1.rn = 1
;