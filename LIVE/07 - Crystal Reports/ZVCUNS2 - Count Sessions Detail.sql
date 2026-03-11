with count_sheet as (
	select
		CUNSSSNUM_0 as [Count Session],
		CUNLISNUM_0 as [Count Sheet],
		c.ITMREF_0 as [Product],
		i.ITMDES1_0+' '+i.ITMDES2_0 as [Description],
		c.PCU_0 as [Unit of Measure],
		sum(c.QTYPCU_0) as [Quantity Expected],
		i.TSICOD_0 as [Status],
		i.CREDAT_0 as [Date Created],
		max(d.CREDAT_0) as [Last Invoice],
		sum(d.QTY_0) as [Qty Sold 1Y]
	from
		LIVE.CUNLISDET c
	inner join
		LIVE.ITMMASTER i
			on c.ITMREF_0=i.ITMREF_0
	left join LIVE.SINVOICED d on c.ITMREF_0=d.ITMREF_0 and c.STOFCY_0=d.SALFCY_0 and d.CREDAT_0 >= dateadd(year, -1, cast(GETDATE() as date))
	group by
		CUNSSSNUM_0,
		CUNLISNUM_0,
		c.ITMREF_0,
		i.ITMDES1_0,
		i.ITMDES2_0,
		c.PCU_0,
		i.TSICOD_0,
		i.CREDAT_0
)
select
	s.[Count Session],
	s.[Count Sheet],
	s.Product,
	s.Description,
	s.[Unit of Measure],
	s.[Quantity Expected],
	s.Status,
	isnull(s.[Qty Sold 1Y],0) as [Qty Sold 1Y],
	s.[Last Invoice],
	s.[Date Created]
from
	count_sheet s