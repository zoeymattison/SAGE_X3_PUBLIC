WITH SoldToData AS (
    SELECT DISTINCT
        BPA.BPAADD_0,
        BPA.BPANUM_0,
        BPA.BPAADDLIG_0,
        BPA.BPAADDLIG_1,
        BPA.BPAADDLIG_2,
        BPA.CTY_0,
        BPA.POSCOD_0,
        BPA.SAT_0,
        BPA.WEB_0,
        BPA.TEL_0,
        BPC.BPCNAM_0
    FROM
        LIVE.BPADDRESS BPA
        LEFT JOIN LIVE.BPCUSTOMER BPC ON BPA.BPANUM_0 = BPC.BPCNUM_0
),
ShipToData AS (
    SELECT DISTINCT
        BPA.BPAADD_0,
        BPA.BPANUM_0,
        BPA.BPAADDLIG_0,
        BPA.BPAADDLIG_1,
        BPA.BPAADDLIG_2,
        BPA.CTY_0,
        BPA.POSCOD_0,
        BPA.SAT_0,
        BPA.WEB_0,
        BPA.TEL_0,
        BPC.BPCNAM_0
    FROM
        LIVE.BPADDRESS BPA
        LEFT JOIN LIVE.BPCUSTOMER BPC ON BPA.BPANUM_0 = BPC.BPCNUM_0
),
SalesReps AS (
    SELECT
        REPNUM_0,
        REPNAM_0
    FROM
        LIVE.SALESREP
),
CreditCardInfo AS (
    SELECT
        SIHNUM_0,
        ACCL4D_0,
        SUM(PAYAMT_0) AS PAYAMT_0,
        SUM(AUTAMT_0) AS AUTAMT_0,
        SUM(TAXAMT_0) AS TAXAMT_0,
        LANMES_0,
        ACCNCKNAM_0,
        STAFLG_0,
		ATX.TEXTE_0
    FROM
        LIVE.SEAUTH
    LEFT JOIN
        LIVE.APLSTD APL ON STAFLG_0 = LANNUM_0
        AND LANCHP_0 = '2095'
        AND LAN_0 = 'ENG'
	LEFT JOIN
		LIVE.ATEXTRA ATX ON CRDTYP_0=ATX.IDENT2_0
		AND ATX.ZONE_0 = 'LNGDES'
		AND ATX.LANGUE_0 = 'ENG'
		AND ATX.CODFIC_0 = 'ATABDIV'
		AND ATX.IDENT1_0 = '398'
    WHERE
        STAFLG_0 IN (3, 6)
    GROUP BY
        SIHNUM_0,
        ACCL4D_0,
        LANMES_0,
        ACCNCKNAM_0,
        STAFLG_0,
		ATX.TEXTE_0
),
RankedCreditCardInfo AS (
    SELECT
        SIHNUM_0,
        ACCL4D_0,
        PAYAMT_0,
        AUTAMT_0,
        TAXAMT_0,
        LANMES_0,
        ACCNCKNAM_0,
		TEXTE_0,
        ROW_NUMBER() OVER (PARTITION BY SIHNUM_0, ACCL4D_0 ORDER BY STAFLG_0 DESC) AS rn
    FROM CreditCardInfo
),
PrepayemntInfo AS (
    SELECT
        DUD.NUM_0,
        DUD.PAMTYP_0,
        SUM(DUD.AMTCUR_0) AS AMTCUR_0,
        SUM(DUD.PAYCUR_0) AS PAYCUR_0,
        SEU.ACCL4D_0,
        SUM(SEU.PAYAMT_0) AS PAYAMT_0,
        SUM(SEU.AUTAMT_0) AS AUTAMT_0,
        SUM(SEU.TAXAMT_0) AS TAXAMT_0,
        APL.LANMES_0,
        SEU.ACCNCKNAM_0,
        SEU.STAFLG_0,
		ATX.TEXTE_0
    FROM
        LIVE.GACCDUDATE DUD
    LEFT JOIN
        LIVE.PAYMENTD PYD ON DUD.NUM_0 = PYD.VCRNUM_0
    LEFT JOIN
        LIVE.SEAUTH SEU ON PYD.NUM_0 = SEU.VCRNUM_0
    LEFT JOIN
        LIVE.APLSTD APL ON SEU.STAFLG_0 = APL.LANNUM_0
        AND APL.LANCHP_0 = '2095'
        AND APL.LAN_0 = 'ENG'
	LEFT JOIN
		LIVE.ATEXTRA ATX ON CRDTYP_0=ATX.IDENT2_0
		AND ATX.ZONE_0 = 'LNGDES'
		AND ATX.LANGUE_0 = 'ENG'
		AND ATX.CODFIC_0 = 'ATABDIV'
		AND ATX.IDENT1_0 = '398'
    WHERE
        DUD.PAMTYP_0 = 2
        AND (SEU.STAFLG_0 IN (3, 6) OR SEU.STAFLG_0 IS NULL)
    GROUP BY
        DUD.NUM_0,
        DUD.PAMTYP_0,
        SEU.ACCL4D_0,
        APL.LANMES_0,
        SEU.ACCNCKNAM_0,
        SEU.STAFLG_0,
		ATX.TEXTE_0
),
RankedPrepaymentInfo AS (
    SELECT
        NUM_0,
        PAMTYP_0,
        AMTCUR_0,
        PAYCUR_0,
        ACCL4D_0,
        PAYAMT_0,
        AUTAMT_0,
        TAXAMT_0,
        LANMES_0,
        ACCNCKNAM_0,
		TEXTE_0,
        ROW_NUMBER() OVER (PARTITION BY NUM_0, ACCL4D_0 ORDER BY STAFLG_0 DESC) AS rn
    FROM PrepayemntInfo
),
RankedSalesOrderInfo AS (
    SELECT
        SID.SOHNUM_0,
        SID.NUM_0,
        SOHA.DRN_0,
		SOHA.YPICKNOTE_0,
        ROW_NUMBER() OVER (PARTITION BY SID.NUM_0 ORDER BY SID.SOHNUM_0) AS rn
    FROM
        LIVE.SINVOICED SID
    LEFT OUTER JOIN
        LIVE.SORDER SOHA ON SID.SOHNUM_0 = SOHA.SOHNUM_0
),
SalesOrderInfo AS (
    SELECT
        SOHNUM_0,
        NUM_0,
        DRN_0,
		YPICKNOTE_0
    FROM
        RankedSalesOrderInfo
    WHERE
        rn = 1
)
SELECT
    /* INVOICE */
	SIH.CREDAT_0 as [Date Created],
	SIH.ACCDAT_0 as [Accounting Date],
	SIV.INVDAT_0 as [Invoice Date],
	SIH.NUM_0 as [Invoice Number],
	CASE
		WHEN SIH.SNS_0=1 THEN 'INVOICE'
		WHEN SIH.SNS_0<1 THEN 'CREDIT MEMO'
	END AS [Invoice Type],
	SIV.INVREF_0 as [Purchase Order],
	UPPER(isnull(REP.REPNAM_0,'')) AS [Rep Name],
	APL.LANMES_0 AS [Route],
	SIH.PTE_0 as [Payment Terms],
	SIV.INVDTAAMT_3 as [Freight Charge],
	SIV.INVDTAAMT_4 as [Fuel Surcharge],
	SOH.YPICKNOTE_0 as [Shipping Instructions],
	SIH.VAC_0 as [Tax Rule],
	SIH.AMTATI_0 as [Total + Tax],
	SIH.AMTNOT_0 as [Total - Tax],

    /* SOLD-TO */
    UPPER(SLD.BPAADD_0) AS [Sold To Address],
    SLD.BPANUM_0 AS [Sold To],
    CASE WHEN UPPER(SIH.BPAADDLIG_0) IN ('~','*') THEN '' ELSE UPPER(SIH.BPAADDLIG_0) END AS [Sold To Address 1],
    CASE WHEN UPPER(SIH.BPAADDLIG_1) IN ('~','*') THEN '' ELSE UPPER(SIH.BPAADDLIG_1) END AS [Sold To Address 2],
    CASE WHEN UPPER(SIH.BPAADDLIG_2) IN ('~','*') THEN '' ELSE UPPER(SIH.BPAADDLIG_2) END AS [Sold To Address 3],
    UPPER(SIH.CTY_0) AS [Sold To City],
    UPPER(SIH.POSCOD_0) AS [Sold To POSCOD],
    UPPER(SIH.SAT_0) AS [Sold To Province],
    UPPER(SLD.BPCNAM_0) AS [Sold To Name],
    SLD.WEB_0 AS [Sold To Email],
    SLD.TEL_0 AS [Sold To Phone],

    /* SHIP-TO */
    UPPER(SHP.BPAADD_0) AS [Ship To Address],
    SHP.BPANUM_0 AS [Ship To],
    CASE WHEN UPPER(SIV.BPDADDLIG_0) IN ('~','*') THEN '' ELSE UPPER(SIV.BPDADDLIG_0) END AS [Ship To Address 1],
    CASE WHEN UPPER(SIV.BPDADDLIG_1) IN ('~','*') THEN '' ELSE UPPER(SIV.BPDADDLIG_1) END AS [Ship To Address 2],
    CASE WHEN UPPER(SIV.BPDADDLIG_2) IN ('~','*') THEN '' ELSE UPPER(SIV.BPDADDLIG_2) END AS [Ship To Address 3],
    UPPER(SIV.BPDCTY_0) AS [Ship To City],
    UPPER(SIV.BPDPOSCOD_0) AS [Ship To POSCOD],
    UPPER(SIV.BPDSAT_0) AS [Ship To Province],
    UPPER(SHP.BPCNAM_0) AS [Ship To Name],
    SHP.WEB_0 AS [Ship To Email],
    SHP.TEL_0 AS [Ship To Phone],

    /* PAYMENT DETAILS */
    CASE
        WHEN SIH.PTE_0 = 'PREPAY' THEN isnull(PRP.AMTCUR_0,0)
        WHEN SIH.PTE_0 = 'CREDITCARDP' THEN isnull(CRD.AUTAMT_0,0)
    ELSE 0
    END AS [Prepayment Amount],
    CASE
        WHEN SIH.PTE_0 = 'CREDITCARDP' THEN isnull(CRD.AUTAMT_0, 0)
        WHEN SIH.PTE_0 = 'PREPAY' THEN isnull(PRP.AUTAMT_0, 0)
        ELSE 0
    END AS [Auth Amount],
    CASE
        WHEN SIH.PTE_0 = 'CREDITCARDP' AND CRD.LANMES_0='Captured' THEN isnull(CRD.AUTAMT_0, 0)
        WHEN SIH.PTE_0 = 'PREPAY' THEN isnull(PRP.PAYAMT_0, 0)
        ELSE 0
    END AS [Paid Amount],
    CASE
        WHEN SIH.PTE_0 = 'CREDITCARDP' THEN isnull(CRD.ACCL4D_0, '')
        WHEN SIH.PTE_0 = 'PREPAY' THEN isnull(PRP.ACCL4D_0, '')
        ELSE ''
    END AS [Last 4],
    CASE
        WHEN SIH.PTE_0 = 'CREDITCARDP' THEN isnull(CRD.LANMES_0, '')
        WHEN SIH.PTE_0 = 'PREPAY' THEN isnull(PRP.LANMES_0, '')
        ELSE ''
    END AS [Card Status],
    CASE
        WHEN SIH.PTE_0 = 'CREDITCARDP' THEN isnull(CRD.ACCNCKNAM_0, '')
        WHEN SIH.PTE_0 = 'PREPAY' THEN isnull(PRP.ACCNCKNAM_0, '')
        ELSE ''
    END AS [Nickname],
    CASE
        WHEN SIH.PTE_0 = 'CREDITCARDP' THEN isnull(CRD.TEXTE_0, '')
        WHEN SIH.PTE_0 = 'PREPAY' THEN isnull(PRP.TEXTE_0, '')
        ELSE ''
    END AS [Card Type]

FROM LIVE.SINVOICE SIH
LEFT JOIN SalesOrderInfo SOH ON SIH.NUM_0 = SOH.NUM_0
LEFT JOIN LIVE.SINVOICEV SIV ON SIH.NUM_0=SIV.NUM_0
LEFT JOIN LIVE.APLSTD APL ON SOH.DRN_0 = APL.LANNUM_0
    AND APL.LANCHP_0 = '409'
    AND APL.LAN_0 = 'ENG'
LEFT JOIN SoldToData SLD ON SIH.BPRPAY_0 = SLD.BPANUM_0 AND SIH.BPAPAY_0 = SLD.BPAADD_0
LEFT JOIN ShipToData SHP ON SIV.BPCORD_0 = SHP.BPANUM_0 AND SIV.BPAADD_0 = SHP.BPAADD_0
LEFT JOIN SalesReps REP ON SIV.REP_0 = REP.REPNUM_0
LEFT JOIN RankedCreditCardInfo CRD ON SIH.NUM_0 = CRD.SIHNUM_0
    AND CRD.rn = 1
LEFT JOIN RankedPrepaymentInfo PRP ON SOH.SOHNUM_0 = PRP.NUM_0
    AND PRP.rn = 1

	WHERE SIH.NUM_0='DIR463882'
