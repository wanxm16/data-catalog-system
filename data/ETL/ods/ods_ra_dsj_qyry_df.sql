INSERT OVERWRITE TABLE ods_ra_dsj_qyry_df
SELECT  id    --'主键',
        ,corp_nm    --'企业名称',
        ,uscc    --'统一社会信用代码',
        ,cert_no AS glory_cert_no    --'荣誉证书编号/文号',
        ,glory_issue_year    --'荣誉颁发年度',
        ,glory_issue_org    --'荣誉颁发机构',--空字符串重置成null
        ,glory_nm    --'荣誉名称',
        ,glory_level    --'荣誉级别',
        ,glory_content    --'荣誉内容',
        ,glory_cognizance_dt    --'荣誉认定日期',
        ,glory_cert_valid_term_start    --'荣誉证书有效期开始日期',
        ,glory_cert_valid_term_end    --'荣誉证书有效期截止日期',
FROM    (
            SELECT  *
                    ,ROW_NUMBER() OVER(PARTITION BY uscc,cert_no,glory_issue_year,glory_issue_org,glory_nm,glory_level,glory_content,glory_cognizance_dt,glory_cert_valid_term_start,glory_cert_valid_term_end ORDER BY id DESC) AS rn
            FROM    (
                        SELECT  *
                                ,COALESCE(glory_cert_no,glory_cert_doc_no) cert_no
                        FROM    stg_ra_dsj_qyry_df
                        WHERE   uscc RLIKE '^[0-9A-HJ-NPQRTUWXY]{2}[0-9]{6}[0-9A-HJ-NPQRTUWXY]{10}$'
                    ) t1
        ) t2
WHERE   rn = 1
;