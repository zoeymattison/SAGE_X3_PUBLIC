
WITH SalesPrice AS (
    SELECT
        PLICRI2_0,
        PRI_0,
        ROW_NUMBER() OVER (PARTITION BY PLICRI2_0 ORDER BY MAXQTY_0 ASC) AS rn
    FROM LIVE.SPRICLIST
    WHERE PLI_0 = '11'
      AND PLICRI1_0 = 'PL2'
),

SalesOrderData AS (
    SELECT
        SID.ITMREF_0,
        SUM(CASE WHEN SID.SALFCY_0 = 'DC30' THEN SID.AMTATILIN_0 * SIV.SNS_0 ELSE 0 END) AS [DC30 Sales],
        SUM(SID.AMTNOTLIN_0 * SIV.SNS_0) AS TotalSales,
        SUM(SID.QTYSTU_0 * SIV.SNS_0) AS TotalSalesQty,
        COUNT(DISTINCT SID.SOHNUM_0) AS [Number of UqO],
        AVG(CASE WHEN SOQ.CREDAT_0 IS NOT NULL
                 THEN DATEDIFF(DAY, SOQ.CREDAT_0, SID.CREDAT_0)
                 ELSE NULL END) AS AvgDeliveryDays
    FROM LIVE.SINVOICED AS SID
    INNER JOIN LIVE.SINVOICE AS SIV
        ON SID.NUM_0 = SIV.NUM_0
    LEFT JOIN LIVE.SORDERQ SOQ
        ON SID.ITMREF_0 = SOQ.ITMREF_0
       AND SID.SOHNUM_0 = SOQ.SOHNUM_0
       AND SID.SOPLIN_0 = SOQ.SOPLIN_0
       AND SID.SOQSEQ_0 = SOQ.SOQSEQ_0
    WHERE SID.CREDAT_0 >= DATEADD(YEAR, -1, GETDATE())
    GROUP BY SID.ITMREF_0
),

StockSafetyData AS (
    SELECT
        STO.ITMREF_0,
        SUM(CASE WHEN STO.STOFCY_0 = 'DC30' THEN STO.QTYSTU_0 ELSE 0 END) AS StockTotalDC30
    FROM LIVE.STOCK STO
    GROUP BY STO.ITMREF_0
),

/* Promote these to top-level CTEs (no nested WITH) */
COG AS (
    SELECT
        ITMREF_0,
        SUM(CASE WHEN STOFCY_0 = 'DC30' THEN CPRPRI_0 ELSE 0 END) AS [COG DC30],
        SUM(CPRPRI_0) AS [COG Total]
    FROM LIVE.SORDERP
    WHERE CREDAT_0 >= DATEADD(YEAR, -1, GETDATE())
    GROUP BY ITMREF_0
),

ITM_AVC AS (
    SELECT ITMREF_0, AVC_0
    FROM LIVE.ITMMVT
    WHERE STOFCY_0 = 'DC30'
),

CostData AS (
    SELECT
        M.ITMREF_0,
        ISNULL(COG.[COG DC30], 0) AS [COG DC30],
        ISNULL(ITM_AVC.AVC_0, 0)  AS [Average Cost]
    FROM LIVE.ITMMASTER M
    LEFT JOIN COG      ON COG.ITMREF_0      = M.ITMREF_0
    LEFT JOIN ITM_AVC  ON ITM_AVC.ITMREF_0  = M.ITMREF_0
),

VendorInfo AS (
    SELECT
        ITMREF_0,
        MAX(CASE WHEN VendorRank = 1 THEN VendorName END) AS PrimaryVendor,
        MAX(CASE WHEN VendorRank = 2 THEN VendorName END) AS SecondaryVendor
    FROM (
        SELECT
            ITP.ITMREF_0,
            ITP.BPSNUM_0 + ' ' + ISNULL(BPS.BPSNAM_0, '') AS VendorName,
            ROW_NUMBER() OVER (
                PARTITION BY ITP.ITMREF_0
                ORDER BY CASE WHEN ITP.PIO_0 = 0 THEN 0 ELSE 1 END, ITP.PIO_0
            ) AS VendorRank
        FROM LIVE.ITMBPS ITP
        LEFT JOIN LIVE.BPSUPPLIER BPS
            ON BPS.BPSNUM_0 = ITP.BPSNUM_0
    ) ranked
    WHERE VendorRank <= 2
    GROUP BY ITMREF_0
),

open_po AS (
    SELECT
        ITMREF_0,
        CREDAT_0,
        BPSNUM_0 + ' ' + BPSNAM_0 AS [Supplier],
        QTYSTU_0 - RCPQTYSTU_0     AS [Quantity on PO],
        ORDDAT_0
    FROM (
        SELECT
            p.ITMREF_0,
            p.CREDAT_0,
            p.BPSNUM_0,
            s.BPSNAM_0,
            p.QTYSTU_0,
            p.RCPQTYSTU_0,
            p.ORDDAT_0,
            ROW_NUMBER() OVER (
                PARTITION BY p.ITMREF_0
                ORDER BY p.CREDAT_0 DESC
            ) AS rn
        FROM LIVE.PORDERQ p
        INNER JOIN LIVE.BPSUPPLIER s
            ON p.BPSNUM_0 = s.BPSNUM_0
        WHERE LEFT(p.BPSNUM_0, 1) = 'V'
          AND p.PRHFCY_0 = 'DC30'
          AND p.LINCLEFLG_0 = 1
    ) ranked
    WHERE rn = 1
),

last_invoice AS (
    SELECT
        ITMREF_0,
        INVDAT_0
    FROM (
        SELECT
            ITMREF_0,
            INVDAT_0,
            ROW_NUMBER() OVER (
                PARTITION BY ITMREF_0
                ORDER BY INVDAT_0 DESC
            ) AS rn
        FROM LIVE.SINVOICED
        WHERE SALFCY_0 = 'DC30'
    ) ranked
    WHERE rn = 1
),

ReceiptsBase AS (
    SELECT
        s.ITMREF_0,
        s.CREDATTIM_0,
        CAST(s.QTYSTU_0 AS DECIMAL(28,13)) AS Qty,
        DATEDIFF(DAY, s.CREDATTIM_0, GETDATE()) AS AgeDays,
        st.StockTotalDC30
    FROM LIVE.STOJOU s
    INNER JOIN StockSafetyData st
        ON st.ITMREF_0 = s.ITMREF_0
    WHERE s.STOFCY_0 = 'DC30'
      AND s.VARVAL_0 > 0
      AND s.REGFLG_0 = 1
      AND s.VCRTYP_0 IN (6, 9, 13, 18, 19)
),

ReceiptsAllocated AS (
    SELECT
        r.ITMREF_0,
        r.CREDATTIM_0,
        r.AgeDays,
        r.Qty,
        r.StockTotalDC30,
        SUM(r.Qty) OVER (
            PARTITION BY r.ITMREF_0
            ORDER BY r.CREDATTIM_0 DESC
            ROWS UNBOUNDED PRECEDING
        ) AS running_incl,
        SUM(r.Qty) OVER (
            PARTITION BY r.ITMREF_0
            ORDER BY r.CREDATTIM_0 DESC
            ROWS UNBOUNDED PRECEDING
        ) - r.Qty AS running_prior
    FROM ReceiptsBase r
),

ReceiptsCapped AS (
    SELECT
        ITMREF_0,
        CREDATTIM_0,
        AgeDays,
        Qty,
        StockTotalDC30,
        CAST(
            CASE
                WHEN (StockTotalDC30 - running_prior) <= 0
                    THEN 0
                ELSE CASE
                    WHEN Qty <= (StockTotalDC30 - running_prior)
                        THEN Qty
                    ELSE (StockTotalDC30 - running_prior)
                END
            END
        AS DECIMAL(28,13)) AS AllocatedQty
    FROM ReceiptsAllocated
),


ReceiptBuckets AS (
    SELECT
        ITMREF_0,
        CAST(CASE WHEN AgeDays BETWEEN 0   AND 180 THEN AllocatedQty ELSE 0 END AS DECIMAL(28,13)) AS Bucket_0_180,
        CAST(CASE WHEN AgeDays BETWEEN 181 AND 365 THEN AllocatedQty ELSE 0 END AS DECIMAL(28,13)) AS Bucket_181_365,
        CAST(CASE WHEN AgeDays >= 366             THEN AllocatedQty ELSE 0 END AS DECIMAL(28,13)) AS Bucket_366_Plus
    FROM ReceiptsCapped
    WHERE AllocatedQty > 0

),


BucketSummary AS (
    SELECT
        ITMREF_0,
        SUM(Bucket_0_180)   AS Bucket_0_180,
        SUM(Bucket_181_365) AS Bucket_181_365,
        SUM(Bucket_366_Plus) AS Bucket_366_Plus
    FROM ReceiptBuckets
    GROUP BY ITMREF_0

)

SELECT
    ITM.ITMREF_0 AS Product,
    ITM.ITMDES1_0 + ' ' + ITM.ITMDES2_0 AS Description,
    ISNULL(CD.[Average Cost], 0) AS [Average Cost],
    ISNULL(SPL.PRI_0, 0) AS PL2Price,
    ITM.TSICOD_0 AS Status,
    ISNULL(SOD.[DC30 Sales], 0) AS [DC30 Sales 1Y],
    ISNULL(SSD.StockTotalDC30, 0) AS STK_DC30,
    ISNULL(po.[Quantity on PO], 0) AS [Quantity on PO],
    ISNULL(po.[Supplier], '') AS [Supplier],
    po.ORDDAT_0 AS [Order Date],
    li.INVDAT_0 AS [Last Sold],
    DATEDIFF(DAY, li.INVDAT_0, GETDATE()) AS [Days Since Last Sold],

    CASE
        WHEN DATEDIFF(DAY, li.INVDAT_0, GETDATE()) BETWEEN 0  AND 30  THEN '0-30'
        WHEN DATEDIFF(DAY, li.INVDAT_0, GETDATE()) BETWEEN 31 AND 60  THEN '31-60'
        WHEN DATEDIFF(DAY, li.INVDAT_0, GETDATE()) BETWEEN 61 AND 90  THEN '61-90'
        WHEN DATEDIFF(DAY, li.INVDAT_0, GETDATE()) BETWEEN 91 AND 120 THEN '91-120'
        WHEN DATEDIFF(DAY, li.INVDAT_0, GETDATE()) >= 121            THEN '121 Plus'
    END AS [Bucket],

    v.ZINSTOCKDAT_0 AS [In Stock Since],
    DATEDIFF(DAY, v.ZINSTOCKDAT_0, GETDATE()) AS [Days in Stock],
    CASE
        WHEN DATEDIFF(DAY, v.ZINSTOCKDAT_0, GETDATE()) BETWEEN 0  AND 30  THEN '0-30'
        WHEN DATEDIFF(DAY, v.ZINSTOCKDAT_0, GETDATE()) BETWEEN 31 AND 60  THEN '31-60'
        WHEN DATEDIFF(DAY, v.ZINSTOCKDAT_0, GETDATE()) BETWEEN 61 AND 90  THEN '61-90'
        WHEN DATEDIFF(DAY, v.ZINSTOCKDAT_0, GETDATE()) BETWEEN 91 AND 120 THEN '91-120'
        WHEN DATEDIFF(DAY, v.ZINSTOCKDAT_0, GETDATE()) >= 121            THEN '121 Plus'
    END AS [DIS Bucket],

    ISNULL(ATX.TEXTE_0, '') AS ClassName,
    ISNULL(CD.[Average Cost], 0) * ISNULL(SSD.StockTotalDC30, 0) AS [Avg Value On Hand],
    ISNULL(VI.PrimaryVendor, 'N/A') AS PrimaryVendor,

    ITM.ACCCOD_0,


    ISNULL(BS.Bucket_0_180,   0) * ISNULL(CD.[Average Cost], 0) AS [Value 0-180],
    ISNULL(BS.Bucket_181_365, 0) * ISNULL(CD.[Average Cost], 0) AS [Value 181-365],
    ISNULL(BS.Bucket_366_Plus, 0)    * ISNULL(CD.[Average Cost], 0) AS [Value 366 Plus]
FROM LIVE.ITMMASTER ITM
LEFT JOIN LIVE.ATEXTRA ATX
    ON ATX.CODFIC_0 = 'ATABDIV'
   AND ATX.IDENT1_0 = '21'
   AND ATX.ZONE_0  = 'LNGDES'
   AND ATX.LANGUE_0 = 'ENG'
   AND ATX.IDENT2_0 = ITM.TSICOD_1
LEFT JOIN SalesPrice SPL
    ON ITM.ITMREF_0 = SPL.PLICRI2_0
   AND SPL.rn = 1
LEFT JOIN SalesOrderData SOD
    ON ITM.ITMREF_0 = SOD.ITMREF_0
LEFT JOIN VendorInfo VI
    ON ITM.ITMREF_0 = VI.ITMREF_0
LEFT JOIN StockSafetyData SSD
    ON ITM.ITMREF_0 = SSD.ITMREF_0
LEFT JOIN CostData CD
    ON ITM.ITMREF_0 = CD.ITMREF_0
LEFT JOIN open_po po
    ON ITM.ITMREF_0 = po.ITMREF_0
LEFT JOIN last_invoice li
    ON ITM.ITMREF_0 = li.ITMREF_0
LEFT JOIN LIVE.ITMMVT v
    ON ITM.ITMREF_0 = v.ITMREF_0
   AND v.STOFCY_0 = 'DC30'
LEFT JOIN BucketSummary BS
    ON ITM.ITMREF_0 = BS.ITMREF_0

	