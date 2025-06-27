--省市回流_小微企业基本信息（包含个体户）
INSERT OVERWRITE TABLE ods_qy_xwqy
SELECT  pripid    --'主体身份代码',
        ,unicode    --'统一社会信用代码',
        ,regno    --'注册号',
        ,entname    --'企业名称',
        ,enttype_name    --'市场主体类型名称',
        ,enttype_code    --'市场主体类型代码',
        ,industryphy_cn    --'行业门类名称',
        ,industryphy    --'行业门类代码',
        ,industryco_cn    --'行业名称',
        ,industryco    --'行业代码',
        ,estdate    --'成立日期',
        ,regcap    --'注册资本',
        ,addtime    --'加入时间',
        ,xwstate    --'小微企业状态代码',
        ,xwsort_cn    --'小微企业分类名称',
        ,remtime    --'退出时间',
        ,remreason_cn    --'退出原因',
        ,regorgname    --'企业登记机关名称'
        ,'小微企业' laiyuan
FROM    ods_qy_xwqy_all 
WHERE   regorg LIKE '330381%' OR entname LIKE '%瑞安%'
;