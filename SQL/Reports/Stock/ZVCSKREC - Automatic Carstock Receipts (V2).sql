WITH delivery_base AS (
    SELECT 
        SDHNUM_0,
        SDDLIN_0,
        BPCORD_0,
        STOFCY_0,
        ITMREF_0,
        ITMDES1_0,
        SAU_0,
        QTY_0
    FROM LIVE.SDELIVERYD
    WHERE LEFT(BPCORD_0, 3) = 'ICR' 
      AND LEFT(SDHNUM_0, 4) <> 'DC52'
),
delivery_transformed AS (
    SELECT 
        SDHNUM_0,
        SDDLIN_0,
        RIGHT(BPCORD_0, 4) AS receiving_site,
        IIF(LEFT(STOFCY_0, 2) = 'DC', 'I' + STOFCY_0, STOFCY_0) AS supplier_site,
        ITMREF_0,
        ITMDES1_0,
        SAU_0,
        QTY_0
    FROM delivery_base
),
receipt_data AS (
    SELECT 
        SDHNUM_0,
        SDDLIN_0,
        PTHNUM_0
    FROM LIVE.PRECEIPTD
),
validated_items AS (
    SELECT DISTINCT 
        ITMREF_0
    FROM LIVE.ITMMASTER
),
report_date AS (
    SELECT FORMAT(GETDATE(), 'yyyyMMdd') AS accounting_date
)
SELECT 
    dt.receiving_site AS [Receiving Site],
    rd.accounting_date AS [Accounting Date],
    dt.supplier_site AS [Supplier Site],
    dt.SDHNUM_0 AS [Delivery],
    dt.SDDLIN_0 AS [Delivery Line],
    dt.ITMREF_0 AS [Product],
    dt.ITMDES1_0 AS [Description],
    dt.SAU_0 AS [Unit of Measure],
    dt.QTY_0 AS [Quantity Received],
    ISNULL(rec.PTHNUM_0, '') AS [Receipt Number]
FROM delivery_transformed dt
CROSS JOIN report_date rd
LEFT JOIN receipt_data rec 
    ON dt.SDHNUM_0 = rec.SDHNUM_0 
    AND dt.SDDLIN_0 = rec.SDDLIN_0
INNER JOIN validated_items vi 
    ON dt.ITMREF_0 = vi.ITMREF_0