--省市回流_企业迁入迁出信息
INSERT OVERWRITE TABLE ods_ra_sjj_qyqrqc_df
SELECT  id    --'ID',
        ,xh    --'序号',
        ,pripid    --'主体身份代码',
        ,uniscid4 AS uniscid    --'统一社会信用代码',
        ,yqymc    --'原企业名称',
        ,yzch    --'原注册号',
        ,qylx    --'企业类型',
        ,qylxdl    --'企业类型大类',
        ,nzsy    --'企业类别',
        ,qyhzrq    --'企业核准日期',
        ,ydjjg    --'原登记机关',
        ,ygxdw    --'原管辖单位',
        ,qcdjjg    --'迁出登记机关',
        ,qcgxdw    --'迁出管辖单位',
        ,moutletnum    --'迁出函号',
        ,qcslr    --'迁出受理人',
        ,qcslsj    --'迁出受理时间',
        ,qcshr    --'迁出审核人',
        ,qcshsj    --'迁出审核时间',
        ,qcdq    --'迁出地区',
        ,qcyj    --'迁出意见',
        ,minletnum    --'迁入函号',
        ,qrslr    --'迁入受理人',
        ,qrslsj    --'迁入受理时间',
        ,qrshr    --'迁入审核人',
        ,qrshsj    --'迁入审核时间',
        ,qrdq    --'迁入地区',
        ,qryj    --'迁入意见',
        ,qrqcbz    --'迁入迁出标志',
        ,qyyy    --'迁移原因',
        ,qylb    --'迁移类别',
        ,qytype    --'迁移类型',
        ,shzt    --'审核状态',
        ,yxbz    --'有效标志',
        ,bz    --'备注',
        ,ywly    --'业务来源'
        ,zcxzabz    --'章程修正案标志',
        ,sjqybz    --'数据迁移标志',
FROM    (
            SELECT  t1.*
                    ,COALESCE(t1.uniscid3,t3.uniscid) uniscid4
                    ,ROW_NUMBER() OVER(PARTITION BY t1.pripid,t1.xh ORDER BY t1.update_time DESC,t1.id DESC,estdate3 DESC) AS rn
            FROM    (
                        SELECT  t1.*
                                ,COALESCE(t1.estdate2,t2.estdate) estdate3
                                ,COALESCE(t1.uniscid2,t2.uniscid) uniscid3
                                ,CASE    WHEN COALESCE(t1.uniscid2,t2.uniscid) IS NULL THEN yqymc 
                                         ELSE NULL 
                                 END entname3    --用于关联
                        FROM    (
                                    SELECT  t1.*
                                            ,COALESCE(t1.estdate,t2.estdate) estdate2
                                            ,COALESCE(t1.uniscid1,t2.uniscid) uniscid2
                                            ,CASE    WHEN COALESCE(t1.uniscid1,t2.uniscid) IS NULL THEN yqymc 
                                                     ELSE NULL 
                                             END entname2    --用于关联
                                    FROM    (
                                                SELECT  t1.*
                                                        ,t2.estdate
                                                        ,COALESCE(t1.uniscid,t2.uniscid) uniscid1
                                                        ,CASE    WHEN COALESCE(t1.uniscid,t2.uniscid) IS NULL THEN yzch 
                                                                 ELSE NULL 
                                                         END regon1    --用于关联
                                                        ,ROW_NUMBER() OVER(PARTITION BY t1.pripid,t1.xh ORDER BY t1.update_time DESC,t1.id DESC) AS rn1
                                                FROM    stg_ra_sjj_qyqrqc_df t1
                                                LEFT JOIN dwd_qy_main2 t2 ON t2.pripid = t1.pripid
                                                WHERE   t1.delflag = '0'
                                            ) t1
                                    LEFT JOIN dwd_qy_main2 t2 ON t2.regno = t1.regon1 AND t2.regno IS NOT NULL
                                    WHERE   t1.rn1 = 1
                                ) t1
                        LEFT JOIN dwd_qy_main2 t2 ON t2.entname = t1.entname2 AND t2.entname IS NOT NULL AND t2.entname NOT LIKE '%*%' AND LENGTH(t2.entname) > 3
                    ) t1
            LEFT JOIN ods_ai_qymc_in t3 ON t3.entname = t1.entname3 AND t3.uniscid IS NOT NULL
        ) 
WHERE   rn = 1
;