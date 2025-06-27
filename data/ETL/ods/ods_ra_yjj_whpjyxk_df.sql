--省市回流_危险化学品经营许可证
INSERT OVERWRITE TABLE ods_ra_yjj_whpjyxk_df
SELECT  qymc    --持证者主体名称
        ,tyshxydm    --持证者主体代码
        ,yxqqsrq    --有效期起始日期--存在年月跟发证年月不同
        ,yxqjzrq    --有效期截止日期--跟起始日期非都是3年
        ,fzrq    --发证日期
        ,xkfw    --许可范围
        ,xkzbh    --许可证编号
        ,unittype    --单位类型
        ,qyzs    --企业住所
        ,qyfddbr    --企业法定代表人
        ,jyfs    --经营方式
        ,zzbz    --证照标识
        ,storaddr    --仓储地址
        ,zzbfjg    --证照颁发机构
        ,fzjgdm    --发证机关组织机构代码
        ,zzdmlxmc    --证照代码类型名称
        ,xzqhdm    --所属区划编码
        ,zzmc    --证照类型名称
        ,zzlxdm    --证照类型代码
        ,jzdwmc    --监制单位名称
        ,STATUS    --证书状态----xxxx都是空
FROM    stg_ra_yjj_whpjyxk_df
WHERE   dsc_biz_operation IN('insert','update')
;
