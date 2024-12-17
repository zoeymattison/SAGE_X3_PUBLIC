SELECT
b.BPSNUM_0,
b.BPSNAM_0,
b.CREDAT_0,
(SELECT TOP 1
CREDAT_0
FROM LIVE.PORDER POH
WHERE POH.BPSNUM_0 = b.BPSNUM_0
Order by CREDAT_0 DESC
),
PTE_0,
(SELECT TOP 1
TEL_0
FROM LIVE.BPADDRESS
WHERE BPANUM_0 = b.BPSNUM_0
),
(SELECT TOP 1
WEB_0
FROM LIVE.BPADDRESS
WHERE BPANUM_0 = b.BPSNUM_0
),
(SELECT TOP 1
CREDAT_0
FROM LIVE.PINVOICE
WHERE BPR_0 = b.BPSNUM_0
order by CREDAT_0 DESC
),
(SELECT TOP 1
CREDAT_0
FROM LIVE.PAYMENTH
WHERE BPR_0 = b.BPSNUM_0
order by CREDAT_0 DESC
),
b.BPSGRU_0,
b.PAYBAN_0,
CASE b.TSSCOD_0
WHEN 'AC' THEN 'AUTOMATIC CONTRACTOR'
WHEN 'AE' THEN 'AUTOMATIC EMPLOYEE'
WHEN 'AU' THEN 'AUTOMATIC UTILITY/ONLINE PYM'
WHEN 'AW' THEN 'AUTOMATIC BANK WITHDRAWAL'
WHEN 'BA' THEN 'BASICS VENDOR'
WHEN 'CP' THEN 'CANADA POST CORPORATION'
WHEN 'DR' THEN 'DRIVERS'
WHEN 'EM' THEN 'END OF MONTH CHEQUE RUN'
WHEN 'MM' THEN 'MILLENIUM MICRO'
WHEN 'NA' THEN 'OLD UNBALANCE SUPPLIERS'
WHEN 'NB' THEN 'NON BASICS'
WHEN 'NI' THEN 'NON INVENTORY'
WHEN 'RN' THEN 'RENTS/LEASES'
WHEN 'US' THEN 'US FUNDS VENDOR'
END
FROM LIVE.BPSUPPLIER b WHERE b.ENAFLG_0 = 2

ORDER BY b.BPSNAM_0 ASC