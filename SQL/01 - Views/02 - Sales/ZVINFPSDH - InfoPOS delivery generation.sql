 ( SALFCY_0 , STOFCY_0 , SOHNUM_0 , SOHTYP_0 , BPCORD_0 , BPAADD_0 , CUR_0 
 , SHIDAT_0 , CFMFLG_0 , SOPLIN_0 , ITMREF_0 , ITMDES_0 , SAU_0 , QTY_0 , STA_0 
 , PCU_0 , QTYPCU_0 , LOC_0 ) As 
with current_location as (
	select distinct
		LOC_0,
		STOCOU_0
	from
		LIVE.STOCK where CUMALLQTY_0>0
)
select 
q.SALFCY_0,
q.STOFCY_0,
q.SOHNUM_0,
'INFPS',
q.BPCORD_0,
q.BPAADD_0,
'CAD',
CONVERT(VARCHAR(8),q.SHIDAT_0,112),
'2',
q.SOPLIN_0,
q.ITMREF_0,
p.ITMDES_0,
p.SAU_0,
q.QTY_0-(q.DLVQTY_0/p.SAUSTUCOE_0),
'A',
p.STU_0,
-1*(q.QTYSTU_0-q.DLVQTY_0),
c.LOC_0
from LIVE.SORDERQ q
inner join LIVE.SORDERP p on q.SOHNUM_0=p.SOHNUM_0 and q.SOPLIN_0=p.SOPLIN_0 and q.SOQSEQ_0=p.SOPSEQ_0
inner join LIVE.STOALL a on q.STOFCY_0=a.STOFCY_0 and q.ITMREF_0=a.ITMREF_0 and q.SOHNUM_0=a.VCRNUM_0 and q.SOPLIN_0=a.VCRLIN_0 and q.SOQSEQ_0=a.VCRSEQ_0
inner join current_location c on a.STOCOU_0=c.STOCOU_0
where q.SOQSTA_0<>3 and left(q.SOHNUM_0,3)='STR' and (select SDHNUM_0 from LIVE.SDELIVERY where SDHNUM_0=q.SOHNUM_0) is null
