 ( SOHNUM_0 , SOPLIN_0 , ITMREF_0 , ITMDES_0 , QTY_0 , BKO_0 , UOM_0 
 , SUPPLIER_0 ) As 
with b2b as (
    select
        q.SOHNUM_0 as [Sales Order],
		q.SOPLIN_0 as [Line],
        q.ITMREF_0 as [Product],
        i.ITMDES1_0 as [Description],
        q.QTYSTU_0 as [Quantity],
        CASE 
            WHEN q.ALLQTY_0 <> 0 THEN 
                CASE 
                    WHEN (q.QTYSTU_0 - q.ALLQTY_0) * p.SAUSTUCOE_0 < 0 THEN 0 
                    ELSE (q.QTYSTU_0 - q.ALLQTY_0) * p.SAUSTUCOE_0 
                END
            ELSE 
                CASE 
                    WHEN ISNULL(SUM(sk.QTYSTU_0 - sk.CUMALLQTY_0), 0) = 0 THEN q.QTYSTU_0 
                    WHEN q.QTYSTU_0 - ISNULL(SUM(sk.QTYSTU_0 - sk.CUMALLQTY_0), 0) < 0 THEN 0
                    ELSE q.QTYSTU_0 - ISNULL(SUM(sk.QTYSTU_0 - sk.CUMALLQTY_0), 0) 
                END
        END as [Backordered],
        i.STU_0 as [Unit],
        s.BPSNUM_0 + ' ' + b.BPSNAM_0 as [Supplier]
    from
        LIVE.SORDERQ q
    inner join
        LIVE.SORDERP p on q.ITMREF_0 = p.ITMREF_0 and q.SOHNUM_0 = p.SOHNUM_0 and q.SOPLIN_0 = p.SOPLIN_0
    inner join
        LIVE.ITMMASTER i on q.ITMREF_0 = i.ITMREF_0
    inner join
        LIVE.SORDER h on q.SOHNUM_0 = h.SOHNUM_0
    inner join
        LIVE.ITMBPS s on q.ITMREF_0 = s.ITMREF_0 and s.PIO_0 = 0
    inner join
        LIVE.BPSUPPLIER b on s.BPSNUM_0 = b.BPSNUM_0 and b.BPSTYP_0 = 1
    left join
        LIVE.STOCK sk on q.ITMREF_0 = sk.ITMREF_0 and q.STOFCY_0 = sk.STOFCY_0
    where
        q.FMI_0 = 3
    and
        q.SOQSTA_0 <> 3
    and
        s.BPSNUM_0 not in ('V2181','V2382','V1990','V33000','V27243','V11088','V782','V121220','V2170','V19898','V2730','V2373','V950','V6160')
    and
        q.FMINUM_0 = ''
    group by 
        q.SOHNUM_0, 
		q.SOPLIN_0,
        q.ITMREF_0, 
        i.ITMDES1_0, 
        q.QTYSTU_0, 
        q.ALLQTY_0,
        p.SAUSTUCOE_0,
        i.STU_0, 
        s.BPSNUM_0, 
        b.BPSNAM_0
)
select
    b.[Sales Order],
	b.[Line],
    b.Product,
    b.Description,
    b.Quantity,
    b.Backordered,
    b.Unit,
    b.[Supplier]
from
    b2b b
where  b.Quantity=b.Backordered
