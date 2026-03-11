with products as (
    select
        i.ITMREF_0 as [Product],
        i.ITMDES1_0 + ' ' + i.ITMDES2_0 as [Description],
        i.TSICOD_0 as [Monk Status],
        i.ACCCOD_0 as [Accounting Code],
        isnull(a.TEXTE_0,'') as [Monk Class],
        cast(isnull((
          select STUFF((
            select ', ' + x.loc
            from (
              select distinct st.LOC_0 as loc
              from LIVE.STOCK st
              where st.ITMREF_0 = i.ITMREF_0
                and st.STOFCY_0 = 'DC30'
                and st.LOC_0 is not null
            ) x
            order by x.loc
            for xml path(''), type
          ).value('.', 'nvarchar(max)'), 1, 2, '')
        ),'') as varchar) as Locations,
		i.STU_0 as [Stock Unit],
	    sum(case when s.STA_0='A' then s.QTYSTU_0-(s.CUMALLQTY_0/s.PCUSTUCOE_0) else 0 end) as [A Stock],
        sum(case when s.STA_0='Q' then s.QTYSTU_0-(s.CUMALLQTY_0/s.PCUSTUCOE_0) else 0 end) as [Q Stock],
        sum(case when s.STA_0='R' then s.QTYSTU_0-(s.CUMALLQTY_0/s.PCUSTUCOE_0) else 0 end) as [R Stock],
		isnull(sum(s.QTYSTU_0-(s.CUMALLQTY_0/s.PCUSTUCOE_0)),0) as [All Stock]
    from LIVE.ITMMASTER i
    left join LIVE.ATEXTRA a
      on a.CODFIC_0 = 'ATABDIV'
     and a.IDENT1_0 = '21'
     and a.ZONE_0 = 'LNGDES'
     and a.LANGUE_0 = 'ENG'
     and a.IDENT2_0 = i.TSICOD_1
    left join LIVE.STOCK s
      on i.ITMREF_0 = s.ITMREF_0
     and s.STOFCY_0 = 'DC30'
	where
	 CCE_1<>'TS' and TSICOD_1 not in ('8029','8030','2713','8020','8023','8045','8025','8010','8040','5200','5250','5275')
    group by
        i.ITMREF_0,
        i.ITMDES1_0,
        i.ITMDES2_0,
        i.TSICOD_0,
		i.ACCCOD_0,
        a.TEXTE_0,
		i.STU_0
	having
		isnull(sum(s.QTYSTU_0),0)>0
),
sales_totals as (
	select
		ITMREF_0 as [Product],
		isnull(sum(d.QTYSTU_0),0) as [Quantity Sold Jan-Now],
		round(isnull(sum(d.QTYSTU_0),0)*12/nullif(month(getdate()),0),2) as [Annualized Quantity]
	from
		LIVE.SINVOICED d 
	where
		d.SALFCY_0='DC30' and d.CREDAT_0>=CONVERT(varchar(10), DATEFROMPARTS(YEAR(GETDATE()), 1, 1), 23)
	group by
		ITMREF_0
),
VendorInfo AS (
    SELECT
        ITMREF_0,
        MAX(CASE WHEN VendorRank = 1 THEN VendorName END) AS PrimaryVendor,
        MAX(CASE WHEN VendorRank = 2 THEN VendorName END) AS SecondaryVendor
    FROM (
        SELECT
            ITMREF_0,
            ITP.BPSNUM_0 + ' ' + ISNULL(BPS.BPSNAM_0, '') AS VendorName,
            ROW_NUMBER() OVER (PARTITION BY ITMREF_0 ORDER BY CASE WHEN PIO_0 = 0 THEN 0 ELSE 1 END, PIO_0) AS VendorRank
        FROM LIVE.ITMBPS ITP
        LEFT JOIN LIVE.BPSUPPLIER BPS ON BPS.BPSNUM_0 = ITP.BPSNUM_0
    ) ranked
    WHERE VendorRank <= 2
    GROUP BY ITMREF_0
)
select
 p.[Product],
 p.[Description],
 p.[Monk Status],
 p.[Accounting Code],
 p.[Monk Class],
 p.[Stock Unit],
 p.[Locations],
 p.[A Stock],
 p.[Q Stock],
 p.[R Stock],
 p.[All Stock],
 isnull(s.[Quantity Sold Jan-Now],0) as [Quantity Sold Jan-Now],
 isnull(s.[Annualized Quantity],0) as [Annualized Quantity],
 isnull(s.[Annualized Quantity]/5,0) as [Ideal Stock Position],
 case when isnull(round(p.[All Stock]-(s.[Annualized Quantity]/5),0),0)=0 then p.[All Stock] else isnull(round(p.[All Stock]-(s.[Annualized Quantity]/5),0),0) end as [Excess Stock],
  case when isnull(round(p.[A Stock]-(s.[Annualized Quantity]/5),0),0)=0 then p.[A Stock] else isnull(round(p.[A Stock]-(s.[Annualized Quantity]/5),0),0) end as [Excess Stock (A Only)],
 isnull(vi.PrimaryVendor, 'N/A') AS PrimaryVendor,
 isnull(vi.SecondaryVendor, 'N/A') AS SecondaryVendor

from products p
left join sales_totals s on p.[Product]=s.[Product]
left join VendorInfo vi ON p.[Product] = vi.ITMREF_0
where left(vi.[PrimaryVendor],5)<>'V5664'