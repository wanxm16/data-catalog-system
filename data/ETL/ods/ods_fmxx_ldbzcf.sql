--省市回流_劳动保障处罚信息
INSERT OVERWRITE TABLE ods_fmxx_ldbzcf
SELECT  CASE    WHEN aab004='鲍少利（瑞安市爵士牛排馆经营者）' THEN '瑞安市爵士牛排馆' 
                WHEN aab004='瑞安市咿加咿娱****分公司' THEN '瑞安市咿加咿娱乐有限公司开发区分公司' 
                ELSE aab004 
        END aab004    --'企业名称'
        ,CASE    WHEN aab004='鲍少利（瑞安市爵士牛排馆经营者）' THEN '92330381MA286UFWXC' 
                 ELSE aab003 
         END aab003    --'统一社会信用代码'
        ,CASE    WHEN aab004='鲍少利（瑞安市爵士牛排馆经营者）' THEN '鲍少利'
                 WHEN aab004='瑞安市唐汉足浴会所' THEN '申友权' 
                 ELSE aab013 
         END aab013    --'法定代表人或负责人'
        ,abb068    --'处罚决定书文号'
        ,abb121    --'处罚决定书内容'
        ,abb010    --'简要案情'
        ,abb087    --'结案日期'
        ,abb701    --'执法部门名称'
FROM    stg_fmxx_ldbzcf
WHERE   dsc_biz_operation IN('insert','update')
;