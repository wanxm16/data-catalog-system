--企业高管_董高监汇总表
INSERT OVERWRITE TABLE dwd_qygg_dgj
SELECT  pripid,person_id,position_cn,position,name
        ,CASE WHEN cerno IS NOT NULL AND cerno RLIKE "^[1-9][0-9]{5}(18|19|20)[0-9]{2}((0[1-9])|10|11|12)(([0-2][1-9])|10|20|30|31)[0-9]{3}[0-9|X|x]$" THEN '中华人民共和国居民身份证'
        ELSE certype_cn END certype_cn
        ,CASE WHEN cerno IS NOT NULL AND cerno RLIKE "^[1-9][0-9]{5}(18|19|20)[0-9]{2}((0[1-9])|10|11|12)(([0-2][1-9])|10|20|30|31)[0-9]{3}[0-9|X|x]$" THEN '10'
        ELSE certype END certype
        ,cerno,country_cn,country,dom,email
FROM (
    SELECT  COALESCE(t1.pripid,t2.pripid,t3.pripid) pripid   --'主体身份代码'
            ,COALESCE(t1.person_id,t2.person_id,t3.personid) person_id    --'人员序号'
            ,COALESCE(t1.position_cn,t2.position_cn,t3.position_cn) position_cn    --'职务名称'
            ,COALESCE(t1.position,t2.position,t3.position) position    --'职位代码'
            ,COALESCE(t1.name,t2.name,t3.name) name    --'姓名'
            ,COALESCE(t2.certype_cn,t3.certype_cn) certype_cn    --'证件类型名称'
            ,COALESCE(t2.certype,t3.certype) certype    --'证件类型代码'
            ,COALESCE(t1.cerno,t2.cerno,t3.cerno) cerno    --'证件号码'
            ,COALESCE(t1.country_cn,t2.country_cn,t3.country_cn) country_cn    --'国籍名称'
            ,COALESCE(t1.country,t2.country,t3.country) country    --'国籍代码'
            ,t2.dom    --'住所'
            ,t3.email    --'电子邮件地址'
    FROM    ods_qygg_zyry t1
    FULL JOIN ods_qygg_dgjhz t2 ON CONCAT_WS('_',t2.pripid,COALESCE(t2.position,''),COALESCE(t2.cerno,''),COALESCE(t2.name,''))
        =CONCAT_WS('_',t1.pripid,COALESCE(t1.position,''),COALESCE(t1.cerno,''),COALESCE(t1.name,'')) AND t2.lerepsign='2'
    FULL JOIN ods_qygg_frqt t3 ON CONCAT_WS('_',t3.pripid,COALESCE(t3.position,''),COALESCE(t3.cerno,''),COALESCE(t3.name,''))
        =COALESCE(CONCAT_WS('_',t1.pripid,COALESCE(t1.position,''),COALESCE(t1.cerno,''),COALESCE(t1.name,''))
            ,CONCAT_WS('_',t2.pripid,COALESCE(t2.position,''),COALESCE(t2.cerno,''),COALESCE(t2.name,''))) AND t3.lerepsign='2'
    )t
;