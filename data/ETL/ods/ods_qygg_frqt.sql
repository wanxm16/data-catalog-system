--省市回流_法定代表人信息(法人库用)--含其他高管
INSERT OVERWRITE TABLE ods_qygg_frqt
SELECT  pripid    --'主体身份代码',
        ,lerepsign    --'法定代表人标志',
        ,personid    --'人员序号',
        ,COALESCE(position_cn0, d2.name) position_cn    --'职务名称',
        ,position0 AS position    --'职位代码',
        ,t2.name    --'姓名',
        ,certype_cn    --'证件类型名称',
        ,certype    --'证件类型代码',
        ,cerno0 AS cerno    --'身份证件号码',
        ,COALESCE(country_cn, d1.cname) country_cn   --'国籍名称',
        ,country0 AS country    --'国籍代码',
        ,email0 AS email    --'电子邮件地址'
        ,dsc_biz_record_id
	    ,dsc_biz_operation
	    ,dsc_biz_timestamp
FROM    (
            SELECT  *
            FROM    (
                        SELECT  *
                                ,row_number() OVER(PARTITION BY pripid,lerepsign,position0,cerno0,name ORDER BY dsc_biz_timestamp DESC,dsc_biz_record_id DESC) AS rn
                        FROM    (
                                    SELECT  *
                                            ,CASE    WHEN position='副总经理' THEN '副总经理'
                                                    -- WHEN position_cn IS NULL AND position='434R' THEN '副总经理' 
                                                    -- WHEN position_cn IS NULL AND position='432Q' THEN '执行公司事务的董事' 
                                                     ELSE position_cn 
                                             END position_cn0    --'职务名称',
                                            ,CASE    WHEN position IS NULL THEN NULL
                                                     WHEN position='副总经理' THEN '434R' 
                                                     ELSE position 
                                             END position0    --'职位代码',
                                            ,CASE    WHEN cerno='...............' THEN NULL
                                                     WHEN cerno='330325296902150012' THEN '330325196902150012'
                                                     WHEN cerno='33.325196401213339' THEN '330325196401213339'
                                                     WHEN cerno='330325194401112213..........' THEN '330325194401112213'
                                                     WHEN LENGTH(cerno)=15 AND cerno RLIKE "^[1-9][0-9]{5}[0-9]{2}((0[1-9])|10|11|12)(([0-2][1-9])|10|20|30|31)[0-9]{3}$" THEN ID15To18(cerno)
                                                     WHEN certype='10' AND cerno NOT RLIKE "^[1-9][0-9]{5}(18|19|20)[0-9]{2}((0[1-9])|10|11|12)(([0-2][1-9])|10|20|30|31)[0-9]{3}[0-9|X|x]$" THEN NULL 
                                                     ELSE cerno 
                                             END cerno0    --'身份证件号码',
                                            ,CASE    WHEN country IS NULL OR country='' THEN NULL 
                                                     ELSE country 
                                             END country0    --'国籍代码',
                                            ,CASE    WHEN email IS NULL OR email='' THEN NULL
                                                     WHEN email NOT RLIKE '^[a-zA-Z0-9\\._%+-]+@[a-zA-Z0-9\\.-]+\\.[a-zA-Z]{2,}$' THEN NULL 
                                                     ELSE email 
                                             END email0    --'电子邮件地址',
                                    FROM    stg_qygg_frqt WHERE dsc_biz_operation<>'D'
                                ) t0
                    ) t1
            WHERE   rn = 1
        ) t2
LEFT JOIN dict_country_code d1 ON d1.code = t2.country0
LEFT JOIN dict_position_code d2 ON d2.code = t2.position0
;