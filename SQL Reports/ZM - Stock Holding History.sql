SELECT 
  ITM.ACCCOD_0, 
  STJ.CREDAT_0, 
  ITF.STOFCY_0, 
  ITM.ITMREF_0, 
  ITM.ITMDES1_0, 
  STJ.STU_0, 
  CASE WHEN (TRSTYP_0 = 1) THEN QTYSTU_0 ELSE 0 END AS MiscReceipt, 
  CASE WHEN (TRSTYP_0 = 1) THEN PRIORD_0 * QTYSTU_0 ELSE 0 END AS MiscReceiptVal, 
  CASE WHEN (TRSTYP_0 = 2) THEN QTYSTU_0 ELSE 0 END AS MiscIssue, 
  CASE WHEN (TRSTYP_0 = 2) THEN PRIORD_0 * QTYSTU_0 ELSE 0 END AS MiscIssueVal, 
  CASE WHEN (TRSTYP_0 = 3) THEN QTYSTU_0 ELSE 0 END AS SupplierReceipt, 
  CASE WHEN (TRSTYP_0 = 3) THEN PRIORD_0 * QTYSTU_0 ELSE 0 END AS SupplierReceiptVal, 
  CASE WHEN (TRSTYP_0 = 4) THEN QTYSTU_0 ELSE 0 END AS CustomerDelivery, 
  isnull(
    CASE WHEN (
      TRSTYP_0 = 4 
      AND AMTVAL_0 <> 0
    ) THEN (
      SELECT 
        TOP 1 STJ2.PRIORD_0 * STJ.QTYSTU_0 
      FROM 
        LIVE.STOJOU STJ2 
      WHERE 
        STJ2.ITMREF_0 = STJ.ITMREF_0 
        AND STJ2.CREDAT_0 <= STJ.CREDAT_0 
        AND TRSTYP_0 = 3 
        AND STJ2.STOFCY_0 = 'DC30' 
		AND REGFLG_0=1
      ORDER BY 
        CREDAT_0 DESC
    ) ELSE 0 END, 
    PRIORD_0 * QTYSTU_0
  ) AS CustomerDeliveryVal, 
  CASE WHEN (TRSTYP_0 = 12) THEN QTYSTU_0 ELSE 0 END AS DeliveryReturn, 
  isnull(
    CASE WHEN (
      TRSTYP_0 = 12 
      AND AMTVAL_0 <> 0
    ) THEN (
      SELECT 
        TOP 1 STJ2.PRIORD_0 * STJ.QTYSTU_0 
      FROM 
        LIVE.STOJOU STJ2 
      WHERE 
        STJ2.ITMREF_0 = STJ.ITMREF_0 
        AND STJ2.CREDAT_0 <= STJ.CREDAT_0 
        AND TRSTYP_0 = 3 
        AND STJ2.STOFCY_0 = 'DC30'
		AND REGFLG_0=1
      ORDER BY 
        CREDAT_0 DESC
    ) ELSE 0 END, 
    PRIORD_0 * QTYSTU_0
  ) AS DeliveryReturnVal, 
  CASE WHEN (TRSTYP_0 = 13) THEN QTYSTU_0 ELSE 0 END AS CountQty, 
  CASE WHEN (TRSTYP_0 = 13) THEN AMTVAL_0 ELSE 0 END AS CountVal, 
  CASE WHEN (
    TRSTYP_0 IN (1, 2, 3, 4, 12, 13)
  ) THEN QTYSTU_0 ELSE 0 END AS TotalQty, 
  (
    CASE WHEN (
      TRSTYP_0 IN (1, 2, 3, 13)
    ) THEN PRIORD_0 * QTYSTU_0 ELSE 0 END
  )+ isnull(
    (
      CASE WHEN TRSTYP_0 IN (4, 12) 
      AND AMTVAL_0 <> 0 THEN (
        SELECT 
          TOP 1 STJ2.PRIORD_0 * STJ.QTYSTU_0 
        FROM 
          LIVE.STOJOU STJ2 
        WHERE 
          STJ2.ITMREF_0 = STJ.ITMREF_0 
          AND STJ2.CREDAT_0 <= STJ.CREDAT_0 
          AND TRSTYP_0 = 3 
          AND STJ2.STOFCY_0 = 'DC30'
		  AND REGFLG_0=1
        ORDER BY 
          CREDAT_0 DESC
      ) ELSE 0 END
    ), 
    PRIORD_0 * QTYSTU_0
  ) AS TotalVal 
FROM 
  LIVE.ITMFACILIT ITF 
  INNER JOIN LIVE.ITMMASTER ITM ON ITF.ITMREF_0 = ITM.ITMREF_0 
  LEFT OUTER JOIN LIVE.STOJOU STJ ON ITF.STOFCY_0 = STJ.STOFCY_0 
  AND ITF.ITMREF_0 = STJ.ITMREF_0 
WHERE 
  TRSTYP_0 IN (1, 2, 3, 4, 12, 13) 
  AND REGFLG_0 = 1
