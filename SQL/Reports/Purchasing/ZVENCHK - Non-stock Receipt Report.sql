WITH AggRec AS (
  SELECT 
    ITMREF_0, 
    SUM(QTYSTU_0) AS TotalReceivedQtyOnDate 
  FROM 
    LIVE.PRECEIPTD 
  WHERE 
    PRHFCY_0 = 'DC30' 
    AND BPSNUM_0 IN (
      'V4939', 'V4938', 'V6503', 'V6502', 
      'V6501', 'V6500'
    ) 
    AND CAST(CREDAT_0 AS DATE) = CAST(
      CASE WHEN DATEPART(
        WEEKDAY, 
        GETDATE()
      ) = 2 THEN DATEADD(
        DAY, 
        -3, 
        GETDATE()
      ) ELSE DATEADD(
        DAY, 
        -1, 
        GETDATE()
      ) END AS DATE
    ) 
  GROUP BY 
    ITMREF_0
), 
AggDel AS (
  SELECT 
    ITMREF_0, 
    SUM(QTYSTU_0) AS TotalDeliveredQtyOnDate 
  FROM 
    LIVE.SDELIVERYD 
  WHERE 
    STOFCY_0 = 'DC30' 
    AND CAST(CREDAT_0 AS DATE) = CAST(
      CASE WHEN DATEPART(
        WEEKDAY, 
        GETDATE()
      ) = 2 THEN DATEADD(
        DAY, 
        -3, 
        GETDATE()
      ) ELSE DATEADD(
        DAY, 
        -1, 
        GETDATE()
      ) END AS DATE
    ) 
  GROUP BY 
    ITMREF_0
), 
LastDel AS (
  SELECT 
    ITMREF_0, 
    MAX(CREDAT_0) AS LastEverDeliveryDate 
  FROM 
    LIVE.SDELIVERYD 
  WHERE 
    STOFCY_0 = 'DC30' 
  GROUP BY 
    ITMREF_0
) 
SELECT 
  SUP.BPSNAM_0 AS SupplierName, 
  PTD.ITMREF_0 AS ItemReference, 
  ITM.ITMDES1_0 + ' ' + ITM.ITMDES2_0 AS ItemDescription, 
  ITM.TSICOD_0 AS ItemClassificationCode, 
  SUM(PTD.QTYSTU_0) AS ConsolidatedReceivedQuantity, 
  PTD.STU_0 AS UnitOfMeasure, 
  LastDel.LastEverDeliveryDate, 
  ISNULL(
    AggDel.TotalDeliveredQtyOnDate, 
    0
  ) AS DeliveredQuantityOnDate, 
  CASE WHEN ISNULL(
    AggDel.TotalDeliveredQtyOnDate, 
    0
  ) > 0 
  AND ISNULL(
    AggDel.TotalDeliveredQtyOnDate, 
    0
  ) < ISNULL(
    AggRec.TotalReceivedQtyOnDate, 0
  ) THEN ISNULL(
    AggRec.TotalReceivedQtyOnDate, 0
  ) - AggDel.TotalDeliveredQtyOnDate ELSE 0 END AS QuantityDifference 
FROM 
  LIVE.PRECEIPTD PTD 
  LEFT OUTER JOIN LIVE.ITMMASTER ITM ON PTD.ITMREF_0 = ITM.ITMREF_0 
  LEFT JOIN LIVE.BPSUPPLIER SUP ON PTD.BPSNUM_0 = SUP.BPSNUM_0 
  LEFT JOIN AggRec ON PTD.ITMREF_0 = AggRec.ITMREF_0 
  LEFT JOIN AggDel ON PTD.ITMREF_0 = AggDel.ITMREF_0 
  LEFT JOIN LastDel ON PTD.ITMREF_0 = LastDel.ITMREF_0 
WHERE 
  CAST(PTD.CREDAT_0 AS DATE) = CAST(
    CASE WHEN DATEPART(
      WEEKDAY, 
      GETDATE()
    ) = 2 THEN DATEADD(
      DAY, 
      -3, 
      GETDATE()
    ) ELSE DATEADD(
      DAY, 
      -1, 
      GETDATE()
    ) END AS DATE
  ) 
  AND PTD.BPSNUM_0 IN (
    'V4939', 'V4938', 'V6503', 'V6502', 
    'V6501', 'V6500'
  ) 
  AND PTD.PRHFCY_0 = 'DC30' 
  AND (
    LastDel.LastEverDeliveryDate IS NULL 
    OR CAST(
      LastDel.LastEverDeliveryDate AS DATE
    ) < CAST(
      CASE WHEN DATEPART(
        WEEKDAY, 
        GETDATE()
      ) = 2 THEN DATEADD(
        DAY, 
        -3, 
        GETDATE()
      ) ELSE DATEADD(
        DAY, 
        -1, 
        GETDATE()
      ) END AS DATE
    ) 
    OR (
      AggDel.TotalDeliveredQtyOnDate IS NOT NULL 
      AND ISNULL(
        AggDel.TotalDeliveredQtyOnDate, 
        0
      ) < ISNULL(
        AggRec.TotalReceivedQtyOnDate, 0
      )
    )
  ) 
GROUP BY 
  SUP.BPSNAM_0, 
  PTD.ITMREF_0, 
  ITM.ITMDES1_0 + ' ' + ITM.ITMDES2_0, 
  ITM.TSICOD_0, 
  PTD.STU_0, 
  LastDel.LastEverDeliveryDate, 
  AggDel.TotalDeliveredQtyOnDate, 
  AggRec.TotalReceivedQtyOnDate 
