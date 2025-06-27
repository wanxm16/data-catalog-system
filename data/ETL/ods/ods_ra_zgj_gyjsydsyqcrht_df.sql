--省市回流_国有建设用地使用权出让合同信息
INSERT OVERWRITE TABLE ods_ra_zgj_gyjsydsyqcrht_df
SELECT  gd_guid    --'供地编号',----唯一
        ,bh    --'合同编号',
        ,srr2    --'受让人',
        ,uniscid2 AS qy_fr_dm    --'统一社会信用代码',
        ,min_rjl    --'容积率',
        ,min_jz_mj    --'建筑密度',
        ,min_lhl    --'绿化率',
        ,min_jz_gd    --'建筑限高',
        ,zt_jz_xz    --'建筑物性质',
        ,zd_bh    --'地块编号',
        ,gg_bh    --'公告编号',
        ,gg_sj    --'公告日期',
        ,lq_wj_sj_s    --'出让文件领取开始日期',
        ,lq_wj_sj_e    --'出让文件领取结束日期',
        ,cr_sj    --'出让时间',
        ,qd_rq    --'合同签订日期',
        ,jd_sj    --'交地时间',
        ,dg_sj    --'约定开工时间',
        ,jg_sj    --'约定竣工时间',
        ,je    --'合同总金额',
        ,srr_dz    --'受让人地址',
        ,CASE WHEN srr_dh IS NULL OR srr_dh='/' THEN NULL
              WHEN srr_dh RLIKE '^\\d+$' THEN srr_dh
              ELSE REGEXP_REPLACE(REGEXP_REPLACE(srr_dh,'[\\.\\/\\s;,#、，　；或]+','\\\\'),'\\\\\\\\','\\\\')
         END srr_dh    --'电话',
        ,srr_cz    --'传真',
        ,sfbzd    --'是否标准地',
        ,sfyfpzzdqy    --'是否在依法批准的省级',
        ,tz_qd    --'固定资产投资强度',
        ,mjss    --'亩均税收',
        ,bzdw    --'发证机关',
        ,gy_fs    --'出让方式',
        ,cr_qj    --'出让起价',
        ,ly_bzj    --'保证金',
        ,bj_zf    --'报价增幅',
        ,td_zl    --'地块坐落',
        ,dk_sz    --'地块四至',
        ,td_yt    --'地块用途',
        ,cr_nx    --'出让年限',
        ,jz_mj    --'建筑面积',
        ,gd_zmj    --'宗地面积',
        ,gy_mj    --'出让土地面积',
        ,dz_ba_bh    --'电子监管号',
        ,hy_fl    --'行业代码',
        ,hy_fl_mc    --'行业分类名称'
FROM    (
    SELECT  t3.*
            ,COALESCE(uniscid1,t4.uniscid) uniscid2
            ,ROW_NUMBER() OVER(PARTITION BY gd_guid,bh,COALESCE(uniscid1,t4.uniscid,qy_fr_dm) ORDER BY estdate DESC,gd_guid) AS rn
    FROM    (
            SELECT  t2.*
                    ,CASE   WHEN uniscid1 IS NOt NULL THEN NULL
                            ELSE srr2
                     END entname2--用于关联
                    ,ROW_NUMBER() OVER(PARTITION BY gd_guid,bh,qy_fr_dm ORDER BY estdate DESC) AS rn2
            FROM    (
                        SELECT  t1.*
                                ,COALESCE(t2.uniscid, uniscid0) uniscid1
                                ,COALESCE(t2.estdate, '9999-12-31') estdate
                        FROM    (
                                    SELECT  t0.*
                                            ,CASE    WHEN uniscid0 RLIKE '^[0-9A-HJ-NPQRTUWXY]{2}[0-9]{6}[0-9A-HJ-NPQRTUWXY]{10}$' THEN NULL 
                                                     ELSE srr2 
                                             END entname1    --用于关联
                                    FROM    (
                                                SELECT  *
                                                        ,CASE    WHEN qy_fr_dm LIKE '%O%' THEN REGEXP_REPLACE(qy_fr_dm,'O','0')
                                                                 WHEN qy_fr_dm LIKE '%I%' THEN REGEXP_REPLACE(qy_fr_dm,'I','1')
                                                                 WHEN qy_fr_dm LIKE '%1/1%' OR qy_fr_dm LIKE '%、%' THEN SUBSTR(qy_fr_dm,1,18)
                                                                 WHEN qy_fr_dm RLIKE '^[0-9A-HJ-NPQRTUWXY]{2}[0-9]{6}[0-9A-HJ-NPQRTUWXY]{10}$' THEN qy_fr_dm
                                                                 ELSE NULL 
                                                         END uniscid0
                                                FROM    stg_ra_zgj_gyjsydsyqcrht_df
                                                WHERE   dsc_biz_operation IN ('insert','update')
                                                AND     (qy_fr_dm IS NULL OR qy_fr_dm NOT RLIKE '^[1-9][0-9]{5}(18|19|20)[0-9]{2}((0[1-9])|10|11|12)(([0-2][1-9])|10|20|30|31)[0-9]{3}[0-9|X|x]$')
                                                AND     (qy_fr_dm RLIKE '^[0-9A-HJ-NPQRTUWXY]{2}[0-9]{6}[0-9A-HJ-NPQRTUWXY]{10}$' OR LENGTH(srr2)>3)
                                            ) t0
                                ) t1
                        LEFT JOIN dwd_qy_main2 t2 ON t2.entname = t1.entname1 AND t2.entname IS NOT NULL AND t2.entname NOT LIKE '%*%' AND LENGTH(t2.entname) > 3
                    ) t2
        ) t3
    LEFT JOIN ods_ai_qymc_in t4 ON t4.entname = t3.entname2 AND t4.uniscid IS NOT NULL
    WHERE   t3.rn2 = 1
) t WHERE   rn = 1
;