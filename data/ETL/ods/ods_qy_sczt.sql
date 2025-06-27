--省市回流_市场主体信息（含个体)
INSERT OVERWRITE TABLE ods_qy_sczt
SELECT
        pripid--'主体身份代码'
        ,uniscid--'统一社会信用代码'
        ,regno--'注册号'
        ,entname--'企业名称'
        ,reporttype--'企业类型名称'
        ,reporttype_code--'企业类型代码'
        ,COALESCE(t3.industryco,d3.content) industryco--'行业名称'
        ,industryco_code1 AS industryco_code--'行业代码'
        ,estdate--'成立日期'
        ,apprdate--'核准日期'
        ,regcap--'注册资本'
        ,regcapcur--'注册资本-币种'
        ,dom1 AS dom--'注册地址'
        ,NULL domdistrict--'行政区划代码'
        ,CASE WHEN dom1Cs IS NOT NULL THEN dom1Zj
              WHEN oploc1Cs IS NOT NULL THEN oploc1Zj
              ELSE COALESCE(dom1Zj,oploc1Zj,sjj1Zj) END dom_street--'归属乡镇街道'
        ,CASE WHEN COALESCE(dom1Cs,oploc1Cs) IS NULL AND proloc_village IS NOT NUll AND proloc_street=COALESCE(dom1Zj,oploc1Zj,sjj1Zj) THEN proloc_village 
              WHEN COALESCE(dom1Cs,oploc1Cs) IS NULL AND COALESCE(dom1Zj,oploc1Zj,sjj1Zj) IS NOT NULL THEN 
                CASE WHEN dom1 RLIKE '([^市区县]{2,8})(社区|村|居委会|委员会)' 
                     THEN regexp_extract(dom1, '([^市区县]{2,8})(社区|村|居委会|委员会)', 1) 
                     ELSE NULL END--再解析一次
              ELSE COALESCE(dom1Cs,oploc1Cs) END dom_village--'归属村居社区'
        ,oploc1 AS oploc--'经营场所'
        ,oploc1Zj AS oploc_street   --'经营场所乡镇街道'
        ,oploc1Cs AS oploc_village  --'经营场所村居社区'
        ,opfrom--'经营(驻在)期限自'
        ,opto--'经营(驻在)期限至'
        ,opscope--'经营范围'
        ,proloc1 AS proloc--'生产经营地'
        ,proloc_street--'生产地乡镇街道'
        ,proloc_village--'生产地村居社区'
        ,NULL yiedistrict--'生产经营地行政代码'
        ,name--'法定代表人'
        ,CASE WHEN country IS NULL THEN d1.cname
              ELSE country END country_cn--'国籍名称'
        ,CASE WHEN country_code IS NULL OR country_code='' THEN d2.code
              ELSE country_code END country_code--'国籍代码'
        ,CASE WHEN tel2 IS NULL THEN NULL 
              WHEN tel2 LIKE '#1%' THEN CONCAT(SUBSTR(tel2, 2, 11),'\\',SUBSTR(tel2, 13))--1开始的先截取手机11位
              WHEN tel2 LIKE '#%' THEN CONCAT(SUBSTR(tel2, 2, 8),'\\',SUBSTR(tel2, 10))--非1开始的先截取8位固话
              ELSE tel2 END tel--'联系电话'
        ,regstate--'状态'
        ,sfgzq--'是否个转企'
        ,sfgzqzx--'是否个转企二次转型'
        ,compform--'个体户组成形式'
        ,regorg--'企业登记机关'
        ,CASE WHEN localadm NOT LIKE '330381%' OR localadm='33038100' THEN NULL
              ELSE localadm END localadm--'管辖单位代码'
        ,CASE WHEN localadm NOT LIKE '330381%' OR localadm='33038100' THEN NULL
              ELSE localadm_cn END localadm_cn--'管辖单位名称'
        ,'市场主体' laiyuan
FROM    (
        SELECT
                t2.*
                ,CASE WHEN tel IS NULL OR length(trim(tel))=0 THEN NULL
                    WHEN tel1 LIKE '%-%' OR tel1 RLIKE '^[0-9]+[\\\\][0-9]+$' THEN tel1 --多号码 或 固定电话
                    WHEN length(tel1)<11 AND tel1 LIKE '1%' THEN  NULL --手机少位数
                    WHEN length(tel1)<11 AND tel1 LIKE '0%' THEN  NULL --错误号码
                    WHEN tel1 RLIKE '^1[0-9]{10}$|^[1-9][0-9]{7}$|^0[0-9]{3}(-)*[0-9]{8}$' AND substr(tel1,4,8) REGEXP '(0000000|1111111|2222222|3333333|4444444|5555555|6666666|7777777|8888888|9999999|12345678)' THEN NULL
                    WHEN length(tel1)=12 AND tel1 LIKE '01%' THEN substr(tel1,2,11) --外地手机
                    WHEN length(tel1)=12 AND tel1 LIKE '1%' THEN NULL --手机多位数
                    WHEN length(tel1)=12 AND tel1 LIKE '0%' THEN tel1 --固定电话
                    WHEN length(tel1) in(16,19,22) THEN CONCAT('#',tel1) --两个号码,加#下步分割
                    WHEN length(tel1)>11 THEN NULL --混乱数据
                    ELSE tel1 END tel2--'联系电话'
                -- 从地址中提取村居社区：匹配"XX社区"、"XX村"、"XX居委会"等
                ,CASE WHEN dom1 RLIKE '([^市区县]{2,8})(社区|村|居委会|委员会)' 
                      THEN regexp_extract(dom1, '([^市区县]{2,8})(社区|村|居委会|委员会)', 1) 
                      ELSE NULL END dom1Cs
                ,CASE WHEN oploc1 RLIKE '([^市区县]{2,8})(社区|村|居委会|委员会)' 
                      THEN regexp_extract(oploc1, '([^市区县]{2,8})(社区|村|居委会|委员会)', 1) 
                      ELSE NULL END oploc1Cs
                ,CASE WHEN proloc1 RLIKE '([^市区县]{2,8})(社区|村|居委会|委员会)' 
                      THEN regexp_extract(proloc1, '([^市区县]{2,8})(社区|村|居委会|委员会)', 1) 
                      ELSE NULL END proloc_village
        FROM    (
                SELECT
                        t1.*
                        ,REGEXP_REPLACE(tel0,'\\\\\\\\','\\\\') tel1
                        -- 从地址中提取乡镇街道：匹配"XX街道"、"XX镇"、"XX乡"等
                        ,CASE WHEN dom1 RLIKE '([^市区县]{2,8})(街道|镇|乡|开发区|园区)' 
                              THEN regexp_extract(dom1, '([^市区县]{2,8})(街道|镇|乡|开发区|园区)', 1) 
                              ELSE NULL END dom1Zj
                        ,CASE WHEN oploc1 RLIKE '([^市区县]{2,8})(街道|镇|乡|开发区|园区)' 
                              THEN regexp_extract(oploc1, '([^市区县]{2,8})(街道|镇|乡|开发区|园区)', 1) 
                              ELSE NULL END oploc1Zj
                        ,CASE WHEN proloc1 RLIKE '([^市区县]{2,8})(街道|镇|乡|开发区|园区)' 
                              THEN regexp_extract(proloc1, '([^市区县]{2,8})(街道|镇|乡|开发区|园区)', 1) 
                              ELSE NULL END proloc_street
                        -- 从管辖单位名称中提取乡镇街道
                        ,CASE WHEN localadm_cn RLIKE '([^市区县]{2,8})(街道|镇|乡|开发区|园区)' 
                              THEN regexp_extract(localadm_cn, '([^市区县]{2,8})(街道|镇|乡|开发区|园区)', 1) 
                              ELSE NULL END sjj1Zj
                FROM    (
                        SELECT
                                *
                                ,REGEXP_REPLACE(REGEXP_REPLACE(TRIM(tel),'[\\.\\/\\s;,#、，　；或]+','\\\\'),'[\\x{3400}-\\x{4db5}\\x{4e00}-\\x{9fa5}]+','') tel0
                                -- 地址词汇纠正：去除多余空格和特殊字符
                                ,TRIM(REGEXP_REPLACE(COALESCE(dom,''), '[\\s　]+', '')) dom1
                                ,TRIM(REGEXP_REPLACE(COALESCE(oploc,''), '[\\s　]+', '')) oploc1
                                ,TRIM(REGEXP_REPLACE(COALESCE(proloc,''), '[\\s　]+', '')) proloc1
                                ,CASE    WHEN TRIM(industryco_code)='' THEN NULL
                                         WHEN industryco_code='3260' THEN '3140' 
                                         ELSE industryco_code 
                                 END industryco_code1    --'行业代码',
                        FROM    stg_qy_sczt
                        WHERE   localadm LIKE '330381%' OR regorg_code LIKE '330381%' OR entname LIKE '%瑞安%' OR dom LIKE '%瑞安%' OR oploc LIKE '%瑞安%' OR proloc LIKE '%瑞安%'
                        ) t1
                ) t2
        ) t3
        LEFT JOIN dict_country_code d1 ON d1.code = t3.country_code
        LEFT JOIN dict_country_code d2 ON d2.cname = t3.country
        LEFT JOIN dict_industry_code d3 ON d3.code = t3.industryco_code1
;