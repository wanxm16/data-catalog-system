--省市回流_执行案件信息--原表已清理
--只提取了被执行人
INSERT OVERWRITE TABLE ods_ra_fay_zxaj_df
SELECT  dsrmc    --'当事人名称',
        ,zxdw    --'执行地位',
        ,pripid    --'主体身份代码',
        ,uniscid    --'统一社会信用代码',
        ,ajxz    --'案件性质',
        ,qsfy    --'前审法院',
        ,sxcpah    --'生效裁判案号',
        ,ajzt    --'案件状态',
        ,sqzxr    --'申请执行人',
        ,bzxr    --'被执行人',
        ,jarq    --'结案日期',
        ,jafs    --'结案方式',
        ,xxjafs    --'详细结案方式',
        ,yzxbd    --'应执行标的',
        ,dwbd    --'到位标的',
        ,ah    --'案号',
        ,larq    --'立案日期',
        ,zxyj    --'执行依据',
        ,ay    --'案由',
        ,sjay    --'实际案由',
        ,wsbh    --'文书编号',
        ,sanh    --'搜案年号',
        ,zxnr    --'执行内容',
        ,dsc_biz_record_id
        ,dsc_biz_operation
        ,dsc_biz_timestamp
FROM    (
            SELECT  *
                    ,ROW_NUMBER() OVER(PARTITION BY ah, COALESCE(uniscid,dsrmc) ORDER BY estdate DESC,dsc_biz_timestamp DESC,dsc_biz_record_id DESC) AS rn
            FROM    (
                        SELECT  t1.*
                                ,COALESCE(t2.pripid,t4.pripid) pripid
                                ,COALESCE(tyshxydm,t2.uniscid,t3.uniscid) uniscid
                                ,COALESCE(t2.estdate,t4.estdate,'9999-12-31') estdate
                        FROM    (
                                    SELECT  *
                                            ,CASE    WHEN tyshxydm IS NOT NULL THEN NULL 
                                                     ELSE dsrmc 
                                             END entname1    --用于关联
                                    FROM    (
                                                SELECT  *
                                                        ,CASE    WHEN gmsfz RLIKE "^[1-9][0-9]{5}(18|19|20)[0-9]{2}((0[1-9])|10|11|12)(([0-2][1-9])|10|20|30|31)[0-9]{3}[0-9|X|x]$" THEN NULL
                                                                 WHEN gmsfz LIKE '%00000000%' OR gmsfz LIKE '%11111111%' THEN NULL
                                                                 WHEN gmsfz RLIKE '^[0-9A-HJ-NPQRTUWXY]{2}[0-9]{6}[0-9A-HJ-NPQRTUWXY]{10}$' THEN gmsfz 
                                                                 ELSE NULL 
                                                         END tyshxydm
                                                        ,ROW_NUMBER() OVER(PARTITION BY ah, dsrmc ORDER BY jarq DESC,larq,dsc_biz_timestamp DESC,dsc_biz_record_id DESC) AS rn0
                                                FROM    stg_ra_fay_zxaj_df
                                                WHERE   zxdw = '被执行人'
                                                AND     dsc_biz_operation IN('insert','update')
                                            ) t0
                                    WHERE   rn0 = 1
                                    AND     (gmsfz IS NULL OR tyshxydm IS NOT NULL)
                                ) t1
                        LEFT JOIN dwd_qy_main2 t2 ON t2.entname = t1.entname1 AND t2.entname IS NOT NULL AND t2.entname NOT LIKE '%*%' AND LENGTH(t2.entname) > 3 
                        LEFT JOIN ods_ai_qymc_in t3 ON t3.entname = t1.entname1 AND t3.uniscid IS NOT NULL
                        LEFT JOIN dwd_qy_main2 t4 ON t4.uniscid = t3.uniscid
                    ) t2
            WHERE LENGTH(dsrmc)>3 AND dsrmc NOT LIKE '%又名%'
        ) t3
WHERE   rn = 1
;