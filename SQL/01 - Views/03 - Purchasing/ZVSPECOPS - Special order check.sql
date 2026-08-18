 ( COUNT_BPS_0 , ITMREF_0 , PIO_0 , ZSPECOPS_0 ) As 
with supplier_records as (
	select
		count(distinct p.BPSNUM_0) as COUNT_BPS,
		p.ITMREF_0,
		p.PIO_0,
		ZSPECOPS_0,
		sum(s.QTYSTU_0-s.CUMALLQTY_0) as [In-Stock]
	from
		LIVE.ITMBPS p
	inner join
		LIVE.BPSUPPLIER b on p.BPSNUM_0=b.BPSNUM_0
	left join
		LIVE.STOCK s on p.ITMREF_0=s.ITMREF_0 and s.STOFCY_0='DC30'
	inner join
		LIVE.ITMMASTER i on p.ITMREF_0=i.ITMREF_0
	where
		PIO_0=0 and i.TSICOD_0='SO' and b.ZSPECOPS_0<>'2' and i.ACCCOD_0 not in ('FURNITURE','FINPRODUCT')
	group by
		p.BPSNUM_0,
		p.ITMREF_0,
		p.PIO_0,
		b.ZSPECOPS_0,
		i.ACCCOD_0,
		i.TSICOD_0
	having
		(SUM(s.QTYSTU_0 - s.CUMALLQTY_0) IS NULL or SUM(s.QTYSTU_0 - s.CUMALLQTY_0)<=0)
)
select distinct
COUNT_BPS,
ITMREF_0,
PIO_0,
ZSPECOPS_0
from supplier_records
where COUNT_BPS=1
