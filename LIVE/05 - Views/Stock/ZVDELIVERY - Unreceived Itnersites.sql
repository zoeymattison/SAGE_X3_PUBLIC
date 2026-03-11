with deliveries as (
	select
		sdh.CREDAT_0,
		sdd.SDHNUM_0,
		sdd.BPCORD_0,
		ITMREF_0,
		ITMDES1_0,
		QTY_0-(RCPQTYSTU_0/SAUSTUCOE_0) as QTY_0,
		SAU_0
	from
		LIVE.SDELIVERYD sdd
	inner join LIVE.SDELIVERY sdh on sdd.SDHNUM_0=sdh.SDHNUM_0
	where
		QTY_0-(RCPQTYSTU_0/SAUSTUCOE_0)>0 and sdh.BETFCY_0=2
	and
		sdh.CREDAT_0<=dateadd(day,-14,GETDATE())

)

select
CREDAT_0,
SDHNUM_0,
BPCORD_0,
ITMREF_0,
ITMDES1_0,
QTY_0,
SAU_0
from deliveries