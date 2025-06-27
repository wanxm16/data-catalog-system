--企业合表左联上市企业、小微企业、互联网监管、法定代表人
--DROP TABLE IF EXISTS dwd_qy_main2;
--CREATE TABLE dwd_qy_main2 LIKE dwd_qy_main;
INSERT OVERWRITE TABLE dwd_qy_main2
SELECT  t1.pripid    --'主体身份代码'--规上补充过来的会是空
        ,COALESCE(t1.uniscid,t2.unicode,t3.uniscid) uniscid    --'统一社会信用代码'--市场主体注销的不能补充完整也可能是空
        ,COALESCE(t1.regno,t2.regno,t3.regno) regno    --'注册号'
        ,TRIM(COALESCE(t1.entname,t2.entname,t3.entname)) entname    --'企业名称'
        ,COALESCE(t1.reporttype_cn,t2.enttype_name,t3.enttype_cn) reporttype_cn    --'企业类型名称'
        ,COALESCE(t1.reporttype_code,t2.enttype_code,t3.enttype) reporttype_code    --'企业类型代码'
        ,COALESCE(t1.industryphy_cn,t2.industryphy_cn,t3.industryphy_cn) industryphy_cn    --'行业门类名称'
        ,COALESCE(t1.industryphy_code,t2.industryphy,t3.industry_category) industryphy_code    --'行业门类代码'
        ,COALESCE(t1.industryco_cn,t2.industryco_cn,t3.industryco_cn) industryco_cn    --'行业名称'
        ,COALESCE(t1.industryco_code,t2.industryco,t3.national_economy) industryco_code    --'行业代码'
        ,COALESCE(t1.estdate,t2.estdate,t3.estdate)  estdate    --'成立日期'
        ,COALESCE(t1.apprdate,t3.apprdate) apprdate    --'核准日期'
        ,COALESCE(t1.regcap,t2.regcap,t3.regcap) regcap    --'注册资本'
        ,COALESCE(t1.regcapcur,t3.currency_cn) regcapcur    --'注册资本币种'
        ,CASE WHEN t1.dom_village IS NOT NULL THEN t1.dom 
            WHEN t3.dom_village IS NOT NULL THEN t3.dom 
            WHEN t5.dom_village IS NOT NULL THEN t5.dom 
            WHEN t1.dom_street IS NOT NULL THEN t1.dom 
            WHEN t3.dom_street IS NOT NULL THEN t3.dom 
            WHEN t5.dom_street IS NOT NULL THEN t5.dom 
            ELSE COALESCE(t1.dom,t3.dom,t5.dom)
         END dom    --'注册地址'
        ,NULL domdistrict    --'行政区划代码'
        ,CASE WHEN t1.dom_village IS NOT NULL THEN t1.dom_street 
            WHEN t3.dom_village IS NOT NULL THEN t3.dom_street 
            WHEN t5.dom_village IS NOT NULL THEN t5.dom_street 
            ELSE COALESCE(t1.dom_street,t3.dom_street,t5.dom_street)
         END dom_street    --'归属乡镇街道'
        ,COALESCE(t1.dom_village,t3.dom_village,t5.dom_village) dom_village    --'归属村居社区'
        ,CASE WHEN t1.oploc_village IS NOT NULL THEN t1.oploc 
            WHEN t3.oploc_village IS NOT NULL THEN t3.oploc 
            WHEN t1.oploc_street IS NOT NULL THEN t1.oploc 
            WHEN t3.oploc_street IS NOT NULL THEN t3.oploc 
            ELSE COALESCE(t1.oploc,t3.oploc)
         END oploc    --'经营场所'
        ,NULL oplocdistrict    --'经营场所行政区划代码'
        ,CASE WHEN t1.oploc_village IS NOT NULL THEN t1.oploc_street 
            WHEN t3.oploc_village IS NOT NULL THEN t3.oploc_street 
            ELSE COALESCE(t1.oploc_street,t3.oploc_street)
         END oploc_street    --'经营场所乡镇街道'
        ,COALESCE(t1.oploc_village,t3.oploc_village) oploc_village    --'经营场所村居社区'
        ,COALESCE(t1.opfrom,t3.opfrom) opfrom    --'经营(驻在)期限自'
        ,COALESCE(t1.opto,t3.opto) opto    --'经营(驻在)期限至'
        ,COALESCE(t1.opscope,t3.opscope) opscope    --'经营范围'
        ,t1.proloc    --'生产经营地'
        ,t1.proloc_street    --'生产地乡镇街道'
        ,t1.proloc_village    --'生产地村居社区'
        ,NULL yiedistrict    --'生产经营地行政代码'
        ,COALESCE(t1.lerep_name,t3.lerep,t5.name) lerep_name    --'法定代表人'
        ,COALESCE(t1.country_cn,t5.country_cn) country_cn    --'国籍名称'
        ,COALESCE(t1.country_code,t5.country) country_code    --'国籍代码'
        ,t5.certype_cn    --'证件类型名称'
        ,t5.certype AS certype_code    --'证件类型代码'
        ,t5.cerno    --'身份证件号码'
        ,COALESCE(t1.tel,t3.linkmanphone,t5.tel) tel    --'联系电话'
        ,t5.email    --'电子邮件地址'
        ,t1.regstate    --'状态'
        ,COALESCE(t1.revdate,t3.revdate) revdate    --'吊销时间'
        ,NULL revdecno    --'吊销处罚文号'
        ,COALESCE(t1.revbasis,t3.sugrevreason) revbasis    --'吊销原因'
        ,NULL revauth    --'吊照处罚实施机关'
        ,NULL candate    --'注销时间'
        ,NULL canrea_cn    --'注销原因中文'
        ,NULL canrea_code    --'注销原因代码'
        ,COALESCE(t1.xwstate,t2.xwstate) xwstate    --'小微企业状态代码'
        ,COALESCE(t1.xwsort_cn,t2.xwsort_cn) xwsort_cn    --'小微企业分类名称'
        ,COALESCE(t1.xw_addtime,t2.addtime) xw_addtime    --'加入时间'
        ,COALESCE(t1.xw_remtime,t2.remtime) xw_remtime    --'退出时间'
        ,COALESCE(t1.xw_remreason,t2.remreason_cn) xw_remreason    --'退出原因'
        ,CASE WHEN t1.web_bit IS NULL AND t3.pripid IS NOT NULL THEN '1' ELSE t1.web_bit END web_bit     --'互联网监管'
        ,t1.above_bit    --'规上规下'
        ,t1.above_year    --'规上年份'
        ,CASE WHEN t4.pripid IS NOT NULL THEN '1' ELSE NULL END stock_bit    --'上市企业'
        ,t4.stock_name    --'股票名称'
        ,t4.stock_code    --'股票代码'
        ,t4.stock_date    --'上市时间'
        ,t4.stock_address    --'上市交易所'
        ,t4.stock_text    --'简介描述'
        ,t1.ind_to_ent    --'是否个转企'
        ,t1.ind_to_ent2    --'是否个转企二次转型'
        ,t1.compform    --'个体户组成形式'
        ,COALESCE(t1.regorg,t2.regorgname,t3.regorg_cn) regorg    --'企业登记机关'
        ,t1.localadm    --'管辖单位代码'
        ,t1.localadm_cn    --'管辖单位名称'
        ,t1.laiyuan    --'合表来源'
FROM    dwd_qy_main1 t1    --企业底数
LEFT JOIN ods_qy_xwqy_all t2 ON t2.pripid=t1.pripid  --小微企业
LEFT JOIN ods_qy_hlwjg_all t3 ON t3.pripid=t1.pripid  --互联网监管
LEFT JOIN ods_ra_jrb_ssqy_all t4 ON t4.pripid=t1.pripid --上市企业
LEFT JOIN (select *,DZTOZJ(dom) dom_street,DZTOCS(dom,NULL) dom_village from dwd_qygg_fddbr) t5 ON t5.pripid=t1.pripid --法定代表人
;