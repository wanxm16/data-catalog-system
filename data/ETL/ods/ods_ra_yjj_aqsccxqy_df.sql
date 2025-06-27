--省回流-安全生产诚信企业信息
INSERT OVERWRITE TABLE ods_ra_yjj_aqsccxqy_df
SELECT  qyid    --'企业ID',
        ,qymc    --'企业名称',
        ,shxydc    --'统一社会信用代码',
        ,zzjgdm    --'组织机构代码',
        ,pjjg    --'评价结果',
        ,pjsj    --'评价时间',
        ,pjyj    --'评价依据',
        ,pjwh    --'文号',
        ,pjdw    --'评价机构'
FROM    stg_ra_yjj_aqsccxqy_df
WHERE   pjdw='瑞安市'
;