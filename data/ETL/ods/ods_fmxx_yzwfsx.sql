--省市回流_严重违法失信企业名单信息
INSERT OVERWRITE TABLE ods_fmxx_yzwfsx 
SELECT  COALESCE(t1.illid,t2.illid,t3.illid,t4.illid) illid    --'严重违法失信企业名单ID'
        ,COALESCE(t1.pripid,t2.pripid,t3.pripid,t4.pripid) pripid    --'内部序号'
        ,COALESCE(t1.abntime,t2.abnormal_putdate,t3.abntime,t4.abntime) abntime    --'列入日期'
        ,COALESCE(t3.dedocnum,t4.dedocnum) --'列入文号',
        ,COALESCE(t1.serillrea_cn,t2.specause_cn) serillrea_cn    --'列入经营异常名录原因'
        ,COALESCE(t1.decorg_cn,t2.decorg_cn,t3.decorg_cn,t4.decorg_cn) decorg_cn    --'作出决定机关(列入)'
        ,COALESCE(t1.recorg_cn,t2.redecorg_cn) recorg_cn    --'作出决定机关(移出)'
        ,COALESCE(t1.remexcpres_cn,t2.remexcpres_cn) remexcpres_cn    --'移出经营异常名录原因'
        ,COALESCE(t1.remdate,t2.remdate) remdate    --'移出日期'
FROM    (
            SELECT  MD5(CONCAT_WS('#',pripid,abntime,serillrea_cn)) illid
                    ,pripid    --'内部序号'
                    ,abntime    --'列入日期'
                    ,serillrea_cn    --'列入经营异常名录原因'
                    ,decorg_cn    --'作出决定机关(列入)'
                    ,recorg_cn    --'作出决定机关(移出)'
                    ,remexcpres_cn    --'移出经营异常名录原因'
                    ,remdate    --'移出日期'
            FROM    ods_fmxx_yzwfsx1 
            WHERE   abntime IS NOT NULL limit 9
        ) t1
FULL JOIN (
              SELECT  MD5(CONCAT_WS('#',pripid,abnormal_putdate,specause_cn)) illid    --'主键'
                      ,pripid    --'内部序号'
                      ,abnormal_putdate    --'列入日期'
                      ,specause_cn    --'列入经营异常名录原因'
                      ,decorg_cn    --'作出决定机关（列入）'
                      ,redecorg_cn    --'作出决定机关（移出）'
                      ,remexcpres_cn    --'移出经营异常名录原因'
                      ,remdate    --'移出日期'
              FROM    ods_fmxx_yzwfsx_wj
          ) t2
ON      t2.illid = t1.illid
FULL JOIN (
              SELECT  MD5(CONCAT_WS('#',pripid,abntime,dedocnum)) illid    --'主键'
                      ,pripid    --'内部序号'
                      ,abntime    --'列入日期'
                      ,decorg_cn    --'作出决定机关（列入）'
                      ,dedocnum    --'列入文号'
              FROM    ods_fmxx_yzwfsx_gj
          ) t3
ON      t3.illid = COALESCE(t1.illid,t2.illid)
FULL JOIN (
              SELECT  MD5(CONCAT_WS('#',pripid,abntime,dedocnum)) illid    --'主键'
                      ,pripid    --'内部序号'
                      ,abntime    --'列入日期'
                      ,decorg_cn    --'作出决定机关（列入）'
                      ,dedocnum    --'列入文号'
              FROM    ods_fmxx_yzwfsx_dz
          ) t4
ON      t4.illid = COALESCE(t1.illid,t2.illid,t3.illid)
;