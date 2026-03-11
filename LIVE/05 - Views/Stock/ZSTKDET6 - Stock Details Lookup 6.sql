with open_pos as (
	select
		p.ORDDAT_0,
		p.POHNUM_0,
		ITMREF_0,
		p.BPSNUM_0+' - '+b.BPSNAM_0 as [Supplier],
		cast(p.CREDATTIM_0 as datetime) as [Datetime],
		p.QTYSTU_0-p.RCPQTYSTU_0 as [Remaining],
		p.EXTRCPDAT_0 as [ETA]
	from
		LIVE.PORDERQ p
	inner join
		LIVE.BPSUPPLIER b on p.BPSNUM_0=b.BPSNUM_0
	inner join
		LIVE.PORDER h on p.POHNUM_0=h.POHNUM_0
	where
		p.LINCLEFLG_0=1 and p.QTYSTU_0-p.RCPQTYSTU_0>0
	and
		h.BETFCY_0=1

)
select
ORDDAT_0,
POHNUM_0,
ITMREF_0,
[Supplier],
[Datetime],
[Remaining],
[ETA]
from
open_pos