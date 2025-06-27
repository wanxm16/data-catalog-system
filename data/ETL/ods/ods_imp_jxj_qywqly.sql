--经信局企业外迁留优_导入
INSERT OVERWRITE TABLE ods_imp_jxj_qywqly
SELECT  check_date    --'排摸时间'
        ,out_status    --'外迁状态'
        ,ent_name    --'企业名称'
        ,COALESCE(uniscid2,t4.uniscid) uniscid    --'统一信用代码'
        ,out_value    --'上年产值（万元）'
        ,industry    --'从事行业'
        ,from_area    --'迁出区域'
        ,to_area    --'迁入区域'
        ,other_place_purchase    --'是否外地购买'
        ,reason    --'搬迁原因及原厂房处理'
        ,advantage    --'拟迁入地优势'
        ,active_bit    --'是否主动对接'
        ,out_date    --'（拟）搬迁时间'
        ,link_person    --'联系人'
        ,link_mobile    --'联系方式'
        ,advise    --'留企稳企建议'
        ,judge_result    --'会商研判结果'
        ,update_time    --'数据更新时间'
FROM    (
            SELECT  t2.*
                    ,CASE    WHEN uniscid2 IS NULL THEN ent_name 
                             ELSE NULL 
                     END ent_name2    --用于关联
                    ,ROW_NUMBER() OVER(PARTITION BY uniscid2,ent_name,check_date ORDER BY estdate DESC,update_time DESC) AS rn
            FROM    (
                        SELECT  t1.*
                                ,COALESCE(uniscid1,t2.uniscid) uniscid2
                                ,t2.estdate
                        FROM    (
                                    SELECT  *
                                            ,CASE    WHEN uniscid RLIKE '^[0-9A-HJ-NPQRTUWXY]{2}[0-9]{6}[0-9A-HJ-NPQRTUWXY]{10}$' THEN uniscid 
                                                     ELSE NULL 
                                             END uniscid1
                                            ,CASE    WHEN uniscid RLIKE '^[0-9A-HJ-NPQRTUWXY]{2}[0-9]{6}[0-9A-HJ-NPQRTUWXY]{10}$' THEN NULL 
                                                     ELSE ent_name 
                                             END ent_name1    --用于关联
                                    FROM    stg_imp_jxj_qywqly
                                ) t1
                        LEFT JOIN dwd_qy_main2 t2 ON t2.entname = t1.ent_name1 AND t2.entname IS NOT NULL AND t2.entname NOT LIKE '%*%' AND LENGTH(t2.entname) > 3
                    ) t2
        ) t3
LEFT JOIN ods_ai_qymc_in t4 ON t4.entname = t3.ent_name2 AND t4.uniscid IS NOT NULL
WHERE   t3.rn = 1
;