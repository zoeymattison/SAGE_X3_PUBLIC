with PrimarySupplier as(
	select
		ITMREF_0,
		max(case when PIO_0=0 then itp.BPSNUM_0 else '' end) as [Supplier],
		max(case when PIO_0=0 then itp.BPSNUM_0+' '+bps.BPSNAM_0 else '' end) as [Supplier Name]
	from
		LIVE.ITMBPS itp
	left join	
		LIVE.BPSUPPLIER bps on itp.BPSNUM_0=bps.BPSNUM_0
	group by
		ITMREF_0
),
purchasecost as (
	select
		PLICRD_0,
		PLICRI1_0,
		PRI_0
	from
		LIVE.PPRICLIST
	where
		PLI_0='T20'
),
salescost as (
	select
		PLICRD_0,
		PRI_0
	from
		LIVE.SPRICLIST
	where
		PLI_0='11' and PLICRI1_0='PL2'
)

select
itm.ITMREF_0,
itm.ITMDES1_0+' '+itm.ITMDES2_0,
isnull(sup.[Supplier Name],''),
isnull(pri.PRI_0,0),
isnull(sal.PRI_0,0)


from LIVE.ITMMASTER itm
left join PrimarySupplier sup on itm.ITMREF_0=sup.ITMREF_0
left join purchasecost pri on sup.ITMREF_0=pri.PLICRD_0 and sup.Supplier=pri.PLICRI1_0
left join salescost sal on itm.ITMREF_0=sal.PLICRD_0