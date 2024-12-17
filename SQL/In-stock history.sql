SELECT 
  DISTINCT 
  /* PRODUCT INFORMATION */
  IVT.STOFCY_0, 
  IVT.ITMREF_0, 
  ITM.ITMDES1_0, 
  ITM.TSICOD_0, 
  ITM.TSICOD_1, 
  (
    SELECT 
      TEXTE_0 
    FROM 
      LIVE.ATEXTRA 
    WHERE 
      CODFIC_0 = 'ATABDIV' 
      AND ZONE_0 = 'LNGDES' 
      AND IDENT1_0 = '21' 
      AND IDENT2_0 = ITM.TSICOD_1 
      AND LANGUE_0 = 'ENG'
  ), 
  ITM.CCE_1, 
  ITF.ABCCLS_0, 
  
  /* SITE INFORMATION */
  CAST(STO.QTYSTU_0 AS INT), 
  STO.PCU_0, 
  STO.LOC_0, 
  STO.LOCTYP_0, 
  IVT.AVC_0, 
  IVT.AVC_0 * STO.QTYSTU_0, 
  CAST(ITF.SAFSTO_0 AS INT), 
  
  /* SUB QUERIES */
  (
    SELECT 
      CONVERT(
        VARCHAR, 
        MAX(CREDAT_0), 
        101
      ) 
    FROM 
      LIVE.STOJOU 
    WHERE 
      ITMREF_0 = IVT.ITMREF_0 
      AND STOFCY_0 = IVT.STOFCY_0 
      AND VCRTYP_0 = 6
  ), 
  (
    SELECT 
      CONVERT(
        VARCHAR, 
        MIN(CREDAT_0), 
        101
      ) 
    FROM 
      LIVE.STOJOU 
    WHERE 
      ITMREF_0 = IVT.ITMREF_0 
      AND STOFCY_0 = IVT.STOFCY_0 
      AND VCRTYP_0 = 6
  ), 
  (
    SELECT 
      CONVERT(
        VARCHAR, 
        MAX(CREDAT_0), 
        101
      ) 
    FROM 
      LIVE.STOJOU 
    WHERE 
      ITMREF_0 = IVT.ITMREF_0 
      AND STOFCY_0 = IVT.STOFCY_0 
      AND (
        VCRTYP_0 = 19 
        OR VCRTYP_0 = 9
      )
  ), 
  (
    SELECT 
      CONVERT(
        VARCHAR, 
        MAX(CREDAT_0), 
        101
      ) 
    FROM 
      LIVE.SINVOICED 
    WHERE 
      ITMREF_0 = IVT.ITMREF_0
  ), 
  (
    CASE WHEN DATEDIFF(
      DAY, 
      (
        SELECT 
          MAX(CREDAT_0) 
        FROM 
          LIVE.SINVOICED 
        WHERE 
          ITMREF_0 = IVT.ITMREF_0
      ), 
      GETDATE()
    ) IS NULL THEN CASE WHEN DATEDIFF(
      DAY, 
      (
        SELECT 
          MAX(CREDAT_0) 
        FROM 
          LIVE.STOJOU 
        WHERE 
          ITMREF_0 = IVT.ITMREF_0 
          AND STOFCY_0 = IVT.STOFCY_0 
          AND VCRTYP_0 = 6
      ), 
      GETDATE()
    ) IS NULL THEN CASE WHEN DATEDIFF(
      DAY, 
      (
        SELECT 
          MAX(CREDAT_0) 
        FROM 
          LIVE.STOJOU 
        WHERE 
          ITMREF_0 = IVT.ITMREF_0 
          AND STOFCY_0 = IVT.STOFCY_0 
          AND (
            VCRTYP_0 = 19 
            OR VCRTYP_0 = 9
          )
      ), 
      GETDATE()
    ) IS NULL THEN 999999 ELSE DATEDIFF(
      DAY, 
      (
        SELECT 
          MAX(CREDAT_0) 
        FROM 
          LIVE.STOJOU 
        WHERE 
          ITMREF_0 = IVT.ITMREF_0 
          AND STOFCY_0 = IVT.STOFCY_0 
          AND (
            VCRTYP_0 = 19 
            OR VCRTYP_0 = 9
          )
      ), 
      GETDATE()
    ) END ELSE DATEDIFF(
      DAY, 
      (
        SELECT 
          MAX(CREDAT_0) 
        FROM 
          LIVE.STOJOU 
        WHERE 
          ITMREF_0 = IVT.ITMREF_0 
          AND STOFCY_0 = IVT.STOFCY_0 
          AND VCRTYP_0 = 6
      ), 
      GETDATE()
    ) END ELSE DATEDIFF(
      DAY, 
      (
        SELECT 
          MAX(CREDAT_0) 
        FROM 
          LIVE.SINVOICED 
        WHERE 
          ITMREF_0 = IVT.ITMREF_0
      ), 
      GETDATE()
    ) END
  ) 
FROM 
  LIVE.ITMMVT IVT 
  LEFT OUTER JOIN LIVE.ITMMASTER ITM ON IVT.ITMREF_0 = ITM.ITMREF_0 
  LEFT OUTER JOIN LIVE.STOCK STO ON IVT.STOFCY_0 = STO.STOFCY_0 
  AND IVT.ITMREF_0 = STO.ITMREF_0 
  LEFT OUTER JOIN LIVE.ITMFACILIT ITF ON IVT.STOFCY_0 = ITF.STOFCY_0 
  AND IVT.ITMREF_0 = ITF.ITMREF_0 
WHERE 
  (
    (
      IVT.PHYSTO_0 + IVT.CTLSTO_0 + IVT.REJSTO_0
    ) > 0
  ) 
  AND (
    IVT.STOFCY_0 >= % 1 % 
    AND (
      IVT.STOFCY_0 <= % 2 % 
      OR RTRIM(% 2 %) IS NULL 
      OR RTRIM(% 2 %) = ''
    )
  ) 
  AND (
    IVT.ITMREF_0 >= % 3 % 
    AND (
      IVT.ITMREF_0 <= % 4 % 
      OR RTRIM(% 4 %) IS NULL 
      OR RTRIM(% 4 %) = ''
    )
  ) 
  AND (
    ITM.CCE_1 >= % 5 % 
    AND (
      ITM.CCE_1 <= % 6 % 
      OR RTRIM(% 6 %) IS NULL 
      OR RTRIM(% 6 %) = ''
    )
  ) 
  AND (
    ITM.TSICOD_0 >= % 7 % 
    AND (
      ITM.TSICOD_0 <= % 8 % 
      OR RTRIM(% 8 %) IS NULL 
      OR RTRIM(% 8 %) = ''
    )
  ) 
  AND (
    ITM.TSICOD_1 >= % 9 % 
    AND (
      ITM.TSICOD_1 <= % 10 % 
      OR RTRIM(% 10 %) IS NULL 
      OR RTRIM(% 10 %) = ''
    )
  )
