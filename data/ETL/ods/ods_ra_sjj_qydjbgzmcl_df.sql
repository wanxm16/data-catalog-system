--省市回流_企业登记变更证明材料信息
INSERT OVERWRITE TABLE ods_ra_sjj_qydjbgzmcl_df
SELECT  pripid    --'主体身份代码'
        ,alt_id    --'序号'
        ,altitem1 AS altitem    --'变更事项代码'
        ,COALESCE(d1.altitem_name,t2.altitem_cn) altitem_cn    --'变更事项名称'
        ,altbe1 AS altbe    --'变更前内容'
        ,altaf1 AS altaf    --'变更后内容'
        ,altdate    --'变更日期'
        ,dsc_biz_record_id
        ,dsc_biz_timestamp
FROM    (
            SELECT  *
                    ,ROW_NUMBER() OVER(PARTITION BY pripid,altitem1,altbe1,altaf1,altdate ORDER BY dsc_biz_timestamp DESC,dsc_biz_record_id DESC,CAST(alt_id AS INT) DESC) AS rn
            FROM    (
                        SELECT  *
                                ,CASE    WHEN LENGTH(altitem)=1 THEN CONCAT('0',altitem)
                                         WHEN altitem_cn IS NULL AND altaf LIKE '%备案%' THEN '99'
                                         WHEN altitem_cn IS NULL THEN '69' 
                                         ELSE altitem 
                                 END altitem1
                                ,CASE    WHEN TRIM(altbe)='' THEN NULL 
                                         ELSE altbe 
                                 END altbe1
                                ,CASE    WHEN TRIM(altaf)='' THEN NULL 
                                         ELSE altaf 
                                 END altaf1
                        FROM    stg_ra_sjj_qydjbgzmcl_df
                        WHERE   dsc_biz_operation IN ('insert','update')
                    ) t1
            WHERE   altbe1 IS NOT NULL OR altaf1 IS NOT NULL
        ) t2
LEFT JOIN dict_alt_item d1 ON d1.altitem_code=t2.altitem1
WHERE t2.rn=1
;