WITH BasePIH AS (
	SELECT
		PIH.NUM_0,
		PIH.CUR_0,
		PIH.AMTATI_0
	FROM LIVE.PINVOICE PIH
	WHERE PIH.STA_0 IN (1,2)
),
PID_OnePerPIH AS (
	SELECT
		PID.NUM_0,
		PID.BPSNUM_0,
		PID.BPR_0
	FROM LIVE.PINVOICED PID
	INNER JOIN (
		SELECT NUM_0, MIN(ROWID) AS MinRow
		FROM LIVE.PINVOICED
		GROUP BY NUM_0
	) sub ON PID.NUM_0 = sub.NUM_0 AND PID.ROWID = sub.MinRow
),
CleanInvoiceNotPosted AS (
	SELECT
		PID.BPSNUM_0,
		PID.BPR_0,
		PIH.CUR_0,
		PIH.AMTATI_0
	FROM BasePIH PIH
	JOIN PID_OnePerPIH PID ON PID.NUM_0 = PIH.NUM_0
),
InvoiceNotPosted AS (
	SELECT
		BPSNUM_0,
		BPR_0,
		CUR_0,
		SUM(AMTATI_0) AS AMTATI_0
	FROM CleanInvoiceNotPosted
	GROUP BY BPSNUM_0, BPR_0, CUR_0
)
SELECT DISTINCT
	BVT.BPSNUM_0 as [Supplier],
	BPS.BPSNAM_0 as [Supplier Name],
	BVT.BPSRSK_0 as [Pay-to],
	BPS2.BPSNAM_0 as [Pay-to Name],
	BVT.CUR_0 as [Currency],
	SUM(BVT.RCPATIC_0) as [Delivered Not Invoiced],
	SUM(BVT.BLCAMTC_0) as [Account Balance],
	SUM(BVT.RCPATIC_0 + BVT.BLCAMTC_0 + ROUND(BVT.ORDATIC_0, 2)) as [Credit Level Total],
	ISNULL(INP.AMTATI_0, 0) as [Invoiced Not Posted]
FROM LIVE.BPSUPPMVT BVT
LEFT JOIN LIVE.BPSUPPLIER BPS ON BVT.BPSNUM_0 = BPS.BPSNUM_0
LEFT JOIN LIVE.BPSUPPLIER BPS2 ON BVT.BPSRSK_0 = BPS2.BPSNUM_0
LEFT JOIN InvoiceNotPosted INP ON 
	BVT.BPSNUM_0 = INP.BPSNUM_0 AND
	BVT.BPSRSK_0 = INP.BPR_0 AND
	BVT.CUR_0 = INP.CUR_0
GROUP BY 
	BVT.BPSNUM_0, BPS.BPSNAM_0, 
	BVT.BPSRSK_0, BPS2.BPSNAM_0, 
	BVT.CUR_0,
	INP.AMTATI_0
ORDER BY BVT.BPSNUM_0 ASC
