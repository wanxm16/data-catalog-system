--企业关联地址库信息
INSERT OVERWRITE TABLE ods_qy_tydz
SELECT  objectid    --'主键标识'
        ,social_credit_code    --'统一社会信用代码'
        ,tydz_name    --'统一地址详情'
        ,t1.create_time    --'创建时间'
        ,t1.update_time    --'更新数据'
        ,tydz_code    --'统一地址编码'
        ,province    --'所属省份'
        ,city    --'城市名称'
        ,county    --'区县市名称'
        ,town    --'镇街名称'
        ,exclusivezone    --'类行政区划名称'
        ,community    --'社区行政村'
        ,village    --'自然村名称'
        ,street    --'街路巷名称'
        ,door    --'门牌号码'
        ,yard_name    --'院落名称'
        ,yard_alias    --'院落别名'
        ,subarea_name    --'子区名称'
        ,subarea_alias    --'子区别名'
        ,internal_road    --'院内道路名'
        ,internal_door    --'院内门牌号'
        ,building_name    --'建筑名称'
        ,building_alias    --'建筑物别名'
        ,building_path    --'楼幢地址'
        ,building_num    --'楼牌号码'
        ,unit    --'单元门号'
        ,floor_num    --'楼层数量'
        ,floor    --'楼层名称'
        ,house_num    --'户室号码'
        ,lon    --'地图经度'
        ,lat    --'地图纬度'
FROM    (
            SELECT  t0.*
                    ,COALESCE(credit_code,t2.uniscid) credit_code0
                    ,ROW_NUMBER() OVER(PARTITION BY COALESCE(credit_code,t2.uniscid) ORDER BY update_time DESC,create_time DESC,objectid DESC,COALESCE(t2.estdate,'9999-12-31') DESC) AS rn 
            FROM    (
                        SELECT  *
                                ,CASE    WHEN social_credit_code RLIKE '^[0-9A-HJ-NPQRTUWXY]{2}[0-9]{6}[0-9A-HJ-NPQRTUWXY]{10}$' THEN social_credit_code 
                                         ELSE NULL 
                                 END credit_code
                                ,CASE    WHEN social_credit_code RLIKE '^[0-9A-HJ-NPQRTUWXY]{2}[0-9]{6}[0-9A-HJ-NPQRTUWXY]{10}$' THEN NULL 
                                         ELSE social_credit_code 
                                 END regno1    --用于关联
                        FROM    stg_dzk_glqy
                    ) t0
            LEFT JOIN dwd_qy_main2 t2 ON t2.regno = regno1 AND t2.regno IS NOT NULL
        ) t1
LEFT JOIN stg_dzk t2 ON t2.code = t1.tydz_code
WHERE   t1.rn = 1 AND t1.credit_code0 IS NOT NULL
;