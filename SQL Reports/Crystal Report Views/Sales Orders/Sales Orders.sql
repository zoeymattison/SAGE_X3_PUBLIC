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
        SOHNUM_0,
        ACCL4D_0,
        SUM(PAYAMT_0) AS PAYAMT_0,
        SUM(AUTAMT_0) AS AUTAMT_0,
        SUM(TAXAMT_0) AS TAXAMT_0,
        LANMES_0,
        ACCNCKNAM_0,
        STAFLG_0
    FROM
        LIVE.SEAUTH
    LEFT JOIN
        LIVE.APLSTD APL ON STAFLG_0 = LANNUM_0
        AND LANCHP_0 = '2095'
        AND LAN_0 = 'ENG'
    WHERE
        STAFLG_0 IN (3, 6)
    GROUP BY
        SOHNUM_0,
        ACCL4D_0,
        LANMES_0,
        ACCNCKNAM_0,
        STAFLG_0
),
RankedCreditCardInfo AS (
    SELECT
        SOHNUM_0,
        ACCL4D_0,
        PAYAMT_0,
        AUTAMT_0,
        TAXAMT_0,
        LANMES_0,
        ACCNCKNAM_0,
        ROW_NUMBER() OVER (PARTITION BY SOHNUM_0, ACCL4D_0 ORDER BY STAFLG_0 DESC) AS rn
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
        SEU.STAFLG_0
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
    WHERE
        DUD.PAMTYP_0 = 2
        AND (SEU.STAFLG_0 IN (3, 6) OR SEU.STAFLG_0 IS NULL)
    GROUP BY
        DUD.NUM_0,
        DUD.PAMTYP_0,
        SEU.ACCL4D_0,
        APL.LANMES_0,
        SEU.ACCNCKNAM_0,
        SEU.STAFLG_0
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
        ROW_NUMBER() OVER (PARTITION BY NUM_0, ACCL4D_0 ORDER BY STAFLG_0 DESC) AS rn
    FROM PrepayemntInfo
)
SELECT
    /* SALES ORDER */
    SOH.CREDAT_0 AS [Date Created],
    SOH.ORDDAT_0 AS [Date Ordered],
    SOH.SHIDAT_0 AS [Required Ship Date],
    SOH.DEMDLVDAT_0 AS [Required Delivery Date],
    SOH.SOHNUM_0 AS [Sales Order],
    SOH.HLDCOD_0 AS [Order Hold],
    SOH.CUSORDREF_0 AS [Customer PO],
    isnull(REP.REPNAM_0,'') AS [Rep Name],
    APL.LANMES_0 AS [Route],
    SOH.PTE_0 AS [Payment Terms],

    /* SOLD-TO */
    SLD.BPAADD_0 AS [Sold To Address],
    SLD.BPANUM_0 AS [Sold To],
	SLD.BPCNAM_0 AS [Sold To Name],
    SLD.BPAADDLIG_0 AS [Sold To Address 1],
    SLD.BPAADDLIG_1 AS [Sold To Address 2],
    SLD.BPAADDLIG_2 AS [Sold To Address 3],
    SLD.CTY_0 AS [Sold To City],
    SLD.POSCOD_0 AS [Sold To POSCOD],
    SLD.SAT_0 AS [Sold To Province],
    SLD.WEB_0 AS [Sold To Email],
    SLD.TEL_0 AS [Sold To Phone],

    /* SHIP-TO */
    SHP.BPAADD_0 AS [Ship To Address],
    SHP.BPANUM_0 AS [Ship To],
	SHP.BPCNAM_0 AS [Ship To Name],
    SHP.BPAADDLIG_0 AS [Ship To Address 1],
    SHP.BPAADDLIG_1 AS [Ship To Address 2],
    SHP.BPAADDLIG_2 AS [Ship To Address 3],
    SHP.CTY_0 AS [Ship To City],
    SHP.POSCOD_0 AS [Ship To POSCOD],
    SHP.SAT_0 AS [Ship To Province],
    SHP.WEB_0 AS [Ship To Email],
    SHP.TEL_0 AS [Ship To Phone]

FROM LIVE.SORDER SOH
LEFT JOIN LIVE.APLSTD APL ON SOH.DRN_0 = APL.LANNUM_0
    AND APL.LANCHP_0 = '409'
    AND APL.LAN_0 = 'ENG'
LEFT JOIN SoldToData SLD ON SOH.BPCINV_0 = SLD.BPANUM_0 AND SOH.BPAINV_0 = SLD.BPAADD_0
LEFT JOIN ShipToData SHP ON SOH.BPCORD_0 = SHP.BPANUM_0 AND SOH.BPAADD_0 = SHP.BPAADD_0
LEFT JOIN SalesReps REP ON SOH.REP_0 = REP.REPNUM_0