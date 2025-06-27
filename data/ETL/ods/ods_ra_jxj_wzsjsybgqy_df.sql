--市回流_温州市市级上云标杆企业名单信息
INSERT OVERWRITE TABLE ods_ra_jxj_wzsjsybgqy_df
SELECT  CASE WHEN t1.qymc='浙江戈尔德减振器股份有限公司' THEN '9133030067161672XJ'
        ELSE t2.uniscid
        END uniscid   --信用码
        ,t1.qymc    --'企业名称'
        ,t1.nd    --'年度'
FROM    stg_ra_jxj_wzsjsybgqy_df t1
LEFT JOIN dwd_qy_main2 t2 ON t2.entname = t1.qymc AND t2.entname IS NOT NULL AND t2.entname NOT LIKE '%*%' AND LENGTH(t2.entname) > 3
;