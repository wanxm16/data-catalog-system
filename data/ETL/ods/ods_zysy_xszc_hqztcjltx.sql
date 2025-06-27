--市回流_惠企直通车-奖励兑现信息
INSERT OVERWRITE TABLE ods_zysy_xszc_hqztcjltx
SELECT  company_name    --'企业名称'
        ,uniscid    --'统一信用代码'
        ,project_name    --'项目名称'
        ,reward    --'核定奖励金额'
        ,create_dt    --'公示开始时间'
        ,expire_dt    --'公示结束时间'
        ,wf_id    --'奖补项目ID'    --奖补id：一次奖补包含多项目，一个项目可多家企业
        ,inst_id    --'实例ID'      --一次奖补中企业项目实例ID（一家企业一个项目多次奖补中实例id不同）
FROM    (
            SELECT  *
                    ,row_number() OVER(PARTITION BY uniscid,project_name,create_dt,expire_dt,wf_id ORDER BY inst_id DESC,publicity_id DESC) AS rn
            FROM    stg_zysy_xszc_hqztcjltx
            WHERE   proc_sts = '审批通过'
            AND     sts = 'FINISHED'
        ) t
WHERE   rn = 1
;