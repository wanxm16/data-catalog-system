--省市回流_“互联网+监管”企业其他信息（严重违法企业信息）
INSERT OVERWRITE TABLE ods_fmxx_yzwfsx_wj
SELECT  illid    --'严重违法信息ID'
        ,pripid    --'主体身份代码'
        ,specause    --'列入严重违法企业名单'
        ,specause_cn    --'列入严重违法企业名单'
        ,SUBSTR(abnormal_putdate,1,10)    --'列入日期'
        ,decorg    --'作出列入决定机关'
        ,decorg_cn    --'作出列入决定机关名称'
        ,remexcpres    --'移出严重违法企业名单'
        ,remexcpres_cn    --'移出严重违法企业名单'
        ,SUBSTR(remdate,1,10)    --'移出日期'
        ,redecorg    --'作出移出决定机关'
        ,redecorg_cn    --'作出移出决定机关名称'
FROM    (
            SELECT  *
                    ,ROW_NUMBER() OVER(PARTITION BY pripid,abnormal_putdate,specause_cn ORDER BY dsc_biz_timestamp DESC ,dsc_biz_record_id DESC) AS rn
            FROM    stg_fmxx_yzwfsx_wj 
            WHERE   dsc_biz_operation IN ('insert','update','I','U')
        ) t1
WHERE   rn = 1
;