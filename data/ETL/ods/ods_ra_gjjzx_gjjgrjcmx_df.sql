--省市回流_公积金个人缴存信息
INSERT OVERWRITE TABLE ods_ra_gjjzx_gjjgrjcmx_df
SELECT  dwmc    --'单位名称'
        ,REGEXP_REPLACE(REGEXP_REPLACE(tyshxydm,'I','1'),'O','0') tyshxydm    --'统一社会信用代码'
        ,xingming    --'姓名'
        ,zjh    --'证件号码'
        ,zjlx    --'证件类型'
        ,grzh    --'个人账户'
        ,grjcjs    --'个人缴存基数'
        ,grjcbl    --'个人缴存比例'
        ,gryjce    --'个人月缴存额'
        ,grjcye    --'个人账户余额'
        ,zrzhzt    --'个人账户状态'
        ,grkhrq    --'开户日期'
        ,grxhrq    --'销户日期'
        ,jgh    --'机构号'----xxxx都是330300000000000
        ,zxjyrq    --'最近交易日期时间'
FROM    stg_ra_gjjzx_gjjgrjcmx_df
;