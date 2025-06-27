--省市回流_农药经营许可
INSERT OVERWRITE TABLE ods_ra_nyj_nyjyxk_df
SELECT  xxid    --'信息主键'
        ,xkzbh_varchar1    --'证编号'
        ,entname_varchar2    --'经营者名称'
        ,COALESCE(uniscid1,t4.uniscid) uniscid_varchar10    --'持证者主体代码'----O => 0、空值、330381607041849=>直接用名称也关联的上
        ,jydz_varchar3    --'经营地点'
        ,fddbr_varchar4    --'法定代表人或负责人'
        ,jyfs_varchar5    --'经营方式'
        ,zylsmd AS zylsmd_varchar7    --'直营连锁门店'----空值或无=》置空
        ,yxks_datetime3    --'有效起始期'
        ,yxjz_datetime2    --'有效期至'
        ,fzrq_datetime1    --'发证日期'
        ,fzjg_varchar8    --'发证机关'
        ,fzjgdm_varchar11    --'发证机关统一社会信用'
        ,yxqy_varchar6    --'有效区域'
        ,sfqy    --'是否启用'----1\启用
        ,bz    --'状态备注'
FROM    (
            SELECT  t2.*
                    ,CASE   WHEN uniscid1 IS NOt NULL THEN NULL
                            ELSE entname_varchar2
                     END entname2--用于关联
                    ,ROW_NUMBER() OVER(PARTITION BY xxid,xkzbh_varchar1 ORDER BY estdate DESC) AS rn
            FROM    (
                        SELECT  t1.*
                                ,COALESCE(t2.uniscid, uniscid0) uniscid1
                                ,COALESCE(t2.estdate, '9999-12-31') estdate
                        FROM    (
                                    SELECT  t0.*
                                            ,CASE    WHEN uniscid0 RLIKE '^[0-9A-HJ-NPQRTUWXY]{2}[0-9]{6}[0-9A-HJ-NPQRTUWXY]{10}$' THEN NULL 
                                                     ELSE entname_varchar2 
                                             END entname1    --用于关联
                                    FROM    (
                                                SELECT  *
                                                        ,CASE    WHEN uniscid_varchar10 LIKE '%O%' THEN REGEXP_REPLACE(uniscid_varchar10,'O','0')
                                                                 WHEN entname_varchar2='瑞安市仙降镇新渡桥村杨圣志农资连锁店' THEN '92330381MA2BUUCL40'
                                                                 WHEN TRIM(uniscid_varchar10)='' THEN NULL
                                                                 ELSE uniscid_varchar10 
                                                         END uniscid0
                                                        ,CASE    WHEN zylsmd_varchar7 IN ('','无') THEN NULL 
                                                                 ELSE zylsmd_varchar7 
                                                         END zylsmd
                                                FROM    stg_ra_nyj_nyjyxk_df
                                                WHERE   zt NOT IN ('注销','过期') 
                                                AND     dsc_biz_operation IN ('insert','update')
                                            ) t0
                                ) t1
                        LEFT JOIN dwd_qy_main2 t2 ON t2.entname = t1.entname1 AND t2.entname IS NOT NULL AND t2.entname NOT LIKE '%*%' AND LENGTH(t2.entname) > 3
                    ) t2
        ) t3
LEFT JOIN ods_ai_qymc_in t4 ON t4.entname = t3.entname2 AND t4.uniscid IS NOT NULL
WHERE   rn = 1
;