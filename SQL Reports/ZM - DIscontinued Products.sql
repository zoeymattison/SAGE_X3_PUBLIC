With SalesData AS (
	SELECT
		ITMREF_0,
		MAX(CREDAT_0) as CREDAT_0
	FROM
		LIVE.SINVOICED SID
	GROUP BY
		ITMREF_0
),
StockData AS (
	SELECT
		ITMREF_0,
		SUM(QTYSTU_0) as QTYSTU_0
	FROM
		LIVE.STOCK
	GROUP BY
		ITMREF_0
)

SELECT
ITM.ITMREF_0 as [Product],
ITM.ITMDES1_0 as [Description],
ITM.TSICOD_0 as [Status],
ITM.YDISDAT_0 as [Discontinuation Date],
ITM.ACCCOD_0 as [Accounting Code],
SAL.CREDAT_0 as [Last Invoice],
isnull(STK.QTYSTU_0,0) as [Total Stock]

FROM LIVE.ITMMASTER ITM
Left Join SalesData SAL ON ITM.ITMREF_0=SAL.ITMREF_0
Left join StockData STK ON ITM.ITMREF_0=STK.ITMREF_0
WHERE TSICOD_0 IN ('DM','DS') and (YDISDAT_0<=dateadd(year,-1,GETDATE()) or YDISDAT_0 IS NULL)
and (SAL.CREDAT_0<=dateadd(year,-1,GETDATE()) or SAL.CREDAT_0 is null)
and (STK.QTYSTU_0 is NULL or STK.QTYSTU_0=0)
and ITM.ACCCOD_0<>'FURNITURE'
