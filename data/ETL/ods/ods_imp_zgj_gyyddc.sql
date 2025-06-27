--资规局工业用地调查_导入
INSERT OVERWRITE TABLE ods_imp_zgj_gyyddc
SELECT  land_index    --'地块索引号'
        ,holder0 AS land_holder    --'土地权利人'
        ,COALESCE(uniscid2,t4.uniscid) land_holder_code    --'土地权利人社会信用代码'
        ,land_holder_code AS old_uniscid
        ,0 only_bit    --'是否1企1地'
        ,town    --'所在乡镇'
        ,village    --'所在村'
        ,transfer_contract    --'出让合同号（或划拨决定书号）'
        ,estate_cert    --'不动产权证'
        ,elec_no    --'电子监管号'
        ,land_location    --'土地座落'
        ,approval_time    --'用地批准时间'
        ,owner_nature    --'权属性质'
        ,approval_use    --'批准用途'
        ,real_use    --'实际用途'
        ,real_area    --'实际用地面积'
        ,illegal_area    --'违法用地面积'
        ,plan_text    --'规划符合情况'
        ,agree_fix_investment    --'约定固定资产投资总额'
        ,agree_investment_intensity    --'约定投资强度'
        ,agree_per_tax    --'约定亩均税收'
        ,agree_start_time    --'约定开工时间'
        ,agree_end_time    --'约定竣工时间'
        ,real_start_time    --'实际开工时间'
        ,real_end_time    --'实际竣工时间'
        ,plan_plot    --'规划容积率'
        ,real_plot    --'实际容积率'
        ,plan_building_density    --'规划建筑密度'
        ,real_building_density    --'实际建筑密度'
        ,real_building_area    --'实际建筑面积'
        ,building_floor_area    --'建筑基底面积'
        ,bz    --'备注'
        ,illegal_bit    --'是否涉及违法用地'
        ,estate_code    --'不动产单元代码'
        ,supply_area    --'供应面积'
        ,reg_area    --'登记面积'
        ,development_name    --'开发区名称'
        ,development_type    --'开发区类型'
        ,limit_date    --'使用权到期日'
        ,illegal_building_area    --'违章建筑面积'
        ,use_change_bit    --'是否整宗改变用途'
        ,use_change_area    --'改变用途总面积'
        ,use_change_building_area    --'改变用途建筑总面积'
        ,real_tax    --'实际税收总额'
        ,real_per_tax    --'实际亩均税收'
        ,industrial_output    --'工业增加值'
        ,employees_num    --'年平均职工人数'
        ,pollutant_discharge    --'四项主要污染物排放量'
        ,rd_expenditure    --'R&D经费支出'
        ,main_income    --'主营业收入'
        ,land_eval    --'用地评价'
        ,reg_bit    --'是否登记'
        ,supply_bit    --'是否供地'
        ,bz2    --'备注2'
        ,bulid_status    --'开发建设情况'
        ,shape_length
        ,shape_area
FROM    (
            SELECT  t1.*
                    ,COALESCE(t2.uniscid, uniscid1) uniscid2
                    ,CASE    WHEN COALESCE(t2.uniscid, uniscid1) IS NOT NULL THEN NULL 
                             ELSE holder0 
                     END entname2    --用于关联
                    ,ROW_NUMBER() OVER(PARTITION BY land_index ORDER BY COALESCE(t1.estdate,t2.estdate,'9999-12-31') DESC) AS rn
            FROM    (
                        SELECT  t1.*
                                ,t2.estdate
                                ,COALESCE(t2.uniscid, code1) uniscid1
                                ,CASE    WHEN COALESCE(t2.uniscid, code1) IS NOT NULL THEN NULL 
                                         ELSE holder0 
                                 END entname1    --用于关联
                        FROM    (
                                    SELECT  *
                                            ,CASE    WHEN code0 RLIKE "^[1-9][0-9]{5}(18|19|20)[0-9]{2}((0[1-9])|10|11|12)(([0-2][1-9])|10|20|30|31)[0-9]{3}[0-9|X|x]$" THEN NULL
                                                     WHEN code0 RLIKE "^[1-9][0-9]{5}[0-9]{2}((0[1-9])|10|11|12)(([0-2][1-9])|10|20|30|31)[0-9]{3}$" THEN NULL
                                                     WHEN code0 LIKE '%、%' OR code0 LIKE '%等%' THEN code0
                                                     WHEN code0 RLIKE '^[0-9A-HJ-NPQRTUWXY]{2}[0-9]{6}[0-9A-HJ-NPQRTUWXY]{10}$' AND code0 NOT LIKE '330381%' AND code0 NOT LIKE '2021%' THEN code0 
                                                     ELSE NULL 
                                             END code1
                                            ,CASE    WHEN code0 RLIKE "^[1-9][0-9]{5}(18|19|20)[0-9]{2}((0[1-9])|10|11|12)(([0-2][1-9])|10|20|30|31)[0-9]{3}[0-9|X|x]$" THEN NULL
                                                     WHEN code0 RLIKE "^[1-9][0-9]{5}[0-9]{2}((0[1-9])|10|11|12)(([0-2][1-9])|10|20|30|31)[0-9]{3}$" THEN NULL
                                                     WHEN code0 LIKE '%、%' OR code0 LIKE '%等%' THEN NULL
                                                     WHEN code0 RLIKE '^[0-9A-HJ-NPQRTUWXY]{2}[0-9]{6}[0-9A-HJ-NPQRTUWXY]{10}$' THEN NULL 
                                                     ELSE code0 
                                             END regon1    --用于关联
                                    FROM    (
                                                SELECT  *
                                                        ,CASE    WHEN land_holder LIKE '%，%' THEN REGEXP_REPLACE(land_holder,'，','、')
                                                                 WHEN land_holder LIKE '%"%' THEN REGEXP_REPLACE(land_holder,'\\"','')
                                                                 WHEN land_holder LIKE '%/%' THEN REGEXP_REPLACE(land_holder,'\\/','、')
                                                                 WHEN land_holder LIKE '%.%' THEN REGEXP_REPLACE(land_holder,'\\.','、')
                                                                 WHEN land_holder='徐贤焕4户' THEN '徐贤焕等4户'
                                                                 WHEN land_holder='周锡弟5户' THEN '周锡弟等5户'
                                                                 WHEN land_holder='张万区张传燕等6户' THEN '张万区、张传燕等6户'
                                                                 WHEN land_holder='陈建国郑春眉' THEN '陈建国、郑春眉'
                                                                 WHEN land_holder='陈雪芹贾灵欣' THEN '陈雪芹、贾灵欣'
                                                                 WHEN land_holder='池小哲池小萍' THEN '池小哲、池小萍'
                                                                 WHEN land_holder='戴维森潘广盟' THEN '戴维森、潘广盟'
                                                                 WHEN land_holder='戴金伟戴祥隆' THEN '戴金伟、戴祥隆'
                                                                 WHEN land_holder='金国富郭国亮' THEN '金国富、郭国亮'
                                                                 WHEN land_holder='金青峰章丽英' THEN '金青峰、章丽英'
                                                                 WHEN land_holder='李永贵游世永葛国洪蔡宋富夏成棉' THEN '李永贵、游世永、葛国洪、蔡宋富、夏成棉'
                                                                 WHEN land_holder='李云锋林海芬' THEN '李云锋、林海芬'
                                                                 WHEN land_holder='林德安林德亨林阿仙' THEN '林德安、林德亨、林阿仙'
                                                                 WHEN land_holder='林德炯刘彩玲' THEN '林德炯、刘彩玲'
                                                                 WHEN land_holder='林德尧林康华' THEN '林德尧、林康华'
                                                                 WHEN land_holder='林光龙林光土' THEN '林光龙、林光土'
                                                                 WHEN land_holder='林光泉林光法' THEN '林光泉、林光法'
                                                                 WHEN land_holder='林华东林星华' THEN '林华东、林星华'
                                                                 WHEN land_holder='林晓韩林晓东' THEN '林晓韩、林晓东'
                                                                 WHEN land_holder='林晓卫周凤英' THEN '林晓卫、周凤英'
                                                                 WHEN land_holder='马千惠蔡建兵' THEN '马千惠、蔡建兵'
                                                                 WHEN land_holder='倪锦荣夏成年陈国清张万成' THEN '倪锦荣、夏成年、陈国清、张万成'
                                                                 WHEN land_holder='钱志贤戴文玲' THEN '钱志贤、戴文玲'
                                                                 WHEN land_holder='邵敏邱海波' THEN '邵敏、邱海波'
                                                                 WHEN land_holder='邵伟国潘新新' THEN '邵伟国、潘新新'
                                                                 WHEN land_holder='施权繁施权珍' THEN '施权繁、施权珍' 
                                                                 WHEN land_holder='王彬鹤王田光' THEN '王彬鹤、王田光'
                                                                 WHEN land_holder='王继曾许恩丽' THEN '王继曾、许恩丽'
                                                                 WHEN land_holder='王钿焕王钿胜张伟王银华刘万林' THEN '王钿焕、王钿胜、张伟、王银华、刘万林'
                                                                 WHEN land_holder='谢振千吴余凤' THEN '谢振千、吴余凤'
                                                                 WHEN land_holder='徐坚陈建肖' THEN '徐坚、陈建肖'
                                                                 WHEN land_holder='杨金林郑祥法' THEN '杨金林、郑祥法'
                                                                 WHEN land_holder='虞冠勉戴定海' THEN '虞冠勉、戴定海'
                                                                 WHEN land_holder='张传斌张爱贤' THEN '张传斌、张爱贤'
                                                                 WHEN land_holder='张弓张传流' THEN '张弓、张传流'
                                                                 WHEN land_holder='郑光明郑邦锡冯寿林戴申友戴云水戴金荣' THEN '郑光明、郑邦锡、冯寿林、戴申友、戴云水、戴金荣'
                                                                 WHEN land_holder='郑素黄倍倍' THEN '郑素、黄倍倍'
                                                                 WHEN land_holder='钟金贤李花权' THEN '钟金贤、李花权'
                                                                 WHEN land_holder='周隆周波' THEN '周隆、周波'
                                                                 WHEN land_holder='朱良高陈建余朱良飞' THEN '朱良高、陈建余、朱良飞'
                                                                 WHEN land_holder='瑞安市同帆锁业有限公司浙江华骐瑞材料有限公司' THEN '瑞安市同帆锁业有限公司、浙江华骐瑞材料有限公司' 
                                                                 WHEN land_holder LIKE '市%' THEN CONCAT('瑞安',land_holder)
                                                                 ELSE TRIM(land_holder) 
                                                         END holder0
                                                        ,CASE    WHEN land_holder_code LIKE '%?%' THEN REGEXP_REPLACE(land_holder_code,'\\?','')
                                                                 WHEN land_holder_code LIKE '%；%' THEN REGEXP_REPLACE(land_holder_code,'；','、')
                                                                 WHEN land_holder_code='30381120331120041' THEN '330381120331120041' 
                                                                 WHEN land_holder_code='9233038MA2JB4N3XL' THEN '92330381MA2JB4N3XL'
                                                                 WHEN land_holder_code='92330381MA290054G' THEN '92330381MA29A0054G'
                                                                 WHEN land_holder_code='91330381721083942' THEN '91330381721083942Q'
                                                                 WHEN land_holder_code='91330381l18390345N' THEN '91330381L18390345N'
                                                                 WHEN land_holder_code='92330381JMA2C6BBX40' THEN '91330381751926082E'
                                                                 WHEN land_holder_code='330325197208206131330325197509106126' THEN '330325197208206131、330325197509106126'
                                                                 WHEN land_holder_code='92330381MA2BWNEU2091330381678426953Q' THEN '92330381MA2BWNEU20、91330381678426953Q'
                                                                 WHEN land_holder_code='9133038166171147k91330381MA2JBX4J9P' THEN '9133038166171147K、91330381MA2JBX4J9P'
                                                                 WHEN land_holder='名博有限公司' THEN '913303811456437955'
                                                                 WHEN land_holder='金恩食品有限公司' THEN '913303267877116220'
                                                                 WHEN land_holder='瑞旭塑胶' THEN '91330381MA8FC7WY1R'
                                                                 WHEN land_holder='宏利塑料机械厂' THEN '91330381L57419489L'
                                                                 WHEN land_holder='瑞锋模具厂' THEN '92330381MA2BTLKC1U'
                                                                 WHEN land_holder='栗部香食（食品加工厂）' THEN '91330381MA285KHK19'
                                                                 WHEN land_holder='晟友机械厂' THEN '91330381MA7D4H1KXT'
                                                                 WHEN land_holder='超宇复合厂' THEN '91330381MA297RTPXL'
                                                                 WHEN land_holder='新峰石业' THEN '91330381MA2JCB1J50'
                                                                 WHEN land_holder='诚鸿箱包有限公司分厂' THEN '91330381MA8FBM953P'
                                                                 WHEN land_holder='布拉格鞋帮厂' THEN '913303810568725029'
                                                                 WHEN land_holder='瑞亮鞋业有限公司' THEN '913303810916870030'
                                                                 WHEN land_holder='国球鞋业' THEN '9133038108529422XC'
                                                                 WHEN land_holder='鸿顺鞋业' THEN '92330381MA2C8HLK93'
                                                                 WHEN land_holder='金榜鞋业' THEN '91330381069210233N'
                                                                 WHEN land_holder='靓加酷鞋业' THEN '91330381L3656525X6'
                                                                 WHEN land_holder='酷泒鞋业' THEN '91330381L12512276P'
                                                                 WHEN land_holder='勤达物流' THEN '91330381MA2JBX4X3G'
                                                                 WHEN land_holder='升泰鞋厂' THEN '913303810669162570'
                                                                 WHEN land_holder='兴富鞋业' THEN '91330381069229954C'
                                                                 WHEN land_holder='亚仕鞋业' THEN '91330381MA8FBP3M2H'
                                                                 WHEN land_holder='欢康鞋业' THEN '92330381MA2BYU8769'
                                                                 WHEN land_holder='大众复合厂' THEN '9133038107759832X1'
                                                                 WHEN land_holder='瑞祥鞋面印花加工厂' THEN '91330381MA297T3EX0'
                                                                 WHEN land_holder='新安纸盒厂' THEN '91330381MA2BW7LB8P'
                                                                 WHEN land_holder='精粮农业农机专业合作社' THEN '933303815681949522'
                                                                 WHEN land_holder='回力士鞋业有限公司' THEN '91330381793394344E'
                                                                 WHEN land_holder='孙从里鞋材加工场' THEN '92330381MA2AQQ6X0B'
                                                                 WHEN land_holder='南方人造革厂' THEN '913303811456684315'
                                                                 WHEN land_holder='国华铜砂加工厂' THEN '91330381MA8G06TH6Y'
                                                                 WHEN land_holder='华丰耐火器厂' THEN '91330381742004262N'
                                                                 WHEN land_holder='海安轻工机械厂' THEN '91330381MA2GCC4GXB'
                                                                 WHEN land_holder='九洲汽摩配有限公司' THEN '913303811456607988'
                                                                 WHEN land_holder='虎光标准件厂' THEN '91330381MA8G05GA3E'
                                                                 WHEN land_holder='春煊铝制品厂' THEN '91330381MA285LGB4U'
                                                                 WHEN land_holder='罗凤金平耐火陶瓷厂' THEN '913303811456488281'
                                                                 WHEN land_holder='华新塑料制品厂' THEN '91330381566992125T'
                                                                 WHEN land_holder='金威粉末冶金厂' THEN '91330381L15339018U'
                                                                 WHEN land_holder='南翔公司' THEN '913303817410485895'
                                                                 WHEN land_holder='瑞平机械厂' THEN '91330381677249262Q'
                                                                 WHEN land_holder='锡博机动车部件厂' THEN '91330381MA8FBUH72F'
                                                                 WHEN land_holder='德建滤清器厂' THEN '92330381MA2C97245G'
                                                                 WHEN land_holder='马南行政村下宫农机宿舍' THEN '913303817511781760'
                                                                 WHEN land_holder='安祥散热器厂' THEN '913303817154936975'
                                                                 WHEN land_holder='隆庆石材' THEN '92330381MA29AX5R69'
                                                                 WHEN land_holder='阿清木线制品厂' THEN '92330381MA287K2G4N'
                                                                 ELSE TRIM(land_holder_code) 
                                                         END code0
                                                FROM    stg_imp_zgj_gyyddc
                                            ) t0
                                ) t1
                        LEFT JOIN dwd_qy_main2 t2 ON t2.regno = t1.regon1 AND t2.regno IS NOT NULL
                    ) t1
            LEFT JOIN dwd_qy_main2 t2 ON t2.entname = t1.entname1 AND t2.entname IS NOT NULL AND t2.entname NOT LIKE '%*%' AND LENGTH(t2.entname) > 3 
        ) t3
LEFT JOIN ods_ai_qymc_in t4 ON t4.entname = t3.entname2 AND t4.uniscid IS NOT NULL
WHERE   rn = 1
;

--排除多企一地相关的 一企一地记录
WITH cur_code AS ( 
    SELECT /*+ MAPJOIN(s2) */ DISTINCT s1.land_holder_code
    FROM (SELECT land_holder_code FROM ods_imp_zgj_gyyddc WHERE land_holder_code IS NOT NULL GROUP BY land_holder_code HAVING COUNT(1) = 1) s1 
    LEFT JOIN (SELECT DISTINCT land_holder_code FROM ods_imp_zgj_gyyddc WHERE land_holder LIKE '%、%' OR land_holder LIKE '%等%' OR land_holder_code LIKE '%、%' OR land_holder_code LIKE '%等%') s2 ON INSTR(s2.land_holder_code,s1.land_holder_code)>0 
    WHERE s2.land_holder_code IS NULL 
)

--标识 一企一地记录
INSERT OVERWRITE TABLE ods_imp_zgj_gyyddc
SELECT  land_index    --'地块索引号'
        ,land_holder    --'土地权利人'
        ,CASE    WHEN t1.land_holder_code IS NOT NULL THEN t1.land_holder_code 
                 WHEN land_holder LIKE '%、%' OR land_holder LIKE '%等%' OR land_holder LIKE '%个体户%' OR LENGTH(land_holder)<=3 THEN old_uniscid
                 WHEN land_holder IN ('机械堆场','健美二厂','羊毛衫厂','毛纱市场','木松农业设施钢棚','上沙塘村空置钢棚','兔宝宝健康板材仓库','华明石材','金豆一次性批发用品','朱安友岩场','海燕企业','谷氏宗祠','抽邦线厂','宝业皮革经营部','名晟豪华车专修','仙新油库','汽摩配原材料市场','金国立木材加工厂','潘晓光机械厂','东辰机械','御海名车行','云江汽车一站式服务中心','四方塑料厂','南镇米厂','文成人织带厂','孙桥丁格复合厂','干生高频厂','明星法器厂','王祝织带加工厂','翁垟后跟厂','下社村染料加工厂','卓岙村山边鞋垫厂','威酷鞋业','凯斯特鞋业','哈蓝猫鞋业','天邦海绵厂','亿舒踏鞋业','江溪锯板岳家具厂','矽利康加工厂','阿红线业','吴善军加工厂','昌生淀粉厂','东科机床修理厂','盛源压铸厂','张玲引模具加工厂','春海塑料机械配件厂','方正纸箱厂','联丰粉末冶金厂','金星炉业厂','金连冲件厂','日浩汽车雨刮器厂'
                                    ) THEN old_uniscid
                 ELSE NULL 
         END land_holder_code   --'土地权利人社会信用代码'
        ,old_uniscid
        ,CASE    WHEN t2.land_holder_code IS NULL THEN 0 
                 ELSE 1 
         END only_bit    --'是否1企1地'
        ,town    --'所在乡镇'
        ,village    --'所在村'
        ,transfer_contract    --'出让合同号（或划拨决定书号）'
        ,estate_cert    --'不动产权证'
        ,elec_no    --'电子监管号'
        ,land_location    --'土地座落'
        ,approval_time    --'用地批准时间'
        ,owner_nature    --'权属性质'
        ,approval_use    --'批准用途'
        ,real_use    --'实际用途'
        ,real_area    --'实际用地面积'
        ,illegal_area    --'违法用地面积'
        ,plan_text    --'规划符合情况'
        ,agree_fix_investment    --'约定固定资产投资总额'
        ,agree_investment_intensity    --'约定投资强度'
        ,agree_per_tax    --'约定亩均税收'
        ,agree_start_time    --'约定开工时间'
        ,agree_end_time    --'约定竣工时间'
        ,real_start_time    --'实际开工时间'
        ,real_end_time    --'实际竣工时间'
        ,plan_plot    --'规划容积率'
        ,real_plot    --'实际容积率'
        ,plan_building_density    --'规划建筑密度'
        ,real_building_density    --'实际建筑密度'
        ,real_building_area    --'实际建筑面积'
        ,building_floor_area    --'建筑基底面积'
        ,bz    --'备注'
        ,illegal_bit    --'是否涉及违法用地'
        ,estate_code    --'不动产单元代码'
        ,supply_area    --'供应面积'
        ,reg_area    --'登记面积'
        ,development_name    --'开发区名称'
        ,development_type    --'开发区类型'
        ,limit_date    --'使用权到期日'
        ,illegal_building_area    --'违章建筑面积'
        ,use_change_bit    --'是否整宗改变用途'
        ,use_change_area    --'改变用途总面积'
        ,use_change_building_area    --'改变用途建筑总面积'
        ,real_tax    --'实际税收总额'
        ,real_per_tax    --'实际亩均税收'
        ,industrial_output    --'工业增加值'
        ,employees_num    --'年平均职工人数'
        ,pollutant_discharge    --'四项主要污染物排放量'
        ,rd_expenditure    --'R&D经费支出'
        ,main_income    --'主营业收入'
        ,land_eval    --'用地评价'
        ,reg_bit    --'是否登记'
        ,supply_bit    --'是否供地'
        ,bz2    --'备注2'
        ,bulid_status    --'开发建设情况'
        ,shape_length
        ,shape_area
FROM    ods_imp_zgj_gyyddc t1
LEFT JOIN cur_code t2 ON t2.land_holder_code = t1.land_holder_code
;