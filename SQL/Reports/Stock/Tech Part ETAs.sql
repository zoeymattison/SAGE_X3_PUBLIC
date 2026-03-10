with demand as (
    -- Calculate running total of the SHORTAGE (what we still need)
    select
        q.ORDDAT_0 as [Order Date],
        h.BPCNAM_0 as [Technician],
        h.CUSORDREF_0 as [Task Ticket],
        q.SOHNUM_0 as [Sales Order],
        q.SOPLIN_0, 
        h.YCONTNAME_0 as [Client Name],
        q.ITMREF_0 as [Product],
        i.ITMDES1_0 as [Description],
        q.QTYSTU_0 as [Ordered],        -- Added Original Ordered Qty
        q.SHTQTYSTU_0 as [Short Qty],   -- Shortage Quantity for allocation
        -- Running total of shortage per product
        sum(q.SHTQTYSTU_0) over (partition by q.ITMREF_0 order by q.ORDDAT_0, q.SOHNUM_0, q.SOPLIN_0) as Cumulative_Demand,
        -- Starting point of this specific shortage line
        sum(q.SHTQTYSTU_0) over (partition by q.ITMREF_0 order by q.ORDDAT_0, q.SOHNUM_0, q.SOPLIN_0) - q.SHTQTYSTU_0 as Demand_Start
    from
        LIVE.SORDERQ q
    inner join
        LIVE.SORDER h on q.SOHNUM_0=h.SOHNUM_0
    inner join
        LIVE.ITMMASTER i on q.ITMREF_0=i.ITMREF_0
    where
        q.SOQSTA_0 <> 3 
        and q.SHTQTYSTU_0 > 0 
        and left(q.BPCORD_0,3) = 'ICR' 
        and h.BETFCY_0 = 2
),
supply as (
    -- Calculate running total of REMAINING PO QUANTITY (Ordered minus Received)
    select
        pq.POHNUM_0,
        pq.EXTRCPDAT_0,
        pq.ITMREF_0,
        (pq.QTYSTU_0 - pq.RCPQTYSTU_0) as [Remaining_To_Receive],
        -- Running total of remaining supply per product
        sum(pq.QTYSTU_0 - pq.RCPQTYSTU_0) over (partition by pq.ITMREF_0 order by pq.EXTRCPDAT_0, pq.POHNUM_0, pq.POPLIN_0) as Cumulative_Supply,
        -- Starting point of this specific PO's remaining balance
        sum(pq.QTYSTU_0 - pq.RCPQTYSTU_0) over (partition by pq.ITMREF_0 order by pq.EXTRCPDAT_0, pq.POHNUM_0, pq.POPLIN_0) - (pq.QTYSTU_0 - pq.RCPQTYSTU_0) as Supply_Start
    from
        LIVE.PORDERQ pq
    where
        pq.LINCLEFLG_0 = 1 
        and (pq.QTYSTU_0 - pq.RCPQTYSTU_0) > 0 
),
allocation as (
    -- Match Shortages to remaining PO balances
    select 
        d.*,
        s.POHNUM_0,
        s.EXTRCPDAT_0,
        case 
            when d.Cumulative_Demand <= s.Supply_Start or d.Demand_Start >= s.Cumulative_Supply then 0
            else (case when d.Cumulative_Demand < s.Cumulative_Supply then d.Cumulative_Demand else s.Cumulative_Supply end) - 
                 (case when d.Demand_Start > s.Supply_Start then d.Demand_Start else s.Supply_Start end)
        end as Allocated_Qty,
        row_number() over (partition by d.Product, d.[Sales Order], d.SOPLIN_0 order by s.EXTRCPDAT_0) as PO_Rank
    from demand d
    left join supply s on d.Product = s.ITMREF_0 
        and d.Demand_Start < s.Cumulative_Supply  
        and d.Cumulative_Demand > s.Supply_Start 
)
select
    [Order Date],
    [Technician],
    [Task Ticket],
    [Sales Order],
    [Client Name],
    [Product],
    [Description],
    [Ordered],        -- Display original order quantity
    [Short Qty] as [Short],
    -- Layer 1: Primary PO
    max(case when PO_Rank = 1 then POHNUM_0 end) as [Next PO],
    max(case when PO_Rank = 1 then EXTRCPDAT_0 end) as [Next ETA],
    max(case when PO_Rank = 1 then Allocated_Qty else 0 end) as [Qty from PO 1],
    -- Layer 2: Secondary PO
    max(case when PO_Rank = 2 then POHNUM_0 end) as [Next PO 2],
    max(case when PO_Rank = 2 then EXTRCPDAT_0 end) as [Next ETA 2],
    max(case when PO_Rank = 2 then Allocated_Qty else 0 end) as [Qty from PO 2],
    -- Shortage tracking
    [Short Qty] - (max(case when PO_Rank = 1 then Allocated_Qty else 0 end) + max(case when PO_Rank = 2 then Allocated_Qty else 0 end)) as [Unallocated Shortage]
from
    allocation
group by
    [Order Date], [Technician], [Task Ticket], [Sales Order], [SOPLIN_0], [Client Name], [Product], [Description], [Ordered], [Short Qty], [Demand_Start]
order by
    [Technician] Asc, [Order Date] asc;

/* test */