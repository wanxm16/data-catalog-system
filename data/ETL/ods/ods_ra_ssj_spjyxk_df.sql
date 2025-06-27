--省市回流_食品经营库食品经营许可信息
INSERT OVERWRITE TABLE ods_ra_ssj_spjyxk_df
SELECT  uniqueid--'业务主键',
        ,entname--'经营者名称',
        ,CASE WHEN uniscid3 IS NOT NULL THEN uniscid3
              WHEN is_card =1 AND entname = leper THEN uniscid 
              ELSE NULL 
         END uniscid--'统一社会信用代码（身份证号码）',
        ,leper--'法定代表人（负责人）',
        ,zs--'住所',
        ,lopoc--'经营场所',
        ,maintype--'主体业态',
        ,licscope--'经营许可项目',
        ,licno--'许可证编号',
        ,licname--'许可证名称',
        ,fzrq--'发证日期',
        ,qsrq--'有效期起',
        ,jzrq--'有效期止',
        ,opstate--'证书状态',
        ,fzjg --'发证机关',
        ,supregorg--'日常监督管理机构'
FROM    (
            SELECT  t2.*
                    ,COALESCE(t2.uniscid2,t3.uniscid) uniscid3
                    ,ROW_NUMBER() OVER(PARTITION BY t2.uniqueid,t2.licno ORDER BY t2.fzrq DESC,t2.jzrq DESC,t2.qsrq,t2.estdate DESC) AS rn
            FROM    (
                        SELECT  t1.*
                                ,t2.estdate
                                ,COALESCE(t1.uniscid1,t2.uniscid) uniscid2
                                ,CASE    WHEN COALESCE(t1.uniscid1,t2.uniscid) IS NULL THEN t1.entname 
                                         ELSE NULL 
                                 END ent_name2    --用于关联
                        FROM    (
                                    SELECT  *
                                            ,CASE    WHEN uniscid RLIKE '^[1-9][0-9]{5}(18|19|20)[0-9]{2}((0[1-9])|10|11|12)(([0-2][1-9])|10|20|30|31)[0-9]{3}[0-9|X|x]$' THEN NULL
                                                     WHEN uniscid RLIKE '^[0-9A-HJ-NPQRTUWXY]{2}[0-9]{6}[0-9A-HJ-NPQRTUWXY]{10}$' THEN uniscid 
                                                     ELSE NULL 
                                             END uniscid1
                                            ,CASE    WHEN uniscid RLIKE '^[1-9][0-9]{5}(18|19|20)[0-9]{2}((0[1-9])|10|11|12)(([0-2][1-9])|10|20|30|31)[0-9]{3}[0-9|X|x]$' THEN 1 
                                                     ELSE 0 
                                             END is_card    --是否身份证
                                            ,CASE    WHEN uniscid RLIKE '^[1-9][0-9]{5}(18|19|20)[0-9]{2}((0[1-9])|10|11|12)(([0-2][1-9])|10|20|30|31)[0-9]{3}[0-9|X|x]$' THEN entname
                                                     WHEN uniscid RLIKE '^[0-9A-HJ-NPQRTUWXY]{2}[0-9]{6}[0-9A-HJ-NPQRTUWXY]{10}$' THEN NULL 
                                                     ELSE entname 
                                             END ent_name1    --用于关联
                                    FROM    stg_ra_ssj_spjyxk_df
                                ) t1
                        LEFT JOIN dwd_qy_main2 t2 ON t2.entname = t1.ent_name1 AND t2.entname IS NOT NULL AND t2.entname NOT LIKE '%*%' AND LENGTH(t2.entname) > 3
                    ) t2
            LEFT JOIN ods_ai_qymc_in t3 ON t3.entname = t2.ent_name2 AND t3.uniscid IS NOT NULL
        ) t3
WHERE   rn = 1
;