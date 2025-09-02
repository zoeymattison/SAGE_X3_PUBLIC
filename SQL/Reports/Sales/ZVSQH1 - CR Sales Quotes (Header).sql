WITH BPDLVCUST AS (
    SELECT
        BPCNUM_0 AS [Customer Number],
        BPAADD_0 AS [Address Code],
        YCOSTCENTRE_0 AS [Cost Center]
    FROM LIVE.BPDLVCUST
),
SALESREP AS (
    SELECT
        REPNUM_0,
        REPNAM_0
    FROM LIVE.SALESREP
),
BPADDRESS AS (
    SELECT
        bpc.BPCNAM_0 AS [Customer Name],
        bpa.BPADES_0 AS [Customer Description],
        bpa.BPAADD_0 AS [Address Code],
        bpa.BPANUM_0 AS [Customer Number],
        bpa.BPAADDLIG_0 AS [Address 1],
        bpa.BPAADDLIG_1 AS [Address 2],
        bpa.BPAADDLIG_2 AS [Address 3],
        bpa.CRY_0 AS [Country Code],
        bpa.CRYNAM_0 AS [Country],
        bpa.SAT_0 AS [Province],
        bpa.POSCOD_0 AS [Postal Code],
        bpa.CTY_0 AS [City],
        bpa.WEB_0 AS [Email]
    FROM LIVE.BPADDRESS bpa
    INNER JOIN LIVE.BPCUSTOMER bpc ON bpa.BPANUM_0 = bpc.BPCNUM_0
),
SORDERLINE AS (
    SELECT
        soq.SQHNUM_0 AS [Sales Order],
        SUM(soq.GROPRI_0 * soq.QTY_0) AS [Line Amount (Before Discounts)],
        SUM(soq.NETPRI_0 * soq.QTY_0) AS [Line Amount (After Discounts)],
        SUM(CASE WHEN soq.VACITM_2 = 'EHF' THEN soq.CLCAMT1_0 ELSE 0 END) AS [Line EHF],
        SUM(CASE WHEN soq.DISCRGVAL1_0 <> 0 THEN (soq.GROPRI_0 - soq.NETPRI_0) * soq.QTY_0 ELSE 0 END) AS [Line Discounts]
    FROM LIVE.SQUOTED soq
    WHERE soq.SQHNUM_0 IN (SELECT DISTINCT SQHNUM_0 FROM LIVE.SQUOTE)
    GROUP BY soq.SQHNUM_0
),
SVCRFOOT AS (
    SELECT
        sv.VCRNUM_0,
        SUM(CASE WHEN sv.DTA_0 = 1 THEN sv.DTAAMT_0 ELSE 0 END) AS [SO Discount],
        SUM(CASE WHEN sv.DTA_0 = 10 THEN sv.DTAAMT_0 ELSE 0 END) AS [SO Discount Percent], 
        SUM(CASE WHEN sv.DTA_0 = 10 THEN sv.DTANOT_0 * -1 ELSE 0 END) AS [SO Discount Percent-Amount], 
        SUM(CASE WHEN sv.DTA_0 = 9 THEN sv.DTAAMT_0 ELSE 0 END) AS [SO Fuel Surhcharge],
        SUM(CASE WHEN sv.DTA_0 = 8 THEN sv.DTAAMT_0 ELSE 0 END) AS [SO Freight Charge],
        SUM(CASE WHEN sv.DTA_0 = 5 THEN sv.DTAAMT_0 ELSE 0 END) AS [SO EHF Fees]
    FROM LIVE.SVCRFOOT sv
    WHERE sv.VCRNUM_0 IN (SELECT DISTINCT SQHNUM_0 FROM LIVE.SQUOTE)
    GROUP BY sv.VCRNUM_0
),
SVCRVAT AS (
    SELECT
        sv.VCRNUM_0,
        SUM(CASE WHEN sv.VAT_0 = 'TAX' AND sv.VATRAT_0 = 12 THEN 0.25 ELSE 0 END) AS [Fuel Tax GST],
        SUM(CASE WHEN sv.VAT_0 = 'TAX' AND sv.VATRAT_0 = 12 THEN 0.35 ELSE 0 END) AS [Fuel Tax PST],
        SUM(CASE WHEN sv.VAT_0 = 'GST' THEN sv.AMTTAX_0 ELSE 0 END) AS [GST],
        SUM(CASE WHEN sv.VAT_0 = 'BCPST' THEN sv.AMTTAX_0 ELSE 0 END) AS [PST]
    FROM LIVE.SVCRVAT sv
    WHERE sv.VCRNUM_0 IN (SELECT DISTINCT SQHNUM_0 FROM LIVE.SQUOTE)
    GROUP BY sv.VCRNUM_0
),
TEXCLOB AS (
    SELECT
        t.CODE_0,
        t.TEXTE_0
    FROM LIVE.TEXCLOB t
    WHERE t.CODE_0 IN (
        SELECT DISTINCT SQHTEX1_0 FROM LIVE.SQUOTE WHERE SQHTEX1_0 IS NOT NULL
        UNION
        SELECT DISTINCT SQHTEX2_0 FROM LIVE.SQUOTE WHERE SQHTEX2_0 IS NOT NULL
    )
)
SELECT
    soh.SALFCY_0 AS [Sales Site],
    soh.CREDAT_0 AS [Creation Date],
    soh.ORDDAT_0 AS [Order Date],
    soh.ORDDAT_0 AS [Ship Date],
    soh.SQHNUM_0 AS [Order Number],
    ISNULL(bpd.[Cost Center], '') AS [Cost Center],
    soh.CUSQUOREF_0 AS [Purchase Order],
    ISNULL(rep.REPNAM_0, '') AS [Sales Rep],
    '' AS [Route],
    soh.PTE_0 AS [Payment Term],
    soh.YPICKNOTE_0 AS [Shipping Instructions],
    soh.VACBPR_0 AS [Tax Rule],

    /* BILL-TO */
    CASE 
        WHEN soh.ZBPCINV_0 = soh.ZBPCPYR_0 THEN soh.ZBPCINV_0
        ELSE soh.ZBPCPYR_0
    END AS [Bill To],

    CASE 
        WHEN soh.ZBPCINV_0 = soh.ZBPCPYR_0 THEN bpa2.[Customer Name]
        ELSE bpa.[Customer Name]
    END AS [Bill-to Name 1],

    CASE 
        WHEN soh.ZBPCINV_0 = soh.ZBPCPYR_0 THEN bpa2.[Customer Description]
        ELSE bpa.[Customer Description]
    END AS [Bill-to Name 2],

    CASE 
        WHEN soh.ZBPCINV_0 = soh.ZBPCPYR_0 THEN 
            CASE WHEN bpa2.[Address 1] IN ('~', '*') THEN '' ELSE bpa2.[Address 1] END
        ELSE 
            CASE WHEN bpa.[Address 1] IN ('~', '*') THEN '' ELSE bpa.[Address 1] END
    END AS [Bill-to Address 1],

    CASE 
        WHEN soh.ZBPCINV_0 = soh.ZBPCPYR_0 THEN 
            CASE WHEN bpa2.[Address 2] IN ('~', '*') THEN '' ELSE bpa2.[Address 2] END
        ELSE 
            CASE WHEN bpa.[Address 2] IN ('~', '*') THEN '' ELSE bpa.[Address 2] END
    END AS [Bill-to Address 2],

    CASE 
        WHEN soh.ZBPCINV_0 = soh.ZBPCPYR_0 THEN 
            CASE WHEN bpa2.[Address 3] IN ('~', '*') THEN '' ELSE bpa2.[Address 3] END
        ELSE 
            CASE WHEN bpa.[Address 3] IN ('~', '*') THEN '' ELSE bpa.[Address 3] END
    END AS [Bill-to Address 3],

    CASE 
        WHEN soh.ZBPCINV_0 = soh.ZBPCPYR_0 THEN bpa2.[Country Code]
        ELSE bpa.[Country Code]
    END AS [Bill-to Country Code],

    CASE 
        WHEN soh.ZBPCINV_0 = soh.ZBPCPYR_0 THEN bpa2.[Country]
        ELSE bpa.[Country]
    END AS [Bill-to Country],

    CASE 
        WHEN soh.ZBPCINV_0 = soh.ZBPCPYR_0 THEN bpa2.[City]
        ELSE bpa.[City]
    END AS [Bill-to City],

    CASE 
        WHEN soh.ZBPCINV_0 = soh.ZBPCPYR_0 THEN bpa2.[Province]
        ELSE bpa.[Province]
    END AS [Bill-to Province],

    CASE 
        WHEN soh.ZBPCINV_0 = soh.ZBPCPYR_0 THEN bpa2.[Postal Code]
        ELSE bpa.[Postal Code]
    END AS [Bill-to Postal Code],

    CASE 
        WHEN soh.ZBPCINV_0 = soh.ZBPCPYR_0 THEN bpa2.[Email]
        ELSE bpa.[Email]
    END AS [Bill-to Email],

    /* SHIP-TO*/
    soh.BPCORD_0 AS [Ship-to],
    CASE WHEN soh.BPDNAM_0 IN ('~', '*') THEN '' ELSE soh.BPDNAM_0 END AS [Ship-to Name 1],
    CASE WHEN soh.BPDNAM_1 IN ('~', '*') THEN '' ELSE soh.BPDNAM_1 END AS [Ship-to Name 2],
    CASE WHEN soh.BPDADDLIG_0 IN ('~', '*') THEN '' ELSE soh.BPDADDLIG_0 END AS [Ship-to Address 1],
    CASE WHEN soh.BPDADDLIG_1 IN ('~', '*') THEN '' ELSE soh.BPDADDLIG_1 END AS [Ship-to Address 2],
    CASE WHEN soh.BPDADDLIG_2 IN ('~', '*') THEN '' ELSE soh.BPDADDLIG_2 END AS [Ship-to Address 3],
    soh.BPDCRY_0 AS [Ship-to Country Code],
    soh.BPDCRYNAM_0 AS [Ship-to Country],
    soh.BPDCTY_0 AS [Ship-to City],
    soh.BPDSAT_0 AS [Ship-to Province],
    soh.BPDPOSCOD_0 AS [Ship-to Postal Code],
    bpa3.[Email],

    /* DISCOUNTS */
    sol.[Line Discounts],
    ISNULL(svf.[SO Discount] + svf.[SO Discount Percent-Amount], 0) AS [SO Discounts],
    ISNULL(sol.[Line Discounts] + svf.[SO Discount] + svf.[SO Discount Percent-Amount], 0) AS [Total Discounts],

    /* INVOICING ELEMENTS */
    ISNULL(svf.[SO Freight Charge], 0) AS [Freight],
    ISNULL(svf.[SO Fuel Surhcharge], 0) AS [Fuel Surcharge],

    /* TOTALS */
    sol.[Line Amount (Before Discounts)] AS [Lines Before Discounts],
    soh.QUOINVNOT_0 AS [Subtotal After Discounts],
    sol.[Line EHF],
    ISNULL(svt.[GST] + svt.[Fuel Tax GST], 0) AS [GST],
    ISNULL(svt.[PST] + svt.[Fuel Tax PST], 0) AS [PST],
    soh.QUOINVATI_0 AS [Total],
    soh.QUOINVATI_0 AS [Owing],

    /* TEXT */
    ISNULL(texh.TEXTE_0, '') AS [Header Text],
    ISNULL(texf.TEXTE_0, '') AS [Footer Text]

FROM LIVE.SQUOTE soh
LEFT JOIN SALESREP rep ON soh.REP_0 = rep.REPNUM_0
LEFT JOIN BPDLVCUST bpd ON soh.BPAADD_0 = bpd.[Address Code] AND soh.BPCORD_0 = bpd.[Customer Number]
LEFT JOIN BPADDRESS bpa ON soh.BPAADD_0 = bpa.[Address Code] AND soh.ZBPCPYR_0 = bpa.[Customer Number]
LEFT JOIN BPADDRESS bpa2 ON soh.BPAADD_0 = bpa2.[Address Code] AND soh.ZBPCINV_0 = bpa2.[Customer Number]
LEFT JOIN BPADDRESS bpa3 ON soh.BPAADD_0 = bpa3.[Address Code] AND soh.BPCORD_0 = bpa3.[Customer Number]
LEFT JOIN SORDERLINE sol ON soh.SQHNUM_0 = sol.[Sales Order]
LEFT JOIN SVCRFOOT svf ON soh.SQHNUM_0 = svf.VCRNUM_0
LEFT JOIN SVCRVAT svt ON soh.SQHNUM_0 = svt.VCRNUM_0
LEFT JOIN TEXCLOB texh ON soh.SQHTEX1_0 = texh.CODE_0
LEFT JOIN TEXCLOB texf ON soh.SQHTEX2_0 = texf.CODE_0