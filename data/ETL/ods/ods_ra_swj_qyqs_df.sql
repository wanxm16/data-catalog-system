--省市回流_企业单位（个体工商户）欠税信息（新）--更新止于23.5.22
INSERT OVERWRITE TABLE ods_ra_swj_qyqs_df
SELECT  nsrmc    --'纳税人名称'
        ,nsrsbh    --'纳税人识别号'
        ,shxydm3 AS shxydm    --'企业社会信用代码'
        ,fddbrxm    --'法定代表人姓名'
        ,zjhm    --'法定代表人证件号码'
        ,scjydz    --'经营地点'
        ,zsxm    --'欠税税种'
        ,qss    --'欠税余额'
        ,zgswjg    --'主管税务机关'
        ,tjjzny    --'统计截止年月'
        ,tjsj    --'统计时间'
        ,djxh    --'登记序号'
FROM    (
    SELECT  t3.*
            ,COALESCE(uniscid1,t4.uniscid) shxydm3
            ,row_number() OVER(PARTITION BY COALESCE(uniscid1,t4.uniscid,nsrsbh),zsxm,tjjzny ORDER BY estdate DESC,nsrsbh) AS rn
    FROM    (
            SELECT  t2.*
                    ,CASE   WHEN uniscid1 IS NOt NULL THEN NULL
                            ELSE nsrmc
                     END entname2--用于关联
                    ,row_number() OVER(PARTITION BY nsrsbh,zsxm,tjjzny ORDER BY estdate DESC) AS rn2
            FROM    (
                        SELECT  t1.*
                                ,COALESCE(t2.uniscid, uniscid0) uniscid1
                                ,COALESCE(t2.estdate, '9999-12-31') estdate
                        FROM    (
                                    SELECT  t0.*
                                            ,CASE    WHEN uniscid0 RLIKE '^[0-9A-HJ-NPQRTUWXY]{2}[0-9]{6}[0-9A-HJ-NPQRTUWXY]{10}$' THEN NULL 
                                                     ELSE nsrmc 
                                             END entname1    --用于关联
                                    FROM    (
                                                SELECT  *
                                                        ,CASE    WHEN shxydm RLIKE '^[0-9A-HJ-NPQRTUWXY]{2}[0-9]{6}[0-9A-HJ-NPQRTUWXY]{10}$' THEN shxydm
                                                                 WHEN nsrsbh RLIKE '^[0-9A-HJ-NPQRTUWXY]{2}[0-9]{6}[0-9A-HJ-NPQRTUWXY]{10}$'
                                                                 AND nsrsbh NOT RLIKE '^[1-9][0-9]{5}(18|19|20)[0-9]{2}((0[1-9])|10|11|12)(([0-2][1-9])|10|20|30|31)[0-9]{3}[0-9|X|x]$' THEN nsrsbh
                                                                 ELSE NULL 
                                                         END uniscid0
                                                        ,row_number() OVER(PARTITION BY nsrsbh,zsxm,tjjzny ORDER BY djxh DESC,dsc_biz_timestamp DESC,dsc_biz_record_id DESC) AS rn0
                                                FROM    stg_ra_swj_qyqs_df
                                                WHERE   dsc_biz_operation <> 'D'
                                                AND     (
                                                            (
                                                                nsrsbh RLIKE '^[0-9A-HJ-NPQRTUWXY]{2}[0-9]{6}[0-9A-HJ-NPQRTUWXY]{10}$'--包括身份证
                                                                AND nsrsbh NOT RLIKE '^[1-9][0-9]{5}(18|19|20)[0-9]{2}((0[1-9])|10|11|12)(([0-2][1-9])|10|20|30|31)[0-9]{3}[0-9|X|x]$'
                                                            )
                                                            OR shxydm RLIKE '^[0-9A-HJ-NPQRTUWXY]{2}[0-9]{6}[0-9A-HJ-NPQRTUWXY]{10}$'
                                                            OR LENGTH(nsrmc) > 3--排除无信用码的个体
                                                        )
                                            ) t0
                                    WHERE   rn0 = 1
                                ) t1
                        LEFT JOIN dwd_qy_main2 t2 ON t2.entname = t1.entname1 AND t2.entname IS NOT NULL AND t2.entname NOT LIKE '%*%' AND LENGTH(t2.entname) > 3
                    ) t2
        ) t3
    LEFT JOIN ods_ai_qymc_in t4 ON t4.entname = t3.entname2 AND t4.uniscid IS NOT NULL
    WHERE   t3.rn2 = 1
) t WHERE   rn = 1
;