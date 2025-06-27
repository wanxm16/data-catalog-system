--省市回流_核准企业董事经理人员信息
INSERT OVERWRITE TABLE ods_qygg_dgjhz
SELECT  pripid    --'主体身份代码'
        ,lerepsign0 AS lerepsign    --'法定代表人标志'
        ,person_id    --'人员序号'
        ,d2.name AS position_cn    --'职务名称'
        ,position0 AS position    --'职位代码'
        ,t2.name    --'姓名'
        ,d3.certype_cn    --'证件类型名称'
        ,t2.certype    --'证件类型代码'
        ,cerno0 AS cerno    --'身份证件号码'
        ,d1.cname AS country_cn    --'国籍名称'
        ,country0 AS country    --'国籍代码'
        ,TRIM(dom)    --'住所'
        ,update_time    --'更新时间'
        ,id --'自增业务主键'
FROM   (
            SELECT  *
            FROM    (
                        SELECT  *
                                ,row_number() OVER(PARTITION BY pripid,position0,cerno0,name ORDER BY update_time DESC,lerepsign0,id DESC) AS rn
                        FROM    (
                                    SELECT  *
                                            ,CASE    WHEN lerepsign IS NULL OR lerepsign in('','0')  THEN '2'
                                                     ELSE lerepsign --1
                                             END lerepsign0    --'法人标识',
                                            ,CASE    WHEN position IS NULL THEN NULL
                                                     WHEN position='副总经理' THEN '434R' 
                                                     ELSE position 
                                             END position0    --'职位代码',
                                            ,CASE    WHEN cerno='...............' THEN NULL
                                                     WHEN cerno='33.325196401213339' THEN '330325196401213339'
                                                     WHEN cerno='330325194401112213..........' THEN '330325194401112213'
                                                     WHEN LENGTH(cerno)=15 AND cerno RLIKE "^[1-9][0-9]{5}[0-9]{2}((0[1-9])|10|11|12)(([0-2][1-9])|10|20|30|31)[0-9]{3}$" THEN ID15To18(cerno)
                                                     WHEN certype='10' AND cerno NOT RLIKE "^[1-9][0-9]{5}(18|19|20)[0-9]{2}((0[1-9])|10|11|12)(([0-2][1-9])|10|20|30|31)[0-9]{3}[0-9|X|x]$" THEN NULL 
                                                     ELSE cerno 
                                             END cerno0    --'身份证件号码',
                                            ,CASE    WHEN country IS NULL OR country='' THEN NULL 
                                                     ELSE country 
                                             END country0    --'国籍代码',
                                    FROM    stg_qygg_dgjhz WHERE delflag='0'
                                ) t0
                    ) t1
            WHERE   rn = 1
        ) t2 
LEFT JOIN dict_country_code d1 ON d1.code = t2.country0
LEFT JOIN dict_position_code d2 ON d2.code = t2.position0
LEFT JOIN dict_person_cert d3 ON d3.certype = t2.certype
;