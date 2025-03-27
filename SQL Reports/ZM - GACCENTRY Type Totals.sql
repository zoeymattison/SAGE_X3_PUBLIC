SELECT
    HAE.TYP_0,
    COUNT(*) AS RecordCount  -- Counts all records for each TYP_0
FROM
    LIVE.GACCENTRY HAE
GROUP BY
    HAE.TYP_0  -- Groups the records so COUNT(*) aggregates per unique TYP_0 value
ORDER BY
    HAE.TYP_0; -- Optional: Orders the results by the type name for readability