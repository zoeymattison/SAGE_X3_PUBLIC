SELECT
SOH.ORDDAT_0,
POH.CREUSR_0,
POH.ORDREF_0,
POH.POHNUM_0,
SOH.SOHNUM_0,
CAST(SUM(SOQ.ALLQTY_0) AS INT),
CAST(SUM(SOQ.OPRQTY_0) AS INT)

FROM LIVE.SORDERQ SOQ
LEFT OUTER JOIN LIVE.SORDER SOH ON
SOQ.SOHNUM_0 = SOH.SOHNUM_0
LEFT OUTER JOIN LIVE.PORDER POH ON
SOH.CUSORDREF_0 = POH.POHNUM_0

WHERE SOH.ORDSTA_0 = 1 AND UPPER(POH.ORDREF_0) LIKE '%PM%' AND SOQ.STOFCY_0 = 'DC30'

GROUP BY 
SOH.ORDDAT_0,
POH.CREUSR_0,
POH.POHNUM_0,
POH.ORDREF_0,
SOH.SOHNUM_0

HAVING SUM(SOQ.ALLQTY_0) > 0 OR SUM(SOQ.OPRQTY_0) > 0

ORDER BY SOH.ORDDAT_0 desc