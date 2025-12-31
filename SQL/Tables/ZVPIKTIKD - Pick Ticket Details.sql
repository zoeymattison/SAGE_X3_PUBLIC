with picking_lines as (
	select
		d.ITMREF_0 as [Product],
		i.ITMDES1_0+' '+ITMDES2_0+' '+ITMDES3_0 as [Description],
		i.EANCOD_0 as [UPC Code],
		d.QTYSTU_0 as [Quantity],
		d.STU_0 as [Stock Unit],
		k.LOC_0 as [Location],
		d.CREDAT_0 as [Creation Date],
		h.STOFCY_0 as [Stock Site],
		d.ORILIN_0 as [SO Line],
		d.ORINUM_0 as [Sales Order],
		d.PRHNUM_0 as [Pick Ticket]
	from
		LIVE.STOPRED d
	inner join
		LIVE.STOPREH h on d.PRHNUM_0=h.PRHNUM_0
	inner join
		LIVE.ITMMASTER i on d.ITMREF_0=i.ITMREF_0
	left join
		LIVE.STOALL s on d.PRELIN_0=s.VCRLIN_0 and d.PRHNUM_0=s.VCRNUM_0
	left join
		LIVE.STOCK k on s.STOCOU_0=k.STOCOU_0 and s.STOFCY_0=k.STOFCY_0
),
stock_locations as (
	select
		ITMREF_0 as [Product],
		STOFCY_0 as [Stock Site],
		min(LOC_0) as [Location]
	from
		LIVE.STOCK
	group by
		STOFCY_0,
		ITMREF_0
),
customer_notes as (
	select
		SOHNUM_0 as [Sales Order],
		SOPLIN_0 as [SO Line],
		ITMREF_0 as [Product],
		FMINUM_0 as [Purhchase Order],
		b.BPSNUM_0+' - '+b.BPSNAM_0 as [Supplier],
		YOPTFEA_0 as [Optional Features],
		ltrim(rtrim(replace(replace(replace(YCUSTNOT_0,'PST Exemption: Yes',''),'PST Exemption: No',''),'PST Exemption:',''))) as [Customer Notes]
	from
		LIVE.SORDERQ s
	left join
		LIVE.BPSUPPLIER b on s.YB2BBPS_0=b.BPSNUM_0 and b.BPAADD_0='REMIT'
),
supplier_part as (
	select
		ITMREF_0 as [Product],
		max(ITMREFBPS_0) as [Supplier Part]
	from
		LIVE.ITMBPS
	where
		PIO_0=0
	group by
		ITMREF_0
)
select top 100
p.[Pick Ticket],
p.[Product],
p.[Description],
p.[UPC Code],
p.[Quantity],
p.[Stock Unit],
isnull(isnull(p.[Location],l.[Location]),'N/A'),
c.[Customer Notes],
s.[Supplier Part],
c.[Purhchase Order],
c.[Supplier],
c.[Optional Features]

from picking_lines p
left join stock_locations l on p.[Stock Site]=l.[Stock Site] and p.[Product]=l.[Product]
left join customer_notes c on p.[Sales Order]=c.[Sales Order] and p.[SO Line]=c.[SO Line]
left join supplier_part s on p.[Product]=s.[Product]