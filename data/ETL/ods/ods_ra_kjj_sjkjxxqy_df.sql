--省市回流_省级科技型中小企业信息
INSERT OVERWRITE TABLE ods_ra_kjj_sjkjxxqy_df
SELECT  id    --'业务库表ID'
        ,enterprisename    --'企业名称'
        ,COALESCE(uniscid1,t4.uniscid) creditcode    --'统一社会信用代码'
        ,certificateno    --'证书编号'
        ,city    --'所在市'
        ,town    --'所在县'
FROM    (
            SELECT  t2.*
                    ,CASE   WHEN uniscid1 IS NOt NULL THEN NULL
                            ELSE enterprisename
                     END entname2--用于关联
                    ,ROW_NUMBER() OVER(PARTITION BY certificateno ORDER BY estdate DESC) AS rn
            FROM    (
                        SELECT  t1.*
                                ,COALESCE(t2.uniscid, creditcode1) uniscid1
                                ,COALESCE(t2.estdate, '9999-12-31') estdate
                        FROM    (
                                    SELECT  *
                                            ,CASE    WHEN creditcode RLIKE '^[0-9A-HJ-NPQRTUWXY]{2}[0-9]{6}[0-9A-HJ-NPQRTUWXY]{10}$' THEN creditcode 
                                             ELSE NULL 
                                             END creditcode1
                                            ,CASE    WHEN creditcode RLIKE '^[0-9A-HJ-NPQRTUWXY]{2}[0-9]{6}[0-9A-HJ-NPQRTUWXY]{10}$' THEN NULL 
                                             ELSE enterprisename 
                                             END entname1    --用于关联
                                            ,ROW_NUMBER() OVER(PARTITION BY certificateno ORDER BY dsc_biz_timestamp DESC,dsc_biz_record_id DESC,id DESC) AS rn1
                                    FROM    stg_ra_kjj_sjkjxxqy_df
                                    WHERE   dsc_biz_operation <> 'D'
                                ) t1
                        LEFT JOIN dwd_qy_main2 t2 ON t2.entname = t1.entname1 AND t2.entname IS NOT NULL AND t2.entname NOT LIKE '%*%' AND LENGTH(t2.entname) > 3
                    ) t2
        ) t3
LEFT JOIN ods_ai_qymc_in t4 ON t4.entname = t3.entname2 AND t4.uniscid IS NOT NULL
WHERE   rn = 1
;