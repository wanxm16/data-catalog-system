--省市回流_建筑施工企业安全生产许可证
INSERT OVERWRITE TABLE ods_ra_zjj_jzsgqyaqscxk_df
SELECT  bh    --'许可编号',
        ,dwmc    --'单位名称',
        ,corpcode    --'企业统一社会信用代码',
        ,zyfzr    --'主要负责人',
        ,dwdz    --'单位地址',
        ,jjlx    --'经济类型',
        ,xkfw    --'许可范围',
        ,fzsj    --'发证时间',
        ,yxqz    --'有效期至',
        ,fzjg    --'发证机关',
        ,STATUS    --'状态'
FROM    stg_ra_zjj_jzsgqyaqscxk_df
WHERE   (corpcode LIKE '__330381%' OR dwmc LIKE '%瑞安%' OR dwdz LIKE '%瑞安%')
;