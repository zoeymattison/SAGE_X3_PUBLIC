with countdate as (
	select 
		ITMREF_0 as [Product],
		STOFCY_0 as [Stock Site],
		CUNDAT_0 as [Last Count Date],
		sum(QTYPCUNEW_0) as [Counted],
		sum(QTYPCU_0) as [Expected],
		sum(QTYPCUNEW_0)-sum(QTYPCU_0) as [Variance],
		max(CUNCST_0) as [Cost],
		sum(CUNCST_0*QTYPCUNEW_0) as [Counted Cost],
		sum(CUNCST_0*QTYPCU_0) as [Expected Cost],
		sum(CUNCST_0*QTYPCUNEW_0)-sum(CUNCST_0*QTYPCU_0) as [Difference],
		ROW_NUMBER() OVER (PARTITION BY ITMREF_0, STOFCY_0 ORDER BY CUNDAT_0 DESC) as rn
	from
		LIVE.CUNLISDET
	group by
		ITMREF_0,
		STOFCY_0,
		CUNDAT_0
),
receipts as (
	select
		ITMREF_0,
		PRHFCY_0,
		CREDAT_0 as [Last Receipt Date],
		ROW_NUMBER() OVER (PARTITION BY ITMREF_0, PRHFCY_0 ORDER BY CREDAT_0 DESC) as rn
	from
		LIVE.PRECEIPTD
),
stockdata as (
	select
		ITMREF_0 as [Product],
		STOFCY_0 as [Stock Site],
		sum(QTYPCU_0) as [Quantity in Stock]
	from
		LIVE.STOCK
	group by
		ITMREF_0,
		STOFCY_0
),
products as (
	select
		ITMREF_0,
		ITMDES1_0+' '+ITMDES2_0 as [Description],
		TSICOD_0 as [Status]
	from
		LIVE.ITMMASTER
)
select
	itf.STOFCY_0 as [Stock Site],
	itf.ITMREF_0 as [Product],
	itm.[Description],
	itm.[Status],
	rec.[Last Receipt Date],
	cun.[Last Count Date],
	isnull(cun.[Counted],0) as [Counted],
	isnull(cun.[Expected],0) as [Expected],
	isnull(cun.[Variance],0) as [Count Variance],
	isnull(cun.[Cost],0) as [Cost],
	isnull(cun.[Counted Cost],0) as [Counted Cost],
	isnull(cun.[Expected Cost],0) as [Expected Cost],
	isnull(cun.[Difference],0) as [Cost Variance],
	isnull(sto.[Quantity in Stock],0) as [Current Stock]

from
	LIVE.ITMFACILIT itf
left join
	countdate cun on itf.ITMREF_0=cun.[Product] 
	                 and itf.STOFCY_0=cun.[Stock Site] 
	                 and cun.rn = 1
left join
	receipts rec on itf.ITMREF_0=rec.ITMREF_0
	                 and itf.STOFCY_0=rec.PRHFCY_0
	                 and rec.rn = 1
left join
	stockdata sto on itf.ITMREF_0=sto.Product and itf.STOFCY_0=sto.[Stock Site]
left join
	products itm on itf.ITMREF_0=itm.ITMREF_0
where sto.[Quantity in Stock] is not null