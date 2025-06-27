--经信局高耗低效帮扶_导入
INSERT OVERWRITE TABLE ods_imp_jxj_ghdxbf
SELECT  
    rect_measure --'整治措施'
    ,region --'区域'
    ,ent_name --'企业名称'
    ,uniscid2 AS uniscid --'统一信用代码'
    ,rect_mode --'整治方式'
    ,rect_reason --'整治提升理由'
    ,expect_freeup_land --'预计腾出用地（亩）'
    ,expect_freeup_energy --'预计腾出能耗（吨标准煤）'
    ,ent_scale --'企业规模'
    ,town --'所属镇街'
    ,update_time --'数据更新时间'
FROM    (
            SELECT  t2.*
                    ,ROW_NUMBER() OVER(PARTITION BY uniscid2,ent_name ORDER BY estdate DESC) AS rn
            FROM    (
                        SELECT  t1.*
                                ,COALESCE(t2.uniscid, uniscid1) uniscid2
                                ,COALESCE(t2.estdate, '9999-12-31') estdate
                        FROM    (
                                    SELECT  *
                                            ,CASE    WHEN uniscid='9133038114561841G' THEN '91330381145618741G'
                                                     WHEN uniscid='9133038114562397T' THEN '91330381145626397T'
                                                     ELSE uniscid 
                                             END uniscid1
                                            ,CASE    WHEN uniscid IS NULL THEN ent_name
                                                     ELSE NULL 
                                             END entname1
                                    FROM    stg_imp_jxj_ghdxbf
                                ) t1
                        LEFT JOIN dwd_qy_main2 t2 ON t2.entname = t1.entname1 AND t2.entname IS NOT NULL AND t2.entname NOT LIKE '%*%' AND LENGTH(t2.entname) > 3
                    ) t2
        ) t3
WHERE   rn = 1
;