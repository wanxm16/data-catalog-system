--经信局荣誉企业_导入
INSERT OVERWRITE  TABLE ods_imp_jxj_ryqy 
SELECT  
    uniscid --'统一信用代码' 
    ,honor_name --'荣誉名称'
    ,ent_name --'企业名称'
    ,year_no --'公示年度'
    ,CASE   WHEN honor_name='国家级“专精特新”小巨人（含重点）' AND ent_name LIKE '%（重点）' THEN '是' 
            WHEN honor_name='国家级“专精特新”小巨人（含重点）' AND ent_name NOT LIKE '%（重点）' THEN '否' 
            ELSE NULL
     END key_ent
FROM (
    SELECT  t3.*
            ,COALESCE(uniscid1,t4.uniscid) uniscid
            ,ROW_NUMBER() OVER(PARTITION BY COALESCE(uniscid1,t4.uniscid,ent_name),honor_name,year_no ORDER BY estdate DESC,ent_name) AS rn
    FROM    (
                SELECT  t2.*
                        ,CASE    WHEN uniscid1 IS NOT NULL THEN NULL 
                                ELSE ent_name 
                        END entname2    --用于关联
                        ,ROW_NUMBER() OVER(PARTITION BY ent_name,honor_name,year_no ORDER BY estdate DESC) AS rn2
                FROM    (
                            SELECT  t1.*
                                    ,t2.uniscid AS uniscid1
                                    ,t2.estdate
                            FROM    stg_imp_jxj_ryqy t1
                            LEFT JOIN dwd_qy_main2 t2 ON t2.entname = t1.ent_name AND t2.entname IS NOT NULL AND t2.entname NOT LIKE '%*%' AND LENGTH(t2.entname) > 3
                            WHERE   LENGTH(t1.ent_name) > 3
                        ) t2
            ) t3
    LEFT JOIN ods_ai_qymc_in t4 ON t4.entname = t3.entname2 AND t4.uniscid IS NOT NULL
    WHERE   t3.rn2 = 1
) t4
WHERE   t4.rn = 1
;