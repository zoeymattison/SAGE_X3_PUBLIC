With CreditCardInfo as (
	select
		PAYNUM_0 as [Payment Number],
		ACCL4D_0 as [Last 4],
		case ATX.TEXTE_0 
			when 'American Express' then 'American Exp.'
			When 'Master Card' then 'Mastercard'
			else ATX.TEXTE_0
		end as [Card Type],
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
), InvoiceSign as (
	select
		NUM_0,
		SNS_0
	from
		LIVE.SINVOICE
)
select
	pyd.CREDATTIM_0,
	pyd.NUM_0 as [Payment Number],
	pyd.VCRNUM_0 as [Reference Number],
	pyd.VCRTYP_0 as [Type],
	sum(pyd.AMTLIN_0) [Payment Amount],
	isnull(cci.[Card Type],'') as [Card Type],
	isnull(cci.[Last 4],'') as [Lsat 4 Digits],
	isnull(cci.[Status],'') as [Status],
case
    when left(pyd.NUM_0,5) in ('RECWT','RECC1','RECCC','PAYC1','PAYCC','RECCH','RECPP') or left(pyd.NUM_0,2)='IP'
        then sum(pyd.AMTLIN_0) * 
            case
                when sih.SNS_0 = 1 then 1
                when sih.SNS_0 = -1 then -1
                else 1
            end

    else 0
end as [PaymentAmt],
case
    when left(pyd.NUM_0,5) = 'RECWT' then 'Electronic Funds Tfr.'
    when left(pyd.NUM_0,5) in ('RECC1','PAYC1','PAYCC') 
        then cci.[Card Type] + ' **' + cast(cci.[Last 4] as varchar)
    when left(pyd.NUM_0,5) = 'RECCH' then 'Cheque ' + pyh.CHQNUM_0
    when left(pyd.NUM_0,5) = 'RECPP' then 'PayPal'
    when left(pyd.NUM_0,2) = 'IP' then 'Retail POS'
	when left(pyd.NUM_0,5) = 'RECDB' then 'In-Person Debit'
	when left(pyd.NUM_0,5) = 'RECCC' then 'Single Use Card'
    else ''
end as [PamType],
	case
		when sih.SNS_0=1 then 'Payment'
		when pyd.VCRTYP_0 =' ' then 'Prepay'
		when sih.SNS_0=-1 then 'Credit'
		else 'Payment'
	end as [Sign]
from LIVE.PAYMENTD pyd
left join CreditCardInfo cci on pyd.NUM_0=cci.[Payment Number]
left join LIVE.PAYMENTH pyh on pyd.NUM_0=pyh.NUM_0
left join InvoiceSign sih on pyd.VCRNUM_0=sih.NUM_0
Where pyd.VCRNUM_0 <>''
group by
pyd.CREDATTIM_0,
pyd.NUM_0,
cci.[Card Type],
cci.[Last 4],
pyd.VCRNUM_0,
pyd.VCRTYP_0,
cci.[Status],
pyh.CHQNUM_0,
sih.SNS_0