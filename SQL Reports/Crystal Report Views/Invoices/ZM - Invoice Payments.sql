With CreditCardInfo as (
	select
		PAYNUM_0 as [Payment Number],
		ACCL4D_0 as [Last 4],
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
		PAYNUM_0,
		ACCL4D_0,
		ATX.TEXTE_0,
		LANMES_0
)
select
	pyd.CREDATTIM_0,
	pyd.NUM_0 as [Payment Number],
	pyd.VCRNUM_0 as [Reference Number],
	pyd.VCRTYP_0 as [Type],
	sum(pyd.AMTLIN_0) [Payment Amount],
	isnull(cci.[Card Type],'') as [Card Type],
	isnull(cci.[Last 4],'') as [Lsat 4 Digits],
	isnull(cci.[Status],'') as [Status]
from LIVE.PAYMENTD pyd
left join CreditCardInfo cci on pyd.NUM_0=cci.[Payment Number]

group by
pyd.CREDATTIM_0,
pyd.NUM_0,
cci.[Card Type],
cci.[Last 4],
pyd.VCRNUM_0,
pyd.VCRTYP_0,
cci.[Status]