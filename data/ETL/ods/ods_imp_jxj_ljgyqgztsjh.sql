--经信局老旧工业区改造提升计划_导入
INSERT OVERWRITE TABLE ods_imp_jxj_ljgyqgztsjh
SELECT  project_type    --'项目类型'
        ,land_name    --'区块名称'
        ,ent_name    --'企业名称'
        ,CASE    WHEN uniscid IS NOT NULL THEN uniscid
                 WHEN ent_name='瑞安市台鑫汽车部件有限公司' THEN '91330381145631815C'
                 WHEN ent_name='瑞安市邦云五金厂' THEN '91330381MA29795C1P' 
                 ELSE NULL 
         END uniscid    --'统一信用代码'
        ,town    --'所属街道'
        ,prime_industry    --'主导产业'
        ,area    --'面积（亩）'
        ,current_plan    --'现状规划功能'
        ,current_type    --'现状土地类型'
        ,reform_mode    --'改造方式'
        ,reform_industry    --'改造后主导产业'
        ,finish_area    --'已完成拆除面积（亩）'
        ,plan_area    --'年计划拆除面积（亩）'
        ,CASE   WHEN LENGTH(plan_date)<6 THEN NULL
                WHEN LENGTH(plan_date)=6 THEN CONCAT(SUBSTR(plan_date,1,4),'-0',SUBSTR(plan_date,6))
                ELSE REPLACE(plan_date,'.','-')
         END plan_date    --'计划拆除时间（具体到月份）'
        ,land_finish --'年已完成拆后供地面积（亩）'
        ,land_area    --'年计划拆后供地面积（亩）'
        ,CASE   WHEN LENGTH(land_time)<6 THEN NULL
                WHEN LENGTH(land_time)=6 THEN CONCAT(SUBSTR(land_time,1,4),'-0',SUBSTR(land_time,6))
                ELSE REPLACE(land_time,'.','-')
         END land_time    --'计划拆后供地时间（具体到月份）'
        ,start_area    --'年计划拆后新开工面积（万㎡）'
        ,start_finish --'年已完成拆后新开工面积（万㎡）'
        ,CASE   WHEN LENGTH(start_date)<6 THEN NULL
                WHEN LENGTH(start_date)=6 THEN CONCAT(SUBSTR(start_date,1,4),'-0',SUBSTR(start_date,6))
                ELSE REPLACE(start_date,'.','-')
         END start_date    --'计划开工时间（具体到月份）'
        ,remark    --'备注'
        ,update_time
FROM    (
            SELECT  t2.*
                    ,ROW_NUMBER() OVER(PARTITION BY rownum ORDER BY estdate DESC) AS rn
            FROM    (
                        SELECT  t1.*
                                ,t2.uniscid
                                ,COALESCE(t2.estdate, '9999-12-31') estdate
                        FROM    (
                                    SELECT  *
                                            ,ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) as rownum --用于唯一标识
                                            ,CASE    WHEN land_name LIKE '%公司%' THEN SUBSTR(land_name, 1, INSTR(land_name, '公司') + 1)
                                                     WHEN land_name LIKE '%厂%' THEN SUBSTR(land_name, 1, INSTR(land_name, '厂'))
                                                     ELSE NULL 
                                             END ent_name
                                    FROM    stg_imp_jxj_ljgyqgztsjh
                                ) t1
                        LEFT JOIN dwd_qy_main2 t2 ON t2.entname = t1.ent_name AND t2.entname IS NOT NULL AND t2.entname NOT LIKE '%*%' AND LENGTH(t2.entname) > 3
                    ) t2
        ) t3
WHERE   rn = 1
;