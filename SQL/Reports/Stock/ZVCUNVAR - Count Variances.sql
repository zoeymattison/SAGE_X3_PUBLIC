with count_detail as (
	select
		d.CUNLISNUM_0 as [Count List],
		d.ITMREF_0 as [Product],
		i.ITMDES1_0+' '+ITMDES2_0 as [Description],
		t.TEXTE_0 as [Class],
		sum(d.QTYPCU_0) as [Exptected],
		sum(d.QTYPCUNEW_0-d.QTYPCU_0) as [Variance],
		sum(d.CUNCST_0*(d.QTYPCUNEW_0-d.QTYPCU_0)) as [Variance Cost]
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
		d.CUNLISNUM_0,
		d.ITMREF_0,
		i.ITMDES1_0,
		i.ITMDES2_0,
		t.TEXTE_0
)

select
	[Count List],
	[Product],
	[Description],
	[Class],
	[Exptected],
	[Variance],
	[Variance Cost]

from
	count_detail