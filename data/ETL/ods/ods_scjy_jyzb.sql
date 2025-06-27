--省市回流_公示系统企业年报基本信息
INSERT OVERWRITE TABLE ods_scjy_jyzb
SELECT  entname    --'企业名称',
        ,pripid    --'主体身份代码',
        ,uniscid    --'统一社会信用代码',
        ,regno    --'营业执照注册号',
        ,enttype    --'企业类型',
        ,busst_cn    --'营运状况',
        ,anchedate    --'年度报告日期',
        ,ancheyear    --'年报年度',    
        ,assgrodis    --'资产总额是否公示',
        ,assgro    --'资产总额',
        ,liagrodis    --'负债总额是否公示',
        ,liagro    --'负债总额',
        ,totequdis    --'所有者权益合计是否公',
        ,totequ    --'所有者权益合计',
        ,vendincdis    --'销售(营业)收入是否',
        ,vendinc    --'销售(营业)收入',
        ,maibusincdis    --'其中主营业务收入是否',
        ,maibusinc    --'其中主营业务收入',
        ,ratgrodis    --'纳税总额是否公示',
        ,ratgro    --'纳税总额',
        ,progrodis    --'利润总额、利润总额是',
        ,progro    --'利润总额',
        ,netincdis    --'净利润是否公示',
        ,netinc    --'净利润',
        ,empnumdis    --'从业人数是否公示',
        ,empnum    --'从业人数',
        ,dsc_biz_record_id
        ,dsc_biz_operation
        ,dsc_biz_timestamp
FROM    (
            SELECT  *
                    ,row_number() OVER(PARTITION BY pripid,ancheyear ORDER BY anchedate DESC,dsc_biz_timestamp DESC,dsc_biz_record_id DESC) AS rn
            FROM    stg_scjy_jyzb
            WHERE   dsc_biz_operation IN('insert','update')
        ) t1
WHERE   rn = 1
;