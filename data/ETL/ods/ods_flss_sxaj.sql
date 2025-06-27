--省市回流_生效案件信息
INSERT OVERWRITE TABLE ods_flss_sxaj
SELECT  ah    --'案号',
        ,ajzt    --'审理状态',
        ,dsr    --'所有当事人',
        ,bzxr2 AS bzxr    --'被执行人'
        ,pripid    --'主体身份代码',
        ,uniscid    --'统一社会信用代码',
        ,larq    --'立案日期',
        ,cbbm    --'承办单位'------可删除,,
        ,cbr    --'承办人'------可删除,,
        ,jarq    --'结案日期',
        ,jafs    --'结案方式',
        ,pjjg    --'判决结果',
        ,sxrq    --'生效日期',
        ,ay    --'案由',
        ,ahdm    --'案号代码'------可删除,
        ,xprq    --'宣判日期',
        ,fymc    --'法院名称',
        ,dsc_biz_record_id
        ,dsc_biz_operation
        ,dsc_biz_timestamp
FROM    (
            SELECT  *
                    ,row_number() OVER(PARTITION BY ah, COALESCE(uniscid,bzxr2) ORDER BY estdate DESC,dsc_biz_timestamp DESC,dsc_biz_record_id DESC) AS rn
            FROM    (
                        SELECT  t1.*
                                ,COALESCE(t2.entname,t4.entname) entname
                                ,COALESCE(t2.pripid,t4.pripid) pripid
                                ,COALESCE(t2.uniscid,t3.uniscid) uniscid
                                ,COALESCE(t2.estdate,t4.estdate) estdate
                        FROM    (
                                    SELECT  *
                                            ,TRIM(REGEXP_REPLACE(REGEXP_REPLACE(REGEXP_REPLACE(bzxr,'(等)(.*?)(人)',''),':',''), '(\r\n|\n\r|\n|\r)', '')) AS bzxr2
                                    FROM    (
                                                SELECT  *
                                                        ,row_number() OVER(PARTITION BY ah, bzxr ORDER BY jarq DESC,larq,dsc_biz_timestamp DESC,dsc_biz_record_id DESC) AS rn0
                                                FROM    stg_flss_sxaj2
                                                WHERE   dsc_biz_operation IN('insert','update')
                                            ) t0
                                    WHERE   rn0 = 1
                                ) t1
                        LEFT JOIN dwd_qy_main2 t2 ON t2.entname = t1.bzxr2 AND t2.entname IS NOT NULL AND t2.entname NOT LIKE '%*%' AND LENGTH(t2.entname)>3
                        LEFT JOIN ods_ai_qymc_in t3 ON t3.entname = t1.bzxr2 AND t3.uniscid IS NOT NULL
                        LEFT JOIN dwd_qy_main2 t4 ON t4.uniscid = t3.uniscid
                    ) t2
            WHERE LENGTH(bzxr2)>3 AND bzxr2 NOT LIKE '%又名%'
        ) t3
WHERE   rn = 1
;