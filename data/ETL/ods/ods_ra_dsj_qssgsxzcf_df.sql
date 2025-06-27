--省市回流_全省双公示行政处罚归集信息
INSERT OVERWRITE TABLE ods_ra_dsj_qssgsxzcf_df
SELECT  punish_base_info_code    --'处罚基本信息主键ID'
        ,punish_case_code    --'处罚案件编号'
        ,case_process_type    --'案件程序类别 01 简易程序 02 一般程序
        ,punish_action_name    --'处罚行为名称'
        ,illegal_fact    --'违法事实'
        ,illegal_basis    --'违法依据'
        ,punish_type    --'处罚决定种类' 01 警告 02 罚款 03 没收违法所得 04 责令停产停业 05 吊销许可证 06 行政拘留 07 法律、行政法规规定的其他行政处罚 08 通报批评 09 没收非法财物 10 降低资质等级 11 暂扣许可证 12 限制开展经营活动 13 限制从业 14 责令关闭
        ,punish_document_code    --'处罚决定文书号'
        ,admin_cp_type    --'行政相对人类型'----------------01都是个人、02、03、04
        ,admin_cp_name    --'当事人名称'
        ,admin_cp_cert_type    --'当事人证件类型'----------001统一社会信用代码、111居民身份证、099、154、411、414、511
        ,admin_cp_cert_code2 AS admin_cp_cert_code    --'当事人证件号码'
        ,legal_represent_type    --'法定代表人证件类型'
        ,legal_represent    --'法定代表人姓名'
        ,legal_represent_idcard2 AS legal_represent_idcard    --'法定代表人证件号码'
        ,punish_content    --'处罚内容'
        ,supervise_item_code    --'监管事项编码'
        ,supervise_item_name    --'监管事项名称'
        ,punish_basis    --'处罚依据'
        ,fine    --'罚款金额'
        ,confiscate_illegal_incom    --'没收违法所得金额'
        ,confiscate_illegal_asset    --'没收非法财物金额'
        ,revoke_licence_name    --'暂扣或吊销证照名称'
        ,revoke_licence_code    --'暂扣或吊销证照编号'
        ,set_time    --'决定日期'
        ,public_date    --'公示日期'
        ,public_end_date    --'公示截止日期'
        ,implement_institution    --'执法主体名称'
        ,implement_institution_code    --'执法主体统一社会信用'
        ,institution_region_code    --'处罚机关所属地区行政'
        ,source_dept_name    --'数据来源单位'
        ,source_dept_code    --'数据来源单位统一信用'
        ,is_public    --'是否公开'
        ,publictext    --公示内容
        ,publicstatus    --'公示状态' 0：正常，1：撤销，2：删除----有NULL
        ,cutreason    --'撤销处罚的原因说明'
        ,sensitiveflag    --'敏感数据标识'
        ,iscancelcase    --'1:撤销立案'
FROM    (
            SELECT  t3.*
                    ,ROW_NUMBER() OVER(PARTITION BY punish_case_code,COALESCE(admin_cp_cert_code2,admin_cp_name) ORDER BY estdate1 DESC,dsc_biz_timestamp DESC,dsc_biz_record_id DESC) AS rn
            FROM    (
                        SELECT  t2.*
                                ,COALESCE(t3.uniscid, t2.admin_cp_cert_code1) admin_cp_cert_code2    --'当事人证件号码'
                                ,CASE    WHEN legal_represent_idcard1 RLIKE "^[1-9][0-9]{5}(18|19|20)[0-9]{2}((0[1-9])|10|11|12)(([0-2][1-9])|10|20|30|31)[0-9]{3}[0-9|X|x]$" THEN legal_represent_idcard1
                                         WHEN legal_represent=t3.lerep_name THEN COALESCE(t3.cerno, legal_represent_idcard1) 
                                         ELSE legal_represent_idcard1 
                                 END legal_represent_idcard2    --'法定代表人证件号码'          
                                ,COALESCE(t2.estdate,t3.estdate,'9999-12-31') estdate1
                        FROM    (
                                    SELECT  t1.*
                                            ,COALESCE(t2.uniscid, t1.cert_code) admin_cp_cert_code1    --'当事人证件号码'
                                            ,CASE    WHEN represent_idcard RLIKE "^[1-9][0-9]{5}(18|19|20)[0-9]{2}((0[1-9])|10|11|12)(([0-2][1-9])|10|20|30|31)[0-9]{3}[0-9|X|x]$" THEN represent_idcard
                                                     WHEN legal_represent=t2.lerep_name THEN COALESCE(t2.cerno, represent_idcard) 
                                                     ELSE represent_idcard 
                                             END legal_represent_idcard1    --'法定代表人证件号码'
                                            ,CASE    WHEN admin_cp_cert_code RLIKE '^[0-9A-HJ-NPQRTUWXY]{2}[0-9]{6}[0-9A-HJ-NPQRTUWXY]{10}$' THEN NULL
                                                     WHEN t2.entname IS Not NULL THEN NULL
                                                     ELSE admin_cp_name 
                                             END entname1--名称用于关联
                                            ,t2.estdate 
                                    FROM    (
                                                SELECT  *
                                                        ,REGEXP_REPLACE(
                                                            REGEXP_REPLACE(
                                                                REGEXP_REPLACE(
                                                                    REGEXP_REPLACE(TOUPPER(admin_cp_cert_code),'统一社会信用代码：','')
                                                                    ,'（1/1）'
                                                                    ,''
                                                                )
                                                                ,'(1/1)'
                                                                ,''
                                                            )
                                                            ,'()'
                                                            ,''
                                                        ) cert_code
                                                        ,CASE   WHEN legal_represent_idcard IN ('','undefined') THEN NULL
                                                                WHEN legal_represent_idcard RLIKE "^[1-9][0-9]{5}[0-9]{2}((0[1-9])|10|11|12)(([0-2][1-9])|10|20|30|31)[0-9]{3}$" THEN ID15To18(legal_represent_idcard)
                                                                WHEN legal_represent_idcard RLIKE "^[1-9][0-9]{5}(18|19|20)[0-9]{2}((0[1-9])|10|11|12)(([0-2][1-9])|10|20|30|31)[0-9]{3}[0-9|X|x]$" THEN legal_represent_idcard
                                                                WHEN legal_represent_idcard=legal_represent OR legal_represent_idcard=admin_cp_cert_code THEN NULL 
                                                                ELSE legal_represent_idcard 
                                                        END represent_idcard
                                                        ,CASE    WHEN admin_cp_cert_code RLIKE '^[0-9A-HJ-NPQRTUWXY]{2}[0-9]{6}[0-9A-HJ-NPQRTUWXY]{10}$' THEN NULL
                                                                ELSE admin_cp_cert_code 
                                                        END regno1--注册号用于关联
                                                FROM    stg_ra_dsj_qssgsxzcf_df
                                                WHERE   admin_cp_type <> '01'    --排除个人
                                                AND     opt_type <> 'D' AND delete_flag = '0' AND publicstatus IN ('0','1')
                                            ) t1
                                    LEFT JOIN dwd_qy_main2 t2 ON t2.regno = t1.regno1 AND t2.regno IS NOT NULL
                                ) t2
                        LEFT JOIN dwd_qy_main2 t3 ON t3.entname = t2.entname1 AND t3.entname IS NOt NULL AND t3.entname NOT LIKE '%*%' AND LENGTH(t3.entname)>3
                    )t3           
        ) t4
WHERE   rn = 1--确保通过名称关联的数据唯一
;