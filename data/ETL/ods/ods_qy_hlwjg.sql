--省回流_“互联网+监管”企业基本信息
INSERT OVERWRITE TABLE ods_qy_hlwjg
SELECT  pripid    --'主体身份代码',
        ,uniscid    --'统一社会信用代码',
        ,regno    --'注册号',
        ,entname    --'企业名称',
        ,enttype_cn    --'企业类型名称',
        ,enttype    --'企业类型代码',
        ,industryphy_cn    --'行业门类名称',
        ,industry_category    --'行业门类代码',
        ,industryco_cn    --'行业名称',
        ,national_economy    --'行业代码',
        ,estdate    --'成立日期',
        ,apprdate    --'核准日期',
        ,regcap    --'注册资本/注册资金',
        ,currency_cn    --'注册资本币种',
        ,dom    --'注册地址',
        ,dom_street    --'归属乡镇街道'
        ,dom_village    --'归属村居社区'
        ,oploc    --'营业场所/主要经营场',
        ,oploc_street   --'经营场所乡镇街道'
        ,oploc_village  --'经营场所村居社区'
        ,opfrom    --'经营期限自/营业期限',
        ,opto    --'经营期限至/营业期限',
        ,opscope    --'经营范围',
        ,lerep    --'法定代表人/负责人',
        ,linkmanphone    --'联络员手机号码',--全空
        ,regstate_cn    --'登记状态名称',
        ,revdate    --'吊销日期',
        ,sugrevreason    --'吊销原因',
        ,regorg_cn    --'登记机关名称'
        ,'互联网监管' laiyuan
FROM    ods_qy_hlwjg_all
WHERE   regorg LIKE '330381%' OR entname LIKE '%瑞安%' OR dom LIKE '%瑞安%' OR oploc LIKE '%瑞安%'
;