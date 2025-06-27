--省回流_基础库_法定代表人信息
INSERT OVERWRITE TABLE ods_qygg_frjc
SELECT
        uscc--'统一社会信用代码'
        ,corp_nm--'企业名称'
        ,legal_rep_nm--'法定代表人'
        ,d1.certype AS legal_rep_ident_type_cd--'身份证类型代码'
        ,COALESCE(d1.certype_cn,legal_rep_ident_type) AS legal_rep_ident_type--'身份证类型名称'
        ,legal_rep_ident_no--'身份证件号'
        ,nationality_cd--'国籍代码'
        ,nationality--'国籍名称'
        ,COALESCE(mobile_phone2,fixed_tel2) tel--'联系电话'
        ,email2 AS email--'电子邮件'
        ,CASE WHEN post_cd='' THEN NULL ELSE post_cd END post_cd--'职务代码'
        ,COALESCE(post,d2.name) post--'职务名称'
FROM    (
        SELECT  *
                ,CASE WHEN email1 IS NULL OR email1 NOT RLIKE '^[a-zA-Z0-9\\._%+-]+@[a-zA-Z0-9\\.-]+\\.[a-zA-Z]{2,}$' THEN NULL
                 ELSE email1 END email2
                ,CASE WHEN mobile_phone1 IS NULL OR mobile_phone1 in('','无','0','1','0577','666666666','88888888888','80000000') THEN NULL
                    WHEN mobile_phone1 LIKE '*%' OR mobile_phone1 LIKE '.%' OR mobile_phone1 LIKE '0000%' THEN NULL
                    WHEN mobile_phone1 RLIKE '^[\\x{3400}-\\x{4db5}\\x{4e00}-\\x{9fa5}]+' THEN NULL
                    WHEN mobile_phone1 LIKE '%-%' OR mobile_phone1 RLIKE '^[0-9]+[\\\\][0-9]+$' THEN mobile_phone1 --多号码 或 固定电话
                    WHEN mobile_phone1 LIKE '000%' THEN SUBSTR(mobile_phone1,4)
                    WHEN mobile_phone1 LIKE '01%' AND LENGTH(mobile_phone1)=12 THEN SUBSTR(mobile_phone1,2)--外地手机
                    WHEN mobile_phone1 LIKE '01%' AND LENGTH(mobile_phone1)>10 THEN NULL--手机少位或多位
                    WHEN mobile_phone1 LIKE '0%' AND LENGTH(mobile_phone1)<10 THEN NULL 
                    WHEN mobile_phone1 LIKE '2%' AND LENGTH(mobile_phone1)<>8 THEN NULL  
                    WHEN SUBSTR(mobile_phone1,1,1) IN ('3','7','9') THEN NULL  
                    WHEN mobile_phone1 LIKE '4%' AND  mobile_phone1 NOT LIKE '400%' THEN NULL  
                    WHEN mobile_phone1 LIKE '1%' AND mobile_phone1 NOT RLIKE '^1[0-9]{10}$|^[1-9][0-9]{7}$|^0[0-9]{3}(-)*[0-9]{8}$' THEN NULL 
                    WHEN mobile_phone1 RLIKE '^1[0-9]{10}$|^[1-9][0-9]{7}$|^0[0-9]{3}(-)*[0-9]{8}$' AND substr(mobile_phone1,4,8) REGEXP '(0000000|1111111|2222222|3333333|4444444|5555555|6666666|7777777|8888888|9999999|12345678)' THEN NULL
                    ELSE mobile_phone1--符合的0124和剩余的568
                    END mobile_phone2
                ,CASE WHEN fixed_tel1 IS NULL OR fixed_tel1 in('','无','0','1','0577','666666666','88888888888','80000000') THEN NULL
                    WHEN fixed_tel1 LIKE '*%' OR fixed_tel1 LIKE '.%' OR fixed_tel1 LIKE '0000%' THEN NULL
                    WHEN fixed_tel1 RLIKE '^[\\x{3400}-\\x{4db5}\\x{4e00}-\\x{9fa5}]+' THEN NULL
                    WHEN fixed_tel1 LIKE '%-%' OR fixed_tel1 RLIKE '^[0-9]+[\\\\][0-9]+$' THEN fixed_tel1 --多号码 或 固定电话
                    WHEN fixed_tel1 LIKE '000%' THEN SUBSTR(fixed_tel1,4)
                    WHEN fixed_tel1 LIKE '01%' AND LENGTH(fixed_tel1)=12 THEN SUBSTR(fixed_tel1,2)--外地手机
                    WHEN fixed_tel1 LIKE '01%' AND LENGTH(fixed_tel1)>10 THEN NULL--手机少位或多位
                    WHEN fixed_tel1 LIKE '0%' AND LENGTH(fixed_tel1)<10 THEN NULL 
                    WHEN fixed_tel1 LIKE '2%' AND LENGTH(fixed_tel1)<>8 THEN NULL  
                    WHEN SUBSTR(fixed_tel1,1,1) IN ('3','7','9') THEN NULL  
                    WHEN fixed_tel1 LIKE '4%' AND  fixed_tel1 NOT LIKE '400%' THEN NULL  
                    WHEN fixed_tel1 LIKE '1%' AND fixed_tel1 NOT RLIKE '^1[0-9]{10}$|^[1-9][0-9]{7}$|^0[0-9]{3}(-)*[0-9]{8}$' THEN NULL 
                    WHEN fixed_tel1 RLIKE '^1[0-9]{10}$|^[1-9][0-9]{7}$|^0[0-9]{3}(-)*[0-9]{8}$' AND substr(fixed_tel1,4,8) REGEXP '(0000000|1111111|2222222|3333333|4444444|5555555|6666666|7777777|8888888|9999999|12345678)' THEN NULL
                    ELSE fixed_tel1--符合的0124和剩余的568
                    END fixed_tel2
        FROM    (
                SELECT
                        *
                        ,CASE WHEN legal_rep_ident_type IS NULL OR TRIM(legal_rep_ident_type)='' THEN NULL
                              ELSE legal_rep_ident_type_cd END legal_rep_ident_type_cd1
                        ,CASE WHEN legal_rep_ident_no IS NULL OR legal_rep_ident_no = '' THEN NULL
                              WHEN legal_rep_ident_type IS NULL OR legal_rep_ident_type <> '1011' THEN legal_rep_ident_no
                              WHEN LENGTH(legal_rep_ident_no)=15 AND legal_rep_ident_no RLIKE "^[1-9][0-9]{5}[0-9]{2}((0[1-9])|10|11|12)(([0-2][1-9])|10|20|30|31)[0-9]{3}$" THEN ID15To18(legal_rep_ident_no)
                              WHEN legal_rep_ident_no = '330325296902150012' THEN '330325196902150012'
                              ELSE legal_rep_ident_no END legal_rep_ident_no1
                        ,CASE WHEN email = '' THEN NULL
                              WHEN email LIKE '%。%' THEN REGEXP_REPLACE(email,'。','.')
                              WHEN email LIKE '% %' THEN REGEXP_REPLACE(email,' ','')
                              WHEN email NOT LIKE '%@%' AND email LIKE '%qq.com%' THEN REGEXP_REPLACE(email,'qq.com','@qq.com')
                              ELSE email END email1
                        ,REGEXP_REPLACE(REGEXP_REPLACE(mobile_phone,'[\\.\\/\\s;,#、，　；或]+','\\\\'),'\\\\\\\\','\\\\') mobile_phone1
                        ,REGEXP_REPLACE(REGEXP_REPLACE(fixed_tel,'[\\.\\/\\s;,#、，　；或]+','\\\\'),'\\\\\\\\','\\\\') fixed_tel1
                        ,ROW_NUMBER() OVER(PARTITION BY uscc ORDER BY post_cd DESC,id DESC) AS rn 
                FROM    stg_qygg_frjc
                ) t1    WHERE rn = 1
        ) t2
        LEFT JOIN dict_person_cert d1 ON d1.jckfr_cert = t2.legal_rep_ident_type_cd1 and d1.jckfr_cert<>''
        LEFT JOIN dict_position_code d2 ON d2.code = t2.post_cd
;