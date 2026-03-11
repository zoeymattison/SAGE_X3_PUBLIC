with supplier_address as (
	select
		iif(s.BPSNUM_0='V9999',s.BPSNAM_0,'MONK OFFICE') as [Supplier Name],
		iif(s.BPSNUM_0='V9999',a.BPANUM_0,s.BPSNUM_0) as [Supplier Number],
		iif(s.BPSNUM_0='V9999',a.BPAADDLIG_0,'ACCOUNTS PAYABLE') as [Address 1],
		iif(s.BPSNUM_0='V9999',a.BPAADDLIG_1,'800 VIEWFIELD ROAD') as [Address 2],
		iif(s.BPSNUM_0='V9999',a.BPAADDLIG_2,'') as [Address 3],
		iif(s.BPSNUM_0='V9999',a.CRY_0,'CA') as [Country Code],
		iif(s.BPSNUM_0='V9999',a.CRYNAM_0,'CANADA') as [Country],
		iif(s.BPSNUM_0='V9999',a.SAT_0,'BC') as [Province],
		iif(s.BPSNUM_0='V9999',a.POSCOD_0,'V9A 4V1') as [Postal Code],
		iif(s.BPSNUM_0='V9999',a.CTY_0,'VICTORIA') as [City],
		iif(s.BPSNUM_0='V9999',a.WEB_0,'') as [Email]
	from
		LIVE.BPADDRESS a
	inner join
		LIVE.BPSUPPLIER s on a.BPANUM_0=s.BPSNUM_0
	where
		BPATYP_0=1 and a.BPAADD_0='REMIT'
)
select
	[Supplier Name],
	[Supplier Number],
	[Address 1],
	[Address 2],
	[Address 3],
	[Country Code],
	[Country],
	[Province],
	[Postal Code],
	[City],
	[Email]
from
	supplier_address
