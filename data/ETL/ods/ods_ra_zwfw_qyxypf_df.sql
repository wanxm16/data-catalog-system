--省市回流_监管库_企业信用评分信息
INSERT OVERWRITE TABLE ods_ra_zwfw_qyxypf_df
SELECT  cd_id    --'主键',
        ,enterprise_name    --'企业名称',
        ,enterprise_cert_no    --'企业证件编号',
        ,enterprise_mark_no    --'企业评分编号',
        ,enterprise_credit_mark_result    --'企业信用评分结果',
        ,enterprise_credit_mark_grade    --'企业信用评分等级',
        ,enterprise_credit_mark_grade_last    --'企业信用评分等级(上一次)',
        ,SUBSTR(assess_date,1,10) assess_date   --'评估日期',
        ,model_name    --'模型名称',
        ,bureau_name    --'厅局名称'
FROM    stg_ra_zwfw_qyxypf_df
WHERE   enterprise_credit_mark_grade <> ''
;