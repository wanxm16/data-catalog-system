--省市回流_保险许可证
INSERT OVERWRITE TABLE ods_ra_jrb_bxxkz_df
SELECT  CASE    WHEN jgmc LIKE '浙江省温州市%' THEN jgzs 
                ELSE jgmc 
        END jgmc    --'机构名称'
        ,tyxydm    --'持证主体统一信用代码'
        ,jgbm    --'机构编码'
        ,CASE    WHEN jgmc LIKE '浙江省温州市%' THEN jgmc 
                 ELSE jgzs 
         END jgzs    --'机构住所'
        ,zsbh    --'证书编号'
        ,zzlx    --'证照类型'
        ,zzbfjgdm    --'证照颁发机构代码'
        ,fzjg    --'发证机关'
        ,REGEXP_REPLACE(REGEXP_REPLACE(REPLACE(bfrq,'/','-'),'[年月]','-'),'日','') bfrq    --'颁发日期'
        ,REGEXP_REPLACE(REGEXP_REPLACE(REPLACE(pzrq,'/','-'),'[年月]','-'),'日','') pzrq    --'批准日期'
        ,ywfw    --'业务范围'
        ,xzqhdm    --'行政区划代码'
FROM    stg_ra_jrb_bxxkz_df
WHERE   zzzt = '有效'
;