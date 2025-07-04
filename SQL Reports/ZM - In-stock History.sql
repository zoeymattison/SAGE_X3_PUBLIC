WITH AggDates AS (
    SELECT
        ITMREF_0,
        STOFCY_0,
        MAX(CASE WHEN VCRTYP_0 = 6 THEN CREDAT_0 END) AS MaxReceiptDate,
        MIN(CASE WHEN VCRTYP_0 = 6 THEN CREDAT_0 END) AS MinReceiptDate,
        MAX(CASE WHEN VCRTYP_0 IN (19, 9) THEN CREDAT_0 END) AS MaxIssueTransferDate
    FROM LIVE.STOJOU
    GROUP BY ITMREF_0, STOFCY_0
),
AggInvoiceDate AS (
    SELECT
        ITMREF_0,
        MAX(CREDAT_0) AS MaxInvoiceDate
    FROM LIVE.SINVOICED
    GROUP BY ITMREF_0
)
SELECT
    DISTINCT
    IVT.STOFCY_0 AS [Stock Site],
    IVT.ITMREF_0 AS [Product],
    ITM.ITMDES1_0 AS [Description],
    ITM.TSICOD_0 AS [Monk Status],
    ITM.TSICOD_1 AS [Monk Class],
    TXT.TEXTE_0 AS [Class Description],
    ITM.CCE_1 AS [Category],
    CASE ITF.ABCCLS_0 
		WHEN 1 then 'A'
		WHEN 2 THEN 'B'
		WHEN 3 THEN 'C'
		WHEN 4 THEN 'D'
	END AS [ABC Class],
    CAST(STO.QTYSTU_0 AS INT) AS [Quantity In Stock],
    ITM.STU_0 as [Stock Unit],
    STO.LOC_0 AS [Location],
    STO.LOCTYP_0 AS [Location Type],
    IVT.AVC_0 AS [Average Cost],
    IVT.AVC_0 * STO.QTYSTU_0 AS [Total Stock Value],
    CAST(ITF.SAFSTO_0 AS INT) AS [Safety Stock],
    AD.MaxReceiptDate AS [Last Receipt Date],
    AD.MinReceiptDate AS [First Receipt Date],
    AD.MaxIssueTransferDate AS [Last Issue_Transfer Date],
    AID.MaxInvoiceDate AS [Last Invoice Date],
    ISNULL(DATEDIFF(DAY, OverallMaxDate.Dt, GETDATE()), 999999) AS [Days Since Last Activity]
FROM
    LIVE.ITMMVT IVT
    LEFT OUTER JOIN LIVE.ITMMASTER ITM ON IVT.ITMREF_0 = ITM.ITMREF_0
    LEFT OUTER JOIN LIVE.STOCK STO ON IVT.STOFCY_0 = STO.STOFCY_0 AND IVT.ITMREF_0 = STO.ITMREF_0
    LEFT OUTER JOIN LIVE.ITMFACILIT ITF ON IVT.STOFCY_0 = ITF.STOFCY_0 AND IVT.ITMREF_0 = ITF.ITMREF_0
    LEFT OUTER JOIN LIVE.ATEXTRA TXT ON TXT.CODFIC_0 = 'ATABDIV' AND TXT.ZONE_0 = 'LNGDES' AND TXT.IDENT1_0 = '21' AND TXT.IDENT2_0 = ITM.TSICOD_1 AND TXT.LANGUE_0 = 'ENG'
    LEFT OUTER JOIN AggDates AD ON IVT.ITMREF_0 = AD.ITMREF_0 AND IVT.STOFCY_0 = AD.STOFCY_0
    LEFT OUTER JOIN AggInvoiceDate AID ON IVT.ITMREF_0 = AID.ITMREF_0
    OUTER APPLY (
        SELECT MAX(D) AS Dt
        FROM (VALUES (AID.MaxInvoiceDate), (AD.MaxReceiptDate), (AD.MaxIssueTransferDate)) AS AllDates(D)
    ) AS OverallMaxDate
WHERE
    (IVT.PHYSTO_0 + IVT.CTLSTO_0 + IVT.REJSTO_0) > 0