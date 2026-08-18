 ( SOHNUM_0 , LANMES_0 ) As 
Select
SOHNUM_0,
LANMES_0
from
LIVE.SORDER s
inner join
		LIVE.APLSTD a on s.DRN_0=LANNUM_0
	    and LANCHP_0 = '409'
		and a.LAN_0 = 'ENG'
