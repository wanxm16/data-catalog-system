--省市回流_电力业务许可证
INSERT OVERWRITE TABLE ods_ra_dsj_dlywxk_df
SELECT  register_id    --'业务主键'
        ,register_no    --'证书编码'
        ,djmc    --'登记名称'
        ,corporate_license_no    --'企业社会统一信用代码'
        ,zjlx    --'证件类型'
        ,manager    --'法定代表人'
        ,home    --'住所'
        ,zzmc    --'证照名称'
        ,xklb    --'许可类别'
        ,valid_date_start    --'起始日期'
        ,valid_date_end    --'截止日期'
        ,issure_date    --'发证日期'
        ,fzjg    --'发证机关'
        ,fzjg_tyxydm    --'发证机关统一信用代码'
        ,zip_code    --'所属区划编码'
        ,STATUS    --'证书状态'
FROM    stg_ra_dsj_dlywxk_df
;