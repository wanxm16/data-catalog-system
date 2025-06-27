--省市回流_“互联网+监管”个体工商户基本信息
INSERT OVERWRITE TABLE ods_ra_sjj_hlwjggtgsh_df
SELECT
        pripid--'主体身份代码',
        ,uniscid--'统一社会信用代码',
        ,regno--'注册号',
        ,traname--'企业名称',
        ,enttype_cn--'企业类型名称',
        ,enttype--'企业类型代码',
        ,estdate--'注册日期',
        ,apprdate--'核准日期',
        ,oploc--'经营场所',
        ,oploc1Zj AS oploc_street--'经营场所乡镇街道',
        ,oploc1Cs AS oploc_village--'经营场所村居社区',
        ,opscope--'经营范围',
        ,COALESCE(name,linkmanname) name--'经营者',
        ,CASE WHEN tel2 IS NULL THEN NULL 
              WHEN tel2 LIKE '#1%' THEN CONCAT(SUBSTR(tel2, 2, 11),'\\',SUBSTR(tel2, 13))--1开始的先截取手机11位
              WHEN tel2 LIKE '#%' THEN CONCAT(SUBSTR(tel2, 2, 8),'\\',SUBSTR(tel2, 10))--非1开始的先截取8位固话
              ELSE tel2 END linkmanphone--'联络员手机号码',
        ,CASE WHEN regstate_cn = '吊销，已注销' THEN '注销'
              WHEN regstate_cn = '吊销，未注销' THEN '吊销'
              WHEN regstate_cn = '已注销' THEN '注销'
              ELSE regstate_cn END regstate_cn--'登记状态名称',
        ,revdate--'吊销日期',
        ,sugrevreason--'吊销原因',
        ,compform_cn--'组成形式',
        ,regorg_cn--'登记机关',
        ,'互联网个体' laiyuan--'来源'
FROM    (
        SELECT  t2.*
                -- 从地址中提取村居社区：匹配"XX社区"、"XX村"、"XX居委会"等
                ,CASE WHEN oploc1 RLIKE '([^市区县]{2,8})(社区|村|居委会|委员会)' 
                      THEN regexp_extract(oploc1, '([^市区县]{2,8})(社区|村|居委会|委员会)', 1) 
                      ELSE NULL END oploc1Cs
                ,CASE WHEN tel1 IS NULL OR LENGTH(tel1)=0 THEN NULL
                    WHEN tel1 LIKE '%-%' OR tel1 RLIKE '^[0-9]+[\\\\][0-9]+$' THEN tel1 --多号码 或 固定电话
                    WHEN LENGTH(tel1)<11 AND tel1 LIKE '1%' THEN  NULL --手机少位数
                    WHEN LENGTH(tel1)<11 AND tel1 LIKE '0%' THEN  NULL --错误号码
                    WHEN tel1 RLIKE '^1[0-9]{10}$|^[1-9][0-9]{7}$|^0[0-9]{3}(-)*[0-9]{8}$' AND SUBSTR(tel1,4,8) REGEXP '(0000000|1111111|2222222|3333333|4444444|5555555|6666666|7777777|8888888|9999999|12345678)' THEN NULL
                    WHEN LENGTH(tel1)=12 AND tel1 LIKE '01%' THEN SUBSTR(tel1,2,11) --外地手机
                    WHEN LENGTH(tel1)=12 AND tel1 LIKE '1%' THEN NULL --手机多位数
                    WHEN LENGTH(tel1)=12 AND tel1 LIKE '0%' THEN tel1 --固定电话
                    WHEN LENGTH(tel1) in(16,19,22) THEN CONCAT('#',tel1) --两个号码,加#下步分割
                    WHEN LENGTH(tel1)>11 THEN NULL --混乱数据
                    ELSE tel1 END tel2--'联系电话'
        FROM    (
                SELECT
                        t1.*
                        -- 从地址中提取乡镇街道：匹配"XX街道"、"XX镇"、"XX乡"等
                        ,CASE WHEN oploc1 RLIKE '([^市区县]{2,8})(街道|镇|乡|开发区|园区)' 
                              THEN regexp_extract(oploc1, '([^市区县]{2,8})(街道|镇|乡|开发区|园区)', 1) 
                              ELSE NULL END oploc1Zj
                        ,REGEXP_REPLACE(tel0,'\\\\\\\\','\\\\') tel1
                FROM    (
                        SELECT
                                *
                                -- 地址词汇纠正：去除多余空格和特殊字符
                                ,TRIM(REGEXP_REPLACE(COALESCE(oploc,''), '[\\s　]+', '')) oploc1
                                ,REGEXP_REPLACE(
                                        REGEXP_REPLACE(TRIM(linkmanphone),'[\\.\\/\\s;,#、，　；或]+','\\\\')
                                        ,'[\\x{3400}-\\x{4db5}\\x{4e00}-\\x{9fa5}]+'
                                        ,'') tel0
                        FROM    stg_ra_sjj_hlwjggtgsh_df
                        WHERE   regstate_cn NOT IN ('撤销','迁出')
                        ) t1
                ) t2
        );