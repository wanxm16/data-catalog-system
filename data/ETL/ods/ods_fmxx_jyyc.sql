--省市回流_经营异常名录信息
INSERT OVERWRITE TABLE ods_fmxx_jyyc
SELECT  COALESCE(t1.busexclist,t2.busexclist,t3.busexclist,t4.busexclist) busexclist    --'经营异常名录ID'
        ,COALESCE(t1.pripid,t2.pripid,t3.pripid,t4.pripid) pripid    --'内部序号'
        ,COALESCE(t1.abntime,t2.abntime,t3.abntime,t4.abntime) abntime    --'列入日期'
        ,COALESCE(t1.specause_cn,t2.specause_cn,t3.specause_cn,t4.specause_cn) specause_cn    --'列入经营异常名录原因'
        ,COALESCE(t1.decorg_cn,t2.decorg_cn,t3.decorg_cn,t4.decorg_cn) decorg_cn    --'作出决定机关(列入)'
        ,COALESCE(t1.redecorg_cn,t2.redecorg_cn,t3.redecorg_cn,t4.redecorg_cn) redecorg_cn    --'作出决定机关(移出)'
        ,COALESCE(t1.remexcpres_cn,t2.remexcpres_cn,t3.remexcpres_cn,t4.remexcpres_cn) remexcpres_cn    --'移出经营异常名录原因'
        ,COALESCE(t1.remdate,t2.remdate,t3.remdate,t4.remdate) remdate    --'移出日期'
FROM    (
            SELECT  MD5(CONCAT_WS('#',pripid,abntime,specause_cn)) busexclist    --'经营异常名录ID'
                    ,pripid    --'内部序号'
                    ,abntime    --'列入日期'
                    ,specause_cn    --'列入经营异常名录原因'
                    ,decorg_cn    --'作出决定机关(列入)'
                    ,redecorg_cn    --'作出决定机关(移出)'
                    ,remexcpres_cn    --'移出经营异常名录原因'
                    ,remdate    --'移出日期'
            FROM    ods_fmxx_jyyc1 
            WHERE   abntime IS NOT NULL
        ) t1
FULL JOIN (
              SELECT  MD5(CONCAT_WS('#',pripid,TO_CHAR(abnormal_putdate,'yyyy-MM-dd'),specause_cn)) busexclist    --'主键'
                      ,pripid    --'内部序号'
                      ,TO_CHAR(abnormal_putdate,'yyyy-MM-dd') abntime    --'列入日期'
                      ,specause_cn    --'列入经营异常名录原因'
                      ,decorg_cn    --'作出决定机关（列入）'
                      ,redecorg_cn    --'作出决定机关（移出）'
                      ,remexcpres_cn    --'移出经营异常名录原因'
                      ,TO_CHAR(remdate,'yyyy-MM-dd') remdate   --'移出日期'
              FROM    ods_fmxx_jyyc_qy
          ) t2
ON      t2.busexclist = t1.busexclist
FULL JOIN (
              SELECT  MD5(CONCAT_WS('#',pripid,TO_CHAR(abntime,'yyyy-MM-dd'),specause_cn)) busexclist    --'主键'
                      ,pripid    --'内部序号'
                      ,TO_CHAR(abntime,'yyyy-MM-dd') abntime    --'列入日期'
                      ,specause_cn    --'列入经营异常名录原因'
                      ,decorg_cn    --'作出决定机关（列入）'
                      ,redecorg_cn    --'作出决定机关（移出）'
                      ,remexcpres_cn    --'移出经营异常名录原因'
                      ,TO_CHAR(remdate,'yyyy-MM-dd') remdate   --'移出日期'
              FROM    ods_fmxx_jyyc_gt
              WHERE   pripid IS NOT NUll
          ) t3
ON      t3.busexclist = COALESCE(t1.busexclist,t2.busexclist)
FULL JOIN (
              SELECT  MD5(CONCAT_WS('#',pripid,TO_CHAR(abnormal_putdate,'yyyy-MM-dd'),specause_cn)) busexclist    --'主键'
                      ,pripid    --'内部序号'
                      ,TO_CHAR(abnormal_putdate,'yyyy-MM-dd') abntime    --'列入日期'
                      ,specause_cn    --'列入经营异常名录原因'
                      ,decorg_cn    --'作出决定机关（列入）'
                      ,redecorg_cn    --'作出决定机关（移出）'
                      ,remexcpres_cn    --'移出经营异常名录原因'
                      ,TO_CHAR(remdate,'yyyy-MM-dd') remdate   --'移出日期'
              FROM    ods_ra_sjj_hlwjgqyjyycml_df
          ) t4
ON      t4.busexclist = COALESCE(t1.busexclist,t2.busexclist,t3.busexclist)
;