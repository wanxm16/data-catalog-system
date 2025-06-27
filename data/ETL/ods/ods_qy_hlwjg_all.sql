--省回流_"互联网+监管"企业基本信息——全部回流
INSERT OVERWRITE TABLE ods_qy_hlwjg_all
SELECT  pripid    --'主体身份代码',
        ,uniscid    --'统一社会信用代码',
        ,regno    --'注册号',
        ,entname    --'企业名称',
        ,enttype_cn    --'企业类型名称',
        ,enttype    --'企业类型代码',
        ,d2.name AS industryphy_cn    --'行业门类名称',
        ,industry_category2 AS industry_category    --'行业门类代码',
        ,industryco_cn    --'行业名称',
        ,industryco_code AS national_economy    --'行业代码',
        ,estdate    --'成立日期',
        ,apprdate    --'核准日期',
        ,regcap    --'注册资本/注册资金',
        ,currency_cn    --'注册资本币种',
        ,dom1 AS dom    --'注册地址',
        ,CASE    WHEN dom1Cs IS NOT NULL THEN dom1Zj
                 WHEN oploc1Cs IS NOT NULL THEN oploc1Zj 
                 ELSE COALESCE(dom1Zj,oploc1Zj) 
         END dom_street    --'归属乡镇街道'
        ,COALESCE(dom1Cs,oploc1Cs) dom_village    --'归属村居社区'
        ,oploc1 AS oploc    --'营业场所/主要经营场',
        ,oploc1Zj AS oploc_street   --'经营场所乡镇街道'
        ,oploc1Cs AS oploc_village  --'经营场所村居社区'
        ,opfrom    --'经营期限自/营业期限',
        ,opto    --'经营期限至/营业期限',
        ,opscope    --'经营范围',
        ,lerep    --'法定代表人/负责人',
        ,linkmanphone    --'联络员手机号码',--全空
        ,CASE    WHEN regstate_cn='吊销，已注销' THEN '注销'
                 WHEN regstate_cn='吊销，未注销' THEN '吊销' 
                 ELSE regstate_cn 
         END regstate_cn    --'登记状态名称',
        ,revdate    --'吊销日期',
        ,sugrevreason    --'吊销原因',
        ,regorg_cn    --'登记机关名称'
        ,regorg     --'登记机关代码'
FROM    (
            SELECT  t2.*
                    -- 从地址中提取村居社区：匹配"XX社区"、"XX村"、"XX居委会"等
                    ,CASE WHEN dom1 RLIKE '([^市区县]{2,8})(社区|村|居委会|委员会)' 
                          THEN regexp_extract(dom1, '([^市区县]{2,8})(社区|村|居委会|委员会)', 1) 
                          ELSE NULL 
                     END dom1Cs
                    ,CASE WHEN oploc1 RLIKE '([^市区县]{2,8})(社区|村|居委会|委员会)' 
                          THEN regexp_extract(oploc1, '([^市区县]{2,8})(社区|村|居委会|委员会)', 1) 
                          ELSE NULL 
                     END oploc1Cs
                    ,COALESCE(t2.industry_category1, d1.ml) industry_category2    --'行业门类代码',
                    ,d1.content AS industryco_cn    --'行业名称',
            FROM    (
                        SELECT  t1.*
                                -- 从地址中提取乡镇街道：匹配"XX街道"、"XX镇"、"XX乡"等
                                ,CASE WHEN dom1 RLIKE '([^市区县]{2,8})(街道|镇|乡|开发区|园区)' 
                                      THEN regexp_extract(dom1, '([^市区县]{2,8})(街道|镇|乡|开发区|园区)', 1) 
                                      ELSE NULL 
                                 END dom1Zj
                                ,CASE WHEN oploc1 RLIKE '([^市区县]{2,8})(街道|镇|乡|开发区|园区)' 
                                      THEN regexp_extract(oploc1, '([^市区县]{2,8})(街道|镇|乡|开发区|园区)', 1) 
                                      ELSE NULL 
                                 END oploc1Zj
                                ,CASE    WHEN industry_category='空' OR TRIM(industry_category)='' THEN NULL 
                                         ELSE industry_category 
                                 END industry_category1    --'行业门类代码',
                                ,CASE    WHEN national_economy='空' OR TRIM(national_economy)='' THEN NULL
                                         WHEN national_economy='3260' THEN '3140' 
                                         ELSE national_economy 
                                 END industryco_code    --'行业代码',
                        FROM    (
                                    SELECT  *
                                            -- 地址词汇纠正：去除多余空格和特殊字符
                                            ,TRIM(REGEXP_REPLACE(COALESCE(dom,''), '[\\s　]+', '')) dom1
                                            ,TRIM(REGEXP_REPLACE(COALESCE(oploc,''), '[\\s　]+', '')) oploc1
                                    FROM    stg_qy_hlwjg
                                    WHERE   regorg LIKE '330381%' OR entname LIKE '%瑞安%' OR dom LIKE '%瑞安%' OR oploc LIKE '%瑞安%'
                                ) t1
                    ) t2
            LEFT JOIN dict_industry_code d1 ON d1.code = t2.industryco_code
        ) t3
LEFT JOIN dict_industry_category d2 ON d2.code = t3.industry_category2
;