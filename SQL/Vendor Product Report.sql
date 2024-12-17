SELECT 
  ITM.ITMREF_0 AS 'PRODUCT', 
  ISNULL(
    ITM.ITMDES1_0 + ' ' + ITM.ITMDES2_0, 
    'N/A'
  ) AS 'DESCRIPTION', 
  ISNULL(
    BPS.BPSNAM_0 + ' - ' + ITP.BPSNUM_0, 
    'N/A'
  ) AS 'VENDOR', 
  ISNULL(
    CAST(ITP.PIO_0 AS VARCHAR), 
    'N/A'
  ) AS 'PRIORITY', 
  ISNULL(ITM.TSICOD_0, 'N/A') AS 'MONK STATUS', 
  ISNULL(
    (
      SELECT 
        CAST(
          SUM(
            SOQ.QTY_0 - SOQ.DLVQTY_0 - SOQ.OPRQTY_0 - SOQ.ALLQTY_0
          ) AS INT
        ) 
      FROM 
        LIVE.SORDERQ SOQ 
        LEFT OUTER JOIN LIVE.SORDER SOH ON SOQ.SOHNUM_0 = SOH.SOHNUM_0 
      WHERE 
        SOQ.ITMREF_0 = ITM.ITMREF_0 
        AND SOH.BPCINV_0 <> 'IMAIN' 
        and SOQ.SOQSTA_0 <> 3
    ), 
    0
  ) AS 'B/O QTY', 
  ISNULL(
    (
      SELECT 
        CASE WHEN ABCCLS_0 = 1 THEN 'A' WHEN ABCCLS_0 = 2 THEN 'B' WHEN ABCCLS_0 = 3 THEN 'C' WHEN ABCCLS_0 = 4 THEN 'D' END 
      FROM 
        LIVE.ITMFACILIT 
      WHERE 
        ITMREF_0 = ITM.ITMREF_0 
        AND STOFCY_0 = 'DC30'
    ), 
    'N'
  ) AS 'DC30 - ABC', 
  ISNULL(
    (
      SELECT 
        CAST(
          SUM(QTYSTU_0 - CUMALLQTY_0) AS INT
        ) 
      FROM 
        LIVE.STOCK 
      WHERE 
        STOFCY_0 = 'DC30' 
        AND ITMREF_0 = ITM.ITMREF_0 
        AND STA_0 = 'A'
    ), 
    0
  ) AS 'DC30 - QTY', 
  ISNULL(
    (
      SELECT 
        CAST(
          SUM(QTYSTU_0 - CUMALLQTY_0) AS INT
        ) 
      FROM 
        LIVE.STOCK 
      WHERE 
        STOFCY_0 = 'DC33' 
        AND ITMREF_0 = ITM.ITMREF_0 
        AND STA_0 = 'A'
    ), 
    0
  ) AS 'DC33 - QTY', 
  ISNULL(
    (
      SELECT 
        CAST(
          SUM(QTYSTU_0 - CUMALLQTY_0) AS INT
        ) 
      FROM 
        LIVE.STOCK 
      WHERE 
        STOFCY_0 = '1200' 
        AND ITMREF_0 = ITM.ITMREF_0 
        AND STA_0 = 'A'
    ), 
    0
  ) AS '1200 - QTY', 
  ISNULL(
    (
      SELECT 
        CAST(
          SUM(QTYSTU_0 - CUMALLQTY_0) AS INT
        ) 
      FROM 
        LIVE.STOCK 
      WHERE 
        STOFCY_0 = '1600' 
        AND ITMREF_0 = ITM.ITMREF_0 
        AND STA_0 = 'A'
    ), 
    0
  ) AS '1600 - QTY', 
  ISNULL(
    (
      SELECT 
        CAST(
          SUM(QTYSTU_0 - CUMALLQTY_0) AS INT
        ) 
      FROM 
        LIVE.STOCK 
      WHERE 
        STOFCY_0 = '1800' 
        AND ITMREF_0 = ITM.ITMREF_0 
        AND STA_0 = 'A'
    ), 
    0
  ) AS '1800 - QTY', 
  ISNULL(
    (
      SELECT 
        CAST(
          SUM(QTYSTU_0 - CUMALLQTY_0) AS INT
        ) 
      FROM 
        LIVE.STOCK 
      WHERE 
        STOFCY_0 = '2100' 
        AND ITMREF_0 = ITM.ITMREF_0 
        AND STA_0 = 'A'
    ), 
    0
  ) AS '2100 - QTY', 
  ISNULL(
    (
      SELECT 
        CAST(
          SUM(QTYSTU_0 - CUMALLQTY_0) AS INT
        ) 
      FROM 
        LIVE.STOCK 
      WHERE 
        STOFCY_0 = '2200' 
        AND ITMREF_0 = ITM.ITMREF_0 
        AND STA_0 = 'A'
    ), 
    0
  ) AS '2200 - QTY', 
  ISNULL(
    (
      SELECT 
        CAST(
          SUM(QTYSTU_0 - CUMALLQTY_0) AS INT
        ) 
      FROM 
        LIVE.STOCK 
      WHERE 
        STOFCY_0 = '2300' 
        AND ITMREF_0 = ITM.ITMREF_0 
        AND STA_0 = 'A'
    ), 
    0
  ) AS '2300 - QTY', 
  ISNULL(
    (
      SELECT 
        CAST(
          SUM(QTYSTU_0 - CUMALLQTY_0) AS INT
        ) 
      FROM 
        LIVE.STOCK 
      WHERE 
        STOFCY_0 = '2600' 
        AND ITMREF_0 = ITM.ITMREF_0 
        AND STA_0 = 'A'
    ), 
    0
  ) AS '2600 - QTY', 
  ISNULL(
    (
      SELECT 
        CAST(
          SUM(QTYSTU_0 - CUMALLQTY_0) AS INT
        ) 
      FROM 
        LIVE.STOCK 
      WHERE 
        STOFCY_0 = '2800' 
        AND ITMREF_0 = ITM.ITMREF_0 
        AND STA_0 = 'A'
    ), 
    0
  ) AS '2800 - QTY', 
  ISNULL(
    (
      SELECT 
        TOP 1 POHNUM_0 
      FROM 
        LIVE.PORDERQ 
      WHERE 
        ITMREF_0 = ITM.ITMREF_0 
        AND POHNUM_0 LIKE 'PO3%' 
        AND BPSNUM_0 LIKE 'V%' 
        AND LINCLEFLG_0 = 1 
      ORDER BY 
        EXTRCPDAT_0 ASC
    ), 
    'N/A'
  ) AS 'EARLIEST PO', 
  ISNULL(
    (
      SELECT 
        TOP 1 CONVERT(VARCHAR, EXTRCPDAT_0, 101) 
      FROM 
        LIVE.PORDERQ 
      WHERE 
        ITMREF_0 = ITM.ITMREF_0 
        AND POHNUM_0 LIKE 'PO3%' 
        AND BPSNUM_0 LIKE 'V%' 
        AND LINCLEFLG_0 = 1 
      ORDER BY 
        EXTRCPDAT_0 ASC
    ), 
    'N/A'
  ) AS 'ETA', 
  ISNULL(
    (
      SELECT 
        TOP 1 BPS1.BPSNAM_0 + ' - ' + POQ1.BPSNUM_0 
      FROM 
        LIVE.PORDERQ POQ1 
        LEFT OUTER JOIN LIVE.BPSUPPLIER BPS1 ON POQ1.BPSNUM_0 = BPS1.BPSNUM_0 
      WHERE 
        ITMREF_0 = ITM.ITMREF_0 
        AND POQ1.POHNUM_0 LIKE 'PO3%' 
        AND POQ1.BPSNUM_0 LIKE 'V%' 
        AND POQ1.LINCLEFLG_0 = 1 
      ORDER BY 
        POQ1.EXTRCPDAT_0 ASC
    ), 
    'N/A'
  ) AS 'PO VENDR', 
  (
    SELECT 
      CASE WHEN SUM(AMTNOTLIN_0) IS NULL THEN CAST(0.00 AS VARCHAR) ELSE CAST(
        CAST(
          SUM(AMTNOTLIN_0) AS DECIMAL(18, 2)
        ) AS VARCHAR
      ) END 
    FROM 
      LIVE.SINVOICED 
    WHERE 
      STOFCY_0 = 'DC30' 
      AND ITMREF_0 = ITM.ITMREF_0 
      AND CREDAT_0 >= DATEADD(
        MONTH, 
        -1, 
        GETDATE()
      )
  ) AS 'DC30 SALES -1 M', 
  (
    SELECT 
      CASE WHEN SUM(AMTNOTLIN_0) IS NULL THEN CAST(0.00 AS VARCHAR) ELSE CAST(
        CAST(
          SUM(AMTNOTLIN_0) AS DECIMAL(18, 2)
        ) AS VARCHAR
      ) END 
    FROM 
      LIVE.SINVOICED 
    WHERE 
      STOFCY_0 = 'DC30' 
      AND ITMREF_0 = ITM.ITMREF_0 
      AND CREDAT_0 >= DATEADD(
        MONTH, 
        -3, 
        GETDATE()
      )
  ) AS 'DC30 SALES -3 M', 
  (
    SELECT 
      CASE WHEN SUM(AMTNOTLIN_0) IS NULL THEN CAST(0.00 AS VARCHAR) ELSE CAST(
        CAST(
          SUM(AMTNOTLIN_0) AS DECIMAL(18, 2)
        ) AS VARCHAR
      ) END 
    FROM 
      LIVE.SINVOICED 
    WHERE 
      STOFCY_0 = 'DC30' 
      AND ITMREF_0 = ITM.ITMREF_0 
      AND CREDAT_0 >= DATEADD(
        MONTH, 
        -12, 
        GETDATE()
      )
  ) AS 'DC30 SALES -12 M', 
  (
    SELECT 
      CASE WHEN SUM(AMTNOTLIN_0) IS NULL THEN CAST(0.00 AS VARCHAR) ELSE CAST(
        CAST(
          SUM(AMTNOTLIN_0) AS DECIMAL(18, 2)
        ) AS VARCHAR
      ) END 
    FROM 
      LIVE.SINVOICED 
    WHERE 
      STOFCY_0 = 'DC33' 
      AND ITMREF_0 = ITM.ITMREF_0 
      AND CREDAT_0 >= DATEADD(
        MONTH, 
        -1, 
        GETDATE()
      )
  ) AS 'DC33 SALES -1 M', 
  (
    SELECT 
      CASE WHEN SUM(AMTNOTLIN_0) IS NULL THEN CAST(0.00 AS VARCHAR) ELSE CAST(
        CAST(
          SUM(AMTNOTLIN_0) AS DECIMAL(18, 2)
        ) AS VARCHAR
      ) END 
    FROM 
      LIVE.SINVOICED 
    WHERE 
      STOFCY_0 = 'DC33' 
      AND ITMREF_0 = ITM.ITMREF_0 
      AND CREDAT_0 >= DATEADD(
        MONTH, 
        -3, 
        GETDATE()
      )
  ) AS 'DC33 SALES -3 M', 
  (
    SELECT 
      CASE WHEN SUM(AMTNOTLIN_0) IS NULL THEN CAST(0.00 AS VARCHAR) ELSE CAST(
        CAST(
          SUM(AMTNOTLIN_0) AS DECIMAL(18, 2)
        ) AS VARCHAR
      ) END 
    FROM 
      LIVE.SINVOICED 
    WHERE 
      STOFCY_0 = 'DC33' 
      AND ITMREF_0 = ITM.ITMREF_0 
      AND CREDAT_0 >= DATEADD(
        MONTH, 
        -12, 
        GETDATE()
      )
  ) AS 'DC33 SALES -12 M', 
  (
    SELECT 
      CASE WHEN SUM(AMTNOTLIN_0) IS NULL THEN CAST(0.00 AS VARCHAR) ELSE CAST(
        CAST(
          SUM(AMTNOTLIN_0) AS DECIMAL(18, 2)
        ) AS VARCHAR
      ) END 
    FROM 
      LIVE.SINVOICED 
    WHERE 
      ITMREF_0 = ITM.ITMREF_0 
      AND CREDAT_0 >= DATEADD(
        MONTH, 
        -1, 
        GETDATE()
      )
  ) AS 'ALL SALES -1 M', 
  (
    SELECT 
      CASE WHEN SUM(AMTNOTLIN_0) IS NULL THEN CAST(0.00 AS VARCHAR) ELSE CAST(
        CAST(
          SUM(AMTNOTLIN_0) AS DECIMAL(18, 2)
        ) AS VARCHAR
      ) END 
    FROM 
      LIVE.SINVOICED 
    WHERE 
      ITMREF_0 = ITM.ITMREF_0 
      AND CREDAT_0 >= DATEADD(
        MONTH, 
        -3, 
        GETDATE()
      )
  ) AS 'ALL SALES -3 M', 
  (
    SELECT 
      CASE WHEN SUM(AMTNOTLIN_0) IS NULL THEN CAST(0.00 AS VARCHAR) ELSE CAST(
        CAST(
          SUM(AMTNOTLIN_0) AS DECIMAL(18, 2)
        ) AS VARCHAR
      ) END 
    FROM 
      LIVE.SINVOICED 
    WHERE 
      ITMREF_0 = ITM.ITMREF_0 
      AND CREDAT_0 >= DATEADD(
        MONTH, 
        -12, 
        GETDATE()
      )
  ) AS 'ALL SALES -12 M', 
  (
    SELECT 
      CASE WHEN SUM(AMTNOTLIN_0) IS NULL THEN CAST(0.00 AS VARCHAR) ELSE CAST(
        CAST(
          SUM(AMTNOTLIN_0) AS DECIMAL(18, 2)
        ) AS VARCHAR
      ) END 
    FROM 
      LIVE.SINVOICED 
    WHERE 
      STOFCY_0 NOT LIKE 'DC%' 
      AND ITMREF_0 = ITM.ITMREF_0 
      AND CREDAT_0 >= DATEADD(
        MONTH, 
        -1, 
        GETDATE()
      )
  ) AS 'RETAIL SALES -1 M', 
  (
    SELECT 
      CASE WHEN SUM(AMTNOTLIN_0) IS NULL THEN CAST(0.00 AS VARCHAR) ELSE CAST(
        CAST(
          SUM(AMTNOTLIN_0) AS DECIMAL(18, 2)
        ) AS VARCHAR
      ) END 
    FROM 
      LIVE.SINVOICED 
    WHERE 
      STOFCY_0 NOT LIKE 'DC%' 
      AND ITMREF_0 = ITM.ITMREF_0 
      AND CREDAT_0 >= DATEADD(
        MONTH, 
        -3, 
        GETDATE()
      )
  ) AS 'RETAIL SALES -3 M', 
  (
    SELECT 
      CASE WHEN SUM(AMTNOTLIN_0) IS NULL THEN CAST(0.00 AS VARCHAR) ELSE CAST(
        CAST(
          SUM(AMTNOTLIN_0) AS DECIMAL(18, 2)
        ) AS VARCHAR
      ) END 
    FROM 
      LIVE.SINVOICED 
    WHERE 
      STOFCY_0 NOT LIKE 'DC%' 
      AND ITMREF_0 = ITM.ITMREF_0 
      AND CREDAT_0 >= DATEADD(
        MONTH, 
        -12, 
        GETDATE()
      )
  ) AS 'RETAIL SALES -12 M' 
FROM 
  LIVE.ITMMASTER ITM 
  LEFT OUTER JOIN LIVE.ITMBPS ITP ON ITM.ITMREF_0 = ITP.ITMREF_0 
  LEFT OUTER JOIN LIVE.BPSUPPLIER BPS ON ITP.BPSNUM_0 = BPS.BPSNUM_0 
WHERE 
  ITM.TSICOD_0 NOT IN ('DM', 'DS') 
  AND ITM.ITMREF_0 NOT LIKE '/%' 
ORDER BY 
  PRODUCT, 
  VENDOR ASC
