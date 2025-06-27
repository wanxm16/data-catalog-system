--省市回流_药品经营许可证（零售）
INSERT OVERWRITE TABLE ods_ra_ssj_ypjyxk_df
SELECT  corp_name    --'企业名称',
        ,tyxydm    --'持证主体代码',
        ,reg_address    --'注册地址',
        ,storehouse_address    --'仓库地址',
        ,id_no    --'法定代表人身份证号',
        ,legal_person_name    --'法定代表人',
        ,corp_principal_name    --'企业负责人',
        ,quality_principal_name    --'质量负责人',
        ,working_scope_remark    --'经营范围',
        ,license_no    --'许可证编号',
        ,license_valid_to    --'有效期至',
        ,grant_date    --'发证日期',
        ,grant_org    --'发证机关',
        ,CASE    WHEN STATUS='10' THEN '正常' 
                 ELSE STATUS 
         END STATUS    --'状态'
FROM    stg_ra_ssj_ypjyxk_df
WHERE   area_name = '温州市瑞安市'
;