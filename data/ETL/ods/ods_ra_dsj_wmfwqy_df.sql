--市回流_外贸服务企业名单信息（含历史）
INSERT OVERWRITE TABLE ods_ra_dsj_wmfwqy_df
SELECT  name    --'企业名称'
        ,uniscid2 AS uniscid    
        ,industryco    --'归属行业'
        ,industryco_code    --'行业代码'
        ,districtname    --'行政区划中文'
FROM    (
    SELECT  t3.*
            ,COALESCE(t3.uniscid,t4.uniscid) uniscid2
            ,ROW_NUMBER() OVER(PARTITION BY COALESCE(t3.uniscid,t4.uniscid,name) ORDER BY estdate DESC) AS rn
    FROM    (
            SELECT  t2.*
                    ,CASE   WHEN uniscid IS NOt NULL THEN NULL
                            ELSE name
                     END entname2--用于关联
                    ,ROW_NUMBER() OVER(PARTITION BY name ORDER BY estdate DESC) AS rn2
            FROM    (
                        SELECT  t1.*
                                ,t2.uniscid
                                ,t2.estdate
                        FROM    (
                                    SELECT  *
                                    FROM    stg_ra_dsj_wmfwqy_df
                                    WHERE   regstate='开业'
                                ) t1
                        LEFT JOIN dwd_qy_main2 t2 ON t2.entname = t1.name AND t2.entname IS NOT NULL AND t2.entname NOT LIKE '%*%' AND LENGTH(t2.entname)>3
                    ) t2
        ) t3
    LEFT JOIN ods_ai_qymc_in t4 ON t4.entname = t3.entname2 AND t4.uniscid IS NOT NULL
    WHERE   t3.rn2 = 1
) t WHERE   t.rn = 1
;