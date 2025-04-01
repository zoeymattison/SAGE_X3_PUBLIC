WITH CreditCardInfo AS (
    SELECT
        SOHNUM_0,
        ACCL4D_0,
        AUTAMT_0,
        LANMES_0,
        ACCNCKNAM_0,
		TEXTE_0,
        STAFLG_0
    FROM
        LIVE.SEAUTH
    LEFT JOIN
        LIVE.APLSTD APL ON STAFLG_0 = LANNUM_0
        AND LANCHP_0 = '2095'
        AND LAN_0 = 'ENG'
	LEFT JOIN
		LIVE.ATEXTRA ATX ON CRDTYP_0=ATX.IDENT2_0
		AND IDENT1_0='398' 
		AND LANGUE_0='ENG' 
		AND CODFIC_0='ATABDIV'
    WHERE
        STAFLG_0 IN (3, 6)
),
RankedCreditCardInfo AS (
    SELECT
        SOHNUM_0,
        ACCL4D_0,
        AUTAMT_0,
        LANMES_0,
        ACCNCKNAM_0,
		TEXTE_0,
        ROW_NUMBER() OVER (PARTITION BY SOHNUM_0, ACCL4D_0 ORDER BY STAFLG_0 DESC) AS rn
    FROM CreditCardInfo
),
PrepayemntInfo AS (
    SELECT
        DUD.NUM_0,
        DUD.PAMTYP_0,
        DUD.AMTCUR_0,
        DUD.PAYCUR_0,
        SEU.ACCL4D_0,
        SEU.AUTAMT_0,
        APL.LANMES_0,
        SEU.ACCNCKNAM_0,
        SEU.STAFLG_0,
		TEXTE_0
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
		LIVE.ATEXTRA ATX ON SEU.CRDTYP_0=ATX.IDENT2_0
		AND IDENT1_0='398' 
		AND LANGUE_0='ENG' 
		AND CODFIC_0='ATABDIV'
    WHERE
        DUD.PAMTYP_0 = 2
        AND (SEU.STAFLG_0 IN (3, 6) OR SEU.STAFLG_0 IS NULL)
),
RankedPrepaymentInfo AS (
    SELECT
        NUM_0,
        PAMTYP_0,
        AMTCUR_0,
        PAYCUR_0,
        ACCL4D_0,
        AUTAMT_0,
        LANMES_0,
        ACCNCKNAM_0,
		TEXTE_0,
        ROW_NUMBER() OVER (PARTITION BY NUM_0, ACCL4D_0 ORDER BY STAFLG_0 DESC) AS rn
    FROM PrepayemntInfo
)
SELECT
	SOH.SOHNUM_0 as [Sales Order],
	CASE
        WHEN SOH.PTE_0 = 'PREPAY' THEN isnull(PRP.AMTCUR_0,0)
        WHEN SOH.PTE_0 = 'CREDITCARDP' THEN isnull(CRD.AUTAMT_0,0)
		ELSE 0
    END AS [Prepayment Amount],
    CASE
        WHEN SOH.PTE_0 = 'CREDITCARDP' THEN isnull(CRD.AUTAMT_0, 0)
        WHEN SOH.PTE_0 = 'PREPAY' THEN isnull(PRP.AUTAMT_0, 0)
        ELSE 0
    END AS [Auth Amount],
    CASE
        WHEN SOH.PTE_0 = 'CREDITCARDP' AND CRD.LANMES_0='Captured' THEN isnull(CRD.AUTAMT_0, 0)
        WHEN SOH.PTE_0 = 'PREPAY' THEN isnull(PRP.PAYCUR_0, 0)
        ELSE 0
    END AS [Paid Amount],
    CASE
        WHEN SOH.PTE_0 = 'CREDITCARDP' THEN isnull(CRD.ACCL4D_0, '')
        WHEN SOH.PTE_0 = 'PREPAY' THEN isnull(PRP.ACCL4D_0, '')
        ELSE ''
    END AS [Last 4],
    CASE
        WHEN SOH.PTE_0 = 'CREDITCARDP' THEN isnull(CRD.LANMES_0, '')
        WHEN SOH.PTE_0 = 'PREPAY' THEN isnull(PRP.LANMES_0, '')
        ELSE ''
    END AS [Card Status],
	CASE
        WHEN SOH.PTE_0 = 'CREDITCARDP' THEN isnull(CRD.TEXTE_0, '')
        WHEN SOH.PTE_0 = 'PREPAY' THEN isnull(PRP.TEXTE_0, '')
        ELSE ''
    END AS [Card Type],
    CASE
        WHEN SOH.PTE_0 = 'CREDITCARDP' THEN isnull(CRD.ACCNCKNAM_0, '')
        WHEN SOH.PTE_0 = 'PREPAY' THEN isnull(PRP.ACCNCKNAM_0, '')
        ELSE ''
    END AS [Nickname]

FROM LIVE.SORDER SOH
LEFT OUTER JOIN RankedCreditCardInfo CRD ON SOH.SOHNUM_0 = CRD.SOHNUM_0
    AND CRD.rn = 1
LEFT OUTER JOIN RankedPrepaymentInfo PRP ON SOH.SOHNUM_0 = PRP.NUM_0
    AND PRP.rn = 1
WHERE SOH.PTE_0 IN ('CREDITCARDP','PREPAY')