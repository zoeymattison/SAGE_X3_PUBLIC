with stock_adjust as (
    select
        cast(s.CREDATTIM_0 AT TIME ZONE 'UTC' AT TIME ZONE 'Pacific Standard Time' as datetime) as [Date Created],
        s.ITMREF_0 as [Product],
        s.QTYSTU_0 as [Movement],
        s.STOFCY_0 as [Site],
        case when s.VCRTYP_0 in (4,13,18) then s.QTYSTU_0 else 0 end as [Quantity Delivered],
        case when s.VCRTYP_0 in (6,8) then s.QTYSTU_0 else 0 end as [Quantity Received],
        case when s.VCRTYP_0 not in (4,13,18,6,8,29) then s.QTYSTU_0 else 0 end as [Quantity Adjusted]
    from
        LIVE.STOJOU s
	where 
	cast(s.CREDATTIM_0 AT TIME ZONE 'UTC' AT TIME ZONE 'Pacific Standard Time' as datetime) > %1%
),
current_stock as (
    select
        v.ITMREF_0 as [Product],
        v.STOFCY_0 as [Site],
        isnull(v.PHYSTO_0+v.CTLSTO_0+v.REJSTO_0,0) as [Stock],
        isnull(v.AVC_0,0) as [Price]
    from
        LIVE.ITMMVT v
),
product_info as (
    select
        i.ITMREF_0 as [Product],
        i.ITMDES1_0+iif(i.ITMDES2_0<>'',' '+i.ITMDES2_0,'') as [Description],
        i.STU_0 as [Unit],
        i.ACCCOD_0 as [Accounting Code],
        isnull(p.PRI_0,0) as [List Price]
    from
        LIVE.ITMMASTER i
    left join
        LIVE.PPRICLIST p on i.ITMREF_0=p.PLICRD_0 
            and p.PLI_0='T20' 
            and i.STU_0=p.UOM_0 
            and PLICRI1_0=(select top 1 BPSNUM_0 from LIVE.ITMBPS b where b.ITMREF_0=i.ITMREF_0 and PIO_0=0 order by BPSNUM_0 asc)
)
select
    cs.[Site],
    cs.[Product],
    p.[Description],
    p.[Unit],
    p.[Accounting Code],
    cs.[Stock] as [Current Stock],
    %1%,
    cs.[Stock]-isnull(sum(s.[Movement]),0) as [Date Adjusted Stock],
    isnull(sum(s.[Movement]),0) as [Difference],
    isnull(sum(s.[Quantity Delivered]),0) as [Delivered],
    isnull(sum(s.[Quantity Received]),0) as [Received],
    isnull(sum(s.[Quantity Adjusted]),0) as [Adjusted],
    isnull(cs.[Price], p.[List Price]) as [Avg. Price],
    cs.[Stock]*isnull(cs.[Price], p.[List Price]) as [Current Avg. Total],
    (cs.[Stock]-isnull(sum(s.[Movement]),0))*isnull(cs.[Price], p.[List Price]) as [Date Adj. Avg. Total],
    isnull(sum(s.[Movement]),0)*isnull(cs.[Price], p.[List Price]) as [Price Movement]
from
    current_stock cs
inner join
    product_info p on cs.[Product] = p.[Product]
left join
    stock_adjust s on cs.[Product] = s.[Product] and cs.[Site] = s.[Site]
group by 
    cs.[Site],
    cs.[Product],
    p.[Description],
    p.[Unit],
    cs.[Stock],
    cs.[Price],
    p.[List Price],
    p.[Accounting Code]
having
	 cs.[Stock]-isnull(sum(s.[Movement]),0)>0
order by cs.[Site] asc, cs.[Product] asc