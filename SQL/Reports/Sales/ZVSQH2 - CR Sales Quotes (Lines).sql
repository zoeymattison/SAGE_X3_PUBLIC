with SORDERLINES as (
	select
		soq.SQHNUM_0 as [Sales Order],
		soq.SQDLIN_0 as [Line Number],
		soq.ITMREF_0 as [Product],
		case soq.ITMDES_0
			when itm.ITMDES1_0 then itm.ITMDES1_0+' '+itm.ITMDES2_0
			else soq.ITMDES_0
		end as [Description],
		itm.SEAKEY_0 as [Catalogue Number],
		soq.QTY_0 as [Ordered],
		sum((sto.QTYSTU_0-sto.CUMALLQTY_0)/soq.SAUSTUCOE_0) as [Available],
		IIF(
    SUM(ISNULL(sto.QTYSTU_0, 0) - ISNULL(sto.CUMALLQTY_0, 0)) / ISNULL(soq.SAUSTUCOE_0, 1) < ISNULL(soq.QTY_0, 0),
    ISNULL(soq.QTY_0, 0) - SUM((ISNULL(sto.QTYSTU_0, 0) - ISNULL(sto.CUMALLQTY_0, 0)) / ISNULL(soq.SAUSTUCOE_0, 1)),
    0
) as [Backordered],
		soq.SAU_0 as [Sales Unit],
		soq.GROPRI_0 as [Product Price],
		soq.GROPRI_0-soq.NETPRI_0 as [Discount],
		soq.NETPRI_0*soq.QTY_0 as [Total],
		tex.TEXTE_0 as [Line Text]
	from
		LIVE.SQUOTED soq
	inner join
		LIVE.ITMMASTER itm on soq.ITMREF_0=itm.ITMREF_0
	left join
		LIVE.STOCK sto on soq.ITMREF_0=sto.ITMREF_0 and soq.STOFCY_0=sto.STOFCY_0 and sto.STA_0='A'
	left join
		LIVE.TEXCLOB tex on soq.SQDTEX_0=tex.CODE_0
	group by
		soq.SQHNUM_0,
		soq.SQDLIN_0,
		soq.ITMREF_0,
		itm.ITMDES1_0,
		itm.ITMDES2_0,
		soq.ITMDES_0,
		itm.SEAKEY_0,
		soq.QTY_0,
		soq.SAUSTUCOE_0,
		soq.SAU_0,
		soq.GROPRI_0,
		soq.DISCRGVAL1_0,
		soq.NETPRI_0,
		tex.TEXTE_0
)

select
	soh.SQHNUM_0 as [Sales Order],
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
	LIVE.SQUOTE soh
left join
	SORDERLINES sol on soh.SQHNUM_0=sol.[Sales Order]