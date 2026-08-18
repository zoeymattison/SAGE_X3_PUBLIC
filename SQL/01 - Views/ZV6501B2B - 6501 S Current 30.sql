 ( ORDDAT_0 , SHIDAT_0 , BPCORD_0 , BPCNAM_0 , SOHNUM_0 , LNCNT_0 ) As 
select distinct
h.ORDDAT_0,
h.SHIDAT_0,
h.BPCORD_0,
h.BPCNAM_0,
h.SOHNUM_0,
count(q.SOPLIN_0)
from LIVE.SORDER h
inner join
	LIVE.SORDERQ q on h.SOHNUM_0=q.SOHNUM_0
where h.CDTSTA_0=1 and h.HLDSTA_0=1 and q.FMINUM_0='' and q.FMI_0=3 and q.SOQSTA_0<>3 and h.ORDSTA_0=1 and (select BPSNUM_0 from LIVE.ITMBPS b where b.ITMREF_0=q.ITMREF_0 and PIO_0=0 and CTMBPSFLG_0=2)='V6501'
group by h.SOHNUM_0,q.YB2BBPS_0,h.ORDDAT_0,
h.SHIDAT_0,
h.BPCORD_0,
h.BPCNAM_0
