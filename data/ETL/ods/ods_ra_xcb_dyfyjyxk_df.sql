--省市回流_电影放映经营许可证（新）
INSERT OVERWRITE TABLE ods_ra_xcb_dyfyjyxk_df
SELECT  REPLACE(REPLACE(xkzh,'(','（'),')','）') xkzh    --'许可证号'
        ,dwmc    --'单位名称'
        ,xydm    --'统一社会信用代码'
        ,czztdmlx    --'持证主体代码类型'
        ,fddbr    --'法定代表人'
        ,jyxm    --'经营项目'
        ,jyqy    --'经营区域'
        ,zczb    --'注册资金'
        ,dwlx    --'经济性质'
        ,dwdz    --'地址'
        ,yxsj    --'有效日期'
        ,yxqe    --'有效期（截止）'
        ,yxqs    --'有效期（起始）'
        ,clsj    --'发证日期'
        ,fzjg    --'发证机关'
        ,zzbfjgdm    --'证照颁发机构代码'
        ,xzqhdm    --'行政区划代码'
        ,zt    --'证照状态'
FROM    (
            SELECT  *
                    ,ROW_NUMBER() OVER(PARTITION BY REPLACE(REPLACE(xkzh,'(','（'),')','）') ORDER BY yxqs DESC,yxsj DESC,clsj DESC) AS rn
            FROM    stg_ra_xcb_dyfyjyxk_df
            WHERE   xkzh <> '浙证放（108）字第001号'
        ) t
WHERE   rn = 1
;