WITH SalesPrice AS (
    SELECT
        PLICRI2_0,
        PRI_0,
        ROW_NUMBER() OVER (PARTITION BY PLICRI2_0 ORDER BY MAXQTY_0 ASC) AS rn
    FROM LIVE.SPRICLIST
    WHERE PLI_0 = '11' AND PLICRI1_0 = 'PL2'
),
SalesOrderData AS (
    SELECT
        SID.ITMREF_0,
        SUM(CASE WHEN SID.SALFCY_0='1600' THEN SID.AMTATILIN_0*SIV.SNS_0 ELSE 0 END) as [1600 Sales],
        SUM(CASE WHEN SID.SALFCY_0='2100' THEN SID.AMTATILIN_0*SIV.SNS_0 ELSE 0 END) as [2100 Sales],
        SUM(CASE WHEN SID.SALFCY_0='2200' THEN SID.AMTATILIN_0*SIV.SNS_0 ELSE 0 END) as [2200 Sales],
        SUM(CASE WHEN SID.SALFCY_0='2300' THEN SID.AMTATILIN_0*SIV.SNS_0 ELSE 0 END) as [2300 Sales],
        SUM(CASE WHEN SID.SALFCY_0='2600' THEN SID.AMTATILIN_0*SIV.SNS_0 ELSE 0 END) as [2600 Sales],
        SUM(CASE WHEN SID.SALFCY_0='DC30' THEN SID.AMTATILIN_0*SIV.SNS_0 ELSE 0 END) as [DC30 Sales],
        SUM(CASE WHEN SID.SALFCY_0='DC33' THEN SID.AMTATILIN_0*SIV.SNS_0 ELSE 0 END) as [DC33 Sales],
        SUM(SID.AMTNOTLIN_0 * SIV.SNS_0) AS TotalSales,
        SUM(SID.QTYSTU_0 * SIV.SNS_0) AS TotalSalesQty,
        COUNT(DISTINCT SID.SOHNUM_0) as [Number of UqO],
        AVG(CASE WHEN SOQ.CREDAT_0 IS NOT NULL 
            THEN DATEDIFF(day, SOQ.CREDAT_0, SID.CREDAT_0) 
            ELSE NULL END) as AvgDeliveryDays
    FROM LIVE.SINVOICED AS SID
    INNER JOIN LIVE.SINVOICE AS SIV ON SID.NUM_0 = SIV.NUM_0
    LEFT JOIN LIVE.SORDERQ SOQ ON SID.ITMREF_0 = SOQ.ITMREF_0 
                              AND SID.SOHNUM_0 = SOQ.SOHNUM_0 
                              AND SID.SOPLIN_0 = SOQ.SOPLIN_0 
                              AND SID.SOQSEQ_0 = SOQ.SOQSEQ_0
    WHERE SID.CREDAT_0 >= DATEADD(year, -1, GETDATE())
    GROUP BY SID.ITMREF_0
),
StockSafetyData AS (
    SELECT
        STO.ITMREF_0,
        SUM(CASE WHEN STO.STOFCY_0 = 'DC30' THEN STO.QTYSTU_0 ELSE 0 END) AS StockTotalDC30,
        SUM(CASE WHEN STO.STOFCY_0 = 'DC33' THEN STO.QTYSTU_0 ELSE 0 END) AS StockTotalDC33,
        SUM(CASE WHEN STO.STOFCY_0 = '1600' THEN STO.QTYSTU_0 ELSE 0 END) AS StockTotalCourt,
        SUM(CASE WHEN STO.STOFCY_0 = '2100' THEN STO.QTYSTU_0 ELSE 0 END) AS StockTotalFort,
        SUM(CASE WHEN STO.STOFCY_0 = '2200' THEN STO.QTYSTU_0 ELSE 0 END) AS StockTotalOak,
        SUM(CASE WHEN STO.STOFCY_0 = '2300' THEN STO.QTYSTU_0 ELSE 0 END) AS StockTotalBroad,
        SUM(CASE WHEN STO.STOFCY_0 = '2600' THEN STO.QTYSTU_0 ELSE 0 END) AS StockTotalSidney,
        SUM(CASE WHEN STO.STOFCY_0 = '3200' THEN STO.QTYSTU_0 ELSE 0 END) AS StockTotal3200,
        MAX(CASE WHEN ITF.STOFCY_0 = 'DC30' THEN ITF.SAFSTO_0 ELSE 0 END) AS SafetyStockDC30,
        MAX(CASE WHEN ITF.STOFCY_0 = 'DC33' THEN ITF.SAFSTO_0 ELSE 0 END) AS SafetyStockDC33,
        MAX(CASE WHEN ITF.STOFCY_0 = '1600' THEN ITF.SAFSTO_0 ELSE 0 END) AS SafetyStockCOR,
        MAX(CASE WHEN ITF.STOFCY_0 = '2100' THEN ITF.SAFSTO_0 ELSE 0 END) AS SafetyStockFRT,
        MAX(CASE WHEN ITF.STOFCY_0 = '2200' THEN ITF.SAFSTO_0 ELSE 0 END) AS SafetyStockOAK,
        MAX(CASE WHEN ITF.STOFCY_0 = '2300' THEN ITF.SAFSTO_0 ELSE 0 END) AS SafetyStockBRD,
        MAX(CASE WHEN ITF.STOFCY_0 = '2600' THEN ITF.SAFSTO_0 ELSE 0 END) AS SafetyStockSID,
        MAX(CASE WHEN ITF.STOFCY_0 = '3200' THEN ITF.SAFSTO_0 ELSE 0 END) AS SafetyStockFRN
    FROM LIVE.STOCK STO
    LEFT JOIN LIVE.ITMFACILIT ITF ON STO.ITMREF_0 = ITF.ITMREF_0 AND STO.STOFCY_0 = ITF.STOFCY_0
    GROUP BY STO.ITMREF_0
),
CostData AS (
    SELECT
        COALESCE(COG.ITMREF_0, ITM.ITMREF_0) as ITMREF_0,
        ISNULL(COG.[COG DC30], 0) as [COG DC30],
        ISNULL(COG.[COG DC33], 0) as [COG DC33],
        ISNULL(COG.[COG 1600], 0) as [COG 1600],
        ISNULL(COG.[COG 2100], 0) as [COG 2100],
        ISNULL(COG.[COG 2200], 0) as [COG 2200],
        ISNULL(COG.[COG 2300], 0) as [COG 2300],
        ISNULL(COG.[COG 2600], 0) as [COG 2600],
        ISNULL(COG.[COG 3200], 0) as [COG 3200],
        ISNULL(COG.[COG Total], 0) as [COG Total],
        ISNULL(ITM.AVC_0, 0) as [Average Cost]
    FROM (
        SELECT
            ITMREF_0,
            SUM(CASE WHEN STOFCY_0='DC30' THEN CPRPRI_0 ELSE 0 END) as [COG DC30],
            SUM(CASE WHEN STOFCY_0='DC33' THEN CPRPRI_0 ELSE 0 END) as [COG DC33],
            SUM(CASE WHEN STOFCY_0='1600' THEN CPRPRI_0 ELSE 0 END) as [COG 1600],
            SUM(CASE WHEN STOFCY_0='2100' THEN CPRPRI_0 ELSE 0 END) as [COG 2100],
            SUM(CASE WHEN STOFCY_0='2200' THEN CPRPRI_0 ELSE 0 END) as [COG 2200],
            SUM(CASE WHEN STOFCY_0='2300' THEN CPRPRI_0 ELSE 0 END) as [COG 2300],
            SUM(CASE WHEN STOFCY_0='2600' THEN CPRPRI_0 ELSE 0 END) as [COG 2600],
            SUM(CASE WHEN STOFCY_0='3200' THEN CPRPRI_0 ELSE 0 END) as [COG 3200],
            SUM(CPRPRI_0) as [COG Total]
        FROM LIVE.SORDERP
        WHERE CREDAT_0 >= DATEADD(year, -1, GETDATE())
        GROUP BY ITMREF_0
    ) COG
    FULL OUTER JOIN (
        SELECT ITMREF_0, AVC_0
        FROM LIVE.ITMMVT
        WHERE STOFCY_0='DC30'
    ) ITM ON COG.ITMREF_0 = ITM.ITMREF_0
),
VendorInfo AS (
    SELECT
        ITMREF_0,
        MAX(CASE WHEN VendorRank = 1 THEN VendorName END) AS PrimaryVendor,
        MAX(CASE WHEN VendorRank = 2 THEN VendorName END) AS SecondaryVendor
    FROM (
        SELECT
            ITMREF_0,
            ITP.BPSNUM_0 + ' ' + ISNULL(BPS.BPSNAM_0, '') AS VendorName,
            ROW_NUMBER() OVER (PARTITION BY ITMREF_0 ORDER BY CASE WHEN PIO_0 = 0 THEN 0 ELSE 1 END, PIO_0) AS VendorRank
        FROM LIVE.ITMBPS ITP
        LEFT JOIN LIVE.BPSUPPLIER BPS ON BPS.BPSNUM_0 = ITP.BPSNUM_0
    ) ranked
    WHERE VendorRank <= 2
    GROUP BY ITMREF_0
),
LastCountData AS (
    SELECT
        ITMREF_0,
        MAX(CASE WHEN STOFCY_0 = '1600' THEN CUNDAT_0 END) as [1600 Last Count],
        MAX(CASE WHEN STOFCY_0 = '2100' THEN CUNDAT_0 END) as [2100 Last Count],
        MAX(CASE WHEN STOFCY_0 = '2200' THEN CUNDAT_0 END) as [2200 Last Count],
        MAX(CASE WHEN STOFCY_0 = '2600' THEN CUNDAT_0 END) as [2600 Last Count]
    FROM LIVE.CUNLISDET
    GROUP BY ITMREF_0
),
SimpleCostOnHand AS (
    SELECT 
        SSD.ITMREF_0,
        SSD.StockTotalDC30 * CD.[Average Cost] AS CostOnHandDC30,
        SSD.StockTotalDC33 * CD.[Average Cost] AS CostOnHandDC33,
        SSD.StockTotalCourt * CD.[Average Cost] AS CostOnHandCourt,
        SSD.StockTotalFort * CD.[Average Cost] AS CostOnHandFort,
        SSD.StockTotalOak * CD.[Average Cost] AS CostOnHandOak,
        SSD.StockTotalBroad * CD.[Average Cost] AS CostOnHandBroad,
        SSD.StockTotalSidney * CD.[Average Cost] AS CostOnHandSidney,
        SSD.StockTotal3200 * CD.[Average Cost] AS CostOnHand3200
    FROM StockSafetyData SSD
    LEFT JOIN CostData CD ON SSD.ITMREF_0 = CD.ITMREF_0
)

SELECT
    ITM.ITMREF_0 as Product,
    ITM.ITMDES1_0 + ' ' + ITM.ITMDES2_0 as Description,
    ITM.RPLITM_0 as Alternate,
    ITM.TSICOD_1 as Class,
    ISNULL(ATX.TEXTE_0,'') as ClassName,
    ISNULL(ITM.TCLCOD_0,'') as Category,
    ISNULL(SPL.PRI_0,0) as PL2Price,
    ITM.TSICOD_0 as Status,
    ISNULL(CD.[Average Cost],0) as [Average Cost],
    ISNULL(SOD.[1600 Sales],0) as [1600 Sales 1Y],
    ISNULL(SOD.[2100 Sales],0) as [2100 Sales 1Y],
    ISNULL(SOD.[2200 Sales],0) as [2200 Sales 1Y],
    ISNULL(SOD.[2300 Sales],0) as [2300 Sales 1Y],
    ISNULL(SOD.[2600 Sales],0) as [2600 Sales 1Y],
    ISNULL(SOD.[DC30 Sales],0) as [DC30 Sales 1Y],
    ISNULL(SOD.[DC33 Sales],0) as [DC33 Sales 1Y],
    ISNULL(SOD.TotalSales,0) as Sales_1Y,
    ISNULL(SOD.TotalSalesQty,0) as SalesQty_1Y,
    ISNULL(CD.[COG DC30],0) as [COG DC30 1Y],
    ISNULL(CD.[COG DC33],0) as [COG DC33 1Y],
    ISNULL(CD.[COG 1600],0) as [COG 1600 1Y],
    ISNULL(CD.[COG 2100],0) as [COG 2100 1Y],
    ISNULL(CD.[COG 2200],0) as [COG 2200 1Y],
    ISNULL(CD.[COG 2300],0) as [COG 2300 1Y],
    ISNULL(CD.[COG 2600],0) as [COG 2600 1Y],
    ISNULL(CD.[COG 3200],0) as [COG 3200 1Y],
    ISNULL(CD.[COG Total],0) as [COG Total 1Y],
    ISNULL(VI.PrimaryVendor, 'N/A') AS PrimaryVendor,
    ISNULL(VI.SecondaryVendor, 'N/A') AS SecondaryVendor,
    ITM.STU_0 as StockUnit,
    ISNULL(SSD.StockTotalDC30,0) as STK_DC30,
    ISNULL(SSD.StockTotalDC33,0) as STK_DC33,
    ISNULL(SSD.StockTotalCourt,0) as STK_COR,
    ISNULL(SSD.StockTotalFort,0) as STK_FRT,
    ISNULL(SSD.StockTotalOak,0) as STK_OAK,
    ISNULL(SSD.StockTotalBroad,0) as STK_BRD,
    ISNULL(SSD.StockTotalSidney,0) as STK_SID,
    ISNULL(SSD.StockTotal3200,0) as STK_FRN,
    ISNULL(SSD.SafetyStockDC30,0) as SAF_DC30,
    ISNULL(SSD.SafetyStockDC33,0) as SAF_DC33,
    ISNULL(SSD.SafetyStockCOR,0) as SAF_COR,
    ISNULL(SSD.SafetyStockFRT,0) as SAF_FRT,
    ISNULL(SSD.SafetyStockOAK,0) as SAF_OAK,
    ISNULL(SSD.SafetyStockBRD,0) as SAF_BRD,
    ISNULL(SSD.SafetyStockSID,0) as SAF_SID,
    ISNULL(SSD.SafetyStockFRN,0) as SAF_FRN,
    ISNULL(SCH.CostOnHandDC30,0) as [Cost On Hand DC30],
    ISNULL(SCH.CostOnHandDC33,0) as [Cost On Hand DC33],
    ISNULL(SCH.CostOnHandCourt,0) as [Cost On Hand COR],
    ISNULL(SCH.CostOnHandFort,0) as [Cost On Hand FRT],
    ISNULL(SCH.CostOnHandOak,0) as [Cost On Hand OAK],
    ISNULL(SCH.CostOnHandBroad,0) as [Cost On Hand BRD],
    ISNULL(SCH.CostOnHandSidney,0) as [Cost On Hand SID],
    ISNULL(SCH.CostOnHand3200,0) as [Cost On Hand FRN],
    ISNULL(SCH.CostOnHandDC30 + SCH.CostOnHandDC33 + SCH.CostOnHandCourt + SCH.CostOnHandFort + 
           SCH.CostOnHandOak + SCH.CostOnHandBroad + SCH.CostOnHandSidney + SCH.CostOnHand3200,0) as [Total Cost On Hand],
    CASE ITM.ITMSTA_0
        WHEN 1 THEN 'Active'
        WHEN 2 THEN 'In development'
        WHEN 3 THEN 'On shortage'
        WHEN 4 THEN 'Not renewed'
        WHEN 5 THEN 'Obsolete'
        WHEN 6 THEN 'Not usable'
    END as ItemStatus,
    ITM.CREDAT_0,
    ISNULL(SOD.AvgDeliveryDays,-1) as AvgDeliveryDays,
    ISNULL(SOD.[Number of UqO],0) as [Number of UqO],
    LCD.[1600 Last Count],
    LCD.[2100 Last Count],
    LCD.[2200 Last Count],
    LCD.[2600 Last Count]

FROM LIVE.ITMMASTER ITM
LEFT JOIN LIVE.ATEXTRA ATX ON ATX.CODFIC_0 = 'ATABDIV'
    AND ATX.IDENT1_0 = '21'
    AND ATX.ZONE_0 = 'LNGDES'
    AND ATX.LANGUE_0 = 'ENG'
    AND ATX.IDENT2_0 = ITM.TSICOD_1
LEFT JOIN SalesPrice SPL ON ITM.ITMREF_0 = SPL.PLICRI2_0 AND SPL.rn = 1 
LEFT JOIN SalesOrderData SOD ON ITM.ITMREF_0 = SOD.ITMREF_0
LEFT JOIN VendorInfo VI ON ITM.ITMREF_0 = VI.ITMREF_0
LEFT JOIN StockSafetyData SSD ON ITM.ITMREF_0 = SSD.ITMREF_0
LEFT JOIN CostData CD ON ITM.ITMREF_0 = CD.ITMREF_0
LEFT JOIN SimpleCostOnHand SCH ON ITM.ITMREF_0 = SCH.ITMREF_0
LEFT JOIN LastCountData LCD ON ITM.ITMREF_0 = LCD.ITMREF_0;