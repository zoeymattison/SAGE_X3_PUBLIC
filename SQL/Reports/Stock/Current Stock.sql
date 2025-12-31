/*
DC30 - All (less MOT and Furniture)
•	ITEM Number
•	Description
•	Quantity
•	Average Cost
•	Bin Location







*/
Select
s.STOFCY_0 as [Stock Site],
s.ITMREF_0 as [Product],
i.ITMDES1_0+' '+i.ITMDES2_0 as [Description],
sum(s.QTYSTU_0-s.CUMALLQTY_0) as [Quantity],
i.STU_0 as [Unit],
v.AVC_0 as [Average Cost],
s.LOC_0 as [Location],
case
when ACCCOD_0='STATIONERY' then 'STATIONERY'
when CCE_1='TS' or TSICOD_1 in ('8029','8030','2713','8020','8023','8045','8025','8010','8040','5200','5250','5275') then 'MOT'
when ACCCOD_0='TECHNOLOGY' then 'TECHNOLOGY'
when ACCCOD_0='FURNITURE' then 'FURNITURE'
when ACCCOD_0='ART' then 'ART'
End as [Type]

from LIVE.STOCK s
inner join LIVE.ITMMVT v on s.STOFCY_0=v.STOFCY_0 and s.ITMREF_0=v.ITMREF_0
inner join LIVE.ITMMASTER i on s.ITMREF_0=i.ITMREF_0

where
s.STOFCY_0 in ('DC30','2200')

group by
s.STOFCY_0,
s.ITMREF_0,
i.ITMDES1_0,
i.ITMDES2_0,
i.STU_0,
v.AVC_0,
s.LOC_0,
i.ACCCOD_0,
CCE_1,
TSICOD_1

having
sum(s.QTYSTU_0-s.CUMALLQTY_0)>0

order by s.STOFCY_0 asc,s.ITMREF_0 asc