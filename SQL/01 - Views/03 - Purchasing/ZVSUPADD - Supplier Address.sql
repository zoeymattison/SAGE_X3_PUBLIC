 ( BPSNAM_0 , BPSNUM_0 , BPS_ADDR1_0 , BPS_ADDR2_0 , BPS_ADDR3_0 
 , BPS_ADDR_CC_0 , BPS_ADDR_CN_0 , BPS_ADDR_PV_0 , BPS_ADDR_POS_0 
 , BPS_ADDR_CTY_0 , BPS_ADDR_EM_0 ) As 
with supplier_address as (
	select
		iif(s.BPSNUM_0='V9999',s.BPSNAM_0,'Your Company') as [Supplier Name],
		iif(s.BPSNUM_0='V9999',a.BPANUM_0,s.BPSNUM_0) as [Supplier Number],
		iif(s.BPSNUM_0='V9999',a.BPAADDLIG_0,'ACCOUNTS PAYABLE') as [Address 1],
		iif(s.BPSNUM_0='V9999',a.BPAADDLIG_1,'123 Fake Street') as [Address 2],
		iif(s.BPSNUM_0='V9999',a.BPAADDLIG_2,'') as [Address 3],
		iif(s.BPSNUM_0='V9999',a.CRY_0,'CA') as [Country Code],
		iif(s.BPSNUM_0='V9999',a.CRYNAM_0,'CANADA') as [Country],
		iif(s.BPSNUM_0='V9999',a.SAT_0,'BC') as [Province],
		iif(s.BPSNUM_0='V9999',a.POSCOD_0,'A0A 0A0') as [Postal Code],
		iif(s.BPSNUM_0='V9999',a.CTY_0,'CITY') as [City],
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
