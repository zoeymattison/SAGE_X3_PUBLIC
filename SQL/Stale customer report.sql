SELECT 
  B.BPCNUM_0 AS 'CUSTOMER NUMBER', 
  B.BPCNAM_0 AS 'CUSTOMER NAME', 
  CONVERT(
    VARCHAR(25), 
    MAX(S.CREDAT_0), 
    101
  ) AS 'LAST INVOICE', 
  datediff(
    day, 
    max(S.CREDAT_0), 
    getdate()
  ) AS 'DAYS SINCE', 
  CONVERT(
    VARCHAR(25), 
    MIN(S.CREDAT_0), 
    101
  ) AS 'FIRST INVOICE', 
  CONVERT(
    VARCHAR(25), 
    B.CREDAT_0, 
    101
  ) AS 'DATE CREATED', 
  SUM(S.AMTNOT_0) 
FROM 
  LIVE.BPCUSTOMER B 
  LEFT OUTER JOIN LIVE.SINVOICE S ON B.BPCNUM_0 = S.BPR_0 
WHERE 
  B.BPCSTA_0 = 2 
  AND B.BPCNUM_0 NOT LIKE 'TMS%' 
  AND (
    (B.BPCNUM_0 NOT LIKE '%-%') 
    OR (
      B.BPCNUM_0 LIKE 'GAIN-%' 
      AND B.BPCNUM_0 NOT LIKE 'GAIN-%-%'
    )
  ) 
GROUP BY 
  B.BPCNUM_0, 
  B.BPCNAM_0, 
  B.CREDAT_0 
ORDER BY 
  datediff(
    day, 
    max(S.CREDAT_0), 
    getdate()
  ) DESC
