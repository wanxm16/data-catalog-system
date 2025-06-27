--省市回流_专利授权信息
INSERT OVERWRITE TABLE ods_yfcx_zlsq
SELECT  id    --'主键'
        ,name    --'专利标题'
        ,TYPE    --'专利类型'
        ,application_date    --'申请入库日'
        ,patentee    --'申请人'
        ,shxydm2 AS office_code    --'专利权人代码'
        ,address    --'申请人地址'
        ,area_name    --'专利所属区域'
        ,agency    --'代理所'
FROM    (
    SELECT  t3.*
            ,COALESCE(t4.uniscid,shxydm1) shxydm2
            ,row_number() OVER(PARTITION BY name,TYPE,COALESCE(t4.uniscid,shxydm1,patentee) ORDER BY estdate DESC,application_date DESC,id DESC) AS rn
    FROM    (
            SELECT  t2.*
                    ,CASE    WHEN shxydm1 IS NOT NULL THEN NULL 
                             ELSE patentee 
                     END entname2    --用于关联
                    ,row_number() OVER(PARTITION BY name,TYPE,patentee,office_code ORDER BY estdate DESC,application_date DESC,id DESC) AS rn2
            FROM    (
                        SELECT  t1.*
                                ,COALESCE(t2.uniscid,t1.office_code) shxydm1
                                ,COALESCE(t2.estdate,'9999-12-31') estdate
                        FROM    (
                                    SELECT  *
                                            ,CASE    WHEN office_code RLIKE '^[0-9A-HJ-NPQRTUWXY]{2}[0-9]{6}[0-9A-HJ-NPQRTUWXY]{10}$' THEN NULL 
                                                     ELSE patentee 
                                             END entname1    --用于关联
                                            ,row_number() OVER(PARTITION BY name,TYPE,patentee,office_code ORDER BY application_date DESC,id DESC) AS rn0
                                    FROM    stg_yfcx_zlsq
                                    WHERE   patentee_type = '3'
                                    OR      (patentee_type <> '1' AND office_code IS NOT NULL)
                                ) t1
                        LEFT JOIN dwd_qy_main2 t2 ON t2.entname = t1.entname1 AND t2.entname IS NOT NULL AND t2.entname NOT LIKE '%*%' AND LENGTH(t2.entname) > 3
                        WHERE   rn0 = 1
                    ) t2
        ) t3
    LEFT JOIN ods_ai_qymc_in t4 ON t4.entname = t3.entname2 AND t4.uniscid IS NOT NULL
    WHERE   t3.rn2 = 1
) t WHERE   rn = 1
;