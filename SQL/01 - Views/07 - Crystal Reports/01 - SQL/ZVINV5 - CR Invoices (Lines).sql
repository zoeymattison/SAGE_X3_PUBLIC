 ( INVOICE_0 , LINENUM_0 , SALESORDER_0 , PRODUCT_0 , DESCRIPTION_0 
 , CATALOGUE_0 , ORDERED_0 , INVOICED_0 , BACKORDERED_0 , SALESUNIT_0 
 , GROSSPRICE_0 , DISCOUNTPERC_0 , NETPRICE_0 , TOTAL_0 , INVREF_0 , LINETEXT_0 
 ) As 
WITH salesordernumber AS (
    SELECT DISTINCT
        NUM_0,
        SOHNUM_0
    FROM LIVE.SINVOICED
),
invoicelines AS (
    SELECT
        sid.NUM_0,
        sid.SOHNUM_0,
        sid.SOPLIN_0,
        sid.ITMREF_0 AS [Invoice Product],
        itm.ITMDES1_0 + ' ' + itm.ITMDES2_0 AS [Invoice Description],
        itm.SEAKEY_0 AS [Invoice Catalogue],
        sid.QTY_0 AS [Invoice QTY],
        sid.SAU_0 AS [Invoice Sales Unit],
        sid.GROPRI_0 AS [Invoice Gross Price],
        (sid.GROPRI_0 - sid.NETPRI_0) AS [Invoice Line Discount],
        sid.NETPRI_0 AS [Invoice Net Price],
        tex.TEXTE_0 AS [Invoice Line Text],
        sid.SIDLIN_0 AS [Invoice Line Number]
    FROM LIVE.SINVOICED sid
    INNER JOIN LIVE.ITMMASTER itm ON sid.ITMREF_0 = itm.ITMREF_0
    LEFT JOIN LIVE.TEXCLOB tex ON sid.SIDTEX_0 = tex.CODE_0
    WHERE LEFT(sid.ITMREF_0, 4) <> 'EHF-'
),
salesorderlines AS (
    SELECT
        soq.SOHNUM_0,
        soq.SOPLIN_0,
        soq.ITMREF_0 AS [Sales Order Product],
        CASE
            WHEN sop.ITMDES_0 <> itm.ITMDES1_0 THEN sop.ITMDES_0
            ELSE itm.ITMDES1_0 + ' ' + itm.ITMDES2_0
        END AS [Sales Order Description],
        itm.SEAKEY_0 AS [Sales Order Catalogue],
        soq.QTY_0 - soq.DLVQTY_0 AS [Sales Order BO QTY],
        soq.QTY_0 AS [Sales Order QTY],
        sop.SAU_0 AS [Sales Order Sales Unit],
        sop.GROPRI_0 AS [Sales Order Gross Price],
        (sop.GROPRI_0 - sop.NETPRI_0) AS [Sales Order Discount],
        sop.NETPRI_0 AS [Sales Order Net Price],
        tex.TEXTE_0 AS [Sales Order Line Text]
    FROM LIVE.SORDERQ soq
    INNER JOIN LIVE.SORDERP sop ON soq.SOHNUM_0 = sop.SOHNUM_0 AND soq.SOPLIN_0 = sop.SOPLIN_0
    INNER JOIN LIVE.ITMMASTER itm ON soq.ITMREF_0 = itm.ITMREF_0
    LEFT JOIN LIVE.TEXCLOB tex ON soq.SOQTEX_0 = tex.CODE_0
    WHERE LEFT(soq.ITMREF_0, 4) <> 'EHF-'
),
interestlines AS (
    SELECT
        NUM_0,
        'Interest Charged for Overdue Account' AS [Description],
        AMTATILIN_0 AS [Amount]
    FROM LIVE.BPCINVLIG
    WHERE LEFT(NUM_0, 3) = 'INT'
),
invoice_reference_return AS (
    SELECT DISTINCT
        d.NUM_0 AS [Number],
        dl.SIHNUM_0 AS [Invoice]
    FROM LIVE.SINVOICED d
    INNER JOIN LIVE.SRETURND r ON d.SRHNUM_0 = r.SRHNUM_0 AND d.SIDORILIN_0 = r.SRDLIN_0
    INNER JOIN LIVE.SDELIVERYD s ON r.SDHNUM_0 = s.SDHNUM_0 AND r.SDDLIN_0 = s.SDDLIN_0
    INNER JOIN LIVE.SDELIVERY dl ON s.SDHNUM_0 = dl.SDHNUM_0
),
invoice_reference_direct AS (
    SELECT
        NUM_0 AS [Number],
        SIHORINUM_0 AS [Invoice Reference]
    FROM LIVE.SINVOICEV
),
bp_invoice_lines AS (
    SELECT
        NUM_0 AS [Invoice],
        DES_0 AS [Description],
        AMTNOTLIN_0 AS [Total]
    FROM LIVE.BPCINVLIG
)
SELECT DISTINCT
    sih.NUM_0 AS [Invoice],
    CASE 
        WHEN ISNULL(son.SOHNUM_0, '') = '' THEN ivl.[Invoice Line Number]
        ELSE sol.SOPLIN_0
    END AS [Line Number],
    CASE
        WHEN ISNULL(son.SOHNUM_0, '') = '' THEN 'N/A'
        WHEN son.SOHNUM_0 IS NULL THEN sih.DES_0
        ELSE son.SOHNUM_0
    END AS [Sales Order],
    CASE
        WHEN ISNULL(son.SOHNUM_0, '') = '' THEN ivl.[Invoice Product]
        WHEN son.SOHNUM_0 IS NULL THEN sih.DES_0
        ELSE sol.[Sales Order Product]
    END AS [Product],
    COALESCE(
        CASE
            WHEN ISNULL(son.SOHNUM_0, '') = '' THEN ivl.[Invoice Description]
            WHEN son.SOHNUM_0 IS NULL THEN interest.[Description]
            ELSE sol.[Sales Order Description]
        END, 
        bp.[Description]
    ) AS [Description],
    ISNULL(
        CASE WHEN ISNULL(son.SOHNUM_0, '') = '' THEN ivl.[Invoice Catalogue] ELSE sol.[Sales Order Catalogue] END,
        ''
    ) AS [Catalogue],
    ISNULL(
        CASE WHEN ISNULL(son.SOHNUM_0, '') = '' THEN 0 ELSE sol.[Sales Order QTY] END,
        0
    ) AS [Ordered QTY],
    ISNULL(ivl.[Invoice QTY], 0) * sih.SNS_0 AS [Invoiced Qty],
    ISNULL(
        CASE WHEN ISNULL(son.SOHNUM_0, '') = '' THEN 0 ELSE sol.[Sales Order BO QTY] * sih.SNS_0 END,
        0
    ) AS [Backordered QTY],
    ISNULL(
        CASE WHEN ISNULL(son.SOHNUM_0, '') = '' THEN ivl.[Invoice Sales Unit] ELSE sol.[Sales Order Sales Unit] END,
        ''
    ) AS [Salse Unit],
    CASE
        WHEN ISNULL(son.SOHNUM_0, '') = '' THEN ISNULL(ivl.[Invoice Gross Price], 0) * sih.SNS_0
        WHEN son.SOHNUM_0 IS NULL THEN ISNULL(interest.[Amount], 0) * sih.SNS_0
        ELSE ISNULL(sol.[Sales Order Gross Price], 0) * sih.SNS_0
    END AS [Gross Price],
    ISNULL(
        CASE WHEN ISNULL(son.SOHNUM_0, '') = '' THEN ivl.[Invoice Line Discount] ELSE sol.[Sales Order Discount] END * sih.SNS_0,
        0
    ) AS [Discount Percent],
    CASE
        WHEN ISNULL(son.SOHNUM_0, '') = '' THEN ISNULL(ivl.[Invoice Net Price], 0) * sih.SNS_0
        WHEN son.SOHNUM_0 IS NULL THEN ISNULL(interest.[Amount], 0) * sih.SNS_0
        ELSE ISNULL(sol.[Sales Order Net Price], 0) * sih.SNS_0
    END AS [Net Price],
    COALESCE(
        CASE
            WHEN ISNULL(son.SOHNUM_0, '') = '' THEN ivl.[Invoice Net Price] * ivl.[Invoice QTY] * sih.SNS_0
            WHEN son.SOHNUM_0 IS NULL THEN interest.[Amount] * sih.SNS_0
            ELSE ISNULL(ivl.[Invoice Net Price], 0) * ISNULL(ivl.[Invoice QTY], 0) * sih.SNS_0
        END,
        bp.[Total],
        0
    ) AS [Total],
    ISNULL(ISNULL(ret.[Invoice], dir.[Invoice Reference]), 'Direct credit') AS [Invoice Reference],
    ISNULL(
        CASE WHEN ISNULL(son.SOHNUM_0, '') = '' THEN ivl.[Invoice Line Text] ELSE sol.[Sales Order Line Text] END,
        ''
    ) AS [Line Text]
FROM LIVE.SINVOICE sih
LEFT JOIN salesordernumber son 
    ON sih.NUM_0 = son.NUM_0
/* Driver join: Brings in ALL order lines for the sales order attached to this invoice */
LEFT JOIN salesorderlines sol 
    ON son.SOHNUM_0 = sol.SOHNUM_0
/* Specific invoice line match: Checks if THIS specific invoice shipped/invoiced this specific order line */
LEFT JOIN invoicelines ivl 
    ON sih.NUM_0 = ivl.NUM_0 
    AND (
        (son.SOHNUM_0 <> '' AND sol.SOPLIN_0 = ivl.SOPLIN_0) 
        OR son.SOHNUM_0 = ''
    )
LEFT JOIN interestlines interest 
    ON sih.NUM_0 = interest.NUM_0
LEFT JOIN invoice_reference_return ret 
    ON sih.NUM_0 = ret.Number
LEFT JOIN invoice_reference_direct dir 
    ON sih.NUM_0 = dir.Number
LEFT JOIN bp_invoice_lines bp 
    ON sih.NUM_0 = bp.[Invoice]
