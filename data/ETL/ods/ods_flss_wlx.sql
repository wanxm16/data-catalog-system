--省市回流_企业未履行生效裁判信息
INSERT OVERWRITE TABLE ods_flss_wlx
SELECT  qymc    --'企业名称',
        ,pripid    --'主体身份代码',--部分已有信用码的，没再取内部序号
        ,uniscid    --'统一社会信用代码',
        ,fddbr2 AS fddbr    --'法定代表人',
        ,dwdz    --'单位地址',
        ,zxfy    --'执行法院',
        ,ah    --'案号',
        ,zxyj    --'执行依据',
        ,zxay    --'执行案由',
        ,lxsj    --'履行时间',
        ,ylxje    --'执行金额',
        ,wlxje    --'未执行金额',
        ,gtbzxr    --'共同被执行人',
        ,pgrq    --'曝光日期',
        ,dsc_biz_record_id
        ,dsc_biz_operation
        ,dsc_biz_timestamp
FROM    (
            SELECT  *
                    ,row_number() OVER(PARTITION BY ah, COALESCE(uniscid,qymc) ORDER BY estdate DESC,dsc_biz_timestamp DESC,dsc_biz_record_id DESC) AS rn
            FROM    (
                        SELECT  t1.*
                                ,COALESCE(t2.pripid,t4.pripid) pripid
                                ,COALESCE(tyshxydm1,t2.uniscid,t3.uniscid) uniscid
                                ,COALESCE(fddbr,t2.lerep_name,t4.lerep_name) fddbr2
                                ,COALESCE(t2.estdate,t4.estdate,'9999-12-31') estdate
                        FROM 
                            (
                                SELECT * 
                                    ,CASE WHEN tyshxydm RLIKE '^[0-9A-HJ-NPQRTUWXY]{2}[0-9]{6}[0-9A-HJ-NPQRTUWXY]{10}$' THEN tyshxydm ELSE NULL END tyshxydm1
                                    ,CASE WHEN tyshxydm RLIKE '^[0-9A-HJ-NPQRTUWXY]{2}[0-9]{6}[0-9A-HJ-NPQRTUWXY]{10}$' THEN NULL ELSE qymc END entname1--用于关联
                                FROM    stg_flss_wlx
                                WHERE   dsc_biz_operation IS NULL OR dsc_biz_operation IN('insert','update')
                            ) t1
                        LEFT JOIN dwd_qy_main2 t2 ON t2.entname = t1.entname1 AND t2.entname IS NOT NULL AND t2.entname NOT LIKE '%*%' AND LENGTH(t2.entname)>3
                        LEFT JOIN ods_ai_qymc_in t3 ON t3.entname = t1.entname1 AND t3.uniscid IS NOT NULL
                        LEFT JOIN dwd_qy_main2 t4 ON t4.uniscid = t3.uniscid
                    ) t2 
            WHERE LENGTH(qymc)>3
        ) t3
WHERE   rn = 1
;