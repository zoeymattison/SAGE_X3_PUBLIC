with backorder_total as (
	select
		ITMREF_0,
		sum(SHTQTY_0) as [Backordered Quantity]
	from
		LIVE.ORDERS
	where
		STOFCY_0='DC30' and SHTQTY_0>0 and ABBFIL_0='SOQ'
	group by
		ITMREF_0
)
select
ITMREF_0,
[Backordered Quantity]
from
backorder_total