--省市回流_拖欠工资黑名单信息 + 拖欠农民工工资失信联合惩戒对象名单信息
INSERT OVERWRITE TABLE ods_ra_sbj_tqgzhmd_df
SELECT  COALESCE(t1.key_md5,t2.key_md5) key_md5
        ,COALESCE(t1.aab004,t2.aab004) aab004    --'对象名称'
        ,COALESCE(t1.aab003,t2.aab003) aab003    --'统一社会信用代码'
        ,COALESCE(t1.lrsj,t2.lrsj) lrsj    --'列入时间'
        ,COALESCE(t1.fbqx,t2.fbqx) fbqx    --'预计退出日期'
        ,COALESCE(t1.aab013,t2.aab013) aab013    --'法定代表人'
        ,COALESCE(t1.aac002,t2.aac002) aac002    --'法定代表人证件号'
        ,COALESCE(t1.zjlx,t2.zjlx) zjlx    --'法定代表人证件类型'--1居民身份证2军官证3外国人护照4港澳居民来往内地通行证5台湾居民来往大陆通行证6港澳台居民居住证7其他证件
        ,COALESCE(t1.fbjg,t2.fbjg) fbjg    --'发布机关名称'
        ,COALESCE(t1.wsh,t2.wsh) wsh    --'文书号'
        ,COALESCE(t1.abb012,t2.abb012) abb012    --'列入黑名单事由'
        ,COALESCE(t1.lryj,t2.lryj) lryj    --'列入依据'
        ,COALESCE(t1.xmmc,t2.xmmc) xmmc    --'失信黑名单项目名称'
        ,COALESCE(t1.dqtcqk,t2.dqtcqk) dqtcqk    --'到期退出情况'
        ,COALESCE(t1.xqyy,t2.xqyy) xqyy    --'续期原因'
        ,COALESCE(t1.aae013,t2.aae013) aae013    --'备注'
FROM    (
            SELECT  *
                    ,MD5(CONCAT_WS('#',aab003,lrsj,wsh)) key_md5
            FROM    stg_ra_sbj_tqnmggzsxlhcjdx_df
            WHERE   aab003 IS NOT NULL
        ) t1
FULL JOIN (
              SELECT  *
                      ,MD5(CONCAT_WS('#',aab003,lrsj,wsh)) key_md5
              FROM    stg_ra_sbj_tqgzhmd_df
          ) t2
ON      t2.key_md5 = t1.key_md5
;