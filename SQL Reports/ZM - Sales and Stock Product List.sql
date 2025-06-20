WITH VendorInfo AS (
    SELECT
        ITMREF_0,
        ITP.BPSNUM_0,
        ITP.BPSNUM_0 + ' ' + BPS.BPSNAM_0 AS VendorName,
        ROW_NUMBER() OVER (PARTITION BY ITMREF_0 ORDER BY CASE WHEN PIO_0 = 0 THEN 0 ELSE 1 END, PIO_0) AS VendorRank
    FROM LIVE.ITMBPS ITP
    LEFT JOIN LIVE.BPSUPPLIER BPS ON BPS.BPSNUM_0 = ITP.BPSNUM_0
), ProductSites as (
	select
		ITMREF_0,
		sum(case when STOFCY_0='DC30' then SAFSTO_0 else 0 end) as [DC30 SS],
		sum(case when STOFCY_0='DC33' then SAFSTO_0 else 0 end) as [DC33 SS],
		sum(case when STOFCY_0='DC30' then REOMINQTY_0 else 0 end) as [DC30 EOQ],
		sum(case when STOFCY_0='DC33' then REOMINQTY_0 else 0 end) as [DC33 EOQ]
	from
		LIVE.ITMFACILIT
	group by
		ITMREF_0
),SalesData AS (
    SELECT
        SID.ITMREF_0,
        SUM(CASE WHEN SIV.SALFCY_0 = '1600' THEN SID.AMTNOTLIN_0 ELSE 0 END) AS SalesCourt,
        SUM(CASE WHEN SIV.SALFCY_0 = '2100' THEN SID.AMTNOTLIN_0 ELSE 0 END) AS SalesFort,
        SUM(CASE WHEN SIV.SALFCY_0 = '2600' THEN SID.AMTNOTLIN_0 ELSE 0 END) AS SalesSidney,
        SUM(CASE WHEN SIV.SALFCY_0 = '2800' THEN SID.AMTNOTLIN_0 ELSE 0 END) AS SalesIBSidney,
        SUM(CASE WHEN SIV.SALFCY_0 = '1600' THEN SID.QTYSTU_0 ELSE 0 END) AS SalesCourtQ,
        SUM(CASE WHEN SIV.SALFCY_0 = '2100' THEN SID.QTYSTU_0 ELSE 0 END) AS SalesFortQ,
        SUM(CASE WHEN SIV.SALFCY_0 = '2600' THEN SID.QTYSTU_0 ELSE 0 END) AS SalesSidneyQ,
        SUM(CASE WHEN SIV.SALFCY_0 = '2800' THEN SID.QTYSTU_0 ELSE 0 END) AS SalesIBSidneyQ
    FROM LIVE.SINVOICED SID
    LEFT JOIN LIVE.SINVOICEV SIV ON SID.NUM_0 = SIV.NUM_0
    GROUP BY SID.ITMREF_0
),
StockData AS (
    SELECT
        STO.ITMREF_0,
        SUM(CASE WHEN STO.STOFCY_0 = 'DC30' THEN STO.QTYSTU_0 ELSE 0 END) AS StockTotalDC30,
        SUM(CASE WHEN STO.STOFCY_0 = '1600' THEN STO.QTYSTU_0 ELSE 0 END) AS StockTotalCourt,
        SUM(CASE WHEN STO.STOFCY_0 = '2100' THEN STO.QTYSTU_0 ELSE 0 END) AS StockTotalFort,
        SUM(CASE WHEN STO.STOFCY_0 = '2200' THEN STO.QTYSTU_0 ELSE 0 END) AS StockTotalOak,
        SUM(CASE WHEN STO.STOFCY_0 = '2300' THEN STO.QTYSTU_0 ELSE 0 END) AS StockTotalBroad,
        SUM(CASE WHEN STO.STOFCY_0 = '2600' THEN STO.QTYSTU_0 ELSE 0 END) AS StockTotalSidney
    FROM LIVE.STOCK STO
    GROUP BY STO.ITMREF_0
)

select distinct
	itm.ITMREF_0 as [Product],
	itm.ITMDES1_0 as [Description],
	itg.TCLCOD_0+' - '+atx2.TEXTE_0 as [Category],
	isnull(atx.TEXTE_0,'') as [Class],
    MAX(CASE WHEN VI.VendorRank = 1 THEN VI.VendorName ELSE '' END) AS [Primary Supplier],
    MAX(CASE WHEN VI.VendorRank = 2 THEN VI.VendorName ELSE '' END) AS [Secondary Supplier],
	isnull(itf.[DC30 SS],0) as [DC30 SS],
	isnull(itf.[DC30 EOQ],0) as [DC30 EOQ],
	isnull(itf.[DC33 SS],0) as [DC33 SS],
	isnull(itf.[DC33 EOQ],0) as [DC33 EOQ],
	isnull(sih.SalesCourt,0) as [Sales 16],
	isnull(sih.SalesFort,0) as [Sales 21],
	isnull(sih.SalesSidney,0) as [Sales 26],
	isnull(sih.SalesIBSidney,0) as [Sales 28],
	isnull(sih.SalesCourtQ,0) as [Sales Qty 16],
	isnull(sih.SalesFortQ,0) as [Sales Qty 21],
	isnull(sih.SalesSidneyQ,0) as [Sales Qty 26],
	isnull(sih.SalesIBSidneyQ,0) as [Sales Qty 28],
	isnull(sto.StockTotalDC30,0) as [Stock 30],
	isnull(sto.StockTotalCourt,0) as [Stock 16],
	isnull(sto.StockTotalFort,0) as [Stock 21],
	isnull(sto.StockTotalOak,0) as [Stock 22],
	isnull(sto.StockTotalBroad,0) as [Stock 23],
	isnull(sto.StockTotalSidney,0) as [Stock 26]


from LIVE.ITMMASTER itm
left join LIVE.ATEXTRA atx ON atx.CODFIC_0 = 'ATABDIV'
	and atx.IDENT1_0 = '21'
	and atx.ZONE_0 = 'LNGDES'
	and atx.LANGUE_0 = 'ENG'
	and atx.IDENT2_0 = itm.TSICOD_1
left join LIVE.ITMCATEG itg on itm.TCLCOD_0=itg.TCLCOD_0
left join LIVE.ATEXTRA atx2 on atx2.CODFIC_0 = 'ITMCATEG'
	and atx2.IDENT1_0=itg.TCLCOD_0
	and atx2.ZONE_0='TCLAXX'
	and atx2.LANGUE_0='ENG'
LEFT JOIN VendorInfo VI ON itm.ITMREF_0 = VI.ITMREF_0
left join ProductSites itf on itm.ITMREF_0=itf.ITMREF_0
left join SalesData sih on itm.ITMREF_0=sih.ITMREF_0
left join StockData sto on itm.ITMREF_0=sto.ITMREF_0

where (
	sih.SalesCourtQ+
	sih.SalesFortQ+
	sih.SalesSidneyQ+
	sih.SalesIBSidneyQ
)>0 or (
	sto.StockTotalFort+
	sto.StockTotalCourt+
	sto.StockTotalSidney
)>0

group by
itm.ITMREF_0,
itm.ITMDES1_0,
itg.TCLCOD_0,
atx.TEXTE_0,
atx2.TEXTE_0,
itf.[DC30 SS],
itf.[DC30 EOQ],
itf.[DC33 SS],
itf.[DC33 EOQ],
sih.SalesCourt,
sih.SalesFort,
sih.SalesSidney,
sih.SalesIBSidney,
sih.SalesCourtQ,
sih.SalesFortQ,
sih.SalesSidneyQ,
sih.SalesIBSidneyQ,
sto.StockTotalDC30,
sto.StockTotalFort,
sto.StockTotalCourt,
sto.StockTotalOak,
sto.StockTotalBroad,
sto.StockTotalSidney