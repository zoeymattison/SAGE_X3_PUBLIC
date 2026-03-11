
WITH picking_lines AS (
    SELECT
        d.ITMREF_0 AS [Product],
        i.ITMDES1_0 + ' ' + ITMDES2_0 + ' ' + ITMDES3_0 AS [Description],
        i.EANCOD_0 AS [UPC Code],
        SUM(ISNULL(s.QTYSTU_0, d.QTYSTU_0)) AS [Quantity],
        d.STU_0 AS [Stock Unit],
        k.LOC_0 AS [Location],
        d.CREDAT_0 AS [Creation Date],
        h.STOFCY_0 AS [Stock Site],
        d.ORILIN_0 AS [SO Line],
        d.ORINUM_0 AS [Sales Order],
        d.PRHNUM_0 AS [Pick Ticket]
    FROM LIVE.STOPRED d
    INNER JOIN LIVE.STOPREH h ON d.PRHNUM_0 = h.PRHNUM_0
    INNER JOIN LIVE.ITMMASTER i ON d.ITMREF_0 = i.ITMREF_0
    LEFT JOIN LIVE.STOALL s 
        ON d.PRELIN_0 = s.VCRLIN_0 
       AND d.PRHNUM_0 = s.VCRNUM_0 
       AND d.ITMREF_0 = s.ITMREF_0
    LEFT JOIN LIVE.STOCK k 
        ON s.STOCOU_0 = k.STOCOU_0 
       AND s.STOFCY_0 = k.STOFCY_0
    GROUP BY
        d.ITMREF_0,
        i.ITMDES1_0,
        i.ITMDES2_0,
        i.ITMDES3_0,
        i.EANCOD_0,
        d.STU_0,
        k.LOC_0,
        d.CREDAT_0,
        h.STOFCY_0,
        d.ORILIN_0,
        d.ORINUM_0,
        d.PRHNUM_0
),
stock_locations AS (
    SELECT
        ITMREF_0 AS [Product],
        STOFCY_0 AS [Stock Site],
        MIN(LOC_0) AS [Location]
    FROM LIVE.STOCK
    GROUP BY STOFCY_0, ITMREF_0
),
customer_notes AS (
    SELECT
        SOHNUM_0 AS [Sales Order],
        SOPLIN_0 AS [SO Line],
        ITMREF_0 AS [Product],
        IIF(s.FMI_0 <> 1, FMINUM_0, '') AS [Purhchase Order],
        IIF(s.FMI_0 <> 1, b.BPSNUM_0 + ' - ' + b.BPSNAM_0, '') AS [Supplier],
        b.BPSNUM_0 AS [Supplier Code],
        YOPTFEA_0 AS [Optional Features],
        IIF(
            LEFT(SOHNUM_0, 3) = 'BTS', 
            '', 
            LTRIM(RTRIM(REPLACE(REPLACE(REPLACE(YCUSTNOT_0, 'PST Exemption: Yes', ''), 'PST Exemption: No', ''), 'PST Exemption:', '')))
        ) AS [Customer Notes]
    FROM LIVE.SORDERQ s
    LEFT JOIN LIVE.PORDER p ON s.FMINUM_0 = p.POHNUM_0
    LEFT JOIN LIVE.BPSUPPLIER b ON p.BPSNUM_0 = b.BPSNUM_0 AND b.BPAADD_0 = 'REMIT'
),
supplier_part AS (
    SELECT
        ITMREF_0    AS [Product],
        PIO_0       AS [Priority],
        BPSNUM_0    AS [Supplier],
        ITMREFBPS_0 AS [Supplier Part]
    FROM LIVE.ITMBPS
)
SELECT
    p.[Pick Ticket],
    p.[Product],
    p.[Description],
    p.[UPC Code],
    p.[Quantity],
    p.[Stock Unit],
    ISNULL(ISNULL(p.[Location], l.[Location]), 'N/A') AS [Location],
    c.[Customer Notes],
    s.[Supplier Part],
    c.[Purhchase Order],
    c.[Supplier],
    c.[Optional Features]
FROM picking_lines p
LEFT JOIN stock_locations l 
    ON p.[Stock Site] = l.[Stock Site] 
   AND p.[Product]    = l.[Product]
LEFT JOIN customer_notes c 
    ON p.[Sales Order] = c.[Sales Order] 
   AND p.[SO Line]     = c.[SO Line]

OUTER APPLY (
    SELECT TOP (1) sp.*
    FROM supplier_part sp
    WHERE sp.[Product] = c.[Product]
      AND (
            (c.[Supplier Code] IS NOT NULL AND c.[Supplier Code] <> '' AND sp.[Supplier] = c.[Supplier Code])
        OR  (c.[Supplier Code] IS NULL)
      )
    ORDER BY sp.[Priority] ASC, sp.[Supplier] ASC
) AS s
