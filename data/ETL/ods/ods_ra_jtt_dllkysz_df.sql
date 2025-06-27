--省市回流_道路旅客运输站信息
INSERT OVERWRITE TABLE ods_ra_jtt_dllkysz_df
SELECT  id    --'ID'
        ,uniscid
        ,com_name    --'业户名称'
        ,com_key    --'经营许可证字'
        ,com_num    --'经营许可证号'
        ,address    --'注册地址'
        ,econ_name    --'经济性质'
        ,station_name    --'客运站名称'
        ,stationno    --'客运站编码'
        ,CASE WHEN kyzdz='' OR kyzdz='0' THEN address ELSE kyzdz END kyzdz    --'客运站地址'
        ,CASE WHEN station_level='三级车站' THEN '3' ELSE station_level END station_level    --'客运站级别'
        ,start_date    --'启用日期'----全空
        ,floor_area    --'占地面积'
        ,parking_area    --'停车场面积'
        ,station_area    --'站房面积'
        ,year_flow    --'设计日发送量'
FROM    (
    SELECT  t1.*
            ,t2.uniscid
            ,ROW_NUMBER() OVER(PARTITION BY com_num,station_name ORDER BY t2.estdate DESC,id DESC) AS rn
    FROM    stg_ra_jtt_dllkysz_df t1
    LEFT JOIN dwd_qy_main2 t2 ON t2.entname = t1.com_name AND t2.entname IS NOT NULL AND t2.entname NOT LIKE '%*%' AND LENGTH(t2.entname)>3
    WHERE t1.dsc_biz_operation IS NULL OR t1.dsc_biz_operation IN('insert','update')
) t WHERE rn = 1
;