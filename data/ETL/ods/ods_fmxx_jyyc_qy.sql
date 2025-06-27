--省市回流_企业经营异常名录信息
INSERT OVERWRITE TABLE ods_fmxx_jyyc_qy
SELECT  busexclist    --'主键'
        ,pripid    --'内部序号'
        ,specause    --'列入经营异常名录原因'
        ,specause_cn    --'列入经营异常名录原因'
        ,abnormal_putdate   --'列入日期'
        ,decorg    --'作出决定机关（列入）'
        ,decorg_cn    --'作出决定机关（列入）'
        ,remexcpres    --'移出经营异常名录原因'
        ,remexcpres_cn    --'移出经营异常名录原因'
        ,remdate    --'移出日期'
        ,redecorg    --'作出决定机关（移出）'
        ,redecorg_cn    --'作出决定机关（移出）'
        ,ismove    --'是否移出'
FROM    (
            SELECT  *
                    ,ROW_NUMBER() OVER(PARTITION BY pripid,TO_CHAR(abnormal_putdate,'yyyy-MM-dd'),specause_cn ORDER BY cd_time DESC,cd_id DESC) AS rn
            FROM    stg_fmxx_jyyc_qy
            WHERE   cd_operation <> 'D'
        ) t1
WHERE   rn = 1
;