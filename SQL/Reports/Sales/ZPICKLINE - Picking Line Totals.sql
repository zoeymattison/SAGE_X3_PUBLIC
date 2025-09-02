select
	sdd.CREDAT_0 as DatePicked,
	sdd.STOFCY_0 as StockSite,
	sdd.PRHNUM_0 as PickTicket,
	sdd.BPCORD_0 as SoldTo,
	sdd.SOHNUM_0 as SalesOrder,
case
	when soh.BETFCY_0=1 then 'COMMERCIAL'
	when soh.BETFCY_0=2 then 'RETAIL'
else 'SALES ORDER N/A'
end as SaleOrderType,
	sdd.ITMREF_0 as Product,
	sdd.ITMDES1_0 as Description,
	sdd.QTYSTU_0/sdd.SAUSTUCOE_0 as Quantity,
	sdd.SAU_0 as SalesUnit,
	sdd.GROPRI_0 as SalesPrice,
	(sdd.QTYSTU_0/sop.SAUSTUCOE_0)*sdd.GROPRI_0 as TotalSales,
	itm.ACCCOD_0 as AccountingCode,
	sdh.BPDADDLIG_0 as [Address Line 1],
	sdh.BPDADDLIG_1 as [Address Line 2],
	sdh.BPDADDLIG_2 as [Address Line 3],
	sdh.BPDCTY_0 as [City],
	isnull(r.REPNUM_0,'') as [Rep],
	isnull(r.REPNAM_0,'') as [Rep Name],
	apl.LANMES_0
from 
	LIVE.SDELIVERYD sdd
inner join 
	LIVE.SDELIVERY sdh on sdd.SDHNUM_0=sdh.SDHNUM_0
left join 
	LIVE.SALESREP r on sdh.REP_0=r.REPNUM_0
left join 
	LIVE.SORDERP sop on sdd.SOHNUM_0=sop.SOHNUM_0 AND sdd.SOPLIN_0=sop.SOPLIN_0
left join 
	LIVE.SORDER soh on sop.SOHNUM_0=soh.SOHNUM_0
left join 
	LIVE.ITMMASTER itm on sdd.ITMREF_0=itm.ITMREF_0
left join 
	LIVE.APLSTD apl on sdh.DRN_0 = apl.LANNUM_0
		and apl.LANCHP_0 = '409'
		and apl.LAN_0 = 'ENG'