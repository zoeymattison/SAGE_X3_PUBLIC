 ( POHNUM_0 , SOHNUM_0 , BPDNAM1_0 , BPDNAM2_0 , LIG1_0 , LIG2_0 , LIG3_0 
 , CTY_0 , STUNAM_0 , PARNAM_0 , STUGRA_0 , PICKNOT_0 , ORDREF_0 ) As 
with sales_order as (
	select
		upper(p.POHNUM_0) as [Purchase Order],
		upper(s.SOHNUM_0) as [Sales Order],
		upper(s.BPDNAM_0) as [Name 1],
		upper(s.BPDNAM_1) as [Name 2],
		upper(s.BPDADDLIG_0) as [Line 1],
		upper(s.BPDADDLIG_1) as [Line 2],
		upper(s.BPDADDLIG_2) as [Line 3],
		upper(s.BPDCTY_0+' '+s.BPDSAT_0+' '+s.BPDPOSCOD_0) as [City],
		upper(s.YSTUNAM_0) as [Student],
		upper(s.YPARNAM_0) as [Parent],
		upper(s.YSTUGRA_0) as [Grade],
		upper(s.YPICKNOTE_0) as [Pick Ticket Note],
		upper(s.CUSORDREF_0) as [Reference]
	
	from
		LIVE.PORDER p
	left join
		LIVE.SORDER s on RTRIM(LEFT(p.ORDREF_0, CHARINDEX('B2B', p.ORDREF_0) - 1))=s.SOHNUM_0
)
select
	*
from 
	sales_order
