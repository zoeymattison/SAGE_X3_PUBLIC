WITH LineDiscounts AS (
  SELECT 
    SID.NUM_0, 
    SUM(
      GROPRI_0 * QTY_0 * (DISCRGVAL1_0 / 100.0)
    ) AS [Discount] 
  FROM 
    LIVE.SINVOICED SID 
  GROUP BY 
    SID.NUM_0
), 
InvoiceElementSingle AS (
  SELECT 
    SVF.DTA_0, 
    SVF.VCRNUM_0, 
    CASE WHEN DTA_0 = 1 THEN DTAAMT_0 ELSE 0 END AS [Discount Amount], 
    CASE WHEN DTA_0 = 10 THEN DTAAMT_0 ELSE 0 END AS [Discount Percent], 
    CASE WHEN DTA_0 = 10 THEN DTANOT_0 *-1 ELSE 0 END AS [Discount Percent-Amount], 
    CASE WHEN DTA_0 = 7 THEN DTAAMT_0 ELSE 0 END AS [Restock Fee Amount] 
  FROM 
    LIVE.SVCRFOOT SVF
) 
SELECT 
  SIH.NUM_0, 
  SUM(INS.[Discount Amount]) AS [Discount Amount], 
  SUM(INS.[Discount Percent]) AS [Discount Percent], 
  SUM(INS.[Discount Percent-Amount]) as [Discount Percet-Amount], 
  SUM(INS.[Restock Fee Amount]) as [Restock fee Amount], 
  isnull(
    MAX(LND.Discount), 
    0
  ) as [Line Discounts] 
FROM 
  LIVE.SINVOICE SIH 
  INNER JOIN LineDiscounts LND ON SIH.NUM_0 = LND.NUM_0 
  INNER JOIN InvoiceElementSingle INS ON SIH.NUM_0 = INS.VCRNUM_0 
GROUP BY 
  SIH.NUM_0
