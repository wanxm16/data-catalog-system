--省市回流_危险废物经营许可证
INSERT OVERWRITE TABLE ods_ra_hbj_wxfwjyxk_df
SELECT  data_id    --'数据唯一编码'
        ,ent_name    --'单位名称'
        ,ent_code    --'统一社会信用代码'
        ,holdertype    --'持证主体代码类型'
        ,main_leader    --'法定代表人'
        ,bus_address    --'经营地址'
        ,reg_address    --'注册地址'
        ,ArrUniqueStr(bus_area) bus_area    --'经营范围'----里面字重复替换下
        ,REGEXP_REPLACE(lic_no,' ','') lic_no    --'证照号'----有空格需替换后，再排重
        ,use_state    --'证件状态'
        ,ava_start    --'有效期限起'
        ,ava_end    --'有效期限止'
        ,auth_date    --'发证日期'
        ,auth_depart    --'发证机关'
        ,issuecode    --'证照颁发机构代码'
        ,arecode    --'行政区划代码'
FROM    (
            SELECT  *
                    ,ROW_NUMBER() OVER(PARTITION BY REGEXP_REPLACE(lic_no,' ','') ORDER BY ava_start DESC,dsc_biz_timestamp DESC,dsc_biz_record_id DESC) AS rn
            FROM    stg_ra_hbj_wxfwjyxk_df
        ) t
WHERE   rn = 1
;