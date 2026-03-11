with itmmvt as (
	select
		STOFCY_0 as [Stock Site],
		ITMREF_0 as [Product],
		PHYSTO_0 as [Quantity],
		ZINSTOCKDAT_0 as [In Stock Since],
		ZSTOCKOUTDAT_0 as [Stockout Date]
	from
		LIVE.ITMMVT v
),
stock as (
	select
		ITMREF_0 as [Product],
		STOFCY_0 as [Stock Site],
		min(CAST(CREDATTIM_0 AT TIME ZONE 'UTC' AT TIME ZONE 'Pacific Standard Time' AS datetime2)) as [Date Created],
		sum(QTYSTU_0) as [Total Stock]
	from
		LIVE.STOCK
	where
		QTYSTU_0>0
	group by
	STOFCY_0,ITMREF_0
)
select
i.[Stock Site],
i.[Product],
isnull(s.[Total Stock],i.Quantity),
cast(format(s.[Date Created],'yyyy-MM-ddThh:mm:ssZ') as varchar) as [New In Stock],
cast(format(GETDATE(),'yyyy-MM-ddThh:mm:ssZ') as varchar) as [New Stockout],
Case
	when s.[Total Stock]>0 and (i.[Stockout Date]>i.[In Stock Since] or i.[Stockout Date]=i.[In Stock Since]) then 'IN'
	when i.[Quantity]=0 and s.[Total Stock] is null and i.[Stockout Date]<i.[In Stock Since] then 'OUT'
End as [Type]

from itmmvt i
left join stock s on i.[Stock Site]=s.[Stock Site] and i.[Product]=s.[Product]
Where
(s.[Total Stock]>0 and (i.[Stockout Date]>i.[In Stock Since] or i.[Stockout Date]=i.[In Stock Since])) or (i.[Quantity]=0 and s.[Total Stock] is null and i.[Stockout Date]<i.[In Stock Since])
