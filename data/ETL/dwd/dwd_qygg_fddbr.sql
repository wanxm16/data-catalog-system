INSERT OVERWRITE TABLE dwd_qygg_fddbr
SELECT  COALESCE(t1.pripid,t2.pripid,t3.pripid) pripid    --'主体身份代码',
        ,COALESCE(t1.name,t2.name,t3.legal_rep_nm) name    --'姓名',
        ,COALESCE(t1.certype_cn,t2.certype_cn,t3.legal_rep_ident_type) certype_cn    --'证件类型名称',
        ,COALESCE(t1.certype,t2.certype,t3.legal_rep_ident_type_cd) certype    --'证件类型代码',
        ,COALESCE(t1.cerno,t2.cerno,t3.legal_rep_ident_no) cerno    --'身份证件号码',
        ,COALESCE(t1.country_cn,t2.country_cn,t3.nationality) country_cn    --'国籍名称',
        ,COALESCE(t1.country,t2.country,t3.nationality_cd) country    --'国籍代码',
        ,COALESCE(t3.tel,t4.lxdh) tel    --联系电话
        ,COALESCE(t1.email,t3.email) email   --'电子邮件地址'
        ,t2.dom    --'住所'
        ,COALESCE(t1.position_cn,t2.position_cn,t3.post) position_cn    --'职务名称',
        ,COALESCE(t1.position,t2.position,t3.post_cd) position    --'职位代码',
FROM    ods_qygg_frqt1 t1
FULL JOIN ods_qygg_dgjhz1 t2 ON t2.pripid=t1.pripid
FULL JOIN (
    SELECT t2.pripid,t1.* FROM ods_qygg_frjc t1 
    LEFT JOIN dwd_qy_main1 t2 on t2.uniscid = t1.uscc
    WHERE t2.pripid IS NOT NULL 
) t3 ON t3.pripid=COALESCE(t1.pripid,t2.pripid)
LEFT JOIN stg_ra_dsj_rylxdh_df t4 ON t4.zjhm=COALESCE(t1.cerno,t2.cerno,t3.legal_rep_ident_no) AND t4.dh_tjjb='1'
;