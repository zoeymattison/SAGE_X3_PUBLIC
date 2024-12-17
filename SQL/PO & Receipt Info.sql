SELECT 
  POQ.POHNUM_0, 
  PTD.CREDAT_0, 
  PTD.PTHNUM_0, 
  POQ.PTDLIN_0, 
  POQ.ITMREF_0, 
  CAST(
    POQ.ITMREFBPS_0 AS VARCHAR(30)
  ), 
  CAST(
    ITM.EANCOD_0 AS VARCHAR(30)
  ), 
  CAST(
    ITM.SEAKEY_0 AS VARCHAR(30)
  ), 
  ITM.ITMDES1_0, 
  CAST(PTD.QTYSTU_0 AS INT), 
  POQ.STU_0, 
  PTD.GROPRI_0, 
  PTD.GROPRI_0 * PTD.QTYSTU_0 
FROM 
  PORDERQ POQ 
  LEFT OUTER JOIN ITMMASTER ITM ON POQ.ITMREF_0 = ITM.ITMREF_0 
  LEFT OUTER JOIN PRECEIPTD PTD ON POQ.POHNUM_0 = PTD.POHNUM_0 
  AND POQ.ITMREF_0 = PTD.ITMREF_0 
WHERE 
  POQ.POHNUM_0 = % 1 %
