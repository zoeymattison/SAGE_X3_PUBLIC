 ( POHNUM_0 , ADDRESS_0 ) As 
with po_header as (
	select
		h.POHNUM_0 as [Purchase Order],
		upper(
			isnull(
				t.TEXTE_0,
				'MONK OFFICE' +
				case when nullif(ltrim(rtrim(b.BPAADDLIG_0)), '') is not null then char(10) + ltrim(rtrim(b.BPAADDLIG_0)) else '' end +
				case when nullif(ltrim(rtrim(b.BPAADDLIG_1)), '') is not null then char(10) + ltrim(rtrim(b.BPAADDLIG_1)) else '' end +
				case when nullif(ltrim(rtrim(b.BPAADDLIG_2)), '') is not null then char(10) + ltrim(rtrim(b.BPAADDLIG_2)) else '' end +
				case 
					when nullif(ltrim(rtrim(b.CTY_0)), '') is not null or nullif(ltrim(rtrim(b.POSCOD_0)), '') is not null 
					then char(10) + ltrim(rtrim(isnull(b.CTY_0, ''))) + ' ' + ltrim(rtrim(isnull(b.POSCOD_0, '')))
					else '' 
				end +
				char(10) + 'CANADA'
			)
		) as [Receiving Address]
	from
		LIVE.PORDER h
	left join
		LIVE.TEXCLOB t on h.TEX2_0=t.CODE_0
	left join
		LIVE.FACILITY f on h.POHFCY_0=f.FCY_0
	left join
		LIVE.BPADDRESS b on f.FCY_0=b.BPANUM_0 and f.BPAADD_0=b.BPAADD_0 and b.BPATYP_0=3 
)
select
	po.[Purchase Order],
	po.[Receiving Address]
from 
	po_header po
