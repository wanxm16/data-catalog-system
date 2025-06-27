--汽车零部件企业竞争力信息
INSERT OVERWRITE TABLE ods_ra_txz_qmpjzl_all
SELECT  t1.id    --'唯一ID'
        ,t1.company_id    --'企业ID'
        ,t2.uniform_code AS uniscid
        ,t1.company_name    --'企业名称'
        ,t1.scale_index    --'规模指数'
        ,t1.inno_index    --'创新指数'
        ,t1.growth_index    --'成长指数'
        ,t1.finance_index    --'投融指数'
        ,t1.effect_index    --'社会效益指数'
        ,t1.total_index    --'竞争力总指数'
        ,t1.version_flag    --'版本号'
        ,t1.scale_desc    --'规模指数描述'
        ,t1.inno_desc    --'创新指数描述'
        ,t1.growth_desc    --'成长指数描述'
        ,t1.finance_desc    --'投融指数描述'
        ,t1.effect_desc    --'社会效益指数描述'
        ,t1.total_desc    --'竞争力总描述'
FROM    stg_ra_txz_qmpjzl_all t1
LEFT JOIN ods_ra_txz_qmpgsxx_all t2 on t2.company_id=t1.company_id
WHERE t2.company_id IS NOT NULL
;