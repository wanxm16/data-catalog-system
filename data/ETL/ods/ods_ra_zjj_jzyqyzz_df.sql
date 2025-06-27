--省市回流_中华人民共和国建筑业企业资质证书--停更
INSERT OVERWRITE TABLE ods_ra_zjj_jzyqyzz_df
SELECT  rowguid    --'企业资质ID'
        ,corpname    --'企业名称'
        ,corpcode    --'组织机构代码'
        ,scucode    --'统一社会信用代码'
        ,econtypename    --'经济性质'
        ,regprin    --'注册资本'
        ,legalmanname    --'法定代表人'
        ,address    --'注册地址'
        ,certid    --'资质证书号'
        ,certlevelname    --'资质等级名称'
        ,yxq    --'有效期'
        ,notedate    --'有效起始日期'
        ,enddate    --'有效到期日期'
        ,organdate    --'资质证书核发日期'
        ,organname    --'资质证书核发机关'
        ,qmjg    --'签名机构'
        ,certstatename    --'资质证书状态'
FROM    (
            SELECT  *
                    ,ROW_NUMBER() OVER(PARTITION BY certid ORDER BY dsc_biz_timestamp DESC,dsc_biz_record_id) AS rn
            FROM    stg_ra_zjj_jzyqyzz_df
            WHERE   dsc_biz_operation IN ('insert','update')
        ) t1
;