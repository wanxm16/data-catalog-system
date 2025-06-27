--省市回流_严重违法失信企业信息（国家）
INSERT OVERWRITE TABLE ods_fmxx_yzwfsx_gj
SELECT  illid    --'严重违法失信企业名单'
        ,COALESCE(t1.pripid1,t2.pripid) pripid    --'主体身份代码'
        ,t1.entname    --'企业名称'
        ,t1.uniscid    --'统一社会信用代码'
        ,t1.regno    --'注册号'
        ,t1.name    --'法定代表人/负责人'
        ,t1.certype    --'法定代表人/负责人证件类型'
        ,COALESCE(t1.cerno1,t2.cerno) cerno    --'法定代表人/负责人证号'
        ,serillrea    --'列入事由'
        ,abntime    --'列入日期'
        ,decorg    --'列入作出决定机关'
        ,decorg_cn    --'列入作出决定机关中文'
        ,dedocnum    --'列入文号'
FROM    (
            SELECT  *
                    ,CASE    WHEN cerno RLIKE '^[1-9][0-9]{5}(18|19|20)[0-9]{2}((0[1-9])|10|11|12)(([0-2][1-9])|10|20|30|31)[0-9]{3}[0-9|X|x]$' THEN cerno 
                             WHEN cerno RLIKE '^[1-9][0-9]{5}[0-9]{2}((0[1-9])|10|11|12)(([0-2][1-9])|10|20|30|31)[0-9]{3}$' THEN ID15TO18(cerno) 
                             ELSE NULL 
                     END cerno1
                    ,CASE    WHEN LENGTH(pripid)<>16 THEN NULL 
                             ELSE pripid 
                     END pripid1
                    ,CASE    WHEN LENGTH(pripid)<>16 THEN uniscid 
                             ELSE NULL 
                     END uniscid1    --用于关联
            FROM    stg_fmxx_yzwfsx_gj
            WHERE   dsc_biz_operation IN ('insert','update')
        ) t1
LEFT JOIN dwd_qy_main2 t2 ON t2.uniscid = t1.uniscid1 AND t2.uniscid IS NOT NULL 
;