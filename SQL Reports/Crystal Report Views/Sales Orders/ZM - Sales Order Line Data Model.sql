With ProductInfo As (
	SELECT
		ITMREF_0,
		ITMDES1_0,
		ITMDES2_0,
		ITMDES3_0,
		EANCOD_0 as UPCNUM_0,
		SEAKEY_0 as BASCOD_0,
		TSICOD_0 as MNKSTA_0,
		TSICOD_2 as EHFCOD_0
	FROM
		LIVE.ITMMASTER
),
EHFCodes As (
	SELECT 
		IDENT2_0,
		PRI_0
	FROM 
		LIVE.ATEXTRA
		LEFT JOIN LIVE.SPRICLIST ON TEXTE_0=left(PLICRI1_0,LEN(TEXTE_0))
		AND PLI_0='21'
	WHERE 
		CODFIC_0='ATABDIV' 
		AND IDENT1_0='22' 
		AND ZONE_0='SHODES'
)

SELECT
SOQ.CREDAT_0 as [Date Created],
SOQ.ORDDAT_0 as [Date Ordered],
SOQ.SHIDAT_0 as [Required Ship Date],
SOQ.DEMDLVDAT_0 as [Required Delivery Date],
SOQ.SOHNUM_0 as [Sales Order],
SOQ.ITMREF_0 as [Product],
ITM.ITMDES1_0 as [Description 1],
ITM.ITMDES2_0 as [Description 2],
ITM.ITMDES3_0 as [Description 3],
ITM.UPCNUM_0 as [UPC Code],
ITM.BASCOD_0 as [Basics Code],
ITM.MNKSTA_0 as [Monk Status],
SOQ.QTY_0 as [Ordered Quantity],
SOQ.DLVQTY_0 as [Delivered Quantity],
SOQ.QTY_0-SOQ.DLVQTY_0 as [Remaining Quantity],
SOQ.ALLQTY_0 as [Allocated Quantity],
SOQ.OPRQTY_0 as [Quantity Being Prepared],
SOQ.QTY_0-SOQ.DLVQTY_0-SOQ.ALLQTY_0-OPRQTY_0 as [Backordered Quantity],
SOP.SAU_0 as [Sales Unit],
SOP.GROPRI_0 as [Gross Price],
SOP.CPRPRI_0 as [Cost Price],
SOP.NETPRI_0 as [Net Price],
CASE WHEN SOP.VACITM_0='GST' THEN (SOP.NETPRI_0+isnull(EHF.PRI_0,0))*0.05 END AS [GST Amt],
CASE WHEN SOP.VACITM_0='GST' THEN ((SOP.NETPRI_0+isnull(EHF.PRI_0,0))*SOQ.QTY_0)*0.05 END AS [GST Total],
CASE WHEN SOP.VACITM_1='PST' THEN SOP.NETPRI_0*0.07 END AS [PST Amt],
CASE WHEN SOP.VACITM_1='PST' THEN ((SOP.NETPRI_0+isnull(EHF.PRI_0,0))*SOQ.QTY_0)*0.07 END AS [PST Total],
isnull(EHF.PRI_0,0) as [EHF Fee],
isnull(SOQ.QTY_0*EHF.PRI_0,0) as [EHF Total],
SOP.NETPRIATI_0 as [Net Price + Tax],
SOP.NETPRI_0*SOQ.QTY_0 as [Total],
ROUND(SOP.NETPRIATI_0*SOQ.QTY_0,2) as [Total + Tax],
APL.LANMES_0 as [Line Status]


FROM LIVE.SORDERQ SOQ
INNER JOIN LIVE.SORDERP SOP ON SOQ.SOHNUM_0=SOP.SOHNUM_0 AND SOQ.SOPLIN_0=SOP.SOPLIN_0 AND SOQ.SOQSEQ_0=SOP.SOPSEQ_0
INNER JOIN ProductInfo ITM ON SOQ.ITMREF_0=ITM.ITMREF_0
LEFT JOIN EHFCodes EHF ON ITM.EHFCOD_0=EHF.IDENT2_0
LEFT JOIN LIVE.APLSTD APL ON SOQ.SOQSTA_0 = APL.LANNUM_0
    AND APL.LANCHP_0 = '279'
    AND APL.LAN_0 = 'ENG'