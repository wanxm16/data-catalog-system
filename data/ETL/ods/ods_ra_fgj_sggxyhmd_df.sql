--省回流_浙江省公共信用红名单信息
INSERT OVERWRITE TABLE ods_ra_fgj_sggxyhmd_df
SELECT  id    --'编号',
        ,xydm    --'统一社会信用代码/身份证号',
        ,mc    --'企业名称/姓名',
        ,rd_xydm    --'认定单位统一社会信用代码',
        ,rd_mc    --'认定单位名称',
        ,rdsj    --'认定时间',
        ,hmdlx    --'红名单类型',
        ,rdwsh    --'认定文号',
FROM    (
            SELECT  *
                    ,ROW_NUMBER() OVER(PARTITION BY xydm,rdsj,hmdlx,rdwsh ORDER BY intime DESC,id DESC) AS rn
            FROM    stg_ra_fgj_sggxyhmd_df
            WHERE   rd_xydm = '13303810000' --OR xydm LIKE '%330381%' OR mc LIKE '%瑞安%'
        ) 
WHERE   rn = 1
;