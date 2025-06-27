--省回流_守合同重信用企业信息
INSERT OVERWRITE TABLE ods_ra_sjj_shtzxy_df
SELECT  fid    --'主键'
        ,fregno    --'工商注册号'
        ,fname    --'企业名称'
        ,flevel    --'信用等级'
        ,fyear    --'公示年度'
        ,flegalperson    --'法人代表人'
        ,fphonenumber    --'联系电话'
        ,fapplytype    --'申报性质'
        ,findustrytype    --'所属行业'
        ,fstartdate    --'公示开始时间'
        ,fenddate    --'有效期限截止时间'
        ,fcontactperson    --'联系人姓名'
        ,fcontactphonenumber    --'联系人联系电话'
        ,finsertdate    --'添加时间'
        ,farea    --'所属辖区'
        ,fremark    --'备注'
        ,fstate    --'状态'
        ,fblackid    --'列入黑名单ID'
        ,fsubmitid    --'信用数据表ID'
FROM    (
            SELECT  *
                    ,ROW_NUMBER() OVER(PARTITION BY fregno,fyear ORDER BY finsertdate DESC,fid DESC) AS rn 
            FROM    stg_ra_sjj_shtzxy_df
            WHERE   farea = '瑞安市'
        ) t
WHERE   rn = 1
;