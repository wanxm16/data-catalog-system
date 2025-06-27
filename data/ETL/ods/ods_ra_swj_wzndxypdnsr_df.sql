--市回流_温州市税务局-年度信用等级评定A级纳税人信息
INSERT OVERWRITE TABLE ods_ra_swj_wzndxypdnsr_df
SELECT  nsrmc    --'纳税人名称'
        ,uniscid2 AS nsrsbh    --'纳税人识别号'
        ,ssnd    --'所属年度'
        ,xydj    --'信用等级'
        ,zgswjg    --'主管税务机关'
FROM    (
    SELECT  t3.*
            ,COALESCE(uniscid1,t4.uniscid) uniscid2
            ,ROW_NUMBER() OVER(PARTITION BY COALESCE(uniscid1,t4.uniscid,nsrmc),ssnd ORDER BY estdate DESC,nsrsbh) AS rn
    FROM    (
            SELECT  t2.*
                    ,CASE   WHEN uniscid1 IS NOt NULL THEN NULL
                            ELSE nsrmc
                     END entname2--用于关联
                    ,ROW_NUMBER() OVER(PARTITION BY nsrmc,nsrsbh,ssnd ORDER BY estdate DESC) AS rn2
            FROM    (
                        SELECT  t1.*
                                ,COALESCE(t2.uniscid, uniscid0) uniscid1
                                ,COALESCE(t2.estdate, '9999-12-31') estdate
                        FROM    (
                                    SELECT  *
                                            ,CASE    WHEN nsrsbh RLIKE '^[0-9A-HJ-NPQRTUWXY]{2}[0-9]{6}[0-9A-HJ-NPQRTUWXY]{10}$' THEN nsrsbh 
                                                     ELSE NULL 
                                             END uniscid0
                                            ,CASE    WHEN nsrsbh RLIKE '^[0-9A-HJ-NPQRTUWXY]{2}[0-9]{6}[0-9A-HJ-NPQRTUWXY]{10}$' THEN NULL 
                                                     ELSE nsrmc 
                                             END entname1    --用于关联
                                    FROM    stg_ra_swj_wzndxypdnsr_df
                                ) t1
                        LEFT JOIN dwd_qy_main2 t2 ON t2.entname = t1.entname1 AND t2.entname IS NOT NULL AND t2.entname NOT LIKE '%*%' AND LENGTH(t2.entname) > 3
                    ) t2
        ) t3
    LEFT JOIN ods_ai_qymc_in t4 ON t4.entname = t3.entname2 AND t4.uniscid IS NOT NULL
    WHERE   t3.rn2 = 1
) t WHERE   rn = 1
;