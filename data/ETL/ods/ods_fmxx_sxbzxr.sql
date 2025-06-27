--省市回流_失信被执行人信息
INSERT OVERWRITE TABLE ods_fmxx_sxbzxr
SELECT  sxid    --'失信ID'
        ,bzxrmc    --'被执行人姓名/名称'
        ,shxydm3 AS uniscid --'统一社会信用代码',
        ,zzjgdm1 AS zzjgdm    --'组织机构代码' ----先信用码再名称
        ,fddbr2 AS fddbr    --'法定代表人或者负责人'
        ,fydm    --'法院代码'
        ,zxfy    --'执行法院'
        ,zxyjwh    --'执行依据文号'
        ,larq    --'立案时间'
        ,ah    --'案号'
        ,zczxyjdw    --'做出执行依据单位'
        ,sxflwsqdyw    --'生效法律文书确定的义'
        ,bzxrlxqk    --'被执行人的履行情况'
        ,fbrq    --'发布时间'
        ,sanh    --'搜案年号'
        ,sabh    --'搜案编号'
        ,bzxrxh    --'被执行人序号'
        ,ylxbf    --'已履行部分'
        ,wlxbf    --'未履行部分'
        ,sxbzxrxwqk    --'失信被执行人行为情况'
        ,biz_time
FROM    (
    SELECT  t3.*
            ,COALESCE(t3.shxydm2,t4.uniscid) shxydm3
            ,row_number() OVER(PARTITION BY ah,COALESCE(t3.shxydm2,t4.uniscid,bzxrmc) ORDER BY estdate DESC,dsc_biz_timestamp DESC,dsc_biz_record_id DESC) AS rn
    FROM    (
            SELECT  t2.*
                    ,CASE   WHEN shxydm2 IS NOt NULL THEN NULL
                            ELSE bzxrmc
                     END entname2--用于关联
                    ,row_number() OVER(PARTITION BY ah,bzxrmc,zzjgdm ORDER BY estdate DESC,dsc_biz_timestamp DESC,dsc_biz_record_id DESC) AS rn2
            FROM    (
                        SELECT  t1.*
                                ,COALESCE(t1.shxydm1,t2.uniscid) shxydm2
                                ,COALESCE(fddbr,t2.lerep_name) fddbr2
                                ,COALESCE(t2.estdate,'9999-12-31') estdate
                        FROM    (
                                    SELECT  *
                                            ,CASE    WHEN zzjgdm RLIKE '^[0-9A-HJ-NPQRTUWXY]{2}[0-9]{6}[0-9A-HJ-NPQRTUWXY]{10}$' THEN NULL
                                                     ELSE zzjgdm 
                                             END zzjgdm1
                                            ,CASE    WHEN zzjgdm RLIKE '^[0-9A-HJ-NPQRTUWXY]{2}[0-9]{6}[0-9A-HJ-NPQRTUWXY]{10}$' THEN zzjgdm
                                                     ELSE NULL 
                                             END shxydm1
                                            ,CASE    WHEN zzjgdm RLIKE '^[0-9A-HJ-NPQRTUWXY]{2}[0-9]{6}[0-9A-HJ-NPQRTUWXY]{10}$' THEN NULL
                                                     ELSE bzxrmc 
                                             END entname1--用于关联
                                    FROM    stg_fmxx_sxbzxr
                                    WHERE   bzxrxz='组织'
                                    AND     dsc_biz_operation IN ('insert','update')
                                ) t1
                        LEFT JOIN dwd_qy_main2 t2 ON t2.entname = t1.entname1 AND t2.entname IS NOT NULL AND t2.entname NOT LIKE '%*%' AND LENGTH(t2.entname)>3
                    ) t2
        ) t3
    LEFT JOIN ods_ai_qymc_in t4 ON t4.entname = t3.entname2 AND t4.uniscid IS NOT NULL
    WHERE   t3.rn2 = 1
)t  WHERE   rn = 1
;