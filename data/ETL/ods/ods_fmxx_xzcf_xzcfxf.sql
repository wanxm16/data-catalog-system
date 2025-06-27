--省市回流_行政处罚信息（消防）
INSERT OVERWRITE TABLE ods_fmxx_xzcf_xzcfxf
SELECT  id    --'数据ID'
        ,bcfdx    --'被处罚当事人（单位）'
        ,COALESCE(shxydm2,t4.uniscid) shxydm    --'统一社会信用代码'
        ,zzjgdm    --'组织机构代码'
        ,cfwh    --'处罚文号'
        ,cfmc    --'处罚名称'
        ,sxmc    --'处罚名称（事项）'
        ,wfss    --'违法事实'
        ,cfyj    --'处罚依据'
        ,cfrq    --'处罚日期'
        ,cfjg    --'处罚机关'
        ,cfzl    --'处罚种类'----11：警告 21：罚款 31：责令三停 34：吊销响应资质、资格 41：行政拘留 99：其他
        ,zlstwh    --'责令三停文号'
        ,zlstnr    --'责令三停内容'----责令“停止施工、停止使用、停产停业”
        ,zxqk    --'执行情况'
        ,bbh    --'信息版本号'
FROM    (
                SELECT  *
                        ,CASE   WHEN shxydm2 IS NOT NULL THEN NULL
                                ELSE bcfdx 
                        END entname2--用于关联
                        ,row_number() OVER(PARTITION BY cfwh,id ORDER BY estdate DESC,dsc_biz_timestamp DESC,dsc_biz_record_id DESC) AS rn
                FROM    (
                            SELECT  t1.*
                                    ,COALESCE(t1.shxydm1,t2.uniscid) shxydm2
                                    ,COALESCE(t2.estdate,'9999-12-31') estdate
                            FROM    (
                                        SELECT  *
                                                ,CASE   WHEN shxydm1 IS NOT NULL THEN NULL
                                                        ELSE bcfdx 
                                                END entname1--用于关联
                                        FROM    (
                                                    SELECT  *
                                                            ,CASE   WHEN shxydm IS NULL OR shxydm='' THEN NULL
                                                                    WHEN shxydm NOT RLIKE '^[0-9A-HJ-NPQRTUWXY]{2}[0-9]{6}[0-9A-HJ-NPQRTUWXY]{10}$' THEN REGEXP_REPLACE(REGEXP_REPLACE(shxydm,'I','1'),'O','0') 
                                                                    ELSE shxydm 
                                                            END shxydm1
                                                            ,row_number() OVER(PARTITION BY cfwh,id ORDER BY bbh DESC,dsc_biz_timestamp DESC,dsc_biz_record_id DESC) AS rn0
                                                    FROM    stg_fmxx_xzcf_xzcfxf
                                                    WHERE   dxfl = '1'
                                                    AND     ztbj = '0' AND dsc_biz_operation IN ('insert','update')
                                                ) t0
                                        WHERE   t0.rn0 = 1
                                    ) t1
                            LEFT JOIN dwd_qy_main2 t2 ON t2.entname = t1.entname1 AND t2.entname IS NOT NULL AND t2.entname NOT LIKE '%*%' AND LENGTH(t2.entname)>3
                        ) t2
        ) t3
LEFT JOIN ods_ai_qymc_in t4 ON t4.entname = t3.entname2 AND t4.uniscid IS NOT NULL
WHERE t3.rn = 1
;