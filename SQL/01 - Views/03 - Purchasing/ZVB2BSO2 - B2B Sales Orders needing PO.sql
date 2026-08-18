 ( SOHNUM_0 , SOPLIN_0 , ITMREF_0 , ITMDES_0 , QTY_0 , BKO_0 , UOM_0 
 , EXPECTED_0 , MISSING_0 , ETA_0 , PRIORITY_0 ) As 
WITH b2b_raw AS (
    SELECT
        q.SOHNUM_0 AS [Sales Order],
        q.SOPLIN_0 AS [Line],
        q.ITMREF_0 AS [Product],
        i.ITMDES1_0 AS [Description],
        q.QTYSTU_0 AS [Quantity],
        o.SHTQTY_0 AS [FullShortage],
        i.STU_0 AS [Unit],
        s.BPSNUM_0 + ' ' + b.BPSNAM_0 AS [Supplier],
        ISNULL((SELECT SUM(sk2.QTYSTU_0 - sk2.CUMALLQTY_0) 
                FROM LIVE.STOCK sk2 
                WHERE sk2.ITMREF_0 = q.ITMREF_0 AND sk2.STOFCY_0 = q.STOFCY_0 and (sk2.STA_0='A' OR sk2.LOC_0='RF01')), 0) AS [TotalStock],
        ISNULL((SELECT SUM(pq2.QTYSTU_0 - pq2.RCPQTYSTU_0) 
                FROM LIVE.PORDERQ pq2 
                WHERE pq2.ITMREF_0 = q.ITMREF_0 AND pq2.LINCLEFLG_0 = 1), 0) AS [TotalSupply],
        SUM(o.SHTQTY_0) OVER (PARTITION BY q.ITMREF_0 ORDER BY q.CREDAT_0, q.SOHNUM_0, q.SOPLIN_0) AS [RunningDemand],
        MAX(pq.EXTRCPDAT_0) AS [Next PO ETA]
    FROM
        LIVE.SORDERQ q
    INNER JOIN
        LIVE.SORDERP p ON q.ITMREF_0 = p.ITMREF_0 AND q.SOHNUM_0 = p.SOHNUM_0 AND q.SOPLIN_0 = p.SOPLIN_0
    INNER JOIN
        LIVE.ITMMASTER i ON q.ITMREF_0 = i.ITMREF_0
    INNER JOIN
        LIVE.ITMBPS s ON q.ITMREF_0 = s.ITMREF_0 AND s.PIO_0 = 0
    INNER JOIN
        LIVE.BPSUPPLIER b ON s.BPSNUM_0 = b.BPSNUM_0 AND b.BPSTYP_0 = 1
    LEFT JOIN
        LIVE.PORDERQ pq ON q.ITMREF_0 = pq.ITMREF_0 AND pq.LINCLEFLG_0 = 1
    LEFT JOIN
        LIVE.ORDERS o ON q.ITMREF_0 = o.ITMREF_0 AND q.SOHNUM_0 = o.VCRNUM_0 AND q.SOPLIN_0 = o.VCRLIN_0
    WHERE
        q.SOQSTA_0 <> 3
        AND s.BPSNUM_0 NOT IN ('V2181','V2382','V1990','V33000','V27243','V11088','V782','V121220','V2170','V19898','V2730','V2373','V950','V6160','V7654','V0052','V3000','V2375','V1600')
    GROUP BY 
        q.SOHNUM_0, q.SOPLIN_0, q.ITMREF_0, i.ITMDES1_0, q.QTYSTU_0, i.STU_0, s.BPSNUM_0, b.BPSNAM_0, o.SHTQTY_0, q.CREDAT_0, q.STOFCY_0
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
    f.[Sales Order],
    f.[Line],
    f.Product,
    f.Description,
    f.Quantity,
    f.FullShortage - f.AllocatedStock AS [Backordered],
    /*f.AllocatedStock AS [Stock on Hand],*/
    f.Unit,
    f.ExpectedPO AS [Expected],
    (f.FullShortage - f.AllocatedStock - f.ExpectedPO) AS [To Order],
    f.[Next PO ETA],
    ISNULL(pv.VendorName, 'N/A') AS PrimaryVendor
FROM
    Final_Calculation f
LEFT JOIN 
    PrimaryVendor pv ON f.Product = pv.ITMREF_0
WHERE 
    (f.FullShortage - f.AllocatedStock - f.ExpectedPO) > 0
    AND LEFT(f.Product, 1) <> '/'
    AND LEFT(f.Product, 4) <> 'MUN-'
