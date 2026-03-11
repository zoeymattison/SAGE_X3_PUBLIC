WITH filtered_customers AS (
    SELECT 
        BPCNUM_0,
        BPCNAM_0,
        CREDAT_0,
        REP_0
    FROM LIVE.BPCUSTOMER
    WHERE BPCSTA_0 = 2 
        AND LEFT(BPCNUM_0, 3) <> 'TMS'
        AND (
            (CHARINDEX('-', BPCNUM_0) = 0) 
            OR (LEFT(BPCNUM_0, 5) = 'GAIN-' AND CHARINDEX('-', SUBSTRING(BPCNUM_0, 6, LEN(BPCNUM_0))) = 0)
        )
),
invoice_aggregates AS (
    SELECT 
        BPR_0,
        MAX(CREDAT_0) AS last_invoice_date,
        MIN(CREDAT_0) AS first_invoice_date,
        SUM(AMTNOT_0) AS total_amount
    FROM LIVE.SINVOICE
    WHERE BPR_0 IN (SELECT BPCNUM_0 FROM filtered_customers)
    GROUP BY BPR_0
),
sales_rep AS (
    SELECT
        REPNUM_0,
        REPNAM_0
    FROM
        LIVE.SALESREP
)
SELECT
    fc.BPCNUM_0 AS 'CUSTOMER NUMBER',
    fc.BPCNAM_0 AS 'CUSTOMER NAME',
    ISNULL(r.REPNAM_0, '') AS 'REP NAME',
    ia.last_invoice_date AS 'LAST INVOICE',
    ISNULL(DATEDIFF(day, ia.last_invoice_date, GETDATE()), 9999999) AS 'DAYS SINCE',
    ia.first_invoice_date AS 'FIRST INVOICE',
    fc.CREDAT_0 AS 'DATE CREATED',
    ia.total_amount AS 'TOTAL AMOUNT'
FROM filtered_customers fc
LEFT JOIN invoice_aggregates ia ON fc.BPCNUM_0 = ia.BPR_0
LEFT JOIN sales_rep r ON fc.REP_0 = r.REPNUM_0