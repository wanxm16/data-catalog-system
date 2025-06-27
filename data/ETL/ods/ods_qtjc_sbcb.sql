--省市回流_企业参保人数情况信息
INSERT OVERWRITE TABLE ods_qtjc_sbcb
SELECT  bab010    --'统一社会信用代码'
        ,aab004    --'单位名称'
        ,aae002    --'数据期别'
        ,ijfrs    --'养老缴费人数'
        ,jjfrs    --'失业缴费人数'
        ,ljfrs    --'工伤参保人数'
FROM    stg_qtjc_sbcb 
WHERE   dsc_biz_operation<>'D'
;