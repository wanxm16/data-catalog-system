--经信局是否达产重点项目_导入
--1、拆分企业，补齐信用码
INSERT OVERWRITE TABLE ods_imp_jxj_sfdczdxm_uniscid
SELECT  target_type    --'是否达产类型'
        ,CASE   WHEN LENGTH(delet_date)=9 THEN CONCAT('20',REGEXP_REPLACE(REGEXP_REPLACE(delet_date,'[年月]','-'),'日',''))
                ELSE REGEXP_REPLACE(REGEXP_REPLACE(delet_date,'[年月]','-'),'日','')
         END delet_date    --'摘牌时间'
        ,ent_name    --'企业名称'
        ,entname1 AS qymc  --用于补齐的单个企业名称
        ,COALESCE(t3.uniscid1,t4.uniscid) uniscid --'统一信用代码'
        ,land_name    --'地块名称'
        ,sell_area    --'出让面积（亩）'
        ,month_no    --'完成整治月份'
        ,complete_policy
        ,org_check
        ,pass_check
        ,town    --'属地'
        ,remark    --'备注'
        ,target_time --'预期达产时间'
        ,update_time --'数据更新时间'
FROM    (
                    SELECT  t2.*
                            ,CASE    WHEN uniscid1 IS NOT NULL THEN NULL
                                    ELSE entname1 
                            END entname2    --用于关联
                            ,ROW_NUMBER() OVER(PARTITION BY rownum ORDER BY estdate DESC) AS rn
                    FROM    (
                                SELECT  t1.*
                                        ,t2.uniscid AS uniscid1
                                        ,COALESCE(t2.estdate, '9999-12-31') estdate
                                FROM    (
                                            SELECT  *
                                                    ,ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) as rownum --用于唯一标识
                                                    ,CASE   WHEN qymc LIKE '%等%' THEN SUBSTR(qymc, 1, INSTR(qymc, '等') - 1)
                                                            WHEN qymc LIKE '%(%' AND qymc NOT LIKE '%(普通合伙%' THEN SUBSTR(qymc, 1, INSTR(qymc, '(') - 1)
                                                            WHEN qymc LIKE '%（%' AND qymc NOT LIKE '%（普通合伙%' THEN SUBSTR(qymc, 1, INSTR(qymc, '（') - 1)
                                                            ELSE qymc 
                                                    END entname1
                                            FROM    (
                                                        SELECT * FROM stg_imp_jxj_sfdczdxm
                                                        LATERAL VIEW EXPLODE(SPLIT(ent_name, '、')) t AS qymc
                                                    ) t0
                                        ) t1
                                LEFT JOIN dwd_qy_main2 t2 ON t2.entname = t1.entname1 AND t2.entname IS NOT NULL AND t2.entname NOT LIKE '%*%' AND LENGTH(t2.entname) > 3
                            ) t2
        ) t3
LEFT JOIN ods_ai_qymc_in t4 ON t4.entname = t3.entname2 AND t4.uniscid IS NOT NULL
WHERE   rn = 1
;
--2、合并信用码，处理空、等
INSERT OVERWRITE TABLE ods_imp_jxj_sfdczdxm
SELECT  target_type    --'是否达产类型'
        ,delet_date    --'摘牌时间'
        ,ent_name    --'企业名称'
        ,CASE   WHEN uniscid='' THEN NULL
                WHEN ent_name LIKE '%等%' THEN CONCAT(uniscid,'等') 
                WHEN ent_name LIKE '%、%' 
                    AND (LENGTH(ent_name) - LENGTH(REPLACE(ent_name, '、', ''))) > (LENGTH(uniscid) - LENGTH(REPLACE(uniscid, ',', '')))
                    THEN CONCAT(uniscid,'等') 
                ELSE uniscid
         END uniscid    --'统一信用代码'
        ,land_name    --'地块名称'
        ,sell_area    --'出让面积（亩）'
        ,month_no    --'完成整治月份'
        ,complete_policy
        ,org_check
        ,pass_check
        ,town    --'属地'
        ,remark    --'备注'
        ,target_time --'预期达产时间'
        ,update_time --'数据更新时间'
FROM    (
            SELECT  target_type    --'是否达产'
                    ,delet_date    --'摘牌时间'
                    ,ent_name    --'企业名称'
                    ,ArrTrimStr(
                        CONCAT_WS(',', COLLECT_SET(COALESCE(uniscid,'')))
                    ) uniscid    --'统一信用代码'
                    ,land_name    --'地块名称'
                    ,sell_area    --'出让面积（亩）'
                    ,month_no    --'完成整治月份'
                    ,complete_policy
                    ,org_check
                    ,pass_check
                    ,town    --'属地'
                    ,remark    --'备注'
                    ,target_time --'预期达产时间'
                    ,update_time --'数据更新时间'
            FROM    ods_imp_jxj_sfdczdxm_uniscid
            GROUP BY target_type,delet_date,ent_name,land_name,sell_area,month_no,complete_policy,org_check,pass_check,town,remark,target_time,update_time
        ) t
;