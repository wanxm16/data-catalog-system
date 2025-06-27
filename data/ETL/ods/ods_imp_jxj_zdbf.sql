--经信局重点帮扶企业_导入
INSERT OVERWRITE  TABLE ods_imp_jxj_zdbf 
SELECT  
    uniscid --'统一信用代码' 
    ,above_type --'规模'
    ,ent_name --'企业名称'
    ,town --'所属镇街'
    ,remark --'备注'
    ,year_no --'统计年度'
FROM (
    SELECT  t3.*
            ,COALESCE(uniscid1,t4.uniscid) uniscid
            ,ROW_NUMBER() OVER(PARTITION BY COALESCE(uniscid1,t4.uniscid,ent_name),year_no ORDER BY estdate DESC,ent_name) AS rn
    FROM    (
                SELECT  t2.*
                        ,CASE    WHEN uniscid1 IS NOT NULL THEN NULL 
                                ELSE ent_name 
                        END entname2    --用于关联
                        ,ROW_NUMBER() OVER(PARTITION BY ent_name,year_no ORDER BY estdate DESC) AS rn2
                FROM    (
                            SELECT  t1.*
                                    ,t2.uniscid AS uniscid1
                                    ,t2.estdate
                            FROM    stg_imp_jxj_zdbf t1
                            LEFT JOIN dwd_qy_main2 t2 ON t2.entname = t1.ent_name AND t2.entname IS NOT NULL AND t2.entname NOT LIKE '%*%' AND LENGTH(t2.entname) > 3
                            WHERE   LENGTH(t1.ent_name) > 3
                        ) t2
            ) t3
    LEFT JOIN ods_ai_qymc_in t4 ON t4.entname = t3.entname2 AND t4.uniscid IS NOT NULL
    WHERE   t3.rn2 = 1
) t4
WHERE   t4.rn = 1
;