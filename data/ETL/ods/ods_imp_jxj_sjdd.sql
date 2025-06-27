--经信局数据得地_导入
INSERT OVERWRITE TABLE ods_imp_jxj_sjdd
SELECT  uniscid3 AS uniscid    --'统一信用代码' 
        ,land_name --'地块名称'
        ,sell_area --'出让面积（亩）'
        ,project_name --'项目名称'
        ,ent_name --'业主单位'
        ,CASE WHEN listing_date IS NULL THEN NULL
              WHEN LENGTH(listing_date)=9 THEN REGEXP_REPLACE(REGEXP_REPLACE(listing_date,'[年月]','-0'),'日','')
              WHEN LENGTH(listing_date)=10 AND SUBSTR(listing_date,7,1)='月' THEN REGEXP_REPLACE(REGEXP_REPLACE(REGEXP_REPLACE(listing_date,'年','-0'),'月','-'),'日','')
              WHEN LENGTH(listing_date)=10 THEN REGEXP_REPLACE(REGEXP_REPLACE(REGEXP_REPLACE(listing_date,'年','-'),'月','-0'),'日','')
              ELSE REGEXP_REPLACE(REGEXP_REPLACE(listing_date,'[年月]','-'),'日','')
         END listing_date --'挂牌公告时间'
        ,CASE WHEN delet_date IS NULL THEN NULL
              WHEN LENGTH(delet_date)=9 THEN REGEXP_REPLACE(REGEXP_REPLACE(delet_date,'[年月]','-0'),'日','')
              WHEN LENGTH(delet_date)=10 AND SUBSTR(delet_date,7,1)='月' THEN REGEXP_REPLACE(REGEXP_REPLACE(REGEXP_REPLACE(delet_date,'年','-0'),'月','-'),'日','')
              WHEN LENGTH(delet_date)=10 THEN REGEXP_REPLACE(REGEXP_REPLACE(REGEXP_REPLACE(delet_date,'年','-'),'月','-0'),'日','')
              ELSE REGEXP_REPLACE(REGEXP_REPLACE(delet_date,'[年月]','-'),'日','')
         END delet_date --'摘牌时间'
        ,CASE WHEN town='上望' THEN '上望街道'
              WHEN town='云周' THEN '云周街道'
              WHEN town='仙降' THEN '仙降街道' 
              WHEN town='南滨' THEN '南滨街道' 
              WHEN town='汀田' THEN '汀田街道' 
              WHEN town='潘岱' THEN '潘岱街道' 
              WHEN town='莘塍' THEN '莘塍街道' 
              WHEN town='飞云' THEN '飞云街道' 
              WHEN town='塘下' THEN '塘下镇' 
              WHEN town='马屿' THEN '马屿镇' 
         END town --'所属镇街'
        ,domain --'所属功能区'
        ,update_time
FROM (
    SELECT  t3.*
            ,COALESCE(uniscid1,t4.uniscid) uniscid3
            ,ROW_NUMBER() OVER(PARTITION BY COALESCE(t3.uniscid,t4.uniscid,ent_name),land_name,project_name,listing_date,update_time ORDER BY estdate DESC,ent_name) AS rn
    FROM    (
                SELECT  t2.*
                        ,CASE   WHEN uniscid1 IS NOT NULL THEN NULL 
                                ELSE ent_name 
                        END entname2    --用于关联
                        ,ROW_NUMBER() OVER(PARTITION BY COALESCE(uniscid1,ent_name),land_name,project_name,listing_date,update_time ORDER BY estdate DESC,ent_name) AS rn2
                FROM    (
                            SELECT  t1.*
                                    ,t2.estdate
                                    ,COALESCE(t1.uniscid,t2.uniscid) uniscid1
                            FROM (
                                SELECT  *
                                        ,CASE WHEN uniscid IS NOT NULL THEN NULL ELSE ent_name END entname1 --用于关联
                                FROM    stg_imp_jxj_sjdd
                            ) t1
                            LEFT JOIN dwd_qy_main2 t2 ON t2.entname = t1.entname1 AND t2.entname IS NOT NULL AND t2.entname NOT LIKE '%*%' AND LENGTH(t2.entname) > 3
                            WHERE   LENGTH(t1.ent_name) > 3
                        ) t2
            ) t3
    LEFT JOIN ods_ai_qymc_in t4 ON t4.entname = t3.entname2 AND t4.uniscid IS NOT NULL
    WHERE   t3.rn2 = 1
) t4
WHERE   t4.rn = 1
;