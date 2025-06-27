--省市回流_危险化学品使用企业信息
INSERT OVERWRITE TABLE ods_ra_yjj_whpsyqy_df
SELECT  enterprisename     --'企业名称'
        ,uniscid2 AS socialcredit    --'统一社会信用代码'
        ,organizationcode0 AS organizationcode    --'组织机构代码'
        ,regaddress    --'具体地址（工商注册）'
        ,legalrepresentative    --'法定代表人'
        ,headname    --'主要负责人姓名'
        ,headtel    --'主要负责人电话'
        ,enterprisetype    --'单位类型'
        ,longitude    --'经度'
        ,latitude    --'纬度'
FROM    (
        SELECT  t3.*
                ,COALESCE(uniscid1,t4.uniscid) uniscid2
                ,ROW_NUMBER() OVER(PARTITION BY COALESCE(uniscid1,t4.uniscid,enterprisename) ORDER BY estdate DESC) AS rn
        FROM    (
            SELECT  t2.*
                    ,CASE   WHEN uniscid1 IS NOt NULL THEN NULL
                            ELSE enterprisename
                     END entname2--用于关联
                    ,ROW_NUMBER() OVER(PARTITION BY enterprisename,uniscid ORDER BY estdate DESC) AS rn2
            FROM    (
                        SELECT  t1.*
                                ,COALESCE(t2.uniscid, uniscid0) uniscid1
                                ,COALESCE(t2.estdate, '9999-12-31') estdate
                        FROM    (
                                    SELECT  t0.*
                                            ,CASE    WHEN uniscid RLIKE '^[0-9A-HJ-NPQRTUWXY]{2}[0-9]{6}[0-9A-HJ-NPQRTUWXY]{10}$' THEN uniscid 
                                                     ELSE NULL 
                                             END uniscid0
                                            ,CASE    WHEN uniscid RLIKE '^[0-9A-HJ-NPQRTUWXY]{2}[0-9]{6}[0-9A-HJ-NPQRTUWXY]{10}$' THEN NULL 
                                                     ELSE enterprisename 
                                             END entname1    --用于关联
                                    FROM    (
                                                SELECT  *
                                                        ,CASE    WHEN socialcredit='330381470863310R' THEN '12330381470863310R'--瑞安市高楼镇高楼学校
                                                                 WHEN socialcredit='12330381470862334' THEN '123303814708623341'--瑞安市湖岭镇中学
                                                                 WHEN socialcredit='12330381MB0T25597AA' THEN '12330381MB0T25597A'--瑞安市林川镇卫生院
                                                                 WHEN socialcredit LIKE '%O%' THEN REGEXP_REPLACE(socialcredit,'O','0')
                                                                 ELSE FULLTOHALF(socialcredit) 
                                                         END uniscid
                                                        ,CASE    WHEN organizationcode='330381470863310R' THEN '12330381470863310R'--瑞安市高楼镇高楼学校
                                                                 WHEN organizationcode='12330381470862334' THEN '123303814708623341'--瑞安市湖岭镇中学
                                                                 WHEN organizationcode='12330381MB0T25597AA' THEN '12330381MB0T25597A'--瑞安市林川镇卫生院
                                                                 WHEN organizationcode='12330381MBOWO5791Q' THEN '12330381MB0W05791Q'--南滨街道社区卫生服务中心阁巷分中心（南滨街道卫生院）
                                                                 ELSE FULLTOHALF(organizationcode) 
                                                         END organizationcode0
                                                FROM    stg_ra_yjj_whpsyqy_df
                                                WHERE   dsc_biz_operation IN ('insert','update')
                                            ) t0
                                ) t1
                        LEFT JOIN dwd_qy_main2 t2 ON t2.entname = t1.entname1 AND t2.entname IS NOT NULL AND t2.entname NOT LIKE '%*%' AND LENGTH(t2.entname) > 3
                    ) t2
        ) t3
    LEFT JOIN ods_ai_qymc_in t4 ON t4.entname = t3.entname2 AND t4.uniscid IS NOT NULL
    WHERE   t3.rn2 = 1
) t WHERE   rn = 1
;