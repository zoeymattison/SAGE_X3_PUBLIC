 ( POHNUM_0 , ITMREFBPS_0 , QTYSTU_0 ) As 
with purchase_lines as (
	select
		q.POHNUM_0 as [Purchase Order],
		RTRIM(LTRIM(LEFT(s.ITMREFBPS_0, 
			CASE 
				WHEN CHARINDEX(' ', s.ITMREFBPS_0) > 0 THEN CHARINDEX(' ', s.ITMREFBPS_0) - 1
				WHEN CHARINDEX('(', s.ITMREFBPS_0) > 0 THEN CHARINDEX('(', s.ITMREFBPS_0) - 1
				ELSE LEN(s.ITMREFBPS_0) 
			END))) as [Supplier Product],
		sum(q.QTYSTU_0) as [Total Quantity]
	from
		LIVE.PORDERQ q
	inner join
		LIVE.ITMBPS s on q.ITMREF_0=s.ITMREF_0 and q.BPSNUM_0=s.BPSNUM_0
	group by
		q.POHNUM_0,
		s.ITMREFBPS_0
)
select
    p.[Purchase Order],
    p.[Supplier Product],
    p.[Total Quantity]
from
	purchase_lines p
