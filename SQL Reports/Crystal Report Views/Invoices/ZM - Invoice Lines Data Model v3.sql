--'DIR474034'

with ProductInfo as (
    select
        ITMREF_0,
        ITMDES1_0,
        ITMDES2_0,
        ITMDES3_0,
        EANCOD_0 as UPCNUM_0,
        SEAKEY_0 as BASCOD_0,
        TSICOD_0 as MNKSTA_0,
        TSICOD_2 as EHFCOD_0
    from LIVE.ITMMASTER
),
SORDERQ_Lines as (
    select
        q.SOHNUM_0,
        q.SOPLIN_0,
        q.ITMREF_0,
        q.QTY_0 - q.DLVQTY_0 as Backordered,
        q.QTY_0 as Ordered,
        tex.TEXTE_0 as [Line Text]
    from LIVE.SORDERQ q
    left join LIVE.TEXCLOB tex ON q.SOQTEX_0 = tex.CODE_0
)

-- Invoiced block
select
    sid.CREDAT_0 as [Date Created],
    sid.INVDAT_0 as [Invoice Date],
    sid.NUM_0 as [Invoice],
    sid.SOHNUM_0 as [Sales Order],
    sid.ITMREF_0 as [Product],
    itm.ITMDES1_0 as [Description 1],
    itm.ITMDES2_0 as [Description 2],
    itm.ITMDES3_0 as [Description 3],
    itm.UPCNUM_0 as [UPC Code],
    itm.BASCOD_0 as [Basics Code],
    itm.MNKSTA_0 as [Monk Status],
    sid.QTY_0 * sih.SNS_0 as [Invoiced Quantity],
    isnull(ibo.Ordered * sih.SNS_0, 0) as [Ordered Quantity],
    isnull(ibo.Backordered * sih.SNS_0, 0) as [Backordered],
    sid.SAU_0 as [Sales Unit],
    sid.GROPRI_0 * sih.SNS_0 as [Gross Price],
    sid.CPRPRI_0 * sih.SNS_0 as [Cost Price],
    cast(cast(DISCRGVAL1_0 * sih.SNS_0 as decimal(18,2)) as varchar) + '%' as [Discount],
    NETPRI_0 * QTY_0 * sih.SNS_0 as [Total],
    isnull(tex.TEXTE_0, '') as [INV Line Text],
    isnull(ibo.[Line Text], '') as [SOH Line Text]
from LIVE.SINVOICED sid
inner join LIVE.SINVOICE sih on sid.NUM_0 = sih.NUM_0
inner join ProductInfo itm on sid.ITMREF_0 = itm.ITMREF_0
left join LIVE.TEXCLOB tex on sid.SIDTEX_0 = tex.CODE_0
left join SORDERQ_Lines ibo on sid.SOHNUM_0 = ibo.SOHNUM_0 and sid.SOPLIN_0 = ibo.SOPLIN_0 and sid.ITMREF_0 = ibo.ITMREF_0

Where sid.NUM_0='DIR474034'

UNION ALL

select
    null as [Date Created],
    null as [Invoice Date],
    null as [Invoice],
    s.SOHNUM_0,
    s.ITMREF_0,
    itm.ITMDES1_0,
    itm.ITMDES2_0,
    itm.ITMDES3_0,
    itm.UPCNUM_0,
    itm.BASCOD_0,
    itm.MNKSTA_0,
    0 as [Invoiced Quantity],
    s.Ordered,
    s.Backordered,
    null as [Sales Unit],
    null as [Gross Price],
    null as [Cost Price],
    null as [Discount],
    null as [Total],
    null as [INV Line Text],
    s.[Line Text]
from SORDERQ_Lines s
left join ProductInfo itm on s.ITMREF_0 = itm.ITMREF_0
where
    -- Ensure the sales order exists in SINVOICED at all (for any line)
    s.SOHNUM_0 IN (SELECT DISTINCT SOHNUM_0 FROM LIVE.SINVOICED WHERE NUM_0 = 'DIR474034')
    -- And the specific sales order line (product and line number) does NOT exist in SINVOICED for that SOHNUM_0
    and not exists (
        select 1
        from LIVE.SINVOICED i
        where i.SOHNUM_0 = s.SOHNUM_0
          and i.ITMREF_0 = s.ITMREF_0 -- This is the crucial part for "product does not exist"
          and i.SOPLIN_0 = s.SOPLIN_0 -- Keep this for exact line matching
    )
