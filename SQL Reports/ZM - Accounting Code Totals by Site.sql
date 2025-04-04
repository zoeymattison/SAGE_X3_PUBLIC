WITH PurchaseCost AS (
	SELECT
		PLICRD_0,
		PRI_0,
		PLI_0,
		ROW_NUMBER() OVER (PARTITION BY PLICRD_0 ORDER BY PRI_0 ASC) AS rn
	FROM 
		LIVE.PPRICLIST
	WHERE
		PLI_0='T20'
),
LastPurPri AS (
	SELECT
		GROPRI_0,
		ITMREF_0,
		ROW_NUMBER() OVER (PARTITION BY ITMREF_0 ORDER BY CREDAT_0 ASC) AS rn
	FROM 
		LIVE.PORDERP
)
SELECT
FCY.FCY_0 AS StockSite,
STO.ITMREF_0 AS Product,
ITM.ITMDES1_0+' '+ITM.ITMDES2_0 AS Description,
STO.QTYSTU_0 AS Quantity,
CASE
WHEN ITV.AVC_0<=0 THEN ISNULL(LP.GROPRI_0,PP.PRI_0)
ELSE ITV.AVC_0
END AS AverageCost,
CASE
WHEN ITV.AVC_0=0 THEN ISNULL(LP.GROPRI_0,PP.PRI_0)*STO.QTYSTU_0
ELSE ITV.AVC_0*STO.QTYSTU_0
END AS TotalValuation,
ITM.ACCCOD_0 AS AccountingCode
FROM LIVE.FACILITY FCY
LEFT JOIN LIVE.STOCK STO ON FCY.FCY_0=STO.STOFCY_0
LEFT JOIN LIVE.ITMMVT ITV ON STO.ITMREF_0=ITV.ITMREF_0 AND STO.STOFCY_0=ITV.STOFCY_0
LEFT JOIN LIVE.ITMMASTER ITM ON ITV.ITMREF_0=ITM.ITMREF_0
LEFT JOIN PurchaseCost PP ON STO.ITMREF_0=PP.PLICRD_0 and (PP.rn=1 OR PP.rn IS NULL)
LEFT JOIN LastPurPri LP ON STO.ITMREF_0=LP.ITMREF_0 AND (LP.rn=1 OR LP.rn IS NULL)
WHERE FCY.FCY_0 NOT IN ('HEAD','MAIN') AND FCY.WRHFLG_0=2