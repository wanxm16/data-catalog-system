--企业合表左联吊销、注销、行业门类、ai地址
--DROP TABLE IF EXISTS dwd_qy_main3;
--CREATE TABLE dwd_qy_main3 LIKE dwd_qy_main;
INSERT OVERWRITE TABLE dwd_qy_main3
SELECT  t1.pripid    --'主体身份代码'--规上补充过来的会是空
        ,t1.uniscid    --'统一社会信用代码'--市场主体注销的不能补充完整也可能是空
        ,t1.regno    --'注册号'
        ,t1.entname    --'企业名称'
        ,t1.reporttype_cn    --'企业类型名称'
        ,t1.reporttype_code    --'企业类型代码'
        ,t1.industryphy_cn    --'行业门类名称'
        ,t1.industryphy_code    --'行业门类代码'
        ,t1.industryco_cn    --'行业名称'
        ,t1.industryco_code    --'行业代码'
        ,t1.estdate    --'成立日期'
        ,t1.apprdate    --'核准日期'
        ,t1.regcap    --'注册资本'
        ,t1.regcapcur    --'注册资本币种'
        ,t1.dom    --'注册地址'
        ,NULL domdistrict    --'行政区划代码'
        ,COALESCE(d1.addr_street,t1.dom_street,d9.addr_street) dom_street    --'归属乡镇街道'
        ,COALESCE(d1.addr_village,t1.dom_village,d9.addr_village) dom_village    --'归属村居社区'
        ,t1.oploc    --'经营场所'
        ,NULL oplocdistrict    --'经营场所行政区划代码'
        ,COALESCE(d2.addr_street,t1.oploc_street) oploc_street    --'经营场所乡镇街道'
        ,COALESCE(d2.addr_village,t1.oploc_village) oploc_village    --'经营场所村居社区'
        ,t1.opfrom    --'经营(驻在)期限自'
        ,t1.opto    --'经营(驻在)期限至'
        ,t1.opscope    --'经营范围'
        ,t1.proloc    --'生产经营地'
        ,COALESCE(d3.addr_street,t1.proloc_street) proloc_street    --'生产地乡镇街道'
        ,COALESCE(d3.addr_village,t1.proloc_village) proloc_village    --'生产地村居社区'
        ,NULL yiedistrict    --'生产经营地行政代码'
        ,t1.lerep_name    --'法定代表人'
        ,t1.country_cn    --'国籍名称'
        ,t1.country_code    --'国籍代码'
        ,t1.certype_cn    --'证件类型名称'
        ,t1.certype_code    --'证件类型代码'
        ,t1.cerno    --'身份证件号码'
        ,t1.tel    --'联系电话'
        ,t1.email    --'电子邮件地址'
        ,CASE WHEN ztyc='3' THEN '注销'
              WHEN ztyc='2' THEN '吊销'
              WHEN regstate IS NULL THEN '存续'
              ELSE regstate
         END regstate    --'状态'
        ,CASE WHEN ztyc='1' AND regstate NOT IN ('注销','吊销') THEN NULL ELSE revdate END revdate    --'吊销时间'
        ,CASE WHEN ztyc='1' AND regstate NOT IN ('注销','吊销') THEN NULL ELSE revdecno END revdecno    --'吊销处罚文号'
        ,CASE WHEN ztyc='1' AND regstate NOT IN ('注销','吊销') THEN NULL ELSE revbasis END revbasis    --'吊销原因'
        ,CASE WHEN ztyc='1' AND regstate NOT IN ('注销','吊销') THEN NULL ELSE revauth END revauth    --'吊照处罚实施机关'
        ,CASE WHEN ztyc<>'3' AND regstate<>'注销' THEN NULL ELSE candate END candate    --'注销时间'
        ,CASE WHEN ztyc<>'3' AND regstate<>'注销' THEN NULL ELSE canrea_cn END canrea_cn    --'注销原因中文'
        ,CASE WHEN ztyc<>'3' AND regstate<>'注销' THEN NULL ELSE canrea_code END canrea_code    --'注销原因代码'
        ,t1.xwstate    --'小微企业状态代码'
        ,t1.xwsort_cn    --'小微企业分类名称'
        ,t1.xw_addtime    --'加入时间'
        ,t1.xw_remtime    --'退出时间'
        ,t1.xw_remreason    --'退出原因'
        ,t1.web_bit    --'互联网监管'
        ,t1.above_bit    --'规上规下'
        ,t1.above_year    --'规上年份'
        ,t1.stock_bit    --'上市企业'
        ,t1.stock_name    --'股票名称'
        ,t1.stock_code    --'股票代码'
        ,t1.stock_date    --'上市时间'
        ,t1.stock_address    --'上市交易所'
        ,t1.stock_text    --'简介描述'
        ,t1.ind_to_ent    --'是否个转企'
        ,t1.ind_to_ent2    --'是否个转企二次转型'
        ,t1.compform    --'个体户组成形式'
        ,t1.regorg    --'企业登记机关'
        ,t1.localadm    --'管辖单位代码'
        ,t1.localadm_cn    --'管辖单位名称'
        ,t1.laiyuan    --'合表来源'
FROM    (
            SELECT  t1.pripid    --'主体身份代码'--规上补充过来的会是空
                    ,t1.uniscid    --'统一社会信用代码'--市场主体注销的不能补充完整也可能是空
                    ,t1.regno    --'注册号'
                    ,t1.entname    --'企业名称'
                    ,t1.reporttype_cn    --'企业类型名称'
                    ,t1.reporttype_code    --'企业类型代码'
                    ,COALESCE(t5.name,t1.industryphy_cn) industryphy_cn    --'行业门类名称'
                    ,COALESCE(t5.code,t1.industryphy_code) industryphy_code    --'行业门类代码'
                    ,t1.industryco_cn    --'行业名称'
                    ,t1.industryco_code    --'行业代码'
                    ,t1.estdate    --'成立日期'
                    ,t1.apprdate    --'核准日期'
                    ,t1.regcap    --'注册资本'
                    ,t1.regcapcur    --'注册资本币种'
                    ,t1.dom    --'注册地址'
                    ,NULL domdistrict    --'行政区划代码'
                    ,t1.dom_street    --'归属乡镇街道'
                    ,t1.dom_village    --'归属村居社区'
                    ,t1.oploc    --'经营场所'
                    ,NULL oplocdistrict    --'经营场所行政区划代码'
                    ,t1.oploc_street    --'经营场所乡镇街道'
                    ,t1.oploc_village    --'经营场所村居社区'
                    ,t1.opfrom    --'经营(驻在)期限自'
                    ,t1.opto    --'经营(驻在)期限至'
                    ,t1.opscope    --'经营范围'
                    ,t1.proloc    --'生产经营地'
                    ,t1.proloc_street    --'生产地乡镇街道'
                    ,t1.proloc_village    --'生产地村居社区'
                    ,NULL yiedistrict    --'生产经营地行政代码'
                    ,t1.lerep_name    --'法定代表人'
                    ,t1.country_cn    --'国籍名称'
                    ,t1.country_code    --'国籍代码'
                    ,t1.certype_cn    --'证件类型名称'
                    ,t1.certype_code    --'证件类型代码'
                    ,t1.cerno    --'身份证件号码'
                    ,t1.tel    --'联系电话'
                    ,t1.email    --'电子邮件地址'
                    ,CASE    WHEN t1.regstate='吊销' AND t3.candate IS NOT NULL THEN '注销' 
                             ELSE t1.regstate 
                     END regstate    --'状态'
                    ,COALESCE(t2.revdate,t1.revdate) revdate    --'吊销时间'
                    ,t2.revdecno    --'吊销处罚文号'
                    ,COALESCE(t2.revbasis,t1.revbasis) revbasis    --'吊销原因'
                    ,t2.revauth    --'吊照处罚实施机关'
                    ,t3.candate    --'注销时间'
                    ,t3.canrea_cn    --'注销原因中文'
                    ,t3.canrea AS canrea_code    --'注销原因代码'
                    ,t1.xwstate    --'小微企业状态代码'
                    ,t1.xwsort_cn    --'小微企业分类名称'
                    ,t1.xw_addtime    --'加入时间'
                    ,t1.xw_remtime    --'退出时间'
                    ,t1.xw_remreason    --'退出原因'
                    ,t1.web_bit    --'互联网监管'
                    ,t1.above_bit    --'规上规下'
                    ,t1.above_year    --'规上年份'
                    ,t1.stock_bit    --'上市企业'
                    ,t1.stock_name    --'股票名称'
                    ,t1.stock_code    --'股票代码'
                    ,t1.stock_date    --'上市时间'
                    ,t1.stock_address    --'上市交易所'
                    ,t1.stock_text    --'简介描述'
                    ,t1.ind_to_ent    --'是否个转企'
                    ,t1.ind_to_ent2    --'是否个转企二次转型'
                    ,t1.compform    --'个体户组成形式'
                    ,COALESCE(t1.regorg,t3.regorg_cn) regorg    --'企业登记机关'
                    ,t1.localadm    --'管辖单位代码'
                    ,t1.localadm_cn    --'管辖单位名称'
                    ,t1.laiyuan    --'合表来源'
                    ,CASE    WHEN t3.candate IS NOT NULL AND t3.candate>t1.apprdate THEN '3' --注销
                             WHEN t2.revdate IS NOT NULL AND t2.revdate>t1.apprdate THEN '2' --吊销
                             ELSE '1' 
                     END ztyc
            FROM    dwd_qy_main2 t1    --企业底数
            LEFT JOIN ods_qysx_dx t2 ON t2.pripid = t1.pripid     --吊销
            LEFT JOIN ods_qysx_zx t3 ON t3.pripid = t1.pripid    --注销
            LEFT JOIN dict_industry_code t4 ON t4.code = t1.industryco_code     --行业
            LEFT JOIN dict_industry_category t5 ON t5.code = t4.ml    --门类
        ) t1
        LEFT JOIN ods_ai_qydz_in d1 ON  d1.key_md5=MD5(CONCAT_WS(',',COALESCE(t1.pripid,''),COALESCE(t1.uniscid,''),'1'))
        LEFT JOIN ods_ai_qydz_in d9 ON  d9.key_md5=MD5(CONCAT_WS(',',COALESCE(t1.pripid,''),COALESCE(t1.uniscid,''),'9'))
        LEFT JOIN ods_ai_qydz_in d2 ON  d2.key_md5=MD5(CONCAT_WS(',',COALESCE(t1.pripid,''),COALESCE(t1.uniscid,''),'2'))
        LEFT JOIN ods_ai_qydz_in d3 ON  d3.key_md5=MD5(CONCAT_WS(',',COALESCE(t1.pripid,''),COALESCE(t1.uniscid,''),'3'))
;