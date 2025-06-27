--省市回流_劳务派遣经营许可证
INSERT OVERWRITE TABLE ods_ra_sbj_lwpqjyxk_df
SELECT  bh    --'编号'
        ,dwmc    --'单位名称'
        ,dw_tyxydm    --'单位统一社会信用代码'
        ,zs    --'住所'
        ,fddbr    --'法定代表人'
        ,zczb    --'注册资本'
        ,xkjysx    --'许可经营事项'
        ,yxqx    --'有效期限'
        ,fzrq    --'发证日期'
        ,fzjg    --'发证机关'
        ,fzjg_tyxydm    --'发证机关统一社会信用'
        ,sfzx    --'是否注销'----都是否
        ,arecode    --'行政区划代码'----都是330381
        ,CASE    WHEN rn = 1 THEN 1 
                 ELSE NULL 
         END new_bit
FROM    (
            SELECT  *
                    ,ROW_NUMBER() OVER(PARTITION BY dw_tyxydm ORDER BY fzrq DESC,bh DESC) AS rn
            FROM    stg_ra_sbj_lwpqjyxk_df
        ) t
;