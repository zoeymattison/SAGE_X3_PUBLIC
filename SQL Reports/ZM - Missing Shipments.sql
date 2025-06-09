SELECT
pth.CREDAT_0 as [Date],
pth.ZLTCOUR_0 as [Courier],
pth.BPSNUM_0+' '+bps.BPSNAM_0 as [Supplier],
poh.POHNUM_0 as [Purchase Order],
poh.OCNNUM_0 as [Supplier Order],
pth.PTHNUM_0 as [Receipt],
pth.ZBOXEXP_0 as [Boxes Expected],
pth.ZBOXRCP_0 as [Boxes Arrived],
pth.ZBOXEXP_0-pth.ZBOXRCP_0 as [Total Missing],
pth.PTHNUM_0+cast(format(pth.CREDATTIM_0,'yyyyMMddHHmmss') as varchar) as [UniqueKey]

FROM LIVE.PRECEIPT pth
inner join LIVE.BPSUPPLIER bps on pth.BPSNUM_0=bps.BPSNUM_0
inner join LIVE.PORDER poh on pth.ZPOHNUM_0=poh.POHNUM_0

Where pth.ZLTEFLG_0=2

order by pth.CREDAT_0 desc