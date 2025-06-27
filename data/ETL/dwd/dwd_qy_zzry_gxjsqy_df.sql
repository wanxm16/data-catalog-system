--企业_资质荣誉_高新技术企业
INSERT OVERWRITE TABLE dwd_qy_zzry_gxjsqy_df
SELECT  COALESCE(MD5(t1.id),t2.id) id          --'标识ID'
        ,COALESCE(t1.enterprisename,t2.qymc) entname    --'企业名称'
        ,COALESCE(t1.creditcode,t2.qydm) uniscid    --'统一社会信用代码'
        ,COALESCE(t1.certificateno,t2.zsbh)cert_no    --'证书编号'
        ,ArrTrimStr(CONCAT_WS(',', COALESCE(t1.laiyuan,''),COALESCE(t2.laiyuan,''))) laiyuan    --'来源'
FROM    
    (SELECT id,enterprisename,creditcode,certificateno,'省市回流_高新技术企业信息' laiyuan FROM ods_ra_kjj_gxjsqy_df) t1                    
FULL JOIN 
    (SELECT id,qymc,qydm,zsbh,'省市回流_省科技厅高新技术企业证书' laiyuan FROM ods_ra_kjj_skjtgxjsqy_df) t2 
ON  t2.zsbh=t1.certificateno
;