/*
Could you pull a query of all open purchase receipts that don’t have an invoice attached. 

With fields: 

PO
Product
Description
Quantity open to invoice
Supplier BP
Intended receiving site
Cost of an item 
Accounting date 
Product dimension of item (i.e. OP, TCRT, DB etc.)
*/
with supplier as (
	select
		BPSNUM_0,
		BPSNAM_0
	from
		LIVE.BPSUPPLIER
),
products as (
	select
		ITMREF_0,
		CCE_1 as [Dimension]
	from
		LIVE.ITMMASTER
),
purchaseorder as (
	select
		POHNUM_0,
		POPLIN_0,
		ITMREF_0,
		NETPRI_0
	from
		LIVE.PORDERP
)
SELECT
ptd.POHNUM_0 as [Purchase Order],
ptd.ITMREF_0 as [Product],
ptd.ITMDES1_0 as [Description],
ptd.QTYPUU_0 as [Quantity],
ptd.INVQTYPUU_0 as [Invoiced],
ptd.QTYPUU_0-ptd.INVQTYPUU_0 as [To Be Invoiced],
ptd.BPSNUM_0+' '+bps.BPSNAM_0 as [Supplier],
ptd.BPSINV_0 as [Pay-to],
ptd.PRHFCY_0 as [Receiving Site],
poh.NETPRI_0 as [Cost],
poh.NETPRI_0*ptd.QTYPUU_0 as [Total],
ptd.CREDAT_0 as [Accounting Date],
itm.[Dimension]


from LIVE.PRECEIPTD ptd
left join supplier bps on ptd.BPSNUM_0=bps.BPSNUM_0
left join products itm on ptd.ITMREF_0=itm.ITMREF_0
left join purchaseorder poh on ptd.POHNUM_0=poh.POHNUM_0 and ptd.POPLIN_0=poh.POPLIN_0 and ptd.ITMREF_0=poh.ITMREF_0

where ptd.QTYPUU_0-ptd.INVQTYPUU_0>0 and left(ptd.BPSNUM_0,1)='V' and LININVFLG_0=1

order by ptd.CREDAT_0