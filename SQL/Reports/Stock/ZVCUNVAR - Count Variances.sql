with count_detail as (
	select
		d.CUNLISNUM_0 as [Count List],
		d.ITMREF_0 as [Product],
		i.ITMDES1_0+' '+ITMDES2_0 as [Description],
		t.TEXTE_0 as [Class],
		sum(d.QTYPCU_0) as [Exptected],
		sum(d.QTYPCUNEW_0-d.QTYPCU_0) as [Variance],
		sum(d.CUNCST_0*(d.QTYPCUNEW_0-d.QTYPCU_0)) as [Variance Cost],
		i.TSICOD_0 as [Status],
		i.CREDAT_0 as [Date Created],
		STOFCY_0 as [Stock Site]

	from
		LIVE.CUNLISDET d
	inner join
		LIVE.ITMMASTER i
		on
			d.ITMREF_0=i.ITMREF_0
	left join
		LIVE.ATEXTRA t
		on 
			t.CODFIC_0 = 'ATABDIV'
			AND t.IDENT1_0 = '21'
			AND t.ZONE_0 = 'LNGDES'
			AND t.LANGUE_0 = 'ENG'
			AND t.IDENT2_0 = i.TSICOD_1
	group by
		d.STOFCY_0,
		d.CUNLISNUM_0,
		d.ITMREF_0,
		i.ITMDES1_0,
		i.ITMDES2_0,
		t.TEXTE_0,
		i.TSICOD_0,
		i.CREDAT_0
),
sales_data as (
	select
		SALFCY_0 as [Sales Site],
		ITMREF_0 as [Product],
		max(CREDAT_0) as [Last Invoice],
		sum(QTY_0) as [Qty Sold 1Y]
	from
		LIVE.SINVOICED
	where
		CREDAT_0 >= dateadd(year, -1, cast(GETDATE() as date))
	group by
		SALFCY_0,
		ITMREF_0
)

select
	[Count List],
	c.[Product],
	[Description],
	isnull([Class],''),
	[Exptected],
	[Variance],
	[Variance Cost],
	[Status],
	[Date Created],
	s.[Last Invoice],
	isnull(s.[Qty Sold 1Y],0)

from
	count_detail c
left join
	sales_data s on c.[Stock Site]=s.[Sales Site] and c.Product=s.Product