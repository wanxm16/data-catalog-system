--省市回流_社会保险个人参保信息(省人力社保厅)
INSERT OVERWRITE TABLE ods_ra_sbj_sbgrcbmx_df
SELECT  id_baz159    --'基准参保关系ID'
        ,grbh_aac001    --'个人编号'
        ,shbzh_aac002    --'社会保障号码'
        ,xm_aac003    --'姓名'
        ,zjxh_aac058    --'证件类型'
        ,zjhm AS zjhm_aac147    --'证件号码'
        ,dwbh_aab001    --'单位编号'
        ,uniscid2 AS uniscid_bab010    --'统一社会信用代码'
        ,entname_aab004    --'单位名称'
        ,xzlx_aae140    --'险种类型'
        ,cbzt_aac008    --'人员参保状态'
        ,jfzt_aac031    --'个人缴费状态'
        ,ksrq_aae030    --'开始日期'
        ,zzrq_aae031    --'终止日期'
        ,xzhf_aab301    --'行政区划代码'
        ,CASE    WHEN rn0=1 THEN '1' 
                 ELSE NULL 
         END new_bit    --'是否最新记录'
FROM    (
            SELECT  t1.*
                    ,COALESCE(t2.uniscid, uniscid1) uniscid2
                    ,ROW_NUMBER() OVER(PARTITION BY id_baz159 ORDER BY COALESCE(t2.estdate, t1.estdate,'9999-12-31') DESC) AS rn
            FROM    (
                        SELECT  t1.*
                                ,COALESCE(t2.uniscid, uniscid0) uniscid1
                                ,t2.estdate
                                ,CASE    WHEN regno1 IS NULL OR t2.uniscid IS NOT NULL THEN NULL 
                                         ELSE t1.entname_aab004 
                                 END entname1    --用于关联
                        FROM    (
                                    SELECT  t0.*
                                            ,CASE    WHEN uniscid0 RLIKE '^[0-9A-HJ-NPQRTUWXY]{2}[0-9]{6}[0-9A-HJ-NPQRTUWXY]{10}$' THEN NULL 
                                                     ELSE uniscid0 
                                             END regno1    --用于关联注册号
                                            ,ROW_NUMBER() OVER(PARTITION BY zjhm,xzlx_aae140,jfzt_aac031 ORDER BY ksrq_aae030 DESC,COALESCE(zzrq_aae031,'99991231') DESC,id_baz159 DESC) AS rn0
                                    FROM    (
                                                SELECT  *
                                                        ,CASE    WHEN zjhm_aac147 RLIKE "^[1-9][0-9]{5}(18|19|20)[0-9]{2}((0[1-9])|10|11|12)(([0-2][1-9])|10|20|30|31)[0-9]{3}[0-9|X|x]$" THEN zjhm_aac147
                                                                 WHEN SUBSTR(zjhm_aac147,1,6)='030381' THEN CONCAT('330381',SUBSTR(zjhm_aac147,6))
                                                                 WHEN SUBSTR(zjhm_aac147,1,6)='030325' THEN CONCAT('330325',SUBSTR(zjhm_aac147,6))
                                                                 WHEN SUBSTR(zjhm_aac147,1,5)='30325' THEN CONCAT('3',zjhm_aac147) 
                                                                 ELSE zjhm_aac147     --除护照，还有错误不好修改
                                                         END zjhm
                                                        ,CASE    WHEN uniscid_bab010 LIKE '%O%' THEN REGEXP_REPLACE(uniscid_bab010,'O','0')
                                                                 WHEN uniscid_bab010='9230381MA2CNDLL8G' THEN '92330381MA2CNDLL8G' 
                                                                 ELSE uniscid_bab010 
                                                         END uniscid0
                                                FROM    stg_ra_sbj_sbgrcbmx_df
                                                WHERE   yxbs_aae100 = '1'
                                                AND     uniscid_bab010 NOT IN ('','11111111','空')
                                            ) t0
                                ) t1
                        LEFT JOIN dwd_qy_main2 t2 ON t2.regno = t1.regno1 AND t2.regno IS NOT NULL
                    ) t1
            LEFT JOIN dwd_qy_main2 t2 ON t2.entname = t1.entname1 AND t2.entname IS NOT NULL AND t2.entname NOT LIKE '%*%' AND LENGTH(t2.entname) > 3
        ) t3
WHERE   rn = 1
;