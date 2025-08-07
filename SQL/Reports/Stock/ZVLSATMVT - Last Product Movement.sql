with product_info as (
	select
		f.STOFCY_0 as [Stock Site],
		i.ITMREF_0 as [Product],
		ITMDES1_0+' '+ITMDES2_0 as [Description],
		TSICOD_0 as [Monk Status],
		i.CREDAT_0 as [Date Created]
	from	
		LIVE.ITMMASTER i
	left join
		LIVE.ITMFACILIT f
		on
			i.ITMREF_0=f.ITMREF_0
),
trans_info as (
	select
		stj.STOFCY_0 as [Stock Site],
		stj.ITMREF_0 as [Product],
		max(case when VCRTYP_0=4 and BPRNUM_0 in ('CR53','CR54','CR55','CR56','CR57','CR58','CR59','CR60','CR63','1600','2100','2200','2300','2600','DC30','IDC33','IDC52') then stj.CREDAT_0 else null end) as [Last Transfer],
		max(case when VCRTYP_0=4 and BPRNUM_0 not in ('CR53','CR54','CR55','CR56','CR57','CR58','CR59','CR60','CR63','1600','2100','2200','2300','2600','DC30','IDC33','IDC52') then stj.CREDAT_0 else null end) as [Last Sales Delivery],
		max(case when VCRTYP_0=13 then stj.CREDAT_0 else null end) as [Last Return]
	from
		LIVE.STOJOU stj
	group by
		stj.STOFCY_0,
		stj.ITMREF_0
),
stock_totals as (
	select
		ITMREF_0,
		STOFCY_0,
		sum(QTYSTU_0-CUMALLQTY_0) as [Stock Total]
	from
		LIVE.STOCK
	group by
		STOFCY_0,
		ITMREF_0
)
select distinct
	i.[Date Created],
	i.[Stock Site],
	i.Product,
	i.Description,
	i.[Monk Status],
	t.[Last Transfer],
	t.[Last Sales Delivery],
	t.[Last Return],
	coalesce(s.[Stock Total],0) as [Stock Total]


from
	product_info i
left join
	trans_info t
	on
		i.Product=t.Product and i.[Stock Site]=t.[Stock Site]
left join
	stock_totals s
	on
		i.[Stock Site]=s.STOFCY_0 and i.Product=s.ITMREF_0
where i.[Stock Site] is not null