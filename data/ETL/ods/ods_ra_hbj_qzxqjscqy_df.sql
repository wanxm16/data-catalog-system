--省市回流_强制性清洁生产审核企业名单信息
INSERT OVERWRITE TABLE ods_ra_hbj_qzxqjscqy_df
SELECT  wh    --'文号'----xxxx全空
        ,REGEXP_REPLACE(qymc, '[^一-龥]', '') qymc    --'企业名称'--特殊符号替换不了，只能采用中文保留形式
        ,tyshxydm    --'统一社会信用代码'
        ,zzjgdm    --'组织机构代码'----xxxx全空
        ,sshy    --'所属行业'
        ,xsq    --'县（市区）'
        ,sqs    --'设区市'
        ,mdfbjg    --'名单发布机关'
        ,mdfbrq    --'名单发布日期'
FROM    stg_ra_hbj_qzxqjscqy_df
WHERE   dsc_biz_operation IN ('insert','update')
;