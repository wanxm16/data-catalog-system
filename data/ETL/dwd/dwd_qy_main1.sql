--企业主体表-底数合表
--DROP TABLE IF EXISTS dwd_qy_main1;
--CREATE TABLE dwd_qy_main1 LIKE dwd_qy_main;
INSERT OVERWRITE TABLE dwd_qy_main1
SELECT  COALESCE(t1.pripid,t2.pripid,t3.pripid,t4.pripid) pripid    --'主体身份代码'--规上补充过来的会是空
        ,COALESCE(t1.uniscid,t2.unicode,t3.uniscid,t4.uniscid,t9.tyshxydm) uniscid    --'统一社会信用代码'--市场主体注销的不能补充完整也可能是空
        ,COALESCE(t1.regno,t2.regno,t3.regno,t4.regno,t9.zzjgdm) regno    --'注册号'
        ,COALESCE(t1.entname,t2.entname,t3.entname,t4.traname,t9.jgmc) entname    --'企业名称'
        ,COALESCE(t1.reporttype,t2.enttype_name,t3.enttype_cn,t4.enttype_cn) reporttype_cn    --'企业类型名称'
        ,COALESCE(t1.reporttype_code,t2.enttype_code,t3.enttype,t4.enttype) reporttype_code    --'企业类型代码'
        ,COALESCE(t2.industryphy_cn,t3.industryphy_cn,t9.industryphy_cn) industryphy_cn    --'行业门类名称'
        ,COALESCE(t2.industryphy,t3.industry_category,t9.industryphy) industryphy_code    --'行业门类代码'
        ,COALESCE(t1.industryco,t2.industryco_cn,t3.industryco_cn,t9.industryco_cn) industryco_cn    --'行业名称'
        ,COALESCE(t1.industryco_code,t2.industryco,t3.national_economy,t9.industryco) industryco_code    --'行业代码'
        ,COALESCE(t1.estdate,t2.estdate,t3.estdate,t4.estdate)  estdate    --'成立日期'
        ,COALESCE(t1.apprdate,t3.apprdate,t4.apprdate) apprdate    --'核准日期'
        ,COALESCE(t1.regcap,t2.regcap,t3.regcap) regcap    --'注册资本'
        ,COALESCE(t1.regcapcur,t3.currency_cn) regcapcur    --'注册资本币种'
        ,CASE WHEN t1.dom_village IS NOT NULL THEN t1.dom 
            WHEN t3.dom_village IS NOT NULL THEN t3.dom 
            WHEN t9.dom_village IS NOT NULL THEN t9.jgdz 
            WHEN t1.dom_street IS NOT NULL THEN t1.dom 
            WHEN t3.dom_street IS NOT NULL THEN t3.dom 
            WHEN t9.dom_street IS NOT NULL THEN t9.jgdz 
            ELSE COALESCE(t1.dom,t3.dom,t9.jgdz)
            END dom    --'注册地址'
        ,NULL domdistrict    --'行政区划代码'
        ,CASE WHEN t1.dom_village IS NOT NULL THEN t1.dom_street 
            WHEN t3.dom_village IS NOT NULL THEN t3.dom_street 
            WHEN t9.dom_village IS NOT NULL THEN t9.dom_street 
            ELSE COALESCE(t1.dom_street,t3.dom_street,t9.dom_street)
            END dom_street    --'归属乡镇街道'
        ,COALESCE(t1.dom_village,t3.dom_village,t9.dom_village) dom_village    --'归属村居社区'
        ,CASE WHEN t1.oploc_village IS NOT NULL THEN t1.oploc 
            WHEN t3.oploc_village IS NOT NULL THEN t3.oploc 
            WHEN t4.oploc_village IS NOT NULL THEN t4.oploc 
            WHEN t1.oploc_street IS NOT NULL THEN t1.oploc 
            WHEN t3.oploc_street IS NOT NULL THEN t3.oploc 
            WHEN t4.oploc_street IS NOT NULL THEN t4.oploc 
            ELSE COALESCE(t1.oploc,t3.oploc,t4.oploc)
            END oploc    --'经营场所'
        ,NULL oplocdistrict    --'经营场所行政区划代码'
        ,CASE WHEN t1.oploc_village IS NOT NULL THEN t1.oploc_street 
            WHEN t3.oploc_village IS NOT NULL THEN t3.oploc_street 
            WHEN t4.oploc_village IS NOT NULL THEN t4.oploc_street 
            ELSE COALESCE(t1.oploc_street,t3.oploc_street,t4.oploc_street)
            END oploc_street    --'经营场所乡镇街道'
        ,COALESCE(t1.oploc_village,t3.oploc_village,t4.oploc_village) oploc_village    --'经营场所村居社区'
        ,COALESCE(t1.opfrom,t3.opfrom) opfrom    --'经营(驻在)期限自'
        ,COALESCE(t1.opto,t3.opto) opto    --'经营(驻在)期限至'
        ,COALESCE(t1.opscope,t3.opscope,t4.opscope) opscope    --'经营范围'
        ,t1.proloc    --'生产经营地'
        ,t1.proloc_street    --'生产地乡镇街道'
        ,t1.proloc_village    --'生产地村居社区'
        ,NULL yiedistrict    --'生产经营地行政代码'
        ,COALESCE(t1.name,t3.lerep,t4.name,t9.fddbr) lerep_name    --'法定代表人'
        ,t1.country_cn    --'国籍名称'
        ,t1.country_code    --'国籍代码'
        ,NULL certype_cn    --'证件类型名称'
        ,NULL certype_code    --'证件类型代码'
        ,NULL cerno    --'身份证件号码'
        ,COALESCE(t1.tel,t3.linkmanphone,t4.linkmanphone,t9.dhhm) tel    --'联系电话'
        ,NULL email    --'电子邮件地址'
        ,COALESCE(t1.regstate,t3.regstate_cn,t4.regstate_cn) regstate    --'状态'--会有空
        ,COALESCE(t3.revdate,t4.revdate) revdate   --'吊销时间'
        ,NULL revdecno    --'吊销处罚文号'
        ,COALESCE(t3.sugrevreason,t4.sugrevreason) AS revbasis    --'吊销原因'
        ,NULL revauth    --'吊照处罚实施机关'
        ,NULL candate    --'注销时间'
        ,NULL canrea_cn    --'注销原因中文'
        ,NULL canrea_code    --'注销原因代码'
        ,t2.xwstate    --'小微企业状态代码'
        ,t2.xwsort_cn    --'小微企业分类名称'
        ,t2.addtime AS xw_addtime    --'加入时间'
        ,t2.remtime AS xw_remtime    --'退出时间'
        ,t2.remreason_cn AS xw_remreason    --'退出原因'
        ,CASE WHEN t3.pripid IS NOT NULL THEN '1' 
            WHEN t4.pripid IS NOT NULL THEN '1'
            ELSE NULL 
        END web_bit   --'互联网监管'
        ,t9.sfwgs AS above_bit    --'规上规下'
        ,t9.nf AS above_year    --'规上年份'
        ,NULL stock_bit    --'上市企业'
        ,NULL stock_name    --'股票名称'
        ,NULL stock_code    --'股票代码'
        ,NULL stock_date    --'上市时间'
        ,NULL stock_address    --'上市交易所'
        ,NULL stock_text    --'简介描述'
        ,t1.sfgzq AS ind_to_ent    --'是否个转企'
        ,t1.sfgzqzx AS ind_to_ent2    --'是否个转企二次转型'
        ,COALESCE(t1.compform,t4.compform_cn) compform   --'个体户组成形式'
        ,COALESCE(t1.regorg,t2.regorgname,t3.regorg_cn,t4.regorg_cn) regorg    --'企业登记机关'
        ,t1.localadm    --'管辖单位代码'
        ,t1.localadm_cn    --'管辖单位名称'
        ,TRIM(REGEXP_REPLACE(
            REGEXP_REPLACE(
                CONCAT_WS(',', 
                    CASE WHEN LENGTH(TRIM(COALESCE(t1.laiyuan,''))) > 0 THEN TRIM(t1.laiyuan) END,
                    CASE WHEN LENGTH(TRIM(COALESCE(t2.laiyuan,''))) > 0 THEN TRIM(t2.laiyuan) END,
                    CASE WHEN LENGTH(TRIM(COALESCE(t3.laiyuan,''))) > 0 THEN TRIM(t3.laiyuan) END,
                    CASE WHEN LENGTH(TRIM(COALESCE(t4.laiyuan,''))) > 0 THEN TRIM(t4.laiyuan) END,
                    CASE WHEN LENGTH(TRIM(COALESCE(t9.laiyuan,''))) > 0 THEN TRIM(t9.laiyuan) END
                ),
                ',{2,}', ','  -- 将多个连续逗号替换为单个逗号
            ),
            '^,+|,+$', ''  -- 去除首尾的逗号
        )) laiyuan    --'合表来源'
FROM    ods_qy_sczt t1    --市场主体
FULL JOIN ods_qy_xwqy t2 ON t2.pripid=t1.pripid  --小微企业
FULL JOIN ods_qy_hlwjg t3 ON t3.pripid=COALESCE(t1.pripid,t2.pripid)  --互联网监管
FULL JOIN ods_ra_sjj_hlwjggtgsh_df t4 ON t4.pripid=COALESCE(t1.pripid,t2.pripid,t3.pripid) --互联网监管个体
FULL JOIN ods_qy_gsgx t9 ON t9.tyshxydm=COALESCE(t1.uniscid,t2.unicode,t3.uniscid,t4.uniscid)  --规上规下
;