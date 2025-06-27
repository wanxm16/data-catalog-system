--省市回流_浙江省劳动人事争议仲裁案件信息
INSERT OVERWRITE TABLE ods_flss_ldzc
SELECT  abb016 AS case_no    --'案件编号',
        ,abb703 AS applicant    --'申请人',
        ,abb704 AS respondent   --'被申请人',--存在多人要分割成多条*****
        ,TRIM(qymc) AS entname --被申请人，从上面字段中分割出来的单体
        ,pripid    --'主体身份代码',
        ,uniscid    --'统一社会信用代码',
        ,abe121 AS isfinal   --'是否一裁终局',
        ,sjldzrs AS worker_num   --'涉及劳动者人数',
        ,bfe043 AS end_reason   --'结案案由',
        ,bfd059 AS end_money   --'结案总金额',
        ,aze505 AS is_apply_law   --'是否申请法律援助',
        ,abb023 AS end_date   --'结案日期',
        ,dsc_biz_record_id
        ,dsc_biz_operation
        ,dsc_biz_timestamp
FROM    (
            SELECT  *
                    ,row_number() OVER(PARTITION BY abb016, abb704, COALESCE(uniscid,TRIM(qymc)) ORDER BY estdate DESC,dsc_biz_timestamp DESC,dsc_biz_record_id DESC) AS rn
            FROM    (
                        SELECT  t1.*
                                ,COALESCE(t2.entname,t4.entname) entname
                                ,COALESCE(t2.pripid,t4.pripid) pripid
                                ,COALESCE(t2.uniscid,t3.uniscid) uniscid
                                ,COALESCE(t2.estdate,t4.estdate) estdate
                        FROM    (
                            SELECT *
                            FROM stg_flss_ldzc
                            LATERAL VIEW explode(split(abb704, ',')) t AS qymc
                            WHERE dsc_biz_operation IN('insert','update')
                        ) t1
                        LEFT JOIN dwd_qy_main2 t2 ON t2.entname = TRIM(t1.qymc) AND t2.entname IS NOT NULL AND t2.entname NOT LIKE '%*%' AND LENGTH(t2.entname)>3
                        LEFT JOIN ods_ai_qymc_in t3 ON t3.entname = TRIM(t1.qymc) AND t3.uniscid IS NOT NULL
                        LEFT JOIN dwd_qy_main2 t4 ON t4.uniscid = t3.uniscid
                        WHERE TRIM(t1.qymc)<>'' AND LENGTH(TRIM(t1.qymc))>3--排除大部分个人
                    ) t2
        ) t3
WHERE   rn = 1
;
