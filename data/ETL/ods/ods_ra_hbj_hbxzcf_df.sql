--省市回流_行政处罚信息----环保--更新止于24.5.13
INSERT OVERWRITE TABLE ods_ra_hbj_hbxzcf_df
SELECT  id    --'主键'
        ,nd    --'年度'
        ,tbsj    --'填报时间'
        ,cfzt    --'处罚主体'
        ,cfzjssjb    --'处罚主体所属级别'
        ,dcjg    --'调查机构'
        ,lah    --'立案号'
        ,jdwsh    --'决定书文号'
        ,lxr    --'经办联系人'
        ,lxdh1 AS lxdh    --'联系电话'--------------------.0
        ,dsrxx    --'当事人信息'--事业单位、企业、其他
        ,dsrmc1 AS dsrmc    --'当事人名称'
        ,yyzzzch3 AS yyzzzch    --'营业执照注册号'
        ,zzjgdm    --'组织机构代码'
        ,COALESCE(tyshxydm3,t5.uniscid) tyshxydm    --'统一社会信用代码'
        ,fddbr3 AS fddbr    --'法定代表人'
        ,sfzhm3 AS sfzhm    --'身份证号码'-----------------法定代表人身份证
        ,sj3 AS sj    --'手机'------------------------.0
        ,bgdh1 AS bgdh    --'办公电话'------------------.0
        ,dz    --'地址'
        ,sfwssgs    --'是否为上市公司'
        ,gpdm    --'股票代码'
        ,sfssjtgs    --'是否所属集团公司'
        ,ssjtgsmc    --'所属集团公司名称'
        ,ssjtgszzjgdm    --'所属集团公司组织机构'
        ,ssjtgsgpdm    --'所属集团公司股票代码'
        ,larq    --'立案日期'
        ,zywfxw    --'主要违法行为'
        ,cfyj    --'处罚依据'
        ,cfzl    --'处罚种类'
        ,fkse    --'罚款数额(万元)'
        ,mswfssdnr    --'没收违法所得的内容'
        ,xzmlzl    --'行政命令种类'
        ,sfjxtz    --'是否举行听证'
        ,jdxdrq    --'决定下达日期'
        ,zcjddxgcl    --'作出决定的相关材料'
        ,zxqktx    --'执行情况填写'
        ,wfajlx    --'违法案件类型'
        ,zzwbrq    --'执行完毕日期'
        ,fyqk    --'复议情况'
        ,fyjg    --'复议结果'
        ,ssqk    --'诉讼情况'
        ,ssjg    --'诉讼结果'
        ,jarq    --'结案日期'
        ,ysxx    --'移送信息'
        ,jtqx    --'具体情形'
        ,sfnryhzxxt    --'是否纳入银行征信系统'
        ,jdssfshgk    --'决定书是否社会公开'
        ,gkrq    --'公开日期'
        ,gkfs    --'公开方式'
        ,gkwz    --'公开网址'
        ,qtgkfsms    --'其他公开方式描述'
        ,ajh    --'案卷号'
        ,fj    --'附件'
        ,jaqk    --'结案情况'------------------未结案、已结案
        ,bz    --'备注'
FROM    (
            SELECT  t3.*
                    ,CASE    WHEN t3.tyshxydm3 IS NOT NULL THEN NULL 
                             ELSE dsrmc1 
                     END entname2    --名称用于关联
                    ,ROW_NUMBER() OVER(PARTITION BY jdwsh ORDER BY estdate1 DESC,dsc_biz_timestamp DESC,dsc_biz_record_id DESC) AS rn
            FROM    (
                        SELECT  t2.*
                                ,COALESCE(t2.yyzzzch2,t3.regno) yyzzzch3
                                ,COALESCE(t2.tyshxydm2,t3.uniscid) tyshxydm3
                                ,COALESCE(t2.fddbr2,t3.lerep_name) fddbr3
                                ,COALESCE(t2.sfzhm2,t3.cerno) sfzhm3
                                ,COALESCE(t2.sj2,t3.tel,t2.bgdh1) sj3
                                ,COALESCE(t2.estdate,t3.estdate,'9999-12-31') estdate1
                        FROM    (
                                    SELECT  t1.*
                                            ,COALESCE(t1.yyzzzch1,t2.regno) yyzzzch2
                                            ,COALESCE(t1.tyshxydm1,t2.uniscid) tyshxydm2
                                            ,COALESCE(t1.fddbr1,t2.lerep_name) fddbr2
                                            ,COALESCE(t1.sfzhm1,t2.cerno) sfzhm2
                                            ,COALESCE(t1.sj1,t2.tel) sj2
                                            ,t2.estdate
                                            ,CASE    WHEN t1.tyshxydm1 IS NOT NULL THEN NULL
                                                     WHEN t2.entname IS NOT NULL THEN NULL 
                                                     ELSE dsrmc1 
                                             END entname1    --名称用于关联
                                    FROM    (
                                                SELECT  t0.*
                                                        ,CASE    WHEN t0.tyshxydm1 IS NOT NULL THEN NULL 
                                                                 ELSE t0.yyzzzch1 
                                                         END regno1    --用于关联注册号
                                                FROM    (
                                                            SELECT  *
                                                                    ,CASE    WHEN lxdh IS NULL OR lxdh='' THEN NULL
                                                                             WHEN INSTR(lxdh,'.')>1 THEN SUBSTR(lxdh,1,INSTR(lxdh,'.')-1) 
                                                                             ELSE lxdh 
                                                                     END lxdh1
                                                                    ,CASE    WHEN bgdh IS NULL OR bgdh='' THEN NULL
                                                                             WHEN INSTR(bgdh,'.')>1 THEN SUBSTR(bgdh,1,INSTR(bgdh,'.')-1) 
                                                                             ELSE bgdh 
                                                                     END bgdh1
                                                                    ,CASE    WHEN sj IS NULL OR sj='' THEN NULL
                                                                             WHEN INSTR(sj,'.')>1 THEN SUBSTR(sj,1,INSTR(sj,'.')-1) 
                                                                             ELSE sj 
                                                                     END sj1
                                                                    ,CASE    WHEN sfzhm RLIKE "^[1-9][0-9]{5}[0-9]{2}((0[1-9])|10|11|12)(([0-2][1-9])|10|20|30|31)[0-9]{3}$" THEN ID15To18(sfzhm)
                                                                             WHEN sfzhm RLIKE "^[1-9][0-9]{5}(18|19|20)[0-9]{2}((0[1-9])|10|11|12)(([0-2][1-9])|10|20|30|31)[0-9]{3}[0-9|X|x]$" THEN sfzhm 
                                                                             ELSE NULL 
                                                                     END sfzhm1
                                                                    ,CASE    WHEN dsrmc IS NULL OR dsrmc='' THEN dwmc 
                                                                             ELSE dsrmc 
                                                                     END dsrmc1
                                                                    ,CASE    WHEN fddbr IS NULL OR fddbr='' THEN dwlxr 
                                                                             ELSE fddbr 
                                                                     END fddbr1
                                                                    ,CASE    WHEN yyzzzch RLIKE '^[0-9A-HJ-NPQRTUWXY]{2}[0-9]{6}[0-9A-HJ-NPQRTUWXY]{10}$' THEN yyzzzch
                                                                             WHEN tyshxydm IS NULL OR tyshxydm='' THEN NULL 
                                                                             ELSE tyshxydm 
                                                                     END tyshxydm1
                                                                    ,CASE    WHEN yyzzzch RLIKE '^[0-9A-HJ-NPQRTUWXY]{2}[0-9]{6}[0-9A-HJ-NPQRTUWXY]{10}$' THEN NULL
                                                                             WHEN yyzzzch IS NULL OR yyzzzch='' THEN NULL 
                                                                             ELSE yyzzzch 
                                                                     END yyzzzch1
                                                                    ,ROW_NUMBER() OVER(PARTITION BY jdwsh ORDER BY dsc_biz_timestamp DESC,dsc_biz_record_id DESC) AS rn0
                                                            FROM    stg_ra_hbj_hbxzcf_df
                                                            WHERE   dsrxx <> '个人'
                                                            AND     (dsc_biz_operation IN ('insert','update') OR dsc_biz_operation IS NULL)
                                                        ) t0
                                                WHERE   t0.rn0 = 1
                                            ) t1
                                    LEFT JOIN dwd_qy_main2 t2 ON t2.regno = t1.regno1 AND t2.regno IS NOT NULL
                                ) t2
                        LEFT JOIN dwd_qy_main2 t3 ON t3.entname = t2.entname1 AND t3.entname IS NOT NULL AND t3.entname NOT LIKE '%*%' AND LENGTH(t3.entname)>3
                    ) t3
        ) t4
LEFT JOIN ods_ai_qymc_in t5 ON t5.entname = t4.entname2 AND t5.uniscid IS NOT NULL
WHERE t4.rn = 1
;