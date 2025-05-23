WITH StockTotals AS (
	SELECT
		STO.STOFCY_0,
		STO.ITMREF_0,
		ITM.ITMDES1_0,
		ITM.TSICOD_0,
		ITM.TSICOD_1,
		ITM.ACCCOD_0,
		ITM.CCE_1,
		ITM.STU_0,
		ATX.TEXTE_0,
		ITF.SAFSTO_0,
		SUM(STO.QTYSTU_0) AS TotalStock
	FROM
		LIVE.STOCK STO
		LEFT JOIN LIVE.ITMMASTER ITM on STO.ITMREF_0=ITM.ITMREF_0
		LEFT JOIN LIVE.ATEXTRA ATX ON ATX.CODFIC_0 = 'ATABDIV'
			AND ATX.IDENT1_0 = '21'
			AND ATX.ZONE_0 = 'LNGDES'
			AND ATX.LANGUE_0 = 'ENG'
			AND ATX.IDENT2_0 = ITM.TSICOD_1
		LEFT JOIN LIVE.ITMFACILIT ITF ON STO.ITMREF_0=ITF.ITMREF_0 and STO.STOFCY_0=ITF.STOFCY_0
	GROUP BY
		STO.STOFCY_0,
		STO.ITMREF_0,
		ITM.ITMDES1_0,
		ITM.TSICOD_0,
		ITM.TSICOD_1,
		ITM.ACCCOD_0,
		ITM.CCE_1,
		ITM.STU_0,
		ATX.TEXTE_0,
		ITF.SAFSTO_0
),
RetailPrice AS (
    SELECT
        PLICRD_0,
        PRI_0,
        ROW_NUMBER() OVER (PARTITION BY PLICRD_0 ORDER BY MAXQTY_0 ASC) AS rn
    FROM LIVE.SPRICLIST
    WHERE PLI_0 = '10'
),
SalesPrice AS (
    SELECT
        PLICRI2_0,
        PRI_0,
        ROW_NUMBER() OVER (PARTITION BY PLICRI2_0 ORDER BY MAXQTY_0 ASC) AS rn
    FROM LIVE.SPRICLIST
    WHERE PLI_0 = '11' AND PLICRI1_0 = 'PL2'
),
SalesTotals AS (
	SELECT
		SID.SALFCY_0,
		SID.ITMREF_0,
		SID.QTYSTU_0,
		SID.QTY_0*SID.GROPRI_0*SIH.SNS_0 as LinePrice,
		SID.CREDAT_0
	FROM LIVE.SINVOICED SID
        INNER JOIN LIVE.SINVOICE SIH ON SID.NUM_0=SIH.NUM_0
	WHERE
		SID.CREDAT_0>=dateadd(year,-1,GETDATE())
)
SELECT
FCY.FCY_0 as StockSite,
STK.ITMREF_0 as Product,
STK.ITMDES1_0 as Description,
Case
When STK.TSICOD_0='' THEN 'N/A'
Else STK.TSICOD_0
End as Status,
Case
When STK.TSICOD_1='' THEN 'N/A'
Else STK.TSICOD_1
End as Class,
isnull(STK.TEXTE_0,'N/A') as ClassName,
STK.ACCCOD_0 as AccountingCode,
STK.SAFSTO_0 as SafetyStock,
STK.TotalStock as StockOH,
STK.STU_0 as StockUnit,
isnull(SAL.QTYSTU_0,0) as QtySold1Y,
isnull(SAL.LinePrice,0) as SaleTotal1Y,
SAL.CREDAT_0 as SalesDate,
isnull(RTP.PRI_0,0) as CurrentPrice


FROM LIVE.FACILITY FCY
LEFT JOIN StockTotals STK ON FCY.FCY_0=STK.STOFCY_0
LEFT JOIN RetailPrice RTP ON STK.ITMREF_0 = RTP.PLICRD_0 AND RTP.rn = 1
LEFT JOIN SalesPrice SLP ON STK.ITMREF_0 = SLP.PLICRI2_0 AND SLP.rn = 1
LEFT JOIN SalesTotals SAL ON STK.ITMREF_0=SAL.ITMREF_0 and STK.STOFCY_0=SAL.SALFCY_0

WHERE FCY.WRHFLG_0=2