with remaining_orders as (
	select
		o.ITMREF_0,
		o.VCRNUM_0,
		o.BPRNUM_0+' - '+b.BPCNAM_0 as [Customer],
		o.SHTQTY_0,
		p.GROPRI_0,
		p.NETPRINOT_0,
		q.ORDDAT_0,
		cast(q.CREDATTIM_0 as datetime) as [Datetime]
	from
		LIVE.ORDERS o
	inner join
		LIVE.BPCUSTOMER b on o.BPRNUM_0=b.BPCNUM_0
	inner join
		LIVE.SORDERQ q on o.VCRNUM_0=q.SOHNUM_0 and o.VCRLIN_0=q.SOPLIN_0 and o.VCRSEQ_0=q.SOQSEQ_0
	inner join
		LIVE.SORDERP p on q.SOHNUM_0=p.SOHNUM_0 and q.SOPLIN_0=p.SOPLIN_0 and q.SOQSEQ_0=p.SOPSEQ_0
	where o.ABBFIL_0='SOQ' and o.SHTQTY_0>0
)
Select
ITMREF_0,
ORDDAT_0,
[Customer],
VCRNUM_0,
SHTQTY_0,
GROPRI_0,
GROPRI_0*SHTQTY_0,
[Datetime]
from
remaining_orders