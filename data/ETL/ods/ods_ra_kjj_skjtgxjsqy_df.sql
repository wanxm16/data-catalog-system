--省市回流_省科技厅高新技术企业证书
INSERT OVERWRITE TABLE ods_ra_kjj_skjtgxjsqy_df
SELECT  id    --'标识ID'
        ,qymc    --'企业名称'
        ,qydm    --'企业代码'
        ,zsbh    --'证书编号'
        ,zzmc    --'证照名称'
        ,zzlxdm    --'证照类型代码'
        ,zzbs    --'证照标识'
        ,zzyxqqsrq    --'证照有效期起始日期'
        ,zzyxqjzsj    --'证照有效期截止时间'
        ,fzrq    --'发证日期'
        ,pzjgdm    --'批准机关代码'
        ,pzjg    --'批准机关'
FROM    stg_ra_kjj_skjtgxjsqy_df
;