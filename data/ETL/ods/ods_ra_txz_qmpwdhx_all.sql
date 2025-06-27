--汽车零部件企业维度画像信息
INSERT OVERWRITE TABLE ods_ra_txz_qmpwdhx_all
SELECT  t1.company_id    --'企业ID'
        ,t2.uniform_code AS uniscid
        ,t1.company_name    --'企业名称'
        ,t1.loc_province    --'省份'
        ,t1.loc_city    --'城市'
        ,t1.loc_area    --'区县'
        ,t1.loc_lng    --'经度'
        ,t1.loc_lat    --'纬度'
        ,t1.loc_geohash    --'地址编码'
        ,t1.loc_division_code    --'行政区划代码'
        ,t1.chain_first    --'产业链大类'
        ,t1.chain_list    --'产业链明细'
        ,t1.industry    --'一级国标行业'
        ,t1.industry_code    --'一级国标行业代码'
        ,t1.subindustry    --'二级国标行业'
        ,t1.subindustry_code  --'二级国标行业代码'
        ,t1.cert_honor    --'荣誉资质'
        ,t1.rank_list    --'入选榜单'
        ,t1.version_flag    --'版本号'
FROM    stg_ra_txz_qmpwdhx_all t1
LEFT JOIN ods_ra_txz_qmpgsxx_all t2 ON t2.company_id=t1.company_id
WHERE t2.company_id IS NOT NULL
;