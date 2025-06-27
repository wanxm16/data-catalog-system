--省市回流_公积金法人缴存信息
INSERT OVERWRITE TABLE ods_qtjc_gjjjc
SELECT  tyshxydm    --'征缴单位统一社会信用'
        ,dwmc    --'征缴单位全称'
        ,jgh    --'机构编号'
        ,dwzh    --'公积金账号'
        ,dwjjlx    --'单位缴存类型'--代码值，找不到字典
        ,dwjcrs    --'缴存人数'
        ,jzny    --'缴存年月止'
        ,dwjcbl    --'缴存比例'
FROM    stg_qtjc_gjjjc 
;