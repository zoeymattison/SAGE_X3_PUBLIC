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
        SUM(CASE WHEN STO.STOFCY_0 = '3200' THEN STO.QTYSTU_0 ELSE 0 END) AS StockTotal3200
    FROM LIVE.STOCK STO
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
open_po AS (
    select
        ITMREF_0,
        CREDAT_0,
        BPSNUM_0 + ' ' + BPSNAM_0 as [Supplier],
        QTYSTU_0-RCPQTYSTU_0 as [Quantity on PO],
        ORDDAT_0
    from (
        select
            p.ITMREF_0,
            p.CREDAT_0,
            p.BPSNUM_0,
            s.BPSNAM_0,
            p.QTYSTU_0,
            p.RCPQTYSTU_0,
            p.ORDDAT_0,
            ROW_NUMBER() over (order by p.CREDAT_0 desc) as rn
        from
            LIVE.PORDERQ p
        inner join
            LIVE.BPSUPPLIER s on p.BPSNUM_0 = s.BPSNUM_0
        where
            left(p.BPSNUM_0, 1) = 'V'
            and PRHFCY_0 = '1600'
            and LINCLEFLG_0 = 1
    ) ranked
    where rn = 1
),
last_invoice as (
    select
        ITMREF_0,
        INVDAT_0
    from (
        select
            ITMREF_0,
            INVDAT_0,
            ROW_NUMBER() over (partition by ITMREF_0 order by INVDAT_0 desc) as rn
        from
            LIVE.SINVOICED
        where
            SALFCY_0 = '1600'
    ) ranked
    where rn = 1
)

SELECT
    ITM.ITMREF_0 as Product,
    ITM.ITMDES1_0 + ' ' + ITM.ITMDES2_0 as Description,
    ISNULL(CD.[Average Cost],0) as [Average Cost],
    ISNULL(SPL.PRI_0,0) as PL2Price,
    ITM.TSICOD_0 as Status,
    ISNULL(SOD.[1600 Sales],0) as [1600 Sales 1Y],
    ISNULL(SSD.StockTotalCourt,0) as STK_1600,
    isnull(po.[Quantity on PO],0),
    isnull(po.[Supplier],''),
    po.ORDDAT_0 as [Order Date],
    li.INVDAT_0 as [Last Sold],
    ISNULL(ATX.TEXTE_0,'') as ClassName,
    ISNULL(CD.[Average Cost],0)*ISNULL(SSD.StockTotalSidney,0) as [Avg Value On Hand],
    ISNULL(VI.PrimaryVendor, 'N/A') AS PrimaryVendor,
ITM.ACCCOD_0
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
LEFT JOIN open_po po on ITM.ITMREF_0=po.ITMREF_0
LEFT JOIN last_invoice li on ITM.ITMREF_0=li.ITMREF_0