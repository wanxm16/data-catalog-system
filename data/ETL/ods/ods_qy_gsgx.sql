--省市回流_规上、规下工业企业清单信息
INSERT OVERWRITE TABLE ods_qy_gsgx
SELECT  tyshxydm    --'统一社会信用代码',
        ,zzjgdm    --'组织机构代码',
        ,jgmc    --'机构名称',
        ,d2.name AS industryphy_cn    --'行业门类名称',
        ,industryphy    --'行业门类代码',
        ,industryco_cn    --'行业名称',
        ,industryco    --'行业代码',
        ,jgdz    --'机构地址',
        ,dom_street    --'归属乡镇街道',
        ,dom_village    --'归属村居社区',
        ,fddbr    --'法定代表人',
        ,dhhm    --'联系电话',
        ,sfwgs    --'是否为规上',
        ,nf    --'年份'
        ,'规上规下' laiyuan
FROM    (
            SELECT  tyshxydm    --'统一社会信用代码',
                    ,zzjgdm    --'组织机构代码',
                    ,jgmc    --'机构名称',
                    ,NULL industryphy_cn    --'行业门类名称',
                    ,COALESCE(industryphy, d1.ml) industryphy    --'行业门类代码',
                    ,COALESCE(d1.content, industryco_cn) industryco_cn    --'行业名称',
                    ,industryco    --'行业代码',
                    ,dom1 AS jgdz    --'机构地址',
                    ,dom_street    --'归属乡镇街道',
                    -- 从地址中提取村居社区：匹配"XX社区"、"XX村"、"XX居委会"等
                    ,CASE WHEN dom1 RLIKE '([^市区县]{2,8})(社区|村|居委会|委员会)' 
                          THEN regexp_extract(dom1, '([^市区县]{2,8})(社区|村|居委会|委员会)', 1) 
                          ELSE NULL END dom_village    --'归属村居社区',
                    ,fddbr    --'法定代表人',
                    ,CASE    WHEN dhhm2 IS NULL OR dhhm2='' THEN NULL
                             WHEN dhhm2 LIKE '1%' AND dhhm2 NOT RLIKE '^1[0-9]{10}$|^[1-9][0-9]{7}$|^0[0-9]{3}(-)*[0-9]{8}$' THEN NULL 
                             ELSE dhhm2 
                     END dhhm    --'联系电话',
                    ,CASE    WHEN sfwgs IS NULL OR sfwgs<>'1' THEN '0'
                             ELSE sfwgs 
                     END sfwgs    --'是否为规上',
                    ,nf    --'年份'
            FROM    (
                        SELECT  *
                                ,TRIM(dhhm1) dhhm2
                                -- 从地址中提取乡镇街道：匹配"XX街道"、"XX镇"、"XX乡"等
                                ,CASE WHEN dom1 RLIKE '([^市区县]{2,8})(街道|镇|乡|开发区|园区)' 
                                      THEN regexp_extract(dom1, '([^市区县]{2,8})(街道|镇|乡|开发区|园区)', 1) 
                                      ELSE NULL END dom_street
                                ,CASE    WHEN industryphy1='X' THEN 'K' 
                                         ELSE industryphy1 
                                 END industryphy
                                ,CASE    WHEN industryco1='3261' THEN '3251'    --铜压延加工
                                         WHEN industryco1='3262' THEN '3252'    --铝压延加工
                                         WHEN industryco1='3263' THEN '3253'    --贵金属压延加工
                                         WHEN industryco1='3269' THEN '3259'    --其他有色金属压延加工
                                         WHEN industryco1='3468' THEN '3467'    --包装专用设备制造
                                         WHEN industryco1='4042' THEN '3920'     --计算机网络设备制造==>通信设备制造
                                         ELSE industryco1 
                                 END industryco
                                ,CASE    WHEN hyfl NOT RLIKE '^[0-9A-Z]+$' THEN hyfl 
                                         ELSE NULL 
                                 END industryco_cn
                        FROM    (
                                    SELECT  *
                                            -- 地址词汇纠正：去除多余空格和特殊字符
                                            ,TRIM(REGEXP_REPLACE(COALESCE(jgdz,''), '[\\s　]+', '')) dom1
                                            -- 全角转半角并去除中文字符
                                            ,REGEXP_REPLACE(REGEXP_REPLACE(COALESCE(dhhm,''), '[０-９]+', 
                                                REGEXP_REPLACE(REGEXP_REPLACE(REGEXP_REPLACE(REGEXP_REPLACE(REGEXP_REPLACE(
                                                REGEXP_REPLACE(REGEXP_REPLACE(REGEXP_REPLACE(REGEXP_REPLACE(REGEXP_REPLACE(
                                                COALESCE(dhhm,''), '０', '0'), '１', '1'), '２', '2'), '３', '3'), '４', '4'),
                                                '５', '5'), '６', '6'), '７', '7'), '８', '8'), '９', '9')),
                                                '[\\x{3400}-\\x{4db5}\\x{4e00}-\\x{9fa5}]+','') dhhm1--'联系电话',
                                            ,CASE    WHEN hyfl RLIKE '^[0-9A-Z]$' THEN hyfl 
                                                     ELSE NULL 
                                             END industryphy1
                                            ,CASE    WHEN hydm IS NOT NULL AND TRIM(hydm)<>'' THEN TRIM(hydm)
                                                     WHEN hyfl RLIKE '^[0-9]{4}$' THEN hyfl 
                                                     ELSE NULL 
                                             END industryco1
                                            ,row_number() OVER(PARTITION BY tyshxydm ORDER BY nf DESC,dsc_biz_timestamp DESC,dsc_biz_record_id DESC) AS rn
                                    FROM    stg_qy_gsgx WHERE dsc_biz_operation IS NULL
                                ) t1
                        WHERE   rn = 1
                    ) t2
                    LEFT JOIN dict_industry_code d1 ON d1.code = t2.industryco
        ) t3
        LEFT JOIN dict_industry_category d2 ON d2.code = t3.industryphy
;