SELECT
    COUNT(SIH.NUM_0) AS [Invoice Count],
    BPC.CREDAT_0 AS [Customer Creation Date],
    BPC.BPCNUM_0 AS [Customer Number],
    BPC.BPCNAM_0 AS [Customer Name],
    BPC.BPCSTA_0 AS [Customer Status],
    CONVERT(VARCHAR, MAX(SIH.CREDAT_0), 101) AS [Last Invoice Date]
FROM
    LIVE.BPCUSTOMER BPC
    LEFT OUTER JOIN LIVE.SINVOICE SIH ON BPC.BPCNUM_0 = SIH.BPR_0
WHERE
    BPC.BPCNUM_0 LIKE 'TMS%'
GROUP BY
    BPC.CREDAT_0,
    BPC.BPCNUM_0,
    BPC.BPCNAM_0,
    BPC.BPCSTA_0
ORDER BY
    [Customer Creation Date] DESC;