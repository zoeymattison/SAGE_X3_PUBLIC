With CreditCardInfo as (
	select
		SIHNUM_0 as [Invoice Number],
		SOHNUM_0 as [Sales Order],
		SDHNUM_0 as [Delivery Number],
		PAYNUM_0 as [Payment Number],
		ACCL4D_0 as [Last 4],
		ORIGAUTH_0 as [Original],
		AUTAMT_0 as [Authorized],
		PAYAMT_0 as [Paid],
		ATX.TEXTE_0 as [Card Type],
		LANMES_0 as [Status]
	from
		LIVE.SEAUTH
	left join
		LIVE.ATEXTRA ATX ON CRDTYP_0=ATX.IDENT2_0
		and ATX.ZONE_0 = 'LNGDES'
		and ATX.LANGUE_0 = 'ENG'
		and ATX.CODFIC_0 = 'ATABDIV'
		and ATX.IDENT1_0 = '398'
	left join
		LIVE.APLSTD APL ON STAFLG_0 = LANNUM_0
		AND LANCHP_0 = '2095'
		AND LAN_0 = 'ENG'
	where
		LANMES_0 in ('Authorized','Captured')
	group by
		SIHNUM_0,
		SOHNUM_0,
		SDHNUM_0,
		PAYNUM_0,
		ACCL4D_0,
		ATX.TEXTE_0,
		AUTAMT_0,
		ORIGAUTH_0,
		PAYAMT_0,
		LANMES_0
)
select top 100
	format(pyd.CREDATTIM_0, 'yyyy-MM-dd'),
	pyd.NUM_0 as [Payment Number],
	pyd.VCRNUM_0 as [Reference Number],
	sum(pyd.AMTLIN_0),
	isnull(cci.[Authorized],0),
	isnull(cci.[Paid],0),
	isnull(cci.[Card Type],''),
	isnull(cci.[Last 4],'')
from LIVE.PAYMENTD pyd
left join CreditCardInfo cci on pyd.NUM_0=cci.[Payment Number]

group by
pyd.CREDATTIM_0,
pyd.NUM_0,
cci.[Authorized],
cci.[Paid],
cci.[Card Type],
cci.[Last 4],
pyd.VCRNUM_0