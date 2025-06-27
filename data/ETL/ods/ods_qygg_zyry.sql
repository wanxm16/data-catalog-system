--市回流_企业主要人员信息（含董事、监事信息）
INSERT OVERWRITE TABLE ods_qygg_zyry
SELECT  pripid    --'主体身份代码'
        ,person_id    --'人员序号'
        ,d2.name AS position_cn    --'职务名称'
        ,position0 AS position    --'职位代码',
        ,t1.name    --'姓名'
        ,cerno0 AS cerno    --'身份证件号码',
        ,d1.cname AS country_cn    --'国籍名称'
        ,country    --'国籍代码'
FROM    (
            SELECT  *
                    ,CASE    WHEN position IS NULL THEN NULL
                             WHEN position='副总经理' THEN '434R' 
                             ELSE position 
                     END position0    --'职位代码',
                    ,CASE    WHEN cerno='33038198303140922' THEN '330381198303140922'
                             WHEN cerno='33038119905185035' THEN '330381199005185035'
                             WHEN LENGTH(cerno)=15 AND cerno RLIKE "^[1-9][0-9]{5}[0-9]{2}((0[1-9])|10|11|12)(([0-2][1-9])|10|20|30|31)[0-9]{3}$" THEN ID15To18(cerno) 
                             ELSE cerno 
                     END cerno0    --'身份证件号码',
            FROM    stg_qygg_zyry
        ) t1
LEFT JOIN dict_country_code d1 ON d1.code = t1.country
LEFT JOIN dict_position_code d2 ON d2.code = t1.position0
;