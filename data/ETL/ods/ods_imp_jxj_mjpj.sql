--经信局亩均评价_导入
INSERT OVERWRITE TABLE ods_imp_jxj_mjpj
SELECT  uniscid    --'统一信用代码' 
        ,above_type    --'亩均规模'
        ,ent_name    --'企业名称'
        ,eval_result    --'评价结果'
        ,eval_year    --'评价年度'
FROM (
    SELECT  t3.*
            ,COALESCE(uniscid1,t4.uniscid,ent_code) uniscid
            ,ROW_NUMBER() OVER(PARTITION BY COALESCE(uniscid1,t4.uniscid,ent_code),eval_year,above_type ORDER BY estdate DESC,ent_name) AS rn
    FROM    (
                SELECT  t2.*
                        ,CASE   WHEN uniscid1 IS NOT NULL THEN NULL 
                                ELSE ent_name 
                        END entname2    --用于关联
                        ,ROW_NUMBER() OVER(PARTITION BY COALESCE(uniscid1,ent_code),eval_year,above_type ORDER BY estdate DESC) AS rn2
                FROM    (
                            SELECT  t1.*
                                    ,COALESCE(t2.uniscid,t1.ent_code1) uniscid1
                                    ,t2.estdate
                            FROM    (
                                SELECT *
                                    ,CASE WHEN ent_code NOT RLIKE '^[0-9A-HJ-NPQRTUWXY]{2}[0-9]{6}[0-9A-HJ-NPQRTUWXY]{10}$' THEN NULL
                                          WHEN ent_code LIKE '330%' THEN NULL
                                          ELSE ent_code 
                                     END ent_code1
                                    ,CASE WHEN ent_code NOT RLIKE '^[0-9A-HJ-NPQRTUWXY]{2}[0-9]{6}[0-9A-HJ-NPQRTUWXY]{10}$' THEN ent_name
                                          WHEN ent_code LIKE '330%' THEN ent_name
                                          ELSE NULL 
                                     END entname1 --用于关联
                                FROM stg_imp_jxj_mjpj
                            ) t1
                            LEFT JOIN dwd_qy_main2 t2 ON t2.entname = t1.entname1 AND t2.entname IS NOT NULL AND t2.entname NOT LIKE '%*%' AND LENGTH(t2.entname) > 3
                            --WHERE   LENGTH(t1.ent_name) > 3
                        ) t2
            ) t3
    LEFT JOIN ods_ai_qymc_in t4 ON t4.entname = t3.entname2 AND t4.uniscid IS NOT NULL
    WHERE   t3.rn2 = 1
) t4
WHERE   t4.rn = 1
;