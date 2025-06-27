--省市回流_高新技术企业研发中心信息
INSERT OVERWRITE TABLE ods_yfcx_yfzx
SELECT  id    --'ID'
        ,pripid
        ,uniscid
        ,adminenterprise    --'依托单位'
        ,institutename    --'研究院名称'
        ,industry    --'行业'
        ,technology    --'技术领域'
        ,citygovernment    --'所属市'--温州市
        ,towngovernment    --'所属县'--瑞安市
        ,address    --'地址'
        ,s_contact    --'联系人'
        ,s_phone    --'电话'
        ,s_mobile    --'手机'
        ,CASE    WHEN s_email='' THEN NULL 
                 ELSE s_email 
         END s_email    --'邮箱'
        ,s_fax    --'传真'
        ,area    --'场地面积'
        ,cost    --'研发投入'
        ,peoplecount    --'科研人员'
        ,x    --'坐标X'
        ,y    --'坐标Y'
        ,summary    --'简介'
        ,approvedate    --'立项时间'
FROM (
    SELECT  t1.*
            ,COALESCE(t2.pripid,t4.pripid) pripid
            ,COALESCE(t2.uniscid,t3.uniscid) uniscid
            ,row_number() OVER(PARTITION BY COALESCE(t2.uniscid,t3.uniscid,adminenterprise),id ORDER BY COALESCE(t2.estdate,t4.estdate) DESC,id DESC) AS rn
    FROM    stg_yfcx_yfzx t1
    LEFT JOIN dwd_qy_main2 t2 ON t2.entname = t1.adminenterprise AND t2.entname IS NOT NULL AND t2.entname NOT LIKE '%*%' AND LENGTH(t2.entname)>3
    LEFT JOIN ods_ai_qymc_in t3 ON t3.entname = t1.adminenterprise AND t3.uniscid IS NOT NULL
    LEFT JOIN dwd_qy_main2 t4 ON t4.uniscid = t3.uniscid
) t WHERE rn = 1
;