with count_sheet as (
	select
		CUNSSSNUM_0 as [Count Session],
		CUNLISNUM_0 as [Count Sheet],
		c.ITMREF_0 as [Product],
		i.ITMDES1_0+' '+i.ITMDES2_0 as [Description],
		c.PCU_0 as [Unit of Measure],
		sum(c.QTYPCU_0) as [Quantity Expected]
	from
		LIVE.CUNLISDET c
	inner join
		LIVE.ITMMASTER i
			on c.ITMREF_0=i.ITMREF_0
	group by
		CUNSSSNUM_0,
		CUNLISNUM_0,
		c.ITMREF_0,
		i.ITMDES1_0,
		i.ITMDES2_0,
		c.PCU_0
)
select
	s.[Count Session],
	s.[Count Sheet],
	s.Product,
	s.Description,
	s.[Unit of Measure],
	s.[Quantity Expected]
from
	count_sheet s