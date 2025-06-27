--省市回流_勘察设计企业资质信息
INSERT OVERWRITE TABLE ods_ra_zjj_kcsjqyzz_df
SELECT  servercertnum    --'企业资质ID'
        ,corpname    --'企业名称'
        ,creditcode    --'统一社会信用代码'
        ,certcode    --'资质证书号'
        ,titlelevelname    --'资质等级名称'
        ,certeffectdate    --'有效到期日期'
        ,awarddate    --'有效起始日期'
        ,awarddepart    --'资质证书核发机关'
        ,certstatusname    --'资质证书状态'
FROM    stg_ra_zjj_kcsjqyzz_df
;
