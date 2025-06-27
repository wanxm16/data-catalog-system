--省回流_个体经营异常状态信息
INSERT OVERWRITE TABLE ods_fmxx_jyyc_gt
SELECT  busexclist    --'个体经营异常状态信息ID'
        ,t2.pripid    --'内部序号'
        ,t1.pripid AS uniscid
        ,specause    --'标记经营异常名录原因'
        ,specause_cn    --'标记经营异常状态原因（中文名称）'
        ,abntime    --'标记日期'
        ,decorg    --'作出决定机关（标记）'
        ,decorg_cn    --'作出决定机关（标记）（中文名称）'
        ,isrecovery    --'是否恢复'
        ,remexcpres    --'恢复正常记载状态原因'
        ,remexcpres_cn    --'恢复正常记载状态原因（中文名称）'
        ,remdate    --'恢复日期'
        ,redecorg    --'作出决定机关（恢复）'
        ,redecorg_cn    --'作出决定机关（恢复）（中文名称）'
FROM    (
            SELECT  *
                    ,ROW_NUMBER() OVER(PARTITION BY pripid,TO_CHAR(abntime,'yyyy-MM-dd'),specause_cn ORDER BY cd_time DESC,busexclist DESC,cd_id DESC) AS rn
            FROM    stg_fmxx_jyyc_gt
            WHERE   cd_operation <> 'D'
            AND     pripid IS NOT NULL
            AND     pripid <> ''
        ) t1
LEFT JOIN dwd_qy_main2 t2 ON t2.uniscid = t1.pripid AND t2.uniscid IS NOT NULL
WHERE   rn = 1
;