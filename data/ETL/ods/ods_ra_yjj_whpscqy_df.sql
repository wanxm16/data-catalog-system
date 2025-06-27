--省市回流_危化品生产企业信息
INSERT OVERWRITE TABLE ods_ra_yjj_whpscqy_df
SELECT  qyid    --'企业标识'
        ,qyname    --'企业名称'
        ,uniscid    --'统一社会信用代码'
        ,zcaddress    --'工商注册地址'
        ,represname    --'法定代表人'
        ,scaddress    --'生产场所地址'
        ,fzrname    --'企业负责人'
        ,qytype    --'单位性质'----都是1，无字典
        ,hxhytype    --'化学行业分类'----IRS上省库有字典
        ,zzaqscglnum    --'专职安全生产管理人员数'
        ,cpgm    --'主要产品及生产规模'
        ,acreage    --'危险化学品库房或仓储'
        ,volume    --'储罐（容器）总容积'
        ,zzaqglnum    --'专职安全管理人员人数'
        ,longitude    --'位置经度'
        ,latitude    --'位置纬度'
        ,businesslicenno    --'工商营业执照编号'
        ,managername    --'经办人'
        ,tel    --'联系电话'
        ,TRIM(fax)    --'传真'
        ,email    --'邮箱'
        ,setuptime    --'成立时间'
        ,productionrange    --'工商营业执照生产范围'
        ,fzrtel    --'企业负责人联系电话'
        ,saferesponsible    --'企业分管安全负责人'
        ,saferesponsibletel    --'企业分管安全负责人联系电话'
        ,economictype1    --'经济类型1'----1农业、2林业、3畜牧业、9有色金属矿采选业、10非金属矿采选业、16烟草制品业
        ,economictype2    --'经济类型2' ----IRS上有但部分匹配不上，需应急部门核对
        ,salesrevenue    --'销售收入'
        ,qygm    --'企业规模'----0.村级 1.乡镇级 2.县级 3.市级 4.省级
        ,industry_code1    --'行业分类及行业代码1'----即字典行业门类，但154不知道IRS上也未是空
        ,industry_code2    --'行业分类及行业代码2'----IRS上有但部分匹配不上，需应急部门核对
        ,industry_code3    --'行业分类及行业代码3'----IRS上有但部分匹配不上，需应急部门核对
        ,industry_code4    --'行业分类及行业代码4'----IRS上有但部分匹配不上，需应急部门核对
        ,aqscgljg    --'安全生产管理机构名称'
        ,aqscgljgpeople    --'安全生产管理机构负责'
        ,TRIM(aqscgljgtel)    --'安全生产管理机构负责'
        ,aqscgljgemail    --'安全生产管理机构负责'
        ,staffnum    --'职工人数'
        ,jdhxpzy    --'剧毒化学品作业人员人'
        ,wxhxpzy    --'危险化学品作业人员人'
        ,tzzy    --'特种作业人员人数'
        ,level    --'安全生产标准化等级'----0-无、1-1级、2-2级、3-3级、4-尚未进行
        ,emergencytel    --'应急咨询服务电话'
        ,dutytel    --'安全值班电话'
        ,isimportdanger    --'是否进口危险化学品'
        ,importenterprisesname    --'进口企业资质证明名称'
        ,importenterprisescode    --'进口企业资质证明编号'
        ,zczb    --'注册资本'
        ,empnum    --'从业人员人数'
        ,isstoragefacilities    --'是否有仓储设施'
        ,websiteurl    --'企业网址'
        ,isindustrialpark    --'是否在工业园区'
        ,CASE    WHEN uniscid='913303007337981871' AND isindustrialpark='1' THEN '瑞安市潘岱化工园区' 
                 ELSE parkname 
         END parkname    --'工业园区名称'
        ,safeproduction    --'安全生产范围'
        ,lockstatus    --'锁定状态'----0-不锁定，1-锁定
FROM    stg_ra_yjj_whpscqy_df
WHERE   isdelete = '0'
AND     dsc_biz_operation IN ('insert','update')
;