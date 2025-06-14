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
SID.CREDAT_0 as [Date Created],
SID.INVDAT_0 as [Invoice Date],
SID.NUM_0 as [Sales Order],
SID.ITMREF_0 as [Product],
ITM.ITMDES1_0 as [Description 1],
ITM.ITMDES2_0 as [Description 2],
ITM.ITMDES3_0 as [Description 3],
ITM.UPCNUM_0 as [UPC Code],
ITM.BASCOD_0 as [Basics Code],
ITM.MNKSTA_0 as [Monk Status],
SID.QTY_0 as [Ordered Quantity],
SID.SAU_0 as [Sales Unit],
SID.GROPRI_0 as [Gross Price],
SID.CPRPRI_0 as [Cost Price],
SID.NETPRI_0 as [Net Price],
isnull(CASE WHEN SID.VACITM_0='GST' THEN (SID.NETPRI_0+isnull(EHF.PRI_0,0))*0.05 END,0) AS [GST Amt],
isnull(CASE WHEN SID.VACITM_0='GST' THEN ((SID.NETPRI_0+isnull(EHF.PRI_0,0))*SID.QTY_0)*0.05 END,0) AS [GST Total],
isnull(CASE WHEN SID.VACITM_1='PST' THEN SID.NETPRI_0*0.07 END,0) AS [PST Amt],
isnull(CASE WHEN SID.VACITM_1='PST' THEN ((SID.NETPRI_0+isnull(EHF.PRI_0,0))*SID.QTY_0)*0.07 END,0) AS [PST Total],
isnull(EHF.PRI_0,0) as [EHF Fee],
isnull(SID.QTY_0*EHF.PRI_0,0) as [EHF Total],
SID.NETPRIATI_0 as [Net Price + Tax],
SID.NETPRI_0*SID.QTY_0 as [Total],
ROUND(SID.NETPRIATI_0*SID.QTY_0,2) as [Total + Tax],
SID.SOHNUM_0 as [Sales Order],
SID.SOPLIN_0 as [Sales Order Line],
SID.SOQSEQ_0 as [Sales Order Line Sequence],



FROM LIVE.SINVOICED SID
INNER JOIN ProductInfo ITM ON SID.ITMREF_0=ITM.ITMREF_0
LEFT JOIN EHFCodes EHF ON ITM.EHFCOD_0=EHF.IDENT2_0