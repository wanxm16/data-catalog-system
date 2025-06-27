--企业_资质标签_资质许可合表
INSERT OVERWRITE TABLE dwd_qy_zzbq_zzxk_df
SELECT qymc,tyshxydm,'危险化学品经营许可证',xkzbh,NULL,xkfw
,CASE WHEN SUBSTR(yxqqsrq, -1, 1)='-' THEN SUBSTR(yxqqsrq,1,7) ELSE REGEXP_REPLACE(REGEXP_REPLACE(yxqqsrq,'[年月]','-'),'日','') END 
,CASE WHEN SUBSTR(yxqjzrq, -1, 1)='-' THEN SUBSTR(yxqjzrq,1,7) ELSE REGEXP_REPLACE(REGEXP_REPLACE(yxqjzrq,'[年月]','-'),'日','') END
,NULL,REGEXP_REPLACE(REGEXP_REPLACE(fzrq,'[年月]','-'),'日',''),zzbfjg,status,'省市回流_危险化学品经营许可证'
,CONCAT('单位类型：',COALESCE(unittype,'')),CONCAT('经营方式：',COALESCE(jyfs,'')),CONCAT('仓储地址：',COALESCE(storaddr,'')) FROM ods_ra_yjj_whpjyxk_df

UNION ALL 
SELECT comp_name,chiyourenbm,zzmc,health_license,NULL,licens_project,licensestart,licenseend,NULL,operatedate,fzjg,zjzt,'省市回流_公共场所卫生许可证证照'
,CONCAT('专业类别：',COALESCE(comp_type,'')),CONCAT('年份：',COALESCE(zi,'')),NULL FROM ods_ra_wjj_ggcswsxk_df

UNION ALL
SELECT mc,uniscid,'医疗机构执业许可证',yljgzyxkzh,NULL,zlkm,TO_CHAR(yxkssj,'yyyy-mm-dd'),TO_CHAR(yxjzsj,'yyyy-mm-dd'),TO_CHAR(pzrq,'yyyy-mm-dd'),NULL,fzjg,NULL,'省市回流_医疗机构执业许可证'
,CONCAT('经营性质：',COALESCE(jyxz,'')),CONCAT('机构类型：',COALESCE(jglx,'')),CONCAT('负责人：',COALESCE(fzrxm,'')) FROM ods_ra_wjj_yljgzyxk_df

UNION ALL
SELECT name,bizlicense,'道路运输经营许可证',license_num,license_key,busi_scope,SUBSTR(valid_date_begin,1,10),SUBSTR(valid_date_end,1,10),NULL,SUBSTR(print_date,1,10),organ_name,status,'省市回流_中华人民共和国道路运输经营许可证'
,NULL,NULL,NULL FROM ods_ra_jtt_dlysjyxk_df

UNION ALL
SELECT jgmc,tyxydm,zzlx,zsbh,NULL,ywfw,NULL,NULL
,CASE WHEN LENGTH(pzrq)=8 THEN CONCAT(SUBSTR(pzrq,1,5),'0',SUBSTR(pzrq,6,2),'0',SUBSTR(pzrq,8))
WHEN LENGTH(pzrq)=9 AND SUBSTR(pzrq,7,1)='-' THEN CONCAT(SUBSTR(pzrq,1,5),'0',SUBSTR(pzrq,6))
WHEN LENGTH(pzrq)=9 THEN CONCAT(SUBSTR(pzrq,1,8),'0',SUBSTR(pzrq,9))
ELSE pzrq END 
,CASE WHEN LENGTH(bfrq)=8 THEN CONCAT(SUBSTR(bfrq,1,5),'0',SUBSTR(bfrq,6,2),'0',SUBSTR(bfrq,8))
WHEN LENGTH(bfrq)=9 AND SUBSTR(bfrq,7,1)='-' THEN CONCAT(SUBSTR(bfrq,1,5),'0',SUBSTR(bfrq,6))
WHEN LENGTH(bfrq)=9 THEN CONCAT(SUBSTR(bfrq,1,8),'0',SUBSTR(bfrq,9))
ELSE bfrq END 
,fzjg,'有效','省市回流_保险许可证',NULL,NULL,NULL FROM ods_ra_jrb_bxxkz_df

UNION ALL
SELECT entname_varchar2,uniscid_varchar10,'农药经营许可',xkzbh_varchar1,NULL,yxqy_varchar6,SUBSTR(yxks_datetime3,1,10),SUBSTR(yxjz_datetime2,1,10),NULL,SUBSTR(fzrq_datetime1,1,10),fzjg_varchar8,'启用','省市回流_农药经营许可'
,CONCAT('经营方式：',COALESCE(jyfs_varchar5,'')),NULL,NULL FROM ods_ra_nyj_nyjyxk_df

UNION ALL
SELECT dwmc,dw_tyxydm,'劳务派遣经营许可证',bh,NULL,xkjysx
,CASE WHEN LENGTH(yxqx1)=8 THEN CONCAT(SUBSTR(yxqx1,1,5),'0',SUBSTR(yxqx1,6,2),'0',SUBSTR(yxqx1,8))
WHEN LENGTH(yxqx1)=9 AND SUBSTR(yxqx1,7,1)='-' THEN CONCAT(SUBSTR(yxqx1,1,5),'0',SUBSTR(yxqx1,6))
WHEN LENGTH(yxqx1)=9 THEN CONCAT(SUBSTR(yxqx1,1,8),'0',SUBSTR(yxqx1,9))
ELSE yxqx1 END 
,CASE WHEN LENGTH(yxqx2)=8 THEN CONCAT(SUBSTR(yxqx2,1,5),'0',SUBSTR(yxqx2,6,2),'0',SUBSTR(yxqx2,8))
WHEN LENGTH(yxqx2)=9 AND SUBSTR(yxqx2,7,1)='-' THEN CONCAT(SUBSTR(yxqx2,1,5),'0',SUBSTR(yxqx2,6))
WHEN LENGTH(yxqx2)=9 THEN CONCAT(SUBSTR(yxqx2,1,8),'0',SUBSTR(yxqx2,9))
ELSE yxqx2 END 
,NULL,REGEXP_REPLACE(REGEXP_REPLACE(fzrq,'[年月]','-'),'日','')
,fzjg,NULL,'省市回流_劳务派遣经营许可证',NULL,NULL,NULL  
FROM    (SELECT *,CONCAT(CNNUMTOARABIC(SUBSTR(SUBSTR(yxqx,2,INSTR(yxqx,'至')-2),1,4)),'-',CHINESETOARABIC(SUBSTR(SUBSTR(yxqx,2,INSTR(yxqx,'至')-2),6,INSTR(SUBSTR(yxqx,2,INSTR(yxqx,'至')-2),'月')-6)),'-',CHINESETOARABIC(SUBSTR(SUBSTR(yxqx,2,INSTR(yxqx,'至')-2),INSTR(SUBSTR(yxqx,2,INSTR(yxqx,'至')-2),'月')+1))) yxqx1,CONCAT(CNNUMTOARABIC(SUBSTR(SUBSTR(yxqx,INSTR(yxqx,'至')+1),1,4)),'-',CHINESETOARABIC(SUBSTR(SUBSTR(yxqx,INSTR(yxqx,'至')+1),6,INSTR(SUBSTR(yxqx,INSTR(yxqx,'至')+1),'月')-6)),'-',CHINESETOARABIC(SUBSTR(SUBSTR(yxqx,INSTR(yxqx,'至')+1),INSTR(SUBSTR(yxqx,INSTR(yxqx,'至')+1),'月')+1))) yxqx2
        FROM ods_ra_sbj_lwpqjyxk_df)

UNION ALL
SELECT place_name,businesscode,'娱乐经营许可证',permit,NULL,mainrange,REGEXP_REPLACE(REGEXP_REPLACE(authdate,'[年月]','-'),'日',''),REGEXP_REPLACE(REGEXP_REPLACE(effectdate,'[年月]','-'),'日',''),REGEXP_REPLACE(REGEXP_REPLACE(authdatefirst,'[年月]','-'),'日',''),REGEXP_REPLACE(REGEXP_REPLACE(fzrq,'[年月]','-'),'日',''),certification_department,NULL,'省市回流_娱乐经营许可证（歌舞和游艺合表） '
,CONCAT('场所类型：',COALESCE(place_type,'')),CONCAT('使用面积：',COALESCE(buildarea,'')),NULL FROM ods_ra_wgj_yljyxk_df

UNION ALL
SELECT companyname,orgcode,'工业产品生产许可证',certno,NULL,productname,NULL,effectivedate,NULL,issuedate,fzjg,status,'省市回流_全国工业产品生产许可证'
,CONCAT('生产地址：',COALESCE(productaddress,'')),CONCAT('检验方式：',COALESCE(testmethods,'')),CONCAT('产品名称：',COALESCE(productname,'')) FROM ods_ra_sjj_gycpscxk_df

UNION ALL
SELECT ent_name,ent_code,'危险废物经营许可证',lic_no,NULL,bus_area,SUBSTR(ava_start,1,10),SUBSTR(ava_end,1,10),NULL,SUBSTR(auth_date,1,10),auth_depart,use_state,'省市回流_危险废物经营许可证'
,NULL,NULL,NULL FROM ods_ra_hbj_wxfwjyxk_df

UNION ALL
SELECT dwmc,xydm,'电影放映经营许可证',xkzh,NULL,jyxm,yxqs,yxqe,NULL,clsj,fzjg,zt,'省市回流_电影放映经营许可证（新）'
,NULL,NULL,NULL FROM ods_ra_xcb_dyfyjyxk_df

UNION ALL
SELECT djmc,corporate_license_no,zzmc,register_no,NULL,xklb,valid_date_start,valid_date_end,NULL,issure_date,fzjg,status,'省市回流_电力业务许可证'
,NULL,NULL,NULL FROM ods_ra_dsj_dlywxk_df

UNION ALL
SELECT name,bizlicense,'道路危险货物运输经营许可证',license_num,license_key,busi_scope,SUBSTR(valid_date_begin,1,10),SUBSTR(valid_date_end,1,10),NULL,SUBSTR(print_date,1,10),organ_name,status,'省市回流_道路危险货物运输经营许可证'
,CONCAT('经营范围备注：',COALESCE(busi_memo,'')),CONCAT('车辆数：',COALESCE(vehicle_num,'')),NULL FROM ods_ra_dsj_dlwxhwysxk_df

UNION ALL
SELECT entname,uniscid,licname,licno,NULL,licscope,REGEXP_REPLACE(REGEXP_REPLACE(qsrq,'[年月]','-'),'日',''),REGEXP_REPLACE(REGEXP_REPLACE(jzrq,'[年月]','-'),'日',''),NULL,REGEXP_REPLACE(REGEXP_REPLACE(fzrq,'[年月]','-'),'日',''),fzjg,opstate,'省市回流_食品经营库食品经营许可信息'
,CONCAT('主体业态：',COALESCE(maintype,'')),CONCAT('经营场所：',COALESCE(lopoc,'')),NULL FROM ods_ra_ssj_spjyxk_df

UNION ALL
SELECT corp_name,tyxydm,'药品零售经营许可证',license_no,NULL,working_scope_remark,NULL,license_valid_to,NULL,grant_date,grant_org,status,'省市回流_药品经营许可证（零售）'
,CONCAT('仓库地址：',COALESCE(storehouse_address,'')),CONCAT('企业负责人：',COALESCE(corp_principal_name,'')),CONCAT('质量负责人：',COALESCE(quality_principal_name,'')) FROM ods_ra_ssj_ypjyxk_df

UNION ALL
SELECT xxmc,czztdm,'民办学校办学许可',bxxkzh,NULL,NULL,yxqxq,yxqxz,NULL,fzrq,fzjg,status,'省市回流_民办学校办学许可证'
,CONCAT('校长：',COALESCE(xz,'')),CONCAT('学校类型：',COALESCE(xxlx,'')),CONCAT('办学内容：',COALESCE(bxnr,'')) FROM ods_ra_jyj_mbxxbxxk_df

UNION ALL
SELECT dwmc,corpcode,'建筑施工企业安全生产许可证',bh,NULL,xkfw,SUBSTR(yxqz,1,10),SUBSTR(yxqz,12,10),NULL,fzsj,fzjg,status,'省市回流_建筑施工企业安全生产许可证'
,CONCAT('主要负责人：',COALESCE(zyfzr,'')),NULL,NULL FROM ods_ra_zjj_jzsgqyaqscxk_df

UNION ALL--已停更
SELECT corpname,scucode,'建筑业企业资质证书',certid,NULL,certlevelname,notedate,enddate,NULL,organdate,organname,certstatename,'省市回流_中华人民共和国建筑业企业资质证书'
,CONCAT('资质等级名称：',COALESCE(certlevelname,'')),NULL,NULL FROM ods_ra_zjj_jzyqyzz_df

UNION ALL
SELECT corpname,creditcode,'勘察设计企业资质证书',certcode,NULL,titlelevelname,SUBSTR(awarddate,1,10),SUBSTR(certeffectdate,1,10),NULL,NULL,awarddepart,certstatusname,'省市回流_勘察设计企业资质信息'
,CONCAT('资质等级名称：',COALESCE(titlelevelname,'')),NULL,NULL FROM ods_ra_zjj_kcsjqyzz_df

UNION ALL--无证书
SELECT qymc,tyshxydm,'强制性清洁生产审核企业名单',COALESCE(wh,tyshxydm),NULL,sshy,NULL,NULL,NULL,mdfbrq,mdfbjg,NULL,'省市回流_强制性清洁生产审核企业名单信息'
,NULL,NULL,NULL FROM ods_ra_hbj_qzxqjscqy_df
;