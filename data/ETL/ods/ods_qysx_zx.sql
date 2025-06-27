--注销企业信息
INSERT OVERWRITE TABLE ods_qysx_zx
SELECT  COALESCE(dj.pripid,hz.pripid) pripid
        ,COALESCE(dj.uniscid,hz.uscc) uniscid
        ,hz.regno
        ,COALESCE(dj.entname,hz.entname) entname
        ,COALESCE(dj.candate,hz.candate) candate
        ,CASE    WHEN dj.canrea IS NOT NULL AND dj.canrea_cn IS NULL THEN '90'     --分不掉的都归到其他原因
                 ELSE dj.canrea 
         END canrea
        ,CASE    WHEN dj.canrea IS NOT NULL AND dj.canrea_cn IS NULL THEN '其他原因'     --分不掉的都归到其他原因
                 ELSE dj.canrea_cn 
         END canrea_cn
        ,CASE    WHEN dj.regorg_cn IS NULL AND dj.regorg='330381' THEN '瑞安市市场监督管理局' 
                 ELSE dj.regorg_cn 
         END regorg_cn    --'登记机关名称'
FROM    (
            SELECT  a.*
                    ,b.reason AS canrea_cn
            FROM    stg_qysx_zxdj a
            LEFT JOIN dict_canrea_code b
            ON      b.code = a.canrea
        ) dj
FULL JOIN stg_qysx_zxhz hz ON hz.pripid = dj.pripid
;