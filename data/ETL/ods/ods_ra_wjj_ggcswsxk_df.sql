--省市回流_公共场所卫生许可证证照
INSERT OVERWRITE TABLE ods_ra_wjj_ggcswsxk_df
SELECT  uniqueid    --业务主键'
        ,comp_name    --持证者主体名称'
        ,COALESCE(t3.shxydm2,t4.uniscid) chiyourenbm    --持证者主体代码'----有空要通过名称补，小写转大写；排除***非信用码的个体和cess非中文
        ,dzreg_addr    --地址'
        ,principal    --法定代表人'----都有不用补
        ,health_license    --证书编码'
        ,licens_project    --许可项目'
        ,operatedate    --发证日期'
        ,licensestart    --证照有效期起始日期'
        ,licenseend    --证照有效期截止日期'
        ,comp_type    --专业类别'
        ,fzjg    --发证机关'
        ,zi    --年份'
        ,hao    --序号'
        ,fzjgbm    --发证机关统一社会信用'
        ,zjzt1 AS zjzt    --证件状态'
        ,zzmc    --证照名称'
        ,bus_addr_code    --行政区划代码'
FROM    (
            SELECT  t2.*
                    ,CASE   WHEN rn2=1 THEN zjzt
                            ELSE '过期'
                     END zjzt1
                    ,CASE   WHEN shxydm2 IS NOt NULL THEN NULL
                            ELSE comp_name
                     END entname2--用于关联
                    ,ROW_NUMBER() OVER(PARTITION BY health_license,uniqueid ORDER BY estdate DESC) AS rn
            FROM    (
                        SELECT  t1.*
                                ,COALESCE(t1.shxydm1,t2.uniscid) shxydm2
                                ,COALESCE(t2.estdate,'9999-12-31') estdate
                                ,ROW_NUMBER() OVER(PARTITION BY health_license ORDER BY licenseend DESC,licensestart DESC) AS rn2
                        FROM    (
                                    SELECT  *
                                            ,CASE   WHEN chiyourenbm RLIKE '^[0-9A-HJ-NPQRTUWXY]{2}[0-9]{6}[0-9A-HJ-NPQRTUWXY]{10}$' THEN chiyourenbm
                                                    WHEN comp_name LIKE '%*%' OR comp_name NOT RLIKE '[\\x{3400}-\\x{4db5}\\x{4e00}-\\x{9fa5}]+' THEN 'delete' 
                                                    ELSE NULL 
                                            END shxydm1
                                            ,CASE   WHEN chiyourenbm RLIKE '^[0-9A-HJ-NPQRTUWXY]{2}[0-9]{6}[0-9A-HJ-NPQRTUWXY]{10}$' THEN NULL 
                                                    ELSE comp_name 
                                            END entname1    --用于关联
                                            ,ROW_NUMBER() OVER(PARTITION BY health_license,licenseend,licensestart ORDER BY operatedate DESC,uniqueid DESC) AS rn1
                                    FROM    stg_ra_wjj_ggcswsxk_df
                                    WHERE   zjzt <> '注销'
                                ) t1
                        LEFT JOIN dwd_qy_main2 t2 ON t2.entname = t1.entname1 AND t2.entname IS NOT NULL AND t2.entname NOT LIKE '%*%' AND LENGTH(t2.entname)>3
                        WHERE t1.rn1=1 AND (shxydm1 IS NULL OR shxydm1<>'delete')
                    ) t2
        ) t3
LEFT JOIN ods_ai_qymc_in t4 ON t4.entname = t3.entname2 AND t4.uniscid IS NOT NULL
WHERE   t3.rn = 1
;