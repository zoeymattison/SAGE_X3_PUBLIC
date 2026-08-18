 ( STOFCY_0 , CREDAT_0 , SHIDAT_0 , SOHNUM_0 , ITMREF_0 , ITMDES1_0 , TSICOD_0 
 , QTYORD_0 , QTYSHT_0 , UOM_0 , QTYEXP_0 , QTYTO_0 , BPSNAM_0 , HLDSTA_0 
 , CDTSTA_0 , BPCORD_0 ) As 
WITH StockTotals AS (
    SELECT
        ITMREF_0,
        STOFCY_0,
        SUM(QTYSTU_0 - CUMALLQTY_0) AS TotalStock
    FROM LIVE.STOCK
    WHERE STA_0 = 'A'
       OR LOC_0 = 'RF01'
    GROUP BY
        ITMREF_0,
        STOFCY_0
),
PORDERQ_Summary AS (
    SELECT
        ITMREF_0,
        PRHFCY_0,
        SUM(QTYSTU_0 - RCPQTYSTU_0) AS TotalSupply,
        MIN(EXTRCPDAT_0) AS EXTRCPDAT_0
    FROM LIVE.PORDERQ
    WHERE LINCLEFLG_0 = 1
and ORI_0=1
    GROUP BY
        ITMREF_0,
        PRHFCY_0
),
b2b_raw AS (
    SELECT
        q.STOFCY_0 as [Stock Site],
        q.SOHNUM_0 AS [Sales Order],
        q.SOPLIN_0 AS [Line],
        q.ITMREF_0 AS [Product],
        i.ITMDES1_0 AS [Description],
        q.QTYSTU_0 AS [Quantity],
        o.SHTQTY_0 AS [FullShortage],
        i.STU_0 AS [Unit],
        s.BPSNUM_0 + ' ' + b.BPSNAM_0 AS [Supplier],
        ISNULL(st.TotalStock,0) AS [TotalStock],
        ISNULL(po.TotalSupply,0) AS [TotalSupply],
        SUM(o.SHTQTY_0) OVER (
            PARTITION BY q.ITMREF_0, q.STOFCY_0
            ORDER BY h.HLDSTA_0, h.CDTSTA_0, h.SHIDAT_0, q.SOHNUM_0, q.SOPLIN_0 asc
        ) AS [RunningDemand],
i.TSICOD_0 as [Monk Status],
h.SHIDAT_0 as ShipDate,
h.CREDAT_0 as CreationDate,
h.HLDSTA_0 as ShippingHold,
h.CDTSTA_0 as CreditHold,
h.BPCORD_0+' '+h.BPDNAM_0 as Customer
    FROM LIVE.SORDERQ q
    INNER JOIN LIVE.SORDERP p
        ON q.ITMREF_0 = p.ITMREF_0
       AND q.SOHNUM_0 = p.SOHNUM_0
       AND q.SOPLIN_0 = p.SOPLIN_0
    INNER JOIN LIVE.ITMMASTER i
        ON q.ITMREF_0 = i.ITMREF_0
    INNER JOIN LIVE.ITMBPS s
        ON q.ITMREF_0 = s.ITMREF_0
       AND s.PIO_0 = 0
    INNER JOIN LIVE.BPSUPPLIER b
        ON s.BPSNUM_0 = b.BPSNUM_0
       AND b.BPSTYP_0 = 1
    LEFT JOIN StockTotals st
        ON st.ITMREF_0 = q.ITMREF_0
       AND st.STOFCY_0 = q.STOFCY_0
    LEFT JOIN PORDERQ_Summary po
        ON po.ITMREF_0 = q.ITMREF_0
       AND po.PRHFCY_0 = q.STOFCY_0
    LEFT JOIN LIVE.ORDERS o
        ON q.ITMREF_0 = o.ITMREF_0
       AND q.SOHNUM_0 = o.VCRNUM_0
       AND q.SOPLIN_0 = o.VCRLIN_0
	inner join LIVE.SORDER h on q.SOHNUM_0=h.SOHNUM_0
    WHERE
        q.SOQSTA_0 <> 3
 AND ISNULL(o.SHTQTY_0,0) > 0
        AND left(s.BPSNUM_0,5)='V6501'
        and q.FMI_0=1 and HLDSTA_0=1 and CDTSTA_0=1 and h.STOFCY_0<>'DC33' and h.APPFLG_0<>1
    GROUP BY
        q.STOFCY_0,
        q.SOHNUM_0,
        q.SOPLIN_0,
        q.ITMREF_0,
        i.ITMDES1_0,
        q.QTYSTU_0,
        i.STU_0,
        s.BPSNUM_0,
        b.BPSNAM_0,
        o.SHTQTY_0,
        o.ENDDAT_0,
        i.TSICOD_0,
        st.TotalStock,
        po.TotalSupply,
		h.CREDAT_0,
		h.SHIDAT_0,
		h.HLDSTA_0,
		h.CDTSTA_0,
		q.FMI_0,
		h.BPCORD_0,
		h.BPDNAM_0
),
Allocated_CTE AS (
    SELECT 
        r.*,
        CASE 
            WHEN (r.TotalStock - (r.RunningDemand - r.FullShortage)) <= 0 THEN 0
            WHEN (r.TotalStock - (r.RunningDemand - r.FullShortage)) >= r.FullShortage THEN r.FullShortage
            ELSE (r.TotalStock - (r.RunningDemand - r.FullShortage))
        END AS [AllocatedStock]
    FROM b2b_raw r
),
Final_Calculation AS (
    SELECT 
        a.*,
        CASE 
            WHEN (a.TotalSupply - (CASE WHEN (a.RunningDemand - a.FullShortage) > a.TotalStock THEN (a.RunningDemand - a.FullShortage) - a.TotalStock ELSE 0 END)) >= (a.FullShortage - a.AllocatedStock)
                THEN (a.FullShortage - a.AllocatedStock)
            ELSE 
                IIF((a.TotalSupply - (CASE WHEN (a.RunningDemand - a.FullShortage) > a.TotalStock THEN (a.RunningDemand - a.FullShortage) - a.TotalStock ELSE 0 END)) < 0, 
                    0, 
                    (a.TotalSupply - (CASE WHEN (a.RunningDemand - a.FullShortage) > a.TotalStock THEN (a.RunningDemand - a.FullShortage) - a.TotalStock ELSE 0 END)))
        END AS [ExpectedPO]
    FROM Allocated_CTE a
),
PrimaryVendor AS (
    SELECT v.ITMREF_0, v.VendorName
    FROM (
        SELECT ITP.ITMREF_0, 
               ITP.BPSNUM_0 + ' ' + BPS.BPSNAM_0 AS VendorName,
               ROW_NUMBER() OVER (PARTITION BY ITP.ITMREF_0 ORDER BY ITP.PIO_0 ASC) as RN
        FROM LIVE.ITMBPS ITP
        INNER JOIN LIVE.BPSUPPLIER BPS ON BPS.BPSNUM_0 = ITP.BPSNUM_0
    ) v
    WHERE v.RN = 1
)
SELECT
    f.[Stock Site],
	f.CreationDate,
	f.ShipDate,
    f.[Sales Order],
    f.Product,
    f.Description,
    f.[Monk Status],
    f.Quantity,
    f.FullShortage - f.AllocatedStock AS [Backordered],
    f.Unit,
    f.ExpectedPO AS [Expected],
    (f.FullShortage - f.AllocatedStock - f.ExpectedPO) AS [To Order],
    ISNULL(pv.VendorName, 'N/A') AS PrimaryVendor,
	f.ShippingHold,
	f.CreditHold,
	f.Customer
FROM Final_Calculation f
LEFT JOIN PrimaryVendor pv 
    ON f.Product = pv.ITMREF_0
WHERE 
    (f.FullShortage - f.AllocatedStock - f.ExpectedPO) > 0
    AND LEFT(f.Product, 1) <> '/'
    AND LEFT(f.Product, 4) <> 'MUN-'
