INSERT OVERWRITE TABLE ods_qygg_frqt1
SELECT  pripid    --'主体身份代码',
        ,name    --'姓名',
        ,certype_cn    --'证件类型名称',
        ,certype    --'证件类型代码',
        ,cerno    --'身份证件号码',
        ,country_cn    --'国籍名称',
        ,country    --'国籍代码',
        ,email    --'电子邮件地址'
        ,position_cn    --'职务名称',
        ,position    --'职位代码',
FROM    (
            SELECT  *
                    ,row_number() OVER(PARTITION BY pripid ORDER BY dsc_biz_timestamp DESC,dsc_biz_record_id DESC) AS rn
            FROM    ods_qygg_frqt
            WHERE   lerepsign = '1'
        ) t1
WHERE   rn = 1
;