--省市回流_全国工业产品生产许可证
INSERT OVERWRITE TABLE ods_ra_sjj_gycpscxk_df
SELECT  certid    --'业务主键'
        ,fzjg    --'发证机关'
        ,fzjg_tyxydm    --'发证机关统一信用代码'
        ,issuedate    --'发证日期'
        ,effectivedate    --'有效期'
        ,companyname    --'企业名称'
        ,orgcode    --'企业统一社会信用代码'
        ,certno    --'证书编号'
        ,STATUS    --'证书状态'
        ,companyaddress    --'住所'
        ,productaddress    --'生产地址'
        ,testmethods    --'检验方式'
        ,productname    --'产品名称'
        ,areacode    --'行政区划代码'
FROM    (
            SELECT  *
                    ,ROW_NUMBER() OVER(PARTITION BY certno ORDER BY effectivedate DESC,issuedate DESC,certid DESC) AS rn
            FROM    stg_ra_sjj_gycpscxk_df
        ) t1
WHERE   rn = 1
;