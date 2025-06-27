INSERT OVERWRITE TABLE ods_qygg_dgjhz1
SELECT  pripid    --'主体身份代码'
        ,lerepsign    --'法定代表人标志'
        ,person_id    --'人员序号'
        ,position_cn    --'职务名称'
        ,position    --'职位代码'
        ,name    --'姓名'
        ,certype_cn    --'证件类型名称'
        ,certype    --'证件类型代码'
        ,cerno    --'身份证件号码'
        ,country_cn    --'国籍名称'
        ,country    --'国籍代码'
        ,dom    --'住所'
FROM    (
            SELECT  *
                    ,row_number() OVER(PARTITION BY pripid ORDER BY update_time DESC,id DESC) AS rn
            FROM    ods_qygg_dgjhz
            WHERE   lerepsign = '1'
        ) t1
WHERE   rn = 1
;