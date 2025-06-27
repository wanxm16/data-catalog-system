--省市回流_企业破产清算信息;
INSERT OVERWRITE TABLE ods_ra_fay_qypcqs_df
SELECT  ahdm    --'案号代码'
        ,xh    --'序号'
        ,qymc    --'企业名称'
        ,shxydm3 AS tyshxydm  --'统一社会信用代码'--有空有非信用码
		,fddbr2 AS frdb    --'法人代表姓名'
        ,sfzhm2 AS fddbrsfzh    --'法定代表人身份证号'
        ,lxdh2 AS lxdh    --'联系电话'
        ,dz    --'地址'
        ,zmzcjz    --'账面资产价值'
        ,kgfpdcce    --'可供分配的财产额'
        ,sjpcqyrs    --'涉及破产企业人数'
        ,tqzjpccxrq    --'提请终结破产程序日期'
        ,sdglrrq    --'送达管理人日期'
        ,pcccpmrq    --'破产财产拍卖日期'
        ,xgpcrq    --'宣告破产日期'
        ,pcqyzxdjrq    --'破产企业注销登记日期'
        ,ydbdccjz    --'有担保的财产价值'
        ,qyhzw    --'欠银行债务'
        ,cdjzpccxrq    --'裁定终结破产程序日期'
        ,tjbgrq    --'提交报告日期'
        ,sdzqrrq    --'送达债权人日期'
        ,qcze    --'清偿总额'
        ,ccfpfa    --'财产分配方案'
        ,qzgzw    --'欠职工债务'
        ,pczcjz    --'破产资产价值'
        ,pcggrq    --'破产公告日期'
        ,pczwze    --'破产债务总额'
FROM    (
    SELECT  t3.*
            ,COALESCE(shxydm2,t4.uniscid) shxydm3
            ,ROW_NUMBER() OVER(PARTITION BY ahdm,COALESCE(shxydm2,t4.uniscid,qymc) ORDER BY estdate DESC,dsc_biz_timestamp DESC,dsc_biz_record_id DESC) AS rn
    FROM    (
            SELECT  t2.*
                    ,CASE   WHEN shxydm2 IS NOt NULL THEN NULL
                            ELSE qymc
                     END entname2--用于关联
                    ,ROW_NUMBER() OVER(PARTITION BY ahdm,qymc ORDER BY estdate DESC,dsc_biz_timestamp DESC,dsc_biz_record_id DESC) AS rn2
            FROM    (
                        SELECT  t1.*
                                ,COALESCE(t1.shxydm1,t2.uniscid) shxydm2
                                ,COALESCE(t1.frdb,t2.lerep_name) fddbr2
                                ,COALESCE(t1.fddbrsfzh,t2.cerno) sfzhm2
                                ,COALESCE(t1.lxdh,t2.tel) lxdh2
                                ,COALESCE(t2.estdate,'9999-12-31') estdate
                        FROM    (
                                    SELECT  *
                                            ,CASE    WHEN tyshxydm RLIKE '^[0-9A-HJ-NPQRTUWXY]{2}[0-9]{6}[0-9A-HJ-NPQRTUWXY]{10}$' THEN tyshxydm
                                                     ELSE NULL 
                                             END shxydm1
                                            ,CASE    WHEN tyshxydm RLIKE '^[0-9A-HJ-NPQRTUWXY]{2}[0-9]{6}[0-9A-HJ-NPQRTUWXY]{10}$' THEN NULL
                                                     ELSE qymc 
                                             END entname1--用于关联
                                    FROM    stg_ra_fay_qypcqs_df
                                    WHERE   sfzh IS NULL AND LENGTH(qymc) > 3--排除个人
                                    AND     dsc_biz_operation IN ('insert','update')
                                ) t1
                        LEFT JOIN dwd_qy_main2 t2 ON t2.entname = t1.entname1 AND t2.entname IS NOT NULL AND t2.entname NOT LIKE '%*%' AND LENGTH(t2.entname)>3
                    ) t2
        ) t3
    LEFT JOIN ods_ai_qymc_in t4 ON t4.entname = t3.entname2 AND t4.uniscid IS NOT NULL
    WHERE   t3.rn2 = 1
) t WHERE   rn = 1
;