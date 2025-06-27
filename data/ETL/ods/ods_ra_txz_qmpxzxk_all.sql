--汽车零部件企业行政许可证书
INSERT OVERWRITE TABLE ods_ra_txz_qmpxzxk_all
SELECT  t1.id    --'ID'
        ,t1.company_id    --'企业ID'
        ,t1.company_name    --'企业名称'
        ,t2.uniform_code AS uniscid
        ,t1.lic_code    --'行政许可证号'
        ,t1.lic_name    --'许可名称'
        ,t1.lic_content    --'许可内容'
        ,t1.valid_from    --'有效期自'
        ,t1.valid_until    --'有效期至'
        ,t1.lic_authority    --'许可机关'
FROM    (
            SELECT  *
                    ,COALESCE(lic_code,lic_name,lic_content) lic_key
                    ,ROW_NUMBER() OVER(PARTITION BY company_id,COALESCE(lic_code,lic_name,lic_content) ORDER BY id DESC) AS rn
            FROM    stg_ra_txz_qmpxzxk_all
            WHERE   COALESCE(lic_code,lic_name,lic_content) IS NOT NULL
        ) t1
LEFT JOIN ods_ra_txz_qmpgsxx_all t2 ON t2.company_id=t1.company_id
WHERE   t2.company_id IS NOT NULL
AND     t1.rn = 1
;