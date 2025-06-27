--汽车零部件产业链成分企业信息
INSERT OVERWRITE TABLE ods_ra_txz_qmpcylcfqy_all
SELECT  t1.id    --'唯一ID'
        ,t1.chain_id    --'产业链ID'
        ,t1.company_id    --'企业ID'
        ,t2.uniform_code AS uniscid
        ,t1.chain_name    --'产业链名称'
        ,t1.company_name    --'企业名称'
        ,t1.is_valid    --'是否有效'
        ,t1.version_flag    --'版本号'
FROM    stg_ra_txz_qmpcylcfqy_all t1
LEFT JOIN ods_ra_txz_qmpgsxx_all t2 ON t2.company_id=t1.company_id
WHERE t2.company_id IS NOT NULL
;