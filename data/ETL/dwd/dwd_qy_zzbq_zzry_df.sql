--企业_资质标签_资质荣誉合表
INSERT OVERWRITE TABLE dwd_qy_zzbq_zzry_df
SELECT  entname    --'企业名称',
        ,uniscid    --'统一社会信用代码',
        ,honor_name    --'荣誉名称',
        ,cert_no    --'证书编号',
        ,honor_level    --'荣誉等级',
        ,year_no    --'公示年度',
        ,issue_date    --'认定日期',
        ,start_date    --'有效开始',
        ,end_date    --'有效截止',
        ,issue_org    --'颁发机构',
        ,from_table    --'来源表',
        ,prop1    --'其他备注1',
        ,prop2    --'其他备注2',
        ,prop3    --'其他备注3'
FROM    (
            SELECT  *
                    ,ROW_NUMBER() OVER(PARTITION BY uniscid,honor_name,year_no ORDER BY sydj,end_date DESC,start_date,issue_date) AS rn
            FROM    (
                        SELECT  corp_nm AS entname,uscc AS uniscid,glory_nm AS honor_name,glory_cert_no AS cert_no,glory_level AS honor_level,glory_issue_year AS year_no
                                ,glory_cognizance_dt AS issue_date,glory_cert_valid_term_start AS start_date,glory_cert_valid_term_end AS end_date,glory_issue_org AS issue_org
                                ,'省市回流_法人库_荣誉信息' from_table,NULL prop1,NULL prop2,NULL prop3,1 sydj
                        FROM    ods_ra_dsj_qyry_df WHERE glory_nm NOT IN ('规上工业企业','专利授权信息')
                        
                        UNION ALL
                        SELECT  entname,uniscid,'高新技术企业' honor_name,cert_no,NULL honor_level,NULL year_no
                                ,NULL issue_date,NULL start_date,NULL end_date,NULL issue_org
                                ,laiyuan AS from_table,NULL prop1,NULL prop2,NULL prop3,2 sydj
                        FROM    dwd_qy_zzry_gxjsqy_df

                        UNION ALL
                        SELECT  enterprisename AS entname,creditcode AS uniscid,'省级科技型中小企业' honor_name,certificateno AS cert_no,NULL honor_level,NULL year_no
                                ,NULL issue_date,NULL start_date,NULL end_date,NULL issue_org
                                ,'省市回流_省级科技型中小企业信息' from_table,NULL prop1,NULL prop2,NULL prop3,2 sydj
                        FROM    ods_ra_kjj_sjkjxxqy_df

                        UNION ALL
                        SELECT  qymc AS entname,uniscid,'温州市市级上云标杆企业' honor_name,NULL cert_no,NULL honor_level,nd AS year_no
                                ,NULL issue_date,NULL start_date,NULL end_date,NULL issue_org
                                ,'市回流_温州市市级上云标杆企业名单信息' from_table,NULL prop1,NULL prop2,NULL prop3,2 sydj
                        FROM    ods_ra_jxj_wzsjsybgqy_df

                        UNION ALL
                        SELECT  nsrmc AS entname,nsrsbh AS uniscid,'温州市年度信用等级评定A级纳税人' honor_name,NULL cert_no,xydj AS honor_level,ssnd AS year_no
                                ,NULL issue_date,NULL start_date,NULL end_date,NULL issue_org
                                ,'市回流_温州市税务局-年度信用等级评定A级纳税人信息' from_table,NULL prop1,NULL prop2,NULL prop3,2 sydj
                        FROM    ods_ra_swj_wzndxypdnsr_df

                        UNION ALL
                        SELECT  fname AS entname,fregno AS uniscid,'守合同重信用企业' honor_name,NULL cert_no,flevel AS honor_level,fyear AS year_no
                                ,fstartdate AS issue_date,fstartdate AS start_date,fenddate AS end_date,NULL issue_org
                                ,'省回流_守合同重信用企业信息' from_table,CONCAT('申报性质：',COALESCE(fapplytype,'')) prop1,NULL prop2,NULL prop3,2 sydj
                        FROM    ods_ra_sjj_shtzxy_df

                        UNION ALL
                        SELECT  mc AS entname,xydm AS uniscid,'浙江省公共信用红名单' honor_name,rdwsh AS cert_no,hmdlx AS honor_level,rdsj AS year_no
                                ,NULL issue_date,NULL start_date,NULL end_date,rd_mc AS issue_org
                                ,'省回流_浙江省公共信用红名单信息' from_table,NULL prop1,NULL prop2,NULL prop3,2 sydj
                        FROM    ods_ra_fgj_sggxyhmd_df

                        UNION ALL
                        SELECT  qymc AS entname,shxydc AS uniscid,'安全生产诚信企业' honor_name,NULL cert_no,pjjg AS honor_level,NULL year_no
                                ,pjsj AS issue_date,NULL start_date,NULL end_date,CONCAT(pjdw,'应急管理局') issue_org
                                ,'省回流-安全生产诚信企业信息' from_table,NULL prop1,NULL prop2,NULL prop3,2 sydj
                        FROM    ods_ra_yjj_aqsccxqy_df

                        UNION ALL
                        SELECT  ent_name,uniscid,honor_name,NULL cert_no,NULL honor_level,year_no
                                ,NULL issue_date,NULL start_date,NULL end_date,NULL issue_org
                                ,'经信局线下导入_荣誉企业清单' from_table,CASE WHEN key_ent IS NOT NULL THEN CONCAT('重点企业：',COALESCE(key_ent,'')) ELSE NULL END prop1,NULL prop2,NULL prop3,3 sydj
                        FROM    ods_imp_jxj_ryqy
                    ) 
        ) 
WHERE   rn = 1
;