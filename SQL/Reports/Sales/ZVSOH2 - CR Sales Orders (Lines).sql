with SORDERLINES as (
	select
		soq.SOHNUM_0 as [Sales Order],
		soq.SOPLIN_0 as [Line Number],
		soq.ITMREF_0 as [Product],
		case sop.ITMDES_0
			when itm.ITMDES1_0 then itm.ITMDES1_0+' '+itm.ITMDES2_0
			else sop.ITMDES_0
		end as [Description],
		itm.SEAKEY_0 as [Catalogue Number],
		soq.QTY_0 as [Ordered],
		ALLQTY_0+soq.DLVQTY_0+soq.PREQTY_0+soq.OPRQTY_0 as [Available],
		soq.QTY_0-soq.DLVQTY_0-soq.ALLQTY_0-soq.PREQTY_0-soq.OPRQTY_0 as [Backordered],
		sop.SAU_0 as [Sales Unit],
		sop.GROPRI_0 as [Product Price],
		sop.GROPRI_0-sop.NETPRI_0 as [Discount],
		sop.NETPRI_0*soq.QTY_0 as [Total],
		soq.YCUSTNOT_0+ltrim(' '+tex.TEXTE_0) as [Line Text]
	from
		LIVE.SORDERQ soq
	inner join
		LIVE.SORDERP sop on soq.SOHNUM_0=sop.SOHNUM_0 and soq.SOPLIN_0=sop.SOPLIN_0 and soq.SOQSEQ_0=sop.SOPLIN_0
	inner join
		LIVE.ITMMASTER itm on soq.ITMREF_0=itm.ITMREF_0
	left join
		LIVE.TEXCLOB tex on soq.SOQTEX_0=tex.CODE_0
	group by
		soq.SOHNUM_0,
		soq.SOPLIN_0,
		soq.ITMREF_0,
		itm.ITMDES1_0,
		itm.ITMDES2_0,
		sop.ITMDES_0,
		itm.SEAKEY_0,
		soq.QTY_0,
		soq.PREQTY_0,
		soq.OPRQTY_0,
		sop.SAUSTUCOE_0,
		soq.DLVQTY_0,
		soq.ALLQTY_0,
		sop.SAU_0,
		sop.GROPRI_0,
		sop.DISCRGVAL1_0,
		sop.NETPRI_0,
		soq.YCUSTNOT_0,
		tex.TEXTE_0
)

select
       
	soh.SOHNUM_0 as [Sales Order],
	sol.[Line Number],
	sol.[Product],
	sol.[Description],
	sol.[Catalogue Number],
	sol.[Ordered],
	isnull(sol.[Available],0) as [Available],
	isnull(case when sol.[Backordered] < 0 then 0 else sol.Backordered end,0) as [Backordered],
	sol.[Sales Unit],
	sol.[Product Price],
	sol.[Discount],
	sol.[Total],
	isnull(sol.[Line Text],'')

from
	LIVE.SORDER soh
left join
	SORDERLINES sol on soh.SOHNUM_0=sol.[Sales Order]