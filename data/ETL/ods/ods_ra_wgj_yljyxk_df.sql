--省市回流_娱乐经营许可证（歌舞和游艺合表） 
INSERT OVERWRITE TABLE ods_ra_wgj_yljyxk_df
SELECT  *
FROM    (
            SELECT  con_recordid    --'唯一标识'
                    ,permit    --'编号'
                    ,place_name    --'单位名称'
                    ,COALESCE(businesscode1,t2.uniscid) businesscode    --'统一社会信用代码'
                    ,place_address    --'住所地址'
                    ,place_main_manager    --'法定代表人'
                    ,place_manager    --'主要负责人姓名'
                    ,economytype    --'类型'
                    ,place_type    --'场所类型'
                    ,buildarea    --'使用面积'
                    ,mainrange    --'经营范围'
                    ,authdatefirst    --'首次发证日期'
                    ,authdate    --'有效期开始'
                    ,effectdate    --'有效期截止'
                    ,fzrq    --'打证日期'
                    ,certification_department    --'发证机关名称'
                    ,certification_departmentid    --'发证机关行政区划代码'
                    ,certification_departmentcode    --'证照颁发机构代码'
            FROM    (
                        SELECT  *
                                ,CASE    WHEN businesscode RLIKE '^[0-9A-HJ-NPQRTUWXY]{2}[0-9]{6}[0-9A-HJ-NPQRTUWXY]{10}$' THEN businesscode 
                                         ELSE NULL 
                                 END businesscode1
                                ,CASE    WHEN businesscode RLIKE '^[0-9A-HJ-NPQRTUWXY]{2}[0-9]{6}[0-9A-HJ-NPQRTUWXY]{10}$' THEN NULL 
                                         ELSE businesscode 
                                 END regno1    --用于关联
                        FROM    stg_ra_wgj_gwyljyxk_df
                        WHERE   islogout = '否'
                        AND     dsc_biz_operation IN ('insert','update') 
                    ) t1
            LEFT JOIN dwd_qy_main2 t2 ON t2.regno = t1.regno1 AND t2.regno IS NOT NULL
        ) t1
UNION ALL 
SELECT  *
FROM    (
            SELECT  con_recordid    --'唯一标识'
                    ,permit    --'编号'
                    ,place_name    --'单位名称'
                    ,businesscode    --'统一社会信用代码'
                    ,place_address    --'住所地址'
                    ,place_main_manager    --'法定代表人'
                    ,place_manager    --'主要负责人姓名'
                    ,economytype    --'类型'
                    ,place_type    --'场所类型'
                    ,buildarea    --'使用面积'
                    ,mainrange    --'经营范围'
                    ,authdatefirst    --'首次发证日期'
                    ,authdate    --'有效期开始'
                    ,effectdate    --'有效期截止'
                    ,fzrq    --'打证日期'
                    ,certification_department    --'发证机关名称'
                    ,certification_departmentid    --'发证机关行政区划代码'
                    ,certification_departmentcode    --'证照颁发机构代码'
            FROM    stg_ra_wgj_yyyljyxk_df
            WHERE   islogout = '否'
            AND     dsc_biz_operation IN ('insert','update') 
        ) t2
;