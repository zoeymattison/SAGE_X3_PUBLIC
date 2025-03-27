WITH SalesData AS (
    SELECT
        ITMREF_0,
        SUM(CASE WHEN STOFCY_0 = 'DC30' THEN AMTNOTLIN_0 ELSE 0 END) AS SalesTotalDC30,
        SUM(CASE WHEN STOFCY_0 = 'DC31' THEN AMTNOTLIN_0 ELSE 0 END) AS SalesTotalDC31,
        SUM(CASE WHEN STOFCY_0 = 'DC33' THEN AMTNOTLIN_0 ELSE 0 END) AS SalesTotalDC33,
        SUM(CASE WHEN STOFCY_0 = 'DC52' THEN AMTNOTLIN_0 ELSE 0 END) AS SalesTotalDC52,
        SUM(CASE WHEN STOFCY_0 = '1200' THEN AMTNOTLIN_0 ELSE 0 END) AS SalesTotalDuncan,
        SUM(CASE WHEN STOFCY_0 = '1600' THEN AMTNOTLIN_0 ELSE 0 END) AS SalesTotalCourt,
        SUM(CASE WHEN STOFCY_0 = '1800' THEN AMTNOTLIN_0 ELSE 0 END) AS SalesTotalPH,
        SUM(CASE WHEN STOFCY_0 = '2100' THEN AMTNOTLIN_0 ELSE 0 END) AS SalesTotalFort,
        SUM(CASE WHEN STOFCY_0 = '2200' THEN AMTNOTLIN_0 ELSE 0 END) AS SalesTotalOak,
        SUM(CASE WHEN STOFCY_0 = '2300' THEN AMTNOTLIN_0 ELSE 0 END) AS SalesTotalBroad,
        SUM(CASE WHEN STOFCY_0 = '2400' THEN AMTNOTLIN_0 ELSE 0 END) AS SalesTotalRylOak,
        SUM(CASE WHEN STOFCY_0 = '2500' THEN AMTNOTLIN_0 ELSE 0 END) AS SalesTotalTusc,
        SUM(CASE WHEN STOFCY_0 = '2600' THEN AMTNOTLIN_0 ELSE 0 END) AS SalesTotalSidney,
        SUM(CASE WHEN STOFCY_0 = '2700' THEN AMTNOTLIN_0 ELSE 0 END) AS SalesTotalFortIB,
        SUM(CASE WHEN STOFCY_0 = '2800' THEN AMTNOTLIN_0 ELSE 0 END) AS SalesTotalSidneyIB,
        SUM(CASE WHEN STOFCY_0 = '3200' THEN AMTNOTLIN_0 ELSE 0 END) AS SalesTotalFrnShwrm
    FROM LIVE.SINVOICED
    WHERE CREDAT_0 >= DATEADD(year, -1, GETDATE()) 
    GROUP BY ITMREF_0
), StockData AS (
    SELECT
        ITMREF_0,
        SUM(CASE WHEN STOFCY_0 = 'DC30' THEN QTYSTU_0 ELSE 0 END) AS StockTotalDC30,
        SUM(CASE WHEN STOFCY_0 = '1600' THEN QTYSTU_0 ELSE 0 END) AS StockTotalCourt,
        SUM(CASE WHEN STOFCY_0 = '2100' THEN QTYSTU_0 ELSE 0 END) AS StockTotalFort,
        SUM(CASE WHEN STOFCY_0 = '2200' THEN QTYSTU_0 ELSE 0 END) AS StockTotalOak,
        SUM(CASE WHEN STOFCY_0 = '2300' THEN QTYSTU_0 ELSE 0 END) AS StockTotalBroad,
        SUM(CASE WHEN STOFCY_0 = '2600' THEN QTYSTU_0 ELSE 0 END) AS StockTotalSidney,
        SUM(CASE WHEN STOFCY_0 = '3200' THEN QTYSTU_0 ELSE 0 END) AS StockTotalFrnShwrm
    FROM LIVE.STOCK
    GROUP BY ITMREF_0
), PrimaryVendor AS (
    SELECT
        ITP2.ITMREF_0,
        ITP2.BPSNUM_0,
        ITP2.BPSNUM_0 + ' ' + BPS.BPSNAM_0 AS PrimaryVendorName,
        ROW_NUMBER() OVER (PARTITION BY ITP2.ITMREF_0 ORDER BY ITP2.PIO_0) AS RowNum
    FROM LIVE.ITMBPS ITP2
    LEFT JOIN LIVE.BPSUPPLIER BPS ON BPS.BPSNUM_0 = ITP2.BPSNUM_0
    WHERE ITP2.PIO_0 = 0
), SecondaryVendor AS (
    SELECT
        ITP2.ITMREF_0,
        ITP2.BPSNUM_0,
        ITP2.BPSNUM_0 + ' ' + BPS.BPSNAM_0 AS SecondaryVendorName,
        ROW_NUMBER() OVER (PARTITION BY ITP2.ITMREF_0 ORDER BY ITP2.PIO_0) AS RowNum
    FROM LIVE.ITMBPS ITP2
    LEFT JOIN LIVE.BPSUPPLIER BPS ON BPS.BPSNUM_0 = ITP2.BPSNUM_0
    WHERE ITP2.PIO_0 <> 0
), PrimaryPrice AS (
    SELECT
        PLICRI2_0,
        PLICRI1_0,
        PRI_0
    FROM LIVE.PPRICLIST
    WHERE PLI_0 = 'T20'
), SecondPrice AS(
    SELECT
        PLICRI2_0,
        PLICRI1_0,
        PRI_0
    FROM LIVE.PPRICLIST
    WHERE PLI_0 = 'T20'
)
SELECT DISTINCT
    ITP.ITMREF_0 AS ProductCode,
    ITM.ITMDES1_0 AS ProductDescrion,
    ITM.TSICOD_0 AS MonkStatus,
    ATX.TEXTE_0 AS MonkClass,
    ITM.STU_0 AS StockUnit,
    ISNULL(ITF.SAFSTO_0, 0) AS DC30SafetyStk,
    ISNULL(ITF.REOMINQTY_0, 0) AS ProductEOQ,
    ISNULL(SD.SalesTotalDC30, 0) AS SalesTotalDC30,
    ISNULL(SD.SalesTotalDC31, 0) AS SalesTotalDC31,
    ISNULL(SD.SalesTotalDC33, 0) AS SalesTotalDC33,
    ISNULL(SD.SalesTotalDC52, 0) AS SalesTotalDC52,
    ISNULL(SD.SalesTotalDuncan, 0) AS SalesTotalDuncan,
    ISNULL(SD.SalesTotalCourt, 0) AS SalesTotalCourt,
    ISNULL(SD.SalesTotalPH, 0) AS SalesTotalPH,
    ISNULL(SD.SalesTotalFort, 0) AS SalesTotalFort,
    ISNULL(SD.SalesTotalOak, 0) AS SalesTotalOak,
    ISNULL(SD.SalesTotalBroad, 0) AS SalesTotalBroad,
    ISNULL(SD.SalesTotalRylOak, 0) AS SalesTotalRylOak,
    ISNULL(SD.SalesTotalTusc, 0) AS SalesTotalTusc,
    ISNULL(SD.SalesTotalSidney, 0) AS SalesTotalSidney,
    ISNULL(SD.SalesTotalFortIB, 0) AS SalesTotalFortIB,
    ISNULL(SD.SalesTotalSidneyIB, 0) AS SalesTotalSidneyIB,
    ISNULL(SD.SalesTotalFrnShwrm, 0) AS SalesTotalFrnShwrm,
    ISNULL(SKD.StockTotalDC30, 0) AS StockTotalDC30,
    ISNULL(SKD.StockTotalCourt, 0) AS StockTotalCourt,
    ISNULL(SKD.StockTotalFort, 0) AS StockTotalFort,
    ISNULL(SKD.StockTotalOak, 0) AS StockTotalOak,
    ISNULL(SKD.StockTotalBroad, 0) AS StockTotalBroad,
    ISNULL(SKD.StockTotalSidney, 0) AS StockTotalSidney,
    ISNULL(SKD.StockTotalFrnShwrm, 0) AS StockTotalFrnShwrm,
    ITM.RPLITM_0 AS AlternateProduct,
    ISNULL(PV.PrimaryVendorName, 'N/A') AS PrimaryVendor,
    ISNULL(SV.SecondaryVendorName, 'N/A') AS SecondaryVendor,
    ISNULL(PP.PRI_0, 0) AS PrimarySupCost,
    ISNULL(SP.PRI_0, 0) AS SecondSupCost,
    ISNULL(SPL.PRI_0, 0) AS CustPL2Price
FROM LIVE.ITMBPS ITP
INNER JOIN LIVE.ITMMASTER ITM ON ITP.ITMREF_0 = ITM.ITMREF_0
LEFT JOIN LIVE.ATEXTRA ATX ON ATX.CODFIC_0 = 'ATABDIV'
    AND ATX.IDENT1_0 = '21'
    AND ATX.ZONE_0 = 'LNGDES'
    AND ATX.LANGUE_0 = 'ENG'
    AND ATX.IDENT2_0 = ITM.TSICOD_1
LEFT JOIN LIVE.ITMFACILIT ITF ON ITM.ITMREF_0 = ITF.ITMREF_0 AND ITF.STOFCY_0 = 'DC30'
LEFT JOIN SalesData SD ON ITM.ITMREF_0 = SD.ITMREF_0
LEFT JOIN StockData SKD ON ITM.ITMREF_0 = SKD.ITMREF_0
LEFT JOIN PrimaryVendor PV ON ITP.ITMREF_0 = PV.ITMREF_0 AND PV.RowNum = 1
LEFT JOIN SecondaryVendor SV ON ITP.ITMREF_0 = SV.ITMREF_0 AND SV.RowNum = 1
LEFT JOIN PrimaryPrice PP ON ITM.ITMREF_0 = PP.PLICRI2_0 AND PP.PLICRI1_0 = PV.BPSNUM_0
LEFT JOIN SecondPrice SP ON ITM.ITMREF_0 = SP.PLICRI2_0 AND SP.PLICRI1_0 = SV.BPSNUM_0
LEFT JOIN LIVE.SPRICLIST SPL ON ITM.ITMREF_0 = SPL.PLICRI2_0 AND SPL.PLI_0 = '11' AND SPL.PLICRI1_0 = 'PL2'