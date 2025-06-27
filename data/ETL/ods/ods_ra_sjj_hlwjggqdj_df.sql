--“互联网+监管”股权冻结详细信息
INSERT OVERWRITE TABLE ods_ra_sjj_hlwjggqdj_df
SELECT  froid    --'股权冻结信息ID'
        ,pripid    --'主体身份代码'
        ,entname    --'被冻结股权所在市场主体名称'
        ,regno    --'被冻结股权所在市场主体注册号'
        ,invtype    --'被执行人类型'
        ,invtype_cn    --'被执行人类型（中文名称）'
        ,inv    --'被执行人'
        ,cerno1 AS cerno    --'证件号码'
        ,blicno    --'证照号码'
        ,froauth    --'执行法院'
        ,frodocno    --'执行裁定书文号'
        ,executeno    --'协助执行通知书文号'
        ,frofrom    --'冻结期限自'
        ,froto    --'冻结期限至'
        ,frozdeadline    --'冻结期限'
        ,publicdate    --'公示日期'
        ,frozstate    --'股权冻结状态'
        ,frozstate_cn    --'股权冻结状态（中文名称）'
        ,thawdate    --'解冻日期'
        ,loseeffdate    --'失效日期'
        ,loseeffres    --'失效原因'
        ,loseeffres_cn    --'失效原因（中文名称）'
        ,executeitem    --'执行事项'
        ,executeitem_cn    --'执行事项（中文名称）'
        ,regcapcur    --'币种'
        ,regcapcur_cn    --'币种（中文名称）'
        ,froam    --'股权数额'
FROM    (
            SELECT  *
                    ,CASE    WHEN cerno RLIKE '^[1-9][0-9]{5}[0-9]{2}((0[1-9])|10|11|12)(([0-2][1-9])|10|20|30|31)[0-9]{3}$' THEN ID15TO18(cerno)
                             WHEN cerno='...............' THEN NULL 
                             ELSE cerno 
                     END cerno1
                    ,ROW_NUMBER() OVER(PARTITION BY pripid,invtype,inv,frodocno,frofrom ORDER BY cd_id DESC) AS rn
            FROM    stg_ra_sjj_hlwjggqdj_df
        ) t
WHERE   rn = 1
;