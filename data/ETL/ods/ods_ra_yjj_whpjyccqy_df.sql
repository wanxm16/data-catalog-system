--省市回流_危险化学品经营（带储存）企业信息
INSERT OVERWRITE TABLE ods_ra_yjj_whpjyccqy_df
SELECT  objectid    --'ID'
        ,enterprisename    --'企业名称'
        ,socialcredit    --'统一社会信用代码'
        ,setuptime    --'成立时间'
        ,regaddress    --'具体地址（工商注册）'
        ,stoaddress    --'具体地址（生产储存）'----N
        ,legalrepresentative    --'法定代表人'
        ,safetybizcertifno    --'安全经营许可证编号'
        ,safetybizcertifst    --'安全经营许可证有效开'
        ,safetybizcertifet    --'安全经营许可证有效结'
        ,businessscope    --'核准经营范围'
        ,safetyusecertifno    --'安全使用许可证编号'----N
        ,safetyusecertifst    --'安全使用许可证有效开'----N
        ,safetyusecertifet    --'安全使用许可证有效结'----N
        ,satetyusescope    --'安全使用许可证许可范'----N
        ,headname    --'主要负责人姓名'
        ,headtel    --'主要负责人电话'
        ,safetyheadname    --'安全负责人姓名'
        ,safetyheadtel    --'安全负责人电话'
        ,staffnum    --'职工人数'
        ,tankareanum    --'罐区总数量'
        ,tankareacubage    --'罐区储罐总容积'
        ,warehousenum    --'仓库总数量'
        ,warehousecubage    --'仓库总容积'
        ,facilitiescondition    --'周边1000米范围内单位或设施情况'
        ,longitude    --'经度'
        ,latitude    --'纬度'
        ,industryclass    --'化工行业分类'      ----IRS字典
        ,industrycode1    --'行业分类及行业代码1'----IRS字典
        ,industrycode2    --'行业分类及行业代码2'----IRS字典
        ,industrycode3    --'行业分类及行业代码3'----IRS字典
        ,industrycode4    --'行业分类及行业代码4'----IRS字典
        ,enterprisetype    --'企业类型2'----S-危化品经营（带存储）企业
        ,saleentertype    --'企业类型1'----全空，也无字典
        ,saletype    --'经营类型'----全空，也无字典
FROM    stg_ra_yjj_whpjyccqy_df
WHERE   dsc_biz_operation IN ('insert','update')
;