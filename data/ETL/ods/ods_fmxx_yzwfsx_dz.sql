--省市回流_全程电子化严重违法失信企业名单信息
INSERT OVERWRITE TABLE ods_fmxx_yzwfsx_dz
SELECT  illid    --'严重违法失信序号'
        ,pripid    --'主体身份代码'
        ,entname    --'企业名称'
        ,uniscid    --'统一社会信用代码'
        ,regno    --'注册号'
        ,name    --'姓名'
        ,certype    --'联络员证件类型'
        ,CASE    WHEN cerno RLIKE '^[1-9][0-9]{5}(18|19|20)[0-9]{2}((0[1-9])|10|11|12)(([0-2][1-9])|10|20|30|31)[0-9]{3}[0-9|X|x]$' THEN cerno
                 WHEN cerno RLIKE '^[1-9][0-9]{5}[0-9]{2}((0[1-9])|10|11|12)(([0-2][1-9])|10|20|30|31)[0-9]{3}$' THEN ID15TO18(cerno) 
                 ELSE NULL 
         END cerno    --'身份证件号码'
        ,serillrea    --'列入严重违法企业名单'
        ,abntime    --'列入日期'
        ,decorg    --'决定机关'
        ,decorg_cn    --'决定机关中文名称'
        ,dedocnum    --'列入文号'
FROM    stg_fmxx_yzwfsx_dz
WHERE   delflag = '0'
AND     COALESCE(zxsign,'0') = '0'
;