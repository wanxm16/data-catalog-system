--汽车零部件企业工商信息
INSERT OVERWRITE TABLE ods_ra_txz_qmpgsxx_all
SELECT  company_id    --'企业ID'
        ,company_name    --'企业名称'
        ,legal_rep    --'法定代表人'
        ,founded_date    --'成立日期'
        ,registered_capital    --'注册资本'
        ,uniform_code1 AS uniform_code    --'统一社会信用代码'
        ,reg_no    --'工商注册号'
        ,business_term    --'经营期限'
        ,company_type    --'企业类型'
        ,address    --'注册地址'
        ,STATUS    --'经营状态'
        ,audit_date    --'核准日期'
        ,paid_capital    --'实缴资本'
        ,organization_code    --'组织机构代码'
        ,taxpayer_no    --'纳税人识别号'
        ,industry    --'所属行业'
        ,reg_authority    --'登记机关'
        ,version_flag    --'版本号'
        ,introduction    --'简介'
        ,business_scope    --'经营范围'
FROM    (
            SELECT  *
                    ,ROW_NUMBER() OVER(PARTITION BY uniform_code1 ORDER BY id DESC) rn
            FROM    (
                        SELECT  *
                                ,CASE    WHEN uniform_code IS NULL AND reg_no RLIKE '^[0-9A-HJ-NPQRTUWXY]{2}[0-9]{6}[0-9A-HJ-NPQRTUWXY]{10}$' THEN reg_no 
                                         ELSE uniform_code 
                                 END uniform_code1
                        FROM    stg_ra_txz_qmpgsxx_all
                        WHERE   (reg_authority LIKE '%瑞安%' OR company_name LIKE '%瑞安%' OR address LIKE '%瑞安%' OR uniform_code LIKE '__330381%')
                    ) t1
        ) t2
WHERE   rn = 1
;