--省市回流_高新技术企业信息
INSERT OVERWRITE TABLE ods_ra_kjj_gxjsqy_df
SELECT  id    --'业务库表ID'
        ,certificateno    --'证书编号'
        ,enterprisename    --'企业名称'
        ,creditcode    --'统一社会信用代码'
        ,cdc_dm_timestamp    --'DM表数据同步时间'
FROM    (
            SELECT  *
                    ,ROW_NUMBER() OVER(PARTITION BY certificateno,creditcode ORDER BY cdc_dm_timestamp DESC,id DESC) AS rn
            FROM    stg_ra_kjj_gxjsqy_df
        ) t
WHERE   rn = 1
;