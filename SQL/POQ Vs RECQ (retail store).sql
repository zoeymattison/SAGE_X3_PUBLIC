SELECT 
  P.UPDDAT_0, 
  P.PRHFCY_0, 
  P.POHNUM_0, 
  P.ITMREF_0, 
  SUM(P.QTYUOM_0), 
  SUM(P.RCPQTYSTU_0) 
FROM 
  PORDERQ P 
WHERE 
  P.PRHFCY_0 BETWEEN '1200' 
  AND '2800' 
GROUP BY 
  P.UPDDAT_0, 
  P.PRHFCY_0, 
  P.POHNUM_0, 
  P.ITMREF_0 
HAVING 
  SUM(P.RCPQTYSTU_0) > SUM(P.QTYUOM_0) 
ORDER BY 
  P.UPDDAT_0 desc
