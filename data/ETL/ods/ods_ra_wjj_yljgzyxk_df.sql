--省市回流_医疗机构执业许可证
INSERT OVERWRITE TABLE ods_ra_wjj_yljgzyxk_df
SELECT  id    --主键'
        ,mc    --名称'
        ,CASE   WHEN COALESCE(t3.uniscid,t4.uniscid) IS NOT NULL THEN COALESCE(t3.uniscid,t4.uniscid)
                WHEN jyxz<>'营利性' AND jglx='村卫生室' THEN ''--非营利的村卫生室AI找不到统一社会信用代码的
                ELSE NULL 
         END uniscid    
        ,fzrxm    --负责人姓名'
        ,COALESCE(fddbr, lerep_name) fddbr    --法定代表人'----补
        ,dd    --地点'
        ,yljgzyxkzh    --医疗机构执业许可证号'
        ,yxjzsj    --有效截止时间'
        ,yxkssj    --有效开始时间'
        ,pzrq    --批准日期'
        ,fzjg    --发证机关'
        ,zlkm    --诊疗科目'
        ,jyxz    --经营性质'--营利性\非营利性（政府办）\非营利性（非政府办）
        ,jglx    --机构类型'
        ,yljgdemc    --医疗机构第二名称'
FROM    (
            SELECT  t2.*
                    ,CASE   WHEN uniscid IS NOt NULL THEN NULL
                            ELSE mc
                     END entname2--用于关联
                    ,ROW_NUMBER() OVER(PARTITION BY yljgzyxkzh ORDER BY estdate DESC) AS rn
            FROM    (
                        SELECT  t1.*
                                ,t2.uniscid
                                ,t2.lerep_name
                                ,t2.estdate
                        FROM    (
                                    SELECT  *
                                            ,ROW_NUMBER() OVER(PARTITION BY yljgzyxkzh,TOUPPER(id) ORDER BY id DESC) AS rn1
                                    FROM    stg_ra_wjj_yljgzyxk_df
                                ) t1
                        LEFT JOIN dwd_qy_main2 t2 ON t2.entname = t1.mc AND t2.entname IS NOT NULL AND t2.entname NOT LIKE '%*%' AND LENGTH(t2.entname)>3
                        WHERE t1.rn1=1
                    ) t2
        ) t3
LEFT JOIN ods_ai_qymc_in t4 ON t4.entname = t3.entname2 AND t4.uniscid IS NOT NULL
WHERE   t3.rn = 1
;