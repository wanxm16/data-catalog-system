--省市回流_严重违法失信企业名单信息
INSERT OVERWRITE TABLE ods_fmxx_yzwfsx1 
SELECT  illid    --'严重违法失信企业名单ID'
        ,entname    --'企业名称'
        ,pripid    --'主体身份代码'
        ,uniscid    --'统一社会信用代码'
        ,regno    --'营业执照注册号'
        ,abntime    --'列入日期'
        ,decorg_cn    --'作出决定机关(列入)'
        ,serillrea_cn    --'列入严重违法失信企业'
        ,remdate    --'移出日期'
        ,recorg_cn    --'作出决定机关(移出)'
        ,remexcpres_cn    --'移出严重违法失信企业'
FROM    (
            SELECT  *
                    ,ROW_NUMBER() OVER(PARTITION BY pripid,abntime,serillrea_cn ORDER BY dsc_biz_timestamp DESC,dsc_biz_record_id DESC) AS rn
            FROM    stg_fmxx_yzwfsx 
            WHERE   dsc_biz_operation IN ('insert','update')
        ) t1
WHERE   rn = 1
;