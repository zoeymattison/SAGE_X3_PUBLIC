 ( STOFCY_0 , CREDAT_0 , SHIDAT_0 , SOHNUM_0 , ITMREF_0 , ITMDES1_0 , BPSNUM_0 
 , SAU_0 , QTYORD_0 , QTYPUR_0 , QTYTO_0 , HLDSTA_0 , CDTSTA_0 , BPCORD_0 
 , BPDNAM_0 , TSICOD_0 ) As 
with b2b as (
	select
		sq.STOFCY_0 as StockSite,
		sq.CREDAT_0 as DateCreated,
		sh.SHIDAT_0 as RequiredShipDate,
		sq.SOHNUM_0 as SalesOrder,
		sq.ITMREF_0 as Product,
		sp.ITMDES_0 as Description,
		isnull(sq.YB2BBPS_0+' '+br.BPSNAM_0,'') as Supplier,
		sp.SAU_0 as Unit,
		sq.QTY_0 as Ordered,
		sum(isnull(pq.QTYSTU_0,0)) as Purchased,
		sq.QTY_0-sum(isnull(pq.QTYPUU_0,0)) as ToOrder,
		sh.HLDSTA_0,
		sh.CDTSTA_0,
		sh.BPCORD_0,
		sh.BPDNAM_0,
ir.TSICOD_0
	from
		LIVE.SORDERQ sq
	left join
		LIVE.PORDERQ pq on sq.FMINUM_0=pq.POHNUM_0 and sq.FMILIN_0=pq.POPLIN_0
	inner join
		LIVE.SORDER sh on sq.SOHNUM_0=sh.SOHNUM_0
	inner join
		LIVE.SORDERP sp on sq.SOHNUM_0=sp.SOHNUM_0 and sq.SOPLIN_0=sp.SOPLIN_0 and sq.SOQSEQ_0=sp.SOPSEQ_0
        inner join
                LIVE.ITMMASTER ir on sq.ITMREF_0=ir.ITMREF_0
	left join
		LIVE.BPSUPPLIER br on sq.YB2BBPS_0=br.BPSNUM_0
	where
		sq.FMI_0=3
	and
		sq.SOQSTA_0<>3
	and
		sq.QTY_0-isnull(pq.QTYPUU_0,0)>0
        and sq.YB2BBPS_0 not in (
            'V2181','V2382','V1990','V33000',
            'V27243','V11088','V782','V121220',
            'V2170','V19898','V2730','V2373',
            'V950','V6160','V7654','V0052',
            'V3000','V2375','V1600','V1004','','V60','V5585'
        ) and ir.TCLCOD_0<>'FFURN'
    AND LEFT(sq.ITMREF_0, 1) <> '/'
    AND LEFT(sq.ITMREF_0, 4) <> 'MUN-'
and sh.APPFLG_0<>1
	group by
		sq.STOFCY_0,
		sq.CREDAT_0,
		sh.SHIDAT_0,
		sq.SOHNUM_0,
		sq.ITMREF_0,
		sp.ITMDES_0,
		sq.YB2BBPS_0,
		br.BPSNAM_0,
		sp.SAU_0,
		sq.QTY_0,
		sh.HLDSTA_0,
		sh.CDTSTA_0,
		sh.BPCORD_0,
		sh.BPDNAM_0,
ir.TSICOD_0
)
select
b.StockSite,
b.DateCreated,
b.RequiredShipDate,
b.SalesOrder,
b.Product,
b.Description,
b.Supplier,
b.Unit,
b.Ordered,
b.Purchased,
b.ToOrder,
b.HLDSTA_0,
b.CDTSTA_0,
b.BPCORD_0,
b.BPDNAM_0,
b.TSICOD_0
from
	b2b b
