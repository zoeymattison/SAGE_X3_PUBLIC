Select
h.ACCDAT_0,
h.NUM_0,
v.BPCINV_0,
v.BPCORD_0,
a.WEB_0

from LIVE.SINVOICE h
inner join LIVE.SINVOICEV v on h.NUM_0=v.NUM_0
inner join LIVE.BPCUSTOMER b on v.BPCORD_0=b.BPCNUM_0
inner join LIVE.BPADDRESS a on b.BPCNUM_0=a.BPANUM_0 and b.BPAADD_0=a.BPAADD_0 and a.BPATYP_0=1

where b.ZSIHEML_0=2 and h.AMTATI_0<>0 and h.ZBPCEML_0<>2 and v.INVSTA_0=3 and h.UPDDAT_0>=dateadd(day,-2,cast(GETDATE() as date)) and (left(h.NUM_0,3)<>'STR' or ((left(h.NUM_0,3)='STR' and v.INVDAT_0<=dateadd(day,-1,cast(GETDATE() as date)))))