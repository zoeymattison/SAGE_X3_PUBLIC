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
	from
		LIVE.ITMMASTER
)

select
'2-BACKORDERS',
soq.CREDAT_0 as [Date Created],
soq.SOHNUM_0 as [Sales Order],
soq.ITMREF_0 as [Product],
itm.ITMDES1_0 as [Description 1],
itm.ITMDES2_0 as [Description 2],
itm.ITMDES3_0 as [Description 3],
itm.UPCNUM_0 as [UPC Code],
itm.BASCOD_0 as [Basics Code],
itm.MNKSTA_0 as [Monk Status],
soq.QTY_0 as [Quantity Ordered],
soq.QTY_0-soq.DLVQTY_0 as [Backordered],
sop.SAU_0 as [Sales Unit],
isnull(tex.TEXTE_0,'') as [Line Text]

from LIVE.SORDERQ soq
inner join LIVE.SORDERP sop on soq.SOHNUM_0=sop.SOHNUM_0 and soq.SOPLIN_0=sop.SOPLIN_0 and soq.SOQSEQ_0=sop.SOPSEQ_0
inner join ProductInfo itm on soq.ITMREF_0=itm.ITMREF_0
left join LIVE.TEXCLOB tex on soq.SOQTEX_0=tex.CODE_0


Where soq.QTY_0-soq.DLVQTY_0>0 and soq.SOQSTA_0 in (1,2)