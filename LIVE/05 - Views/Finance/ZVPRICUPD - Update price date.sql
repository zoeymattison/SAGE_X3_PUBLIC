with pricelist as (
	select distinct
		PLI_0,
		PLICRD_0,
		PLISTRDAT_0,
		PLIENDDAT_0
	from
		LIVE.SPRICLIST
)

select distinct
h.PLI_0 as [Price List],
h.PLICRD_0 as [Record],
h.PLISTRDAT_0 as [Start Date],
h.PLIENDDAT_0 as [End Date],
l.PLISTRDAT_0 as [List Start Date],
l.PLIENDDAT_0 as [List End Date]

from LIVE.SPRICFICH h
inner join pricelist l on h.PLI_0=l.PLI_0 and h.PLICRD_0=l.PLICRD_0

where h.PLI_0='131' and (h.PLISTRDAT_0 <> l.PLISTRDAT_0 or h.PLIENDDAT_0<>l.PLIENDDAT_0)