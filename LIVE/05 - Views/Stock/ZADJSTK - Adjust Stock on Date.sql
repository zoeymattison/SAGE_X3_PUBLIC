with stock_adjust as (
    select
        cast(s.CREDATTIM_0 as datetime) as [Date Created],
        i.ITMREF_0 as [Product],
        i.ITMDES1_0+' '+i.ITMDES2_0 as [Description],
        i.STU_0 as [Unit],
        s.QTYSTU_0 as [Movement],
        s.STOFCY_0 as [Site],
        isnull(v.PHYSTO_0+v.CTLSTO_0+v.REJSTO_0,0) as [Stock],
		case when s.VCRTYP_0 in (4,13,18) then s.QTYSTU_0 else 0 end as [Quantity Delivered],
		case when s.VCRTYP_0 in (6,8) then s.QTYSTU_0 else 0 end as [Quantity Received],
		case when s.VCRTYP_0 not in (4,13,18,6,8,29) then s.QTYSTU_0 else 0 end as [Quantity Adjusted],
		isnull(v.AVC_0,p.PRI_0) as [Price],
		i.ACCCOD_0 as [Accounting Code]
    from
        LIVE.STOJOU s
    inner join
        LIVE.ITMMASTER i on s.ITMREF_0=i.ITMREF_0
    left join
        LIVE.ITMMVT v on s.ITMREF_0=v.ITMREF_0 and s.STOFCY_0=v.STOFCY_0
	left join
		LIVE.PPRICLIST p on i.ITMREF_0=p.PLICRD_0 and p.PLI_0='T20' and i.STU_0=p.UOM_0 and PLICRI1_0=(select top 1 BPSNUM_0 from LIVE.ITMBPS b where b.ITMREF_0=i.ITMREF_0 and PIO_0=0 order by BPSNUM_0 asc)
)
select
    [Site],
    [Product],
    [Description],
    [Unit],
	[Accounting Code],
    [Stock] as [Current Stock],
	/*[Stock]-sum([Movement]) as [Date Adjusted Stock]*/
	[Movement] as [Difference],
	[Quantity Delivered] as [Delivered],
	[Quantity Received] as [Received],
	[Quantity Adjusted] as [Adjusted],
	[Price] as [Avg. Price],
	[Stock]*[Price] as [Current Avg. Total],
	/*([Stock]-sum([Movement]))*[Price] as [Date Adj. Avg. Total]*/
	[Movement]*[Price] as [Price Movement],
[Date Created]
from
    stock_adjust
group by 
    [Site],
    [Product],
    [Description],
    [Unit],
	[Stock],
	[Price],
	[Accounting Code],
	[Movement]