--经信局工业厂房出租_导入
--create table ods_imp_jxj_gycfcc_241021 as select * from ods_imp_jxj_gycfcc ;
INSERT OVERWRITE TABLE ods_imp_jxj_gycfcc 
SELECT year_no
    ,t3.town --'属地'
    ,no
    ,COALESCE(t3.land_index,t5.land_index) land_index --'地块索引'
	,CASE    WHEN t5.land_index IS NULL THEN 0 
             ELSE 1 
     END index_bit --'1企1地补齐索引'
    ,COALESCE(uniscid2,t4.uniscid) land_holder_code --'出租统一信用代码'
    ,t3.land_holder_code AS old_uniscid
    ,holder0 AS land_holder --'出租主体'
    ,land_above --'出租规上企业（是/否）'
    ,person0 AS land_person --'出租负责人'
    ,REGEXP_REPLACE(mobile0, '\\?', '') land_mobile --'出租联系电话'
    ,land_addr --'出租地址'
    ,total_area
    ,REGEXP_REPLACE(land_area, '\\?', '') land_area --'出租面积（㎡）'
    ,tenant0 AS tenant --'承租对象'
    ,tenant_above --'承租规上企业（是/否）'
    ,tenant_code0 AS tenant_uniscid --'承租统一信用代码'
    ,tenant_code --'原承租统一信用代码'
    ,REGEXP_REPLACE(tenant_area, '\\?', '') tenant_area --'承租面积'
    ,tenant_industry --'承租行业类别'
    ,tenant_person --'承租负责人'
    ,REGEXP_REPLACE(tenant_mobile, '\\?', '') tenant_mobile --'承租联系电话'
    ,rect_type1 AS rect_type --'整治类型（填序号）'
    ,rect_over --'已完成整治（是/否）'
    ,remark --'备注'
	,update_date
FROM    (
            SELECT  t1.*
                    ,COALESCE(t2.uniscid, uniscid1) uniscid2
                    ,CASE    WHEN COALESCE(t2.uniscid, uniscid1) IS NOT NULL THEN NULL
                             WHEN holder0 LIKE '%个人%' OR holder0=person0 OR LENGTH(holder0)<=3 THEN NULL  
                             ELSE holder0 
                     END entname2    --用于关联
                    ,ROW_NUMBER() OVER(PARTITION BY rownum ORDER BY COALESCE(t1.estdate,t2.estdate,'9999-12-31') DESC) AS rn
            FROM    (
                        SELECT  t1.*
                                ,t2.estdate
                                ,COALESCE(t2.uniscid, code1) uniscid1
                                ,CASE    WHEN COALESCE(t2.uniscid, code1) IS NOT NULL THEN NULL 
                                         WHEN holder0 LIKE '%个人%' OR holder0=person0 OR LENGTH(holder0)<=3 THEN NULL 
                                         ELSE holder0 
                                 END entname1    --用于关联
                        FROM    (
                                    SELECT  *
                                            ,REGEXP_REPLACE(SUBSTR(rect_type0,1,LENGTH(rect_type0)-1),'0','10') rect_type1
                                            ,CASE    WHEN code0 RLIKE "^[1-9][0-9]{5}(18|19|20)[0-9]{2}((0[1-9])|10|11|12)(([0-2][1-9])|10|20|30|31)[0-9]{3}[0-9|X|x]$" THEN NULL
                                                     WHEN code0 RLIKE "^[1-9][0-9]{5}[0-9]{2}((0[1-9])|10|11|12)(([0-2][1-9])|10|20|30|31)[0-9]{3}$" THEN NULL
                                                     WHEN code0 LIKE '%、%' OR code0 LIKE '%等%' THEN code0
                                                     WHEN code0 RLIKE '^[0-9A-HJ-NPQRTUWXY]{2}[0-9]{6}[0-9A-HJ-NPQRTUWXY]{10}$' AND code0 NOT LIKE '330381%' THEN code0 
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
                                                        ,ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) as rownum --用于唯一标识
                                                        ,CASE    WHEN land_holder LIKE '%，%' THEN REGEXP_REPLACE(land_holder,'，','、')
                                                                 WHEN land_holder LIKE '%"%' THEN REGEXP_REPLACE(land_holder,'\\"','')
                                                                 WHEN land_holder LIKE '%/%' THEN REGEXP_REPLACE(land_holder,'\\/','、')
                                                                 WHEN land_holder LIKE '%.%' THEN REGEXP_REPLACE(land_holder,'\\.','、')
                                                                 WHEN land_holder IS NULL AND land_person='程模震13587962766范春根13967762371许光亮13758760918' THEN '程模震、范春根、许光亮'
                                                                 WHEN land_holder='个人' AND land_person='"林枫,李光"' THEN '林枫、李光'
                                                                 WHEN land_holder IN ('个人','（个人）') OR land_holder IS NULL THEN CONCAT(COALESCE(land_person,'（个人）'))
                                                                 WHEN land_holder='何海弟（金笃社）' THEN '何海弟、金笃社'
                                                                 WHEN land_holder='瑞安市温康鞋厂，平亮日用品' THEN '瑞安市温康鞋厂、平亮日用品'
                                                                 WHEN land_holder='（瑞安市驰远鞋业有限公司）' THEN '瑞安市驰远鞋业有限公司'
                                                                 ELSE TRIM(land_holder) 
                                                         END holder0
                                                        ,CASE    WHEN land_holder_code='9133038173382201X1L' THEN '9133038173382201XK'
                                                                 WHEN land_holder_code='913303817909543XM' THEN '9133038179095430XM'
                                                                 WHEN land_holder_code='145666583' THEN '91330381145666583P'
                                                                 WHEN land_holder='黄友锡(飞鹿鞋厂）' THEN '91330381MA8G0R5F4Q'
                                                                 WHEN land_holder='林福兴（兴泰印刷包装）' THEN '91330381792084766P'
                                                                 WHEN land_holder='蔡其荣（瑞安市隆泰箱包配件有限公司）' THEN '91330381MAD66CL725'
                                                                 WHEN land_holder='贾道鹏（瑞安市宏威鞋业有限公司）' THEN '913303815985062162'
                                                                 WHEN land_holder='金美龙（瑞安市利友复合加工厂）' THEN '92330381MA287WCR0D'
                                                                 WHEN land_holder='林周涛（瑞安市迈凯宏鞋业有限公司）' THEN '91330381MADBLABB21'
                                                                 WHEN land_holder='孙景（温州联迪实业有限公司）' THEN '91330381MAD6GFXE98'
                                                                 WHEN land_holder='孙一华（亿华实业）' THEN '91330381MA2AW7CN86'
                                                                 WHEN land_holder='孙景权（再生胶鞋厂）' THEN '91330381145669725Q'
                                                                 WHEN land_holder='陈崇育（金利特鞋业）（三驰鞋业）' THEN '91330381704388402J'
                                                                 WHEN land_holder='纯宏鞋厂（康尔纳鞋业内）' THEN '913303813502008704'
                                                                 WHEN land_holder='潘献乐（金利旅游用品）' THEN '913303813136267926'
                                                                 WHEN land_holder='鲍成宝（鸿大箱包配件）' THEN '91330381570555892R'
                                                                 WHEN land_holder='谷安源（瑞安市瑞谷箱包配件厂）' THEN '92330381MA2C9KCE6D'                                                                 
                                                                 WHEN land_holder='瑞安市佳彩印刷包装有限公司（林晓云）' THEN '91330381562392771D'
                                                                 WHEN land_holder='瑞安市洁敏贸易有限公司（汤凤銮）' THEN '91330381MA29A3GC12'
                                                                 WHEN land_holder='栗部香食（食品加工厂）' THEN '91330381MA285KHK19'
                                                                 WHEN land_holder='精粮农业农机专业合作社' THEN '933303815681949522'
                                                                 WHEN land_holder='回力士鞋业有限公司' THEN '91330381793394344E'
                                                                 WHEN land_holder='南方人造革厂' THEN '913303811456684315'
                                                                 WHEN land_holder='高格公司' THEN '91330381145637192Y'
                                                                 WHEN land_holder='华华橡胶' THEN '9133038168910735XF'
                                                                 WHEN land_holder='华安泰公司' THEN '913303812554712506'
                                                                 WHEN land_holder='水泵二厂' THEN '913303811456334154'
                                                                 WHEN land_holder='国名液压机' THEN '92330381MA2C2JJ996'
                                                                 WHEN land_holder='安祥散热器厂' THEN '913303817154936975'
                                                                 WHEN land_holder='巧夫人电器有限公司' THEN '91330381MA2856T813'
                                                                 WHEN land_holder='龙珊经济合作社' THEN '913303815753494658'
                                                                 WHEN land_holder='下泽村委会' THEN '543303817757105501'
                                                                 WHEN land_holder='龙腾村委会' THEN 'N2330381MF13828267'
                                                                 WHEN land_holder='江隆村委会' THEN '54330381ME3471554C'
                                                                 ELSE TRIM(land_holder_code) 
                                                         END code0
                                                        ,CASE    WHEN land_person='程模震13587962766范春根13967762371许光亮13758760918' THEN '程模震、范春根、许光亮'
                                                                 WHEN land_person='"林枫,李光"' THEN '林枫、李光'
                                                                 WHEN land_person LIKE '%，%' THEN REGEXP_REPLACE(land_person,'，','、')
                                                                 WHEN land_person LIKE '%,%' THEN REGEXP_REPLACE(land_person,',','、')
                                                                 WHEN land_person LIKE '%"%' THEN REGEXP_REPLACE(land_person,'\\"','')
                                                                 ELSE TRIM(land_person) 
                                                         END person0
                                                        ,CASE    WHEN land_person='程模震13587962766范春根13967762371许光亮13758760918' THEN '13587962766、13967762371、13758760918'
                                                                 WHEN land_person='137068888080577-58907783' THEN '13706888808、0577-58907783'
                                                                 WHEN land_person='13706889680.13706647195.' THEN '13706889680、13706647195'
                                                                 WHEN land_person='18968789312.13958819555.' THEN '18968789312、13958819555'
                                                                 ELSE TRIM(land_mobile) 
                                                         END mobile0
                                                        ,CASE    WHEN tenant_code='145666583' THEN '91330381145666583P'
                                                                 WHEN tenant_code='MA2CN9316' THEN '91330381MA2CN93J6X'
                                                                 WHEN tenant_code='MA2L3YCM5' THEN '91330381MA2L3YCM5A'
                                                                 WHEN LENGTH(tenant_code)=18 AND tenant_code LIKE '%O%' THEN REGEXP_REPLACE(tenant_code,'O','0')
                                                                --  WHEN tenant_code='91330381MA2CNG5TOY' THEN '91330381MA2CNG5T0Y'
                                                                --  WHEN tenant_code='92330381MA2HAQKLOH' THEN '92330381MA2HAQKL0H'
                                                                --  WHEN tenant_code='91330381MA2AQ4WPOL' THEN '91330381MA2AQ4WP0L'
                                                                --  WHEN tenant_code='91330381MACOAYUX7E' THEN '91330381MAC0AYUX7E'
                                                                --  WHEN tenant_code='91330381MADQCCDJOF' THEN '91330381MADQCCDJ0F'
                                                                --  WHEN tenant_code='92330381MA2875OU5L' THEN '92330381MA28750U5L'
                                                                --  WHEN tenant_code='92330381MA298EN9OT' THEN '92330381MA298EN90T'
                                                                --  WHEN tenant_code='92330381MA2C5RQQOM' THEN '92330381MA2C5RQQ0M'
                                                                --  WHEN tenant_code='92330381MA2CNTDLOX' THEN '92330381MA2CNTDL0X'
                                                                 WHEN LENGTH(tenant_code)=18 AND tenant_code LIKE '%I%' THEN REGEXP_REPLACE(tenant_code,'I','1')
                                                                --  WHEN tenant_code='9233038IMA294RHU8A' THEN '92330381MA294RHU8A'
                                                                --  WHEN tenant_code='92330381MA287LINXT' THEN '92330381MA287L1NXT'
                                                                --  WHEN tenant_code='9233038IMA287QR177' THEN '92330381MA287QR177'
                                                                 WHEN LENGTH(tenant_code)=18 AND tenant_code LIKE '%Z%' THEN REGEXP_REPLACE(tenant_code,'Z','2')
                                                                --  WHEN tenant_code='91330381MAZR1M7L10' THEN '91330381MA2L1M7L10'
                                                                 WHEN LENGTH(tenant_code)=23 AND tenant_code LIKE '%(1/1)' THEN SUBSTR(tenant_code,1,18)
                                                                -- WHEN tenant_code='91330381MA2L7PQB14(1/1)' THEN '91330381MA2L7PQB14'
                                                                 WHEN tenant_code='9133034MA2AW721E32' THEN '91330304MA2AWE1E32'
                                                                 WHEN tenant_code='9133038131355515400' THEN '913303813135515400'
                                                                 WHEN tenant_code='91330381L03920974434' THEN '91330381L092097434'
                                                                 WHEN tenant_code='91330381L25491603N111D' THEN '91330381L25491603N'
                                                                 WHEN tenant_code='91330381MA2J89TR113' THEN '91330381MA2J89TR1B'
                                                                 WHEN tenant_code='91330381MA2L4E98A' THEN '91330381MA2L4EKG8A'
                                                                 WHEN tenant_code='91330381MABQFXTFXMC' THEN '91330381MABQFXTFXM'
                                                                 WHEN tenant_code='91330381MACALK410' THEN '91330381MACALK4101'
                                                                 WHEN tenant_code='91330381MACRMUJ3C' THEN '91330381MAC1RMUJ3C'
                                                                 WHEN tenant_code='91330381MAHARC51P' THEN '91330381MA2HARC51P'
                                                                 WHEN tenant_code='91330381MD1BK612U' THEN '91330381MAD1BK612U'
                                                                 WHEN tenant_code='92330381MA28P3AXQ' THEN '92330381MA286P3AXQ'
                                                                 WHEN tenant_code='92330381MA2CN0Q3M' THEN '92330381MA2CN0QG3M'
                                                                 WHEN tenant_code='92330381MA2JD0M8J' THEN '92330381MA2JAD0M8J'
                                                                 WHEN tenant_code='92330381MA2V0G5H6D' THEN '92330381MA2C0G5H6D'
                                                                 WHEN tenant_code='92330381MAC4FCRW' THEN '92330381MAC4FCRW08'
                                                                 WHEN tenant_code='9233081MA2ATWHM37' THEN '92330381MA2ATWHM37'
                                                                 WHEN tenant_code='92330381MA2AWD069' THEN '92330381MA2AWD069W'
                                                                 WHEN tenant_code='91330203MA7G6AFA1' THEN '91330203MA7G6AFA1T'
                                                                 WHEN tenant_code='91330381MA2914N93' THEN '91330381MA29814N93'
                                                                 WHEN tenant_code='9233081MA296FXY00' THEN '92330381MA296FXY00'
                                                                 WHEN tenant_code='913205079856118B' THEN '91320507079856118B'
                                                                 WHEN tenant_code='92330381MA2C7E7TX' THEN '92330381MA2C7E7TX1'
                                                                 WHEN tenant_code='9130381MA2L4LJH94' THEN '91330381MA2L4LJH94'
                                                                 WHEN tenant_code='9133038MA2L3XBD2U' THEN '91330381MA2L3XBD2U'
                                                                 WHEN tenant_code='91330381MADKU0B5X' THEN '91330381MADKAU0B5X'
                                                                 WHEN tenant_code='91330381MADS59A9H8R' THEN '91330381MAD59A9H8R'
                                                                 WHEN tenant_code='92330381MA2BU6Y82LL' THEN '92330381MA2BU6Y82U'
                                                                 WHEN tenant_code='91330381MA4259EX29U' THEN '91330381MAD59EX29U'
                                                                 WHEN tenant_code='92330381MAZ2H9XLWOU' THEN '92330381MA2H9XLW0U'
                                                                 WHEN tenant='高格公司' THEN '91330381145637192Y'
                                                                 WHEN tenant='小江机械加工厂' THEN '92330381MA2CTND488'
                                                                 WHEN tenant='丁爱兰塑料加工厂' THEN '92330381MA2HB5GQ4F'
                                                                 WHEN tenant='义兴众鞋业' THEN '91330381MADCUHTT34'
                                                                 WHEN tenant='伟力液压机' THEN '91330381712531184H'
                                                                 WHEN tenant='凯力机械厂' THEN '91330381590582038E'
                                                                 WHEN tenant='刘以新鞋帮加工' THEN '91330381MA7M2KB48N'
                                                                 WHEN tenant='刘智力铣床加工厂' THEN '92330381MA2C7AWL2H'
                                                                 WHEN tenant='博业包装' THEN '92330381MA286Q4077'
                                                                 WHEN tenant='启力包装厂' THEN '91330381MACXDH6T1M'
                                                                 WHEN tenant='品正机械' THEN '91330381MA294ETC1U'
                                                                 WHEN tenant='弘耀鞋业' THEN '91330381MADHCTHW0K'
                                                                 WHEN tenant='璟森鞋厂' THEN '91330381MA7MK4YF98'
                                                                 WHEN tenant='由你选择服装加工厂' THEN '92330381MA2C8F1297'
                                                                 WHEN tenant='申尔美洁具公司' THEN '913303817549393216'
                                                                 WHEN tenant='法西特服装加工厂' THEN '92330381MA2ATG0L3Y'
                                                                 WHEN tenant='百花仙子服装加工厂' THEN '91330381MA8FC6066A'
                                                                 WHEN tenant='百雀得鞋厂(仓库)' THEN '91330381L47057971B'
                                                                 WHEN tenant='祥星电脑绣花厂' THEN '91330381MA2L5CMT76'
                                                                 WHEN tenant='豪磊大理石厂' THEN '92330381MA2BU57E7P'
                                                                 WHEN tenant='足高服装加工厂' THEN '91330381MACN09T410'
                                                                 WHEN tenant='轩源服装加工' THEN '91330381MADRG0037N'
                                                                 WHEN tenant='邓思荣服装加工场' THEN '92330381MA29871LX6'
                                                                 WHEN tenant='金华明服装加工厂' THEN '92330381MA2C74UT9C'
                                                                 WHEN tenant='金顺海车床加工厂' THEN '92330381MA29701F6F'
                                                                 WHEN tenant='鑫旺新材塑' THEN '91330381573969986C'
                                                                 WHEN tenant='吴丽聪塑料薄膜加工' THEN '92330381MA2BWQQCXB'
                                                                 WHEN tenant='吴小荣机械加工厂' THEN '92330381MA296XC32Y'
                                                                 WHEN tenant='昌新朝阳国际宴会中心' THEN '91330381MA2HATF56F'
                                                                 WHEN tenant='瑞朗服饰' THEN '92330381MA2C7RJP9X'
                                                                 WHEN tenant='中京鞋业（1F2F3F）' THEN '91330381MA7EGAN03T'
                                                                WHEN tenant='中泰机械' THEN '91330381552892342H'
                                                                WHEN tenant='中通快运' THEN '91330122MA27XHKQ30'
                                                                WHEN tenant='余淑琴服装加工场' THEN '92330381MA2986PLXU'
                                                                WHEN tenant='余贤春复合加工厂' THEN '92330381MA2C2J821D'
                                                                WHEN tenant='依美珍服装加工厂' THEN '92330381MA2J8Y3467'
                                                                WHEN tenant='华工混凝土公司' THEN '91330381MA2862H8XH'
                                                                WHEN tenant='南润五金' THEN '92330381MA2J8EMT7K'
                                                                WHEN tenant='吴文祥服装加工厂' THEN '92330381MA2L2G215W'
                                                                WHEN tenant='吴正顺绣花加工' THEN '92330381MA2L1YXP21'
                                                                WHEN tenant='吴海燕（订纽扣服务）' THEN '92330381MA2CQ42Y5R'
                                                                WHEN tenant='啊友服装加工厂' THEN '91330381MA285C9D13'
                                                                WHEN tenant='姜文兵鞋帮加工厂' THEN '91330381MA2L878038'
                                                                WHEN tenant='宏聚鞋业' THEN '91330381MACJGGJE24'
                                                                WHEN tenant='巨盛机械' THEN '91330381749840351A'
                                                                WHEN tenant='康然美搭服装厂' THEN '92330381MA2H9RND1X'
                                                                WHEN tenant='张华敏服装加工厂' THEN '92330381MA295UHQ9G'
                                                                WHEN tenant='张小磊服装加工场' THEN '91330381MA8FCDYE7J'
                                                                WHEN tenant='帅府服装加工厂' THEN '91350300MA346J782G'
                                                                WHEN tenant='姜建胜服装加工' THEN '92330703MA2HQQG94K'
                                                                WHEN tenant='吴志刚服装加工场' THEN '92330481MA2CY5UK57'
                                                                WHEN tenant='张斌雄服装加工' THEN '91440118MACE16G056'
                                                                WHEN tenant='张昌海塑料制品厂' THEN '92330381MA2BRH6U8R'
                                                                WHEN tenant='彭来庆塑料加工厂' THEN '92330381MA2BX7A70R'
                                                                WHEN tenant='徐瑞瑞服装加工厂' THEN '92330381MA2JBWLRXD'
                                                                WHEN tenant='徐雷雷电子商务' THEN '92330381MA2BUP2Y3H'
                                                                WHEN tenant='徐顺利加工厂' THEN '92330381MA2953NB06'
                                                                WHEN tenant='戴如意纸箱厂（康润后面一层做配套）' THEN '92430623MA4N7DQC2L'
                                                                WHEN tenant='昕洲商贸行' THEN '92330381MA2AWB4BX8'
                                                                WHEN tenant='李争强服装加工厂' THEN '92330381MA2C68284H'
                                                                WHEN tenant='李云凤服装加工' THEN '92330381MA2C1YDU88'
                                                                WHEN tenant='李冕辅料加工厂' THEN '92330381MA2HA26JXG'
                                                                WHEN tenant='李洪福机械加工厂' THEN '91370112MA93L8Q40R'
                                                                WHEN tenant='李海涛机械加工厂' THEN '92330381MA2ARF9PXN'
                                                                WHEN tenant='李瑞鞋材贸易公司' THEN '91330381MA299XTM2B'
                                                                WHEN tenant='欧派家居集团有限公司（仓库）' THEN '913303810641924278'
                                                                WHEN tenant='汇恒鞋业(4F5F6F)' THEN '91330381MAC8TRD6XP'
                                                                WHEN tenant='鸿博新材料有限公司' THEN '91330381307560301T'
                                                                WHEN tenant='极兔快递公司' THEN '91310118667759488H'
                                                                WHEN tenant='毅隆分厂' THEN '91331081MA7H08XN5R'
                                                                WHEN tenant='鑫登机械' THEN '91330381MA7B0FT801'
                                                                WHEN tenant='林丰鞋面加工' THEN '91330381MADK73FX0H'
                                                                WHEN tenant='林国龙不锈钢' THEN '92330381MA2C447U45'
                                                                WHEN tenant='林建水加工厂' THEN '91330381721084216H'
                                                                WHEN tenant='柯媛媛工艺品加工厂' THEN '92421124MA49UW8G5R'
                                                                WHEN tenant='柳齐九服装加工厂' THEN '92330381MA2972MN04'
                                                                WHEN tenant='毛定安服装加工厂' THEN '91330381MAD703XF86'
                                                                WHEN tenant='江涛服装加工场' THEN '92330381MA2CBB8E7F'
                                                                WHEN tenant='程洪余纸箱加工厂' THEN '92330381MA2C9EXP3R'
                                                                WHEN tenant='缪秀芳鞋子销售' THEN '92330381MA2CAYU18J'
                                                                WHEN tenant='若东冷作加工厂' THEN '91330381MACG6PA593'
                                                                WHEN tenant='范光盛复合加工' THEN '92330381MA294Y3J8M'
                                                                WHEN tenant='蔡之岩标准件厂' THEN '92330381MA2BYD6504'
                                                                WHEN tenant='薛迪飞瓷砖仓库' THEN '92330381MA2945557U'
                                                                WHEN tenant='虞臣彪服装加工厂' THEN '92330381MA296D7NX6'
                                                                WHEN tenant='角主黑子服装加工厂' THEN '92330381MA2JANB56B'
                                                                WHEN tenant='贝莱达鞋业' THEN '92330381MA2966MN6U'
                                                                WHEN tenant='铭利汽配新居分厂' THEN '91330381689982058U'
                                                                WHEN tenant='锦美电脑绣花厂' THEN '91330381MA2JBEE130'
                                                                WHEN tenant='锦阳鞋厂' THEN '91330381MACKF8J959'
                                                                WHEN tenant='陈万昆塑料袋加工' THEN '92330381MA2C1C1M6M'
                                                                WHEN tenant='陈小建服装加工厂' THEN '92330381MA2C8ME20G'
                                                                WHEN tenant='陈晓武加工' THEN '92330381MA2C7ETC0L'
                                                                WHEN tenant='陈洪进织带加工' THEN '92330381MA2C70Y65F'
                                                                WHEN tenant='陈玉建飞织加工' THEN '92330381MA2995G382'
                                                                WHEN tenant='陈金良注塑加工' THEN '92330381MA2C1KRR4E'
                                                                WHEN tenant='魏霞服装加工厂' THEN '92330381MA2C2A9Y5J'
                                                                WHEN tenant='长鸿生物颗粒' THEN '91330381MAC7DH6D72'
                                                                 ELSE TRIM(TOUPPER(tenant_code)) 
                                                         END tenant_code0
                                                        ,CASE    WHEN tenant IS NULL THEN tenant_person
                                                                 WHEN tenant LIKE '%，%' THEN REGEXP_REPLACE(tenant,'，','、')
                                                                 WHEN tenant='余成连（李钗玉）' THEN '余成连、李钗玉'
                                                                 WHEN tenant='余成钦（林美平）' THEN '余成钦、林美平'
                                                                 WHEN tenant='余维荣（建甫）' THEN '余维荣、建甫'
                                                                 WHEN tenant='陈彩荣（张建伟）' THEN '陈彩荣、张建伟'
                                                                 WHEN tenant='余建松（金培钗）' THEN '余建松、金培钗'
                                                                 WHEN tenant='杨福道（张建伟）' THEN '杨福道、张建伟'
                                                                 ELSE TRIM(tenant) 
                                                         END tenant0 
                                                        ,REGEXP_REPLACE(
                                                            REGEXP_REPLACE(
                                                                REGEXP_REPLACE(REGEXP_REPLACE(REGEXP_REPLACE(REGEXP_REPLACE(REGEXP_REPLACE(REGEXP_REPLACE(REGEXP_REPLACE(REGEXP_REPLACE(REGEXP_REPLACE(REGEXP_REPLACE(
                                                                    rect_type, '①', '1')
                                                                    , '②', '2')
                                                                    , '③', '3')
                                                                    , '④', '4')
                                                                    , '⑤', '5')
                                                                    , '⑥', '6')
                                                                    , '⑦', '7')
                                                                    , '⑧', '8')
                                                                    , '⑨', '9')
                                                                    , '⑩', '0')
                                                                , '[^\\d]+', '')
                                                            , '(.{1})', '\\1,')
                                                        rect_type0 
                                                FROM    stg_imp_jxj_gycfcc
                                            ) t0 
                                ) t1
                        LEFT JOIN dwd_qy_main2 t2 ON t2.regno = t1.regon1 AND t2.regno IS NOT NULL
                        
                    ) t1
            LEFT JOIN dwd_qy_main2 t2 ON t2.entname = t1.entname1 AND t2.entname IS NOT NULL AND t2.entname NOT LIKE '%*%' AND LENGTH(t2.entname) > 3 
        ) t3
LEFT JOIN ods_ai_qymc_in t4 ON t4.entname = t3.entname2 AND t4.uniscid IS NOT NULL
LEFT JOIN ods_imp_zgj_gyyddc t5 ON t5.land_holder_code=COALESCE(uniscid2,t4.uniscid) AND t5.only_bit=1
WHERE   rn = 1
;

--处理承租
INSERT OVERWRITE TABLE ods_imp_jxj_gycfcc 
SELECT year_no
    ,town --'属地'
    ,no
    ,land_index --'地块索引'
	,index_bit --'1企1地补齐索引'
    ,CASE    WHEN land_holder_code IS NOT NULL THEN land_holder_code 
             WHEN land_holder LIKE '%、%' OR land_holder LIKE '%等%' OR land_holder LIKE '%个人%' OR land_holder=land_person OR LENGTH(land_holder)<=3 THEN COALESCE(old_uniscid,'')
             WHEN land_holder IN ('卓岙村山边鞋垫厂','河岱自然村生产队','工业区2幢','塘头村出租','沙园村村里出租','法院拍卖（官司中）','郑氏祠堂','飞度园区','郑小超厂房','小梅厂房','林小平他哥厂房','贾道熙厂房','郑金良厂房','金征良厂房','金都瑞厂房','鲍永华厂房') THEN COALESCE(old_uniscid,'')
             ELSE NULL 
     END land_holder_code --'出租统一信用代码'
    ,old_uniscid
    ,land_holder --'出租主体'
    ,land_above --'出租规上企业（是/否）'
    ,land_person --'出租负责人'
    ,land_mobile --'出租联系电话'
    ,land_addr --'出租地址'
    ,total_area
    ,land_area --'出租面积（㎡）'
    ,tenant --'承租对象'
    ,tenant_above --'承租规上企业（是/否）'
    ,CASE    WHEN COALESCE(uniscid2,t4.uniscid) IS NOT NULL THEN COALESCE(uniscid2,t4.uniscid) 
             WHEN tenant LIKE '%、%' OR tenant LIKE '%等%' OR tenant LIKE '%个体%' OR tenant LIKE '%个人%' OR tenant=tenant_person OR LENGTH(tenant)<=3 THEN COALESCE(tenant_code,'')
             WHEN tenant IN ('瑞竹制辊厂','中洲宴会中心','中远童装车间','五林吴银锋仓库','众佳纸片厂','傅品芳服装加工厂','刘君五金加工','刘江弟铣床加工厂','刘群服装加工厂','卖布销售（仓库）','博阳模具','卢爱玉家具（仓库）','叶付荣机械加工厂','吴春强冲床加工厂','塑料加工','夏敏绣花厂','奥凯鞋业踩鞋帮','好乐捷超市','孙林秀花加工','宋红玲塑料制品厂','富锦绣花加工厂','崔华伟机械加工','张星建（4楼）','张朝松车库','张龙鞋模','忠华酒店宴会中心','数控加工','文华缩水加工厂','新卓组注塑','施雪霞服装加工厂','旷光善电商','易冠织带','曹志平服装加工厂','曾煌滨鞋垫生产厂','木型加工厂','朱云申织带加工','朱天良服装加工厂','汽车设备加工','李先棒绣花加工厂','李加才标准件加工','李晓飞木门加工厂','鸿亮卖布销售（仓库）','杨世荣包装加工厂','林中和音乐工作室','林光银塑料加工','林光龙不锈钢冷作','林建顺缩水加工','林昌书鞋帮加工厂','林昌静鞋垫加工厂','桃桃服装加工厂','梁文明五金加工厂','梁荣秋加工厂','江湖机械厂','汪奎鞋帮加工厂','汪超鞋子销售（电商）','程玉和服装加工厂','竺利平注塑加工','管光基织带加工','维加特服装加工厂','胡刚银薄膜加工','胡邵武汽配加工厂','范孝军印花加工','蒲昭斌数控加工','蔡之芬汽配加工','薛一伟标准件厂','飞云电脑车鞋帮加工厂','马明鞋帮加工厂','钱伟数控加工','阳中发印花厂','陈孝木（汽配加工厂）','陈孝权塑料制品厂','陈小波机械加工厂','陈希岳纸箱厂','黄仁安像胶加工','黄姚春服装加工','黄文通铝加工厂','薛光国印花加工','陈纪棉阀芯加工','袁信国冲压件','西布郎纺织（仓库）','许永峰服装加工厂','诺希电子商务','林建定膜加工厂','郑良光机械加工','金乐鞋类销售（电商）','金文莲（织带加工）','鑫潮服饰','汽配组装加工厂','琳鑫服饰','王记勇服装加工厂','王让锦纸箱加工厂','潘瑞凯仓库','浩龙电器','福宝文件柜仓库（无营业执照）','车床加工','大理石加工','皮革销售（仓库）','铁板制业','钢材堆放场','钢筋加工场','赵成秋（3楼）','白天万加工厂','电子商务','电商仓库','服装加工厂','起航百货','鑫胜电子','云周街道仓库','云周街道仓库(移动)','云周街道小作坊','渔具仓库','中晨汽修钣喷中心','中远服装车间','中远绣花车间','佑安迪仓库','初心仓库','印花加工厂','嘉嘉好餐桌','塑料加工厂','床垫加工','稻谷堆放场','紧固件厂','纸箱包装厂','织带加工','模具加工','荣豪仓库','防盗网厂'
                            ) THEN COALESCE(tenant_code,'')
             ELSE NULL 
     END tenant_uniscid --'承租统一信用代码'
    ,tenant_code --'原承租统一信用代码'
    ,tenant_area --'承租面积'
    ,tenant_industry --'承租行业类别'
    ,tenant_person --'承租负责人'
    ,tenant_mobile --'承租联系电话'
    ,rect_type --'整治类型（填序号）'
    ,rect_over --'已完成整治（是/否）'
    ,remark --'备注'
	,update_date
FROM    (
            SELECT  t1.*
                    ,COALESCE(t2.uniscid, uniscid1) uniscid2
                    ,CASE    WHEN COALESCE(t2.uniscid, uniscid1) IS NOT NULL THEN NULL
                             WHEN tenant0 LIKE '%个体%' OR tenant0=tenant_person OR LENGTH(tenant0)<=3 THEN NULL  
                             ELSE tenant0 
                     END entname2    --用于关联
                    ,ROW_NUMBER() OVER(PARTITION BY rownum ORDER BY COALESCE(t1.estdate,t2.estdate,'9999-12-31') DESC) AS rn
            FROM    (
                        SELECT  t1.*
                                ,t2.estdate
                                ,COALESCE(t2.uniscid, code1) uniscid1
                                ,CASE    WHEN COALESCE(t2.uniscid, code1) IS NOT NULL THEN NULL 
                                         WHEN tenant0 LIKE '%个体%' OR tenant0=tenant_person OR LENGTH(tenant0)<=3 THEN NULL
                                         ELSE tenant0 
                                 END entname1    --用于关联
                        FROM    (
                                    SELECT  *
                                            ,ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) as rownum --用于唯一标识
                                            ,CASE    WHEN tenant LIKE '%（仓库）%' THEN REGEXP_REPLACE(tenant,'（仓库）','')
                                                     WHEN tenant LIKE '%（电商）%' THEN REGEXP_REPLACE(tenant,'（电商）','')
                                                     WHEN tenant LIKE '%（办公）%' THEN REGEXP_REPLACE(tenant,'（办公）','')
                                                     ELSE tenant 
                                             END tenant0 
                                            ,CASE    WHEN tenant_uniscid RLIKE "^[1-9][0-9]{5}(18|19|20)[0-9]{2}((0[1-9])|10|11|12)(([0-2][1-9])|10|20|30|31)[0-9]{3}[0-9|X|x]$" THEN NULL
                                                     WHEN tenant_uniscid RLIKE "^[1-9][0-9]{5}[0-9]{2}((0[1-9])|10|11|12)(([0-2][1-9])|10|20|30|31)[0-9]{3}$" THEN NULL
                                                     WHEN tenant_uniscid LIKE '%、%' OR tenant_uniscid LIKE '%等%' THEN tenant_uniscid
                                                     WHEN tenant_uniscid RLIKE '^[0-9A-HJ-NPQRTUWXY]{2}[0-9]{6}[0-9A-HJ-NPQRTUWXY]{10}$' AND tenant_uniscid NOT LIKE '330381%' THEN tenant_uniscid 
                                                     ELSE NULL 
                                             END code1
                                            ,CASE    WHEN tenant_uniscid RLIKE "^[1-9][0-9]{5}(18|19|20)[0-9]{2}((0[1-9])|10|11|12)(([0-2][1-9])|10|20|30|31)[0-9]{3}[0-9|X|x]$" THEN NULL
                                                     WHEN tenant_uniscid RLIKE "^[1-9][0-9]{5}[0-9]{2}((0[1-9])|10|11|12)(([0-2][1-9])|10|20|30|31)[0-9]{3}$" THEN NULL
                                                     WHEN tenant_uniscid LIKE '%、%' OR tenant_uniscid LIKE '%等%' THEN NULL
                                                     WHEN tenant_uniscid RLIKE '^[0-9A-HJ-NPQRTUWXY]{2}[0-9]{6}[0-9A-HJ-NPQRTUWXY]{10}$' THEN NULL 
                                                     ELSE tenant_uniscid 
                                             END regon1    --用于关联
                                    FROM    ods_imp_jxj_gycfcc 
                                ) t1
                        LEFT JOIN dwd_qy_main2 t2 ON t2.regno = t1.regon1 AND t2.regno IS NOT NULL
                    ) t1
            LEFT JOIN dwd_qy_main2 t2 ON t2.entname = t1.entname1 AND t2.entname IS NOT NULL AND t2.entname NOT LIKE '%*%' AND LENGTH(t2.entname) > 3 
        ) t3
LEFT JOIN ods_ai_qymc_in t4 ON t4.entname = t3.entname2 AND t4.uniscid IS NOT NULL
WHERE   rn = 1
;