with invoice_lines as (
	select
		d.ITMREF_0,
		d.INVDAT_0,
		v.BPCORD_0+' - '+b.BPCNAM_0 as [Customer],
		d.NUM_0,
		d.SOHNUM_0,
		d.QTYSTU_0,
		d.GROPRI_0,
		d.AMTNOTLIN_0,
		FCY_0,
		cast(CREDATTIM_0 as datetime) as [Datetime]
	from
		(select ITMREF_0, INVDAT_0,NUM_0,SOHNUM_0,QTYSTU_0,GROPRI_0,AMTNOTLIN_0 from LIVE.SINVOICED) d
	inner join
		(select BPCORD_0,NUM_0 from LIVE.SINVOICEV) v on d.NUM_0=v.NUM_0
	inner join
		(select BPCNUM_0,BPCNAM_0,BPCTYP_0 from LIVE.BPCUSTOMER) b on v.BPCORD_0=b.BPCNUM_0 and BPCTYP_0=1
	inner join
		(select NUM_0,CREDATTIM_0,FCY_0 from LIVE.SINVOICE) h on v.NUM_0=h.NUM_0
	where
		d.INVDAT_0>=dateadd(year,-1,cast(GETDATE() as date))
		and FCY_0='DC30'
		
)
select
ITMREF_0,
INVDAT_0,
[Customer],
NUM_0,
SOHNUM_0,
QTYSTU_0,
GROPRI_0,
AMTNOTLIN_0,
FCY_0,
[Datetime]


from
invoice_lines