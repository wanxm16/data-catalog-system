--省市回流_小微企业基本信息（包含个体户）——全部
INSERT OVERWRITE TABLE ods_qy_xwqy_all
SELECT  d1.pripid    --'主体身份代码',
        ,d1.unicode    --'统一社会信用代码',
        ,d1.regno    --'注册号',
        ,d1.entname    --'企业名称',
        ,d2.type_name AS enttype_name    --'市场主体类型名称',
        ,d1.enttype AS enttype_code    --'市场主体类型代码',
        ,d3.name AS industryphy_cn    --'行业门类名称',
        ,industryphy1 AS industryphy    --'行业门类代码',
        ,industryco_cn1 AS industryco_cn    --'行业名称',
        ,industryco1 AS industryco    --'行业代码',
        ,d1.estdate    --'成立日期',
        ,d1.regcap    --'注册资本',
        ,d1.addtime    --'加入时间',
        ,d1.xwstate    --'小微企业状态代码',
        ,d1.xwsort_cn    --'小微企业分类名称',
        ,d1.remtime    --'退出时间',
        ,d1.remreason_cn    --'退出原因',
        ,d1.regorgname    --'企业登记机关名称'
        ,d1.regorg  --'企业登记机关代码'
FROM    (
            SELECT  *
                    ,COALESCE(t1.industryphy,t2.ml) industryphy1   --'行业门类代码',
                    ,COALESCE(t1.industryco_cn,t2.content) industryco_cn1    --'行业名称',
            FROM    (
                        SELECT  *
                                ,CASE    WHEN industryco='0000' OR TRIM(industryco)='' THEN NULL
                                         WHEN industryco='3260' THEN '3140' 
                                         ELSE industryco 
                                 END industryco1    --'行业代码',
                        FROM    stg_qy_xwqy
                        --WHERE   regorg LIKE '330381%' OR entname LIKE '%瑞安%'
                    ) t1
            LEFT JOIN dict_industry_code t2 ON t2.code = t1.industryco1
        ) d1
LEFT JOIN dict_ent_type d2 ON d2.type_code = d1.enttype 
LEFT JOIN dict_industry_category d3 ON d3.code = d1.industryphy1
;