with SalesOrders as (
	select
		ITMREF_0,
		sum(QTYSTU_0) as [Ordered Quantity],
		max(SHIDAT_0) as [Next Drop Date]
	from
		LIVE.SORDERQ
	where
		SOQSTA_0<>3
	group by ITMREF_0
),
StockData as (
	select
		ITMREF_0,
		sum(case when STOFCY_0='1600' then (QTYSTU_0-CUMALLQTY_0) else 0 end) as [1600],
		sum(case when STOFCY_0='2100' then (QTYSTU_0-CUMALLQTY_0) else 0 end) as [2100],
		sum(case when STOFCY_0='2200' then (QTYSTU_0-CUMALLQTY_0) else 0 end) as [2200],
		sum(case when STOFCY_0='2300' then (QTYSTU_0-CUMALLQTY_0) else 0 end) as [2300],
		sum(case when STOFCY_0='2600' then (QTYSTU_0-CUMALLQTY_0) else 0 end) as [2600],
		sum(case when STOFCY_0='DC30' then (QTYSTU_0-CUMALLQTY_0) else 0 end) as [DC30],
		sum(case when STOFCY_0='DC33' then (QTYSTU_0-CUMALLQTY_0) else 0 end) as [DC33]
	from
		LIVE.STOCK
	group by
		ITMREF_0
),
PurchaseOrderData as (
	select
		ITMREF_0,
		sum(case when p.ZPOSTA_0=2 and PRHFCY_0 in ('DC30','DC33') then (QTYSTU_0-RCPQTYSTU_0) else 0 end) as [Approved. PO Qty],
		sum(case when p.ZPOSTA_0=1 and PRHFCY_0 in ('DC30','DC33') then (QTYSTU_0-RCPQTYSTU_0) else 0 end) as [Unpproved. PO Qty]
	from
		LIVE.PORDERQ q
	inner join
		LIVE.PORDER p on q.POHNUM_0=p.POHNUM_0
	where
		q.LINCLEFLG_0=1
	group by ITMREF_0
)

select
s.[Next Drop Date] as [Next Drop Date],
i.ITMREF_0 as [Product],
i.ITMDES1_0 as [Description],
isnull(s.[Ordered Quantity],0) as [SO Quantity],
isnull(stk.[1600],0) as [1600],
isnull(stk.[2100],0) as [2100],
isnull(stk.[2200],0) as [2200],
isnull(stk.[2300],0) as [2300],
isnull(stk.[2600],0) as [2600],
isnull(stk.[DC30],0) as [DC30],
isnull(stk.[DC33],0) as [DC33],
isnull(p.[Approved. PO Qty],0) as [App. POQ],
isnull(p.[Unpproved. PO Qty],0) as [Uapp. POQ],
i.RPLITM_0 as [Alternative],
isnull(stk2.[1600],0) as [Alt1600],
isnull(stk2.[2100],0) as [Alt2100],
isnull(stk2.[2200],0) as [Alt2200],
isnull(stk2.[2300],0) as [Alt2300],
isnull(stk2.[2600],0) as [Alt2600],
isnull(stk2.[DC30],0) as [AltDC30],
isnull(stk2.[DC33],0) as [AltDC33],
isnull(p2.[Approved. PO Qty],0) as [App. AltPOQ],
isnull(p2.[Unpproved. PO Qty],0) as [Uapp. AltPOQ]


from LIVE.ITMMASTER i
left outer join SalesOrders s on i.ITMREF_0=s.ITMREF_0
left outer join StockData stk on i.ITMREF_0=stk.ITMREF_0
left outer join StockData stk2 on i.RPLITM_0=stk.ITMREF_0
left outer join PurchaseOrderData p on i.ITMREF_0=p.ITMREF_0
left outer join PurchaseOrderData p2 on i.RPLITM_0=p.ITMREF_0

where ZBTSFLG_0=2

Order by i.ITMREF_0 asc