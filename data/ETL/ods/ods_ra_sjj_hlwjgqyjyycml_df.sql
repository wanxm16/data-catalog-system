--省市回流_“互联网+监管”企业其他信息（企业经营异常名录信息）
INSERT OVERWRITE TABLE ods_ra_sjj_hlwjgqyjyycml_df
SELECT  busexclist    --'企业经营异常名录信息ID',
        ,pripid    --'统一社会信用代码',
        ,specause    --'列入经营异常名录原因',
        ,specause_cn    --'列入经营异常名录原因描述',
        ,abnormal_putdate    --'列入日期',
        ,decorg    --'作出列入决定机关',
        ,decorg_cn    --'作出列入决定机关名称',
        ,remexcpres    --'移出经营异常名录原因',
        ,remexcpres_cn    --'移出经营异常名录原因描述',
        ,remdate    --'移出日期',
        ,redecorg    --'作出移出决定机关',
        ,redecorg_cn    --'作出移出决定机关名称',
FROM    (
            SELECT  *
                    ,ROW_NUMBER() OVER(PARTITION BY pripid,TO_CHAR(abnormal_putdate,'yyyy-MM-dd'),specause_cn ORDER BY dsc_biz_timestamp DESC,dsc_biz_record_id DESC) AS rn
            FROM    stg_ra_sjj_hlwjgqyjyycml_df
            WHERE   dsc_biz_operation IN ('insert','update', 'I')
        ) t1
WHERE   rn = 1
;