--省市回流_民办学校办学许可证
INSERT OVERWRITE TABLE ods_ra_jyj_mbxxbxxk_df
SELECT  zjid    --'证件ID',
        ,bxxkzh    --'办学许可证号',
        ,xxmc    --'学校名称',
        ,COALESCE(t1.uniscid1,t2.uniscid) czztdm    --'持证主体代码',
        ,xxdz    --'学校地址',
        ,xz    --'校长',
        ,sfzh    --'身份证号',
        ,xxlx    --'学校类型',
        ,bxnr    --'办学内容',
        ,zgbm    --'主管部门',
        ,fzjg    --'发证机构',
        ,CASE    WHEN LENGTH(fzrq)=8 THEN CONCAT(SUBSTR(fzrq,1,5),'0',SUBSTR(fzrq,6,2),'0',SUBSTR(fzrq,8))
                 WHEN LENGTH(fzrq)=9 AND SUBSTR(fzrq,7,1)='-' THEN CONCAT(SUBSTR(fzrq,1,5),'0',SUBSTR(fzrq,6))
                 WHEN LENGTH(fzrq)=9 THEN CONCAT(SUBSTR(fzrq,1,8),'0',SUBSTR(fzrq,9)) 
                 ELSE fzrq 
         END fzrq    --'发证日期',
        ,CASE    WHEN LENGTH(yxqxq)=8 THEN CONCAT(SUBSTR(yxqxq,1,5),'0',SUBSTR(yxqxq,6,2),'0',SUBSTR(yxqxq,8))
                 WHEN LENGTH(yxqxq)=9 AND SUBSTR(yxqxq,7,1)='-' THEN CONCAT(SUBSTR(yxqxq,1,5),'0',SUBSTR(yxqxq,6))
                 WHEN LENGTH(yxqxq)=9 THEN CONCAT(SUBSTR(yxqxq,1,8),'0',SUBSTR(yxqxq,9)) 
                 ELSE yxqxq 
         END yxqxq    --'有效期限起',
        ,CASE    WHEN LENGTH(yxqxz)=8 THEN CONCAT(SUBSTR(yxqxz,1,5),'0',SUBSTR(yxqxz,6,2),'0',SUBSTR(yxqxz,8))
                 WHEN LENGTH(yxqxz)=9 AND SUBSTR(yxqxz,7,1)='-' THEN CONCAT(SUBSTR(yxqxz,1,5),'0',SUBSTR(yxqxz,6))
                 WHEN LENGTH(yxqxz)=9 THEN CONCAT(SUBSTR(yxqxz,1,8),'0',SUBSTR(yxqxz,9)) 
                 ELSE yxqxz 
         END yxqxz    --'有效期限止',
        ,STATUS    --'证照状态'
FROM    (
            SELECT  *
                    ,CASE    WHEN czztdm RLIKE '^[0-9A-HJ-NPQRTUWXY]{2}[0-9]{6}[0-9A-HJ-NPQRTUWXY]{10}$' THEN czztdm 
                             ELSE NULL 
                     END uniscid1
                    ,CASE    WHEN czztdm RLIKE '^[0-9A-HJ-NPQRTUWXY]{2}[0-9]{6}[0-9A-HJ-NPQRTUWXY]{10}$' THEN NULL 
                             ELSE xxmc 
                     END ent_name1    --用于关联
            FROM    stg_ra_jyj_mbxxbxxk_df
        ) t1
        LEFT JOIN ods_ai_qymc_in t2 ON t2.entname = t1.ent_name1 AND t2.uniscid IS NOT NULL
;