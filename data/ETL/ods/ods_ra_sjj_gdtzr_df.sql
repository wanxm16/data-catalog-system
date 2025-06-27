INSERT OVERWRITE TABLE ods_ra_sjj_gdtzr_df
SELECT  pripid    --'主体身份代码'
        ,invid    --'投资人身份标识'
        ,inv    --'姓名（名称）'
        ,invtype_cn    --'股东类型名称'
        ,invtype    --'股东类型代码'--1-法人股东、2-自然人股东、3-其他股东
        ,subconprop    --'认缴出资比例'
        ,subconam    --'认缴出资额'
        ,d2.certype_cn    --'身份证件名称'
        ,certype1 AS certype    --'身份证件代码'--NULL、null
        ,cerno0 AS cerno    --'身份证件号码'--NULL、null
        ,country_cn    --'国籍名称'--null
        ,country    --'国籍代码'--null
        ,exeaffsign    --'执行事务合伙人标志'--NULL、null=>0
        ,asrename    --'委派代表名字'--NULL、null
        ,fddbr    --'执行法定代表人'--NULL、null
        ,asrecerno    --'执行合伙人证件号'--NULL、null
        ,asremobtel    --'执行合伙人联系电话'--NULL、null
FROM    (
            SELECT  *
                    ,CASE    WHEN cerno0 RLIKE '^[0-9A-HJ-NPQRTUWXY]{2}[0-9]{6}[0-9A-HJ-NPQRTUWXY]{10}$' THEN '90'
                             WHEN cerno0 RLIKE "^[1-9][0-9]{5}(18|19|20)[0-9]{2}((0[1-9])|10|11|12)(([0-2][1-9])|10|20|30|31)[0-9]{3}[0-9|X|x]$" THEN '10' 
                             ELSE certype 
                     END certype1
                    ,ROW_NUMBER() OVER(PARTITION BY pripid,cerno0,inv ORDER BY update_time DESC,invid DESC) AS rn
            FROM    (
                        SELECT  *
                                ,CASE    WHEN cerno IS NULL THEN NULL
                                         WHEN cerno RLIKE '^[0-9A-HJ-NPQRTUWXY]{2}[0-9]{6}[0-9A-HJ-NPQRTUWXY]{10}$' THEN cerno    --营业执照
                                         WHEN LENGTH(cerno)=15 AND cerno RLIKE "^[1-9][0-9]{5}[0-9]{2}((0[1-9])|10|11|12)(([0-2][1-9])|10|20|30|31)[0-9]{3}$" THEN ID15To18(cerno)
                                         WHEN certype='10' AND cerno NOT RLIKE "^[1-9][0-9]{5}(18|19|20)[0-9]{2}((0[1-9])|10|11|12)(([0-2][1-9])|10|20|30|31)[0-9]{3}[0-9|X|x]$" THEN NULL 
                                         ELSE cerno 
                                 END cerno0    --'身份证件号码',
                        FROM    (
                                    SELECT  pripid
                                            ,invid
                                            ,inv
                                            ,invtype
                                            ,CASE    WHEN subconprop='null' THEN NULL 
                                                     ELSE subconprop 
                                             END subconprop
                                            ,subconam
                                            ,update_time
                                            ,CASE    WHEN invtype='1' THEN '法人股东'
                                                     WHEN invtype='2' THEN '自然人股东' 
                                                     ELSE '其他股东' 
                                             END invtype_cn
                                            ,CASE    WHEN TOUPPER(certype)='NULL' THEN NULL 
                                                     ELSE certype 
                                             END certype
                                            ,CASE    WHEN TOUPPER(cerno)='NULL' OR TRIM(cerno)='' OR cerno='...............' THEN NULL 
                                                     ELSE FULLTOHALF(TOUPPER(cerno)) 
                                             END cerno
                                            ,CASE    WHEN TOUPPER(country_cn)='NULL' THEN NULL 
                                                     ELSE country_cn 
                                             END country_cn
                                            ,CASE    WHEN TOUPPER(country)='NULL' THEN NULL 
                                                     ELSE country 
                                             END country
                                            ,CASE    WHEN TOUPPER(exeaffsign)='NULL' THEN '0' 
                                                     ELSE exeaffsign 
                                             END exeaffsign
                                            ,CASE    WHEN TOUPPER(asrename)='NULL' THEN NULL 
                                                     ELSE asrename 
                                             END asrename
                                            ,CASE    WHEN TOUPPER(fddbr)='NULL' THEN NULL 
                                                     ELSE fddbr 
                                             END fddbr
                                            ,CASE    WHEN TOUPPER(asrecerno)='NULL' THEN NULL 
                                                     ELSE asrecerno 
                                             END asrecerno
                                            ,CASE    WHEN TOUPPER(asremobtel)='NULL' THEN NULL 
                                                     ELSE asremobtel 
                                             END asremobtel
                                    FROM    stg_ra_sjj_gdtzr_df
                                ) t0
                    ) t1
        ) t2
--LEFT JOIN dict_country_code d1 ON d1.code = t2.country
LEFT JOIN dict_person_cert d2 ON d2.certype = t2.certype1
WHERE t2.rn=1
;