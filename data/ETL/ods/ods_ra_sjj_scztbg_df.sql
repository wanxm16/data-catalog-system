--省市回流_市场主体变更对比信息
INSERT OVERWRITE TABLE ods_ra_sjj_scztbg_df
SELECT  pripid    --'主体身份代码'
        ,alt_id    --'序号'
        ,altitem2 AS altitem    --'变更事项代码'
        ,altitem_cn    --'变更事项名称'
        ,altbe1 AS altbe    --'变更前内容'
        ,altaf1 AS altaf    --'变更后内容'
        ,altdate    --'变更日期'
        ,dsc_biz_record_id
        ,dsc_biz_timestamp
FROM    (
            SELECT  *
                    ,ROW_NUMBER() OVER(PARTITION BY pripid,altitem2,altbe1,altaf1,altdate ORDER BY dsc_biz_timestamp DESC,dsc_biz_record_id DESC,CAST(alt_id AS INT) DESC) AS rn
            FROM    (
                        SELECT  t1.*
                                ,CASE    WHEN d1.altitem_name IS NOT NULL THEN d1.altitem_name
                                         WHEN altaf1 LIKE '%备案%' THEN '其他事项备案' 
                                         ELSE '其他变更' 
                                 END altitem_cn
                                ,CASE    WHEN d1.altitem_name IS NOT NULL THEN altitem1
                                         WHEN altaf1 LIKE '%备案%' THEN '99' 
                                         ELSE '69' 
                                 END altitem2
                        FROM    (
                                    SELECT  *
                                            ,CASE    WHEN LENGTH(altitem)=1 THEN CONCAT('0',altitem) 
                                                     ELSE altitem 
                                             END altitem1
                                            ,CASE    WHEN TRIM(altbe)='' THEN NULL 
                                                     ELSE altbe 
                                             END altbe1
                                            ,CASE    WHEN TRIM(altaf)='' THEN NULL 
                                                     ELSE altaf 
                                             END altaf1
                                    FROM    stg_ra_sjj_scztbg_df
                                    WHERE   dsc_biz_operation IN ('insert','update')
                                ) t1
                        LEFT JOIN dict_alt_item d1 ON d1.altitem_code = t1.altitem1
                        WHERE altbe1 IS NOT NULL OR altaf1 IS NOT NULL
                    ) t2
        ) t3
WHERE   t3.rn = 1
;