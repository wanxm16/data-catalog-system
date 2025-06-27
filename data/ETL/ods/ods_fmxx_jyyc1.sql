--省市回流_经营异常名录信息
INSERT OVERWRITE TABLE ods_fmxx_jyyc1
SELECT  busexclist    --'经营异常名录ID'
        ,entname    --'企业名称'
        ,pripid    --'内部序号'
        ,uniscid    --'统一社会信用代码'
        ,regno    --'营业执照注册号'
        ,abntime    --'列入日期'
        ,specause_cn    --'列入经营异常名录原因'
        ,decorg_cn    --'作出决定机关(列入)'
        ,redecorg_cn    --'作出决定机关(移出)'
        ,remexcpres_cn    --'移出经营异常名录原因'
        ,remdate    --'移出日期'
FROM    (
            SELECT  *
                    ,ROW_NUMBER() OVER(PARTITION BY pripid,abntime,specause_cn ORDER BY dsc_biz_timestamp DESC,dsc_biz_record_id DESC) AS rn
            FROM    stg_fmxx_jyyc
            WHERE   dsc_biz_operation IN ('insert','update')
        ) t1
WHERE   rn = 1
;