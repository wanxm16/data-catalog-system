--省市回流_法院判决书信息
INSERT OVERWRITE TABLE ods_ra_fay_fypjs_df
SELECT  ah    --'案号'
        ,ahdm    --'案号代码'
        ,wsmc    --'文书名称'
        ,fzjg    --'发证机关'
        ,fzrq    --'发证日期'
        ,dsr    --'当事人'
        ,STATUS    --'状态'
FROM    (
            SELECT  *
                    ,ROW_NUMBER() OVER(PARTITION BY ah, wsmc ORDER BY xh DESC,dsc_biz_timestamp DESC,dsc_biz_record_id DESC) AS rn
            FROM    stg_ra_fay_fypjs_df
            WHERE status='正常' AND dsc_biz_operation IN('insert','update')
        ) t
WHERE   rn = 1
;