--省市回流_工商吊销企业信息
INSERT OVERWRITE TABLE ods_qysx_dx
SELECT  pripid    --'内部序号',
        ,revdate    --'吊销时间',
        ,revdecno0 AS revdecno    --'吊销处罚文号',
        ,revbasis    --'吊销原因',
        ,CASE    WHEN revauth1 IS NULL AND revdecno0 LIKE '%瑞工商%' THEN '瑞安市工商行政管理局'
                 WHEN revauth1 IS NULL AND revdecno0 LIKE '%瑞市监%' THEN '瑞安市市场监督管理局'
                 WHEN revauth1 IS NULL AND revdecno0 LIKE '%温鹿市监%' THEN '温州市鹿城区市场监督管理局'
                 --若出现其他区域的空数据，还要对应处理
                 WHEN revauth1 IS NULL AND revdecno0 NOT LIKE '%工商%' AND revdate<'2018-03-05' THEN '瑞安市工商行政管理局'    --十三届全国人大会议决定（2018.3.5-3.20）
                 WHEN revauth1 IS NULL AND revdecno0 NOT LIKE '%市监%' AND revdate>='2018-03-05' THEN '瑞安市市场监督管理局' 
                 ELSE revauth1 
         END revauth    --'吊照处罚实施机关'
FROM    (
            SELECT  *
                    ,CASE    WHEN revauth0 IS NULL OR revauth0='' THEN NULL
                             WHEN revauth0 LIKE '%瑞工商%' OR revauth0 LIKE '%瑞安工商%' OR revauth0 LIKE '%瑞安市工商%' THEN '瑞安市工商行政管理局'
                             WHEN revauth0='如爱你是工商局' OR revauth0='瑞安市工守丧行政管理局' THEN '瑞安市工商行政管理局'
                             WHEN revauth0 NOT LIKE '%工商%' AND revauth0 NOT LIKE '%市场监督%' AND revauth0 NOT LIKE '%市监%' THEN NULL 
                             ELSE revauth0 
                     END revauth1
            FROM    (
                        SELECT  *
                                ,CASE    WHEN revdecno NOT LIKE '%瑞工商处字%' AND revauth LIKE '%瑞工商处字%' THEN revauth 
                                         ELSE revdecno 
                                 END revdecno0    --'吊销处罚文号'
                                ,CASE    WHEN revdecno NOT LIKE '%瑞工商处字%' AND revauth LIKE '%瑞工商处字%' THEN revdecno 
                                         ELSE revauth 
                                 END revauth0    --'吊照处罚实施机关'--此字段较乱有些填的是企业名称，正常机关可根据处罚文号去逆推
                        FROM    stg_qysx_dx
                    ) t1
        ) t2
;