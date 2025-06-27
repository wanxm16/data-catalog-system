--省市回流_中华人民共和国道路运输经营许可证
INSERT OVERWRITE TABLE ods_ra_jtt_dlysjyxk_df
SELECT  e_id    --'ID'
        ,name    --'业户名称'
        ,bizlicense    --'工商执照号'
        ,czztdmlx    --'持证主体代码类型'----xxxx都是统一社会信用代码
        ,CASE    WHEN t2.uniscid IS NOT NULL THEN t2.lerep_name 
                 ELSE t1.repres_name 
         END repres_name    --'法定代表人'
        ,CASE    WHEN t2.uniscid IS NOT NULL THEN t2.cerno 
                 ELSE t1.repres_id 
         END repres_id    --'法人代表证件号'
        ,address    --'注册地址'
        ,econ_name    --'经济类型'
        ,print_date    --'核发时间'
        ,valid_date_begin    --'有效期起'
        ,valid_date_end    --'有效期止'
        ,license_key    --'经营许可证字'
        ,license_num    --'经营许可证号'
        ,busi_scope    --'经营范围'
        ,organ_name    --'发证机关'
        ,zzbfjgdm    --'证照颁发机构代码'
        ,xzqhdm    --'行政区划代码'
        ,STATUS    --'证照状态'
FROM    (
            SELECT  *
                    ,CASE    WHEN repres_id RLIKE "^[1-9][0-9]{5}(18|19|20)[0-9]{2}((0[1-9])|10|11|12)(([0-2][1-9])|10|20|30|31)[0-9]{3}[0-9|X|x]$" THEN NULL 
                             ELSE bizlicense 
                     END uniscid1    --用于关联
            FROM    stg_ra_jtt_dlysjyxk_df
        ) t1
LEFT JOIN dwd_qy_main2 t2
ON      t2.uniscid = t1.uniscid1
;