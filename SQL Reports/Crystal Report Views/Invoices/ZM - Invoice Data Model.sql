with SINVOICEV as (
	select
		siv.NUM_0 as [Invoice],
		siv.SALFCY_0 as [Sales Site],
		siv.INVDAT_0 as [Invoice Date],
		siv.INVREF_0 as [Purchase Order],
		Case 
			when siv.SIHORINUM_0='' then 'Direct'
			when siv.SIHORINUM_0<>'' then siv.SIHORINUM_0
		end as [Source],
		rep.REPNAM_0 as [Sales Rep],
		siv.BPCINV_0 as [Bill-to],
		siv.BPCORD_0 as [Ship-to],
		siv.BPAADD_0 as [Address Code],
		sum(case when DTA_0 = 1 then DTAAMT_0 else 0 end) as [Invoice $ Discount],
		sum(case when DTA_0 = 10 then DTAAMT_0 else 0 end) as [Discount Percent], 
		sum(case when DTA_0 = 10 then DTANOT_0 *-1 else 0 end) as [Discount Percent-Amount], 
		sum(case when DTA_0 = 7 then DTAAMT_0 else 0 end) as [Restock Fee Amount],
		sum(case when DTA_0 = 9 then DTAAMT_0 else 0 end) as [Fuel Surharge],
		sum(case when DTA_0 = 8 then DTAAMT_0 else 0 end) as [Freight Charge],
		sum(case when DTA_0 = 5 then DTAAMT_0 else 0 end) as [EHF Fees]
	from
		LIVE.SINVOICEV siv
	left join
		LIVE.SALESREP rep on siv.REP_0=rep.REPNUM_0
	left join
		LIVE.SVCRFOOT svf on siv.NUM_0=svf.VCRNUM_0
	group by
		siv.NUM_0,
		siv.SALFCY_0,
		siv.INVDAT_0,
		siv.INVREF_0,
		siv.SIHORINUM_0,
		rep.REPNAM_0,
		siv.BPCINV_0,
		siv.BPCORD_0,
		siv.BPAADD_0
),
EDD as (
	select
		BPCNUM_0 as [Customer],
		YSENDEMAIL_0 as [EDD]
	from
		LIVE.BPCUSTOMER

),
SINVOICED as (
	select
		NUM_0 as [Invoice],
		sum(GROPRI_0*QTY_0) as [Line Amount (Before Discounts)],
		sum(AMTNOTLIN_0) as [Line Amount (After Discounts)],
		sum(case when VAT_2='EHF' then AMTTAXLIN_2 else 0 end) as [Line EHF],
		sum(Case when DISCRGVAL1_0<>0 then (GROPRI_0-NETPRI_0)*QTY_0 else 0 end) as [Line Discounts]
	from
		LIVE.SINVOICED
	group by
		NUM_0
),
SORDER as (
	select
		NUM_0 as [Invoice],
		sid.SOHNUM_0 as [Sales Order],
		apl.LANMES_0 as [Route],
		YPICKNOTE_0 as [Shipping Instructions],
		BPINAM_0 as [Bill-to Name 1],
		BPINAM_1 as [Bill-to Name 2],
		BPIADDLIG_0 as [Bill-to Addr 1],
		BPIADDLIG_1 as [Bill-to Addr 2],
		BPIADDLIG_2 as [Bill-to Addr 3],
		BPICRY_0 as [Bill-to Country Code],
		BPICRYNAM_0 as [Bill-to Country],
		BPICTY_0 as [Bill-to City],
		BPISAT_0 as [Bill-to Province],
		BPIPOSCOD_0 as [Bill-to Postal Code],
		BPDNAM_0 as [Ship-to Name 1],
		BPDNAM_1 as [Ship-to Name 2],
		BPDADDLIG_0 as [Ship-to Addr 1],
		BPDADDLIG_1 as [Ship-to Addr 2],
		BPDADDLIG_2 as [Ship-to Addr 3],
		BPDCRY_0 as [Ship-to Country Code],
		BPDCRYNAM_0 as [Ship-to Country],
		BPDCTY_0 as [Ship-to City],
		BPDSAT_0 as [Ship-to Province],
		BPDPOSCOD_0 as [Ship-to Postal Code]
	from
		LIVE.SINVOICED sid
	left join
		LIVE.SORDER soh on sid.SOHNUM_0=soh.SOHNUM_0
	left join 
		LIVE.APLSTD apl ON soh.DRN_0 = apl.LANNUM_0
		and apl.LANCHP_0 = '409'
		and apl.LAN_0 = 'ENG'
	where
		SIDLIN_0=1000
),
SALESREP as (
	select
		REPNUM_0,
		REPNAM_0
	from
		LIVE.SALESREP
),
BPADDRESS as (
	select
		bpc.BPCNAM_0 as [Customer Name],
		bpa.BPADES_0 as [Customer Description],
		bpa.BPAADD_0 as [Address Code],
		BPANUM_0 as [Customer Number],
		BPAADDLIG_0 as [Address 1],
		BPAADDLIG_1 as [Address 2],
		BPAADDLIG_2 as [Address 3],
		CRY_0 as [Country Code],
		CRYNAM_0 as [Country],
		SAT_0 as [Province],
		POSCOD_0 as [Postal Code],
		CTY_0 as [City],
		WEB_0 as [Email]
	from
		LIVE.BPADDRESS bpa
	left join
		LIVE.BPCUSTOMER bpc on bpa.BPANUM_0=bpc.BPCNUM_0
),
GACCDUDATE as (
	select
		NUM_0,
		TYP_0,
		AMTCUR_0-(PAYCUR_0+TMPCUR_0) as [Remaining]
	from
		LIVE.GACCDUDATE
),
BPDLVCUST as (
	select
		BPCNUM_0 as [Customer Number],
		BPAADD_0 as [Address Code],
		LANMES_0 as [Route],
		YCOSTCENTRE_0 as [Cost Center]
	from
		LIVE.BPDLVCUST
	left join 
		LIVE.APLSTD apl ON DRN_0 = apl.LANNUM_0
		and apl.LANCHP_0 = '409'
		and apl.LAN_0 = 'ENG'
)

select
isnull(zsiv.[Sales Site],'MAIN') as [Sales Site],
zsih.CREDAT_0 as [Creation Date],
zsih.ACCDAT_0 as [Accounting Date],
isnull(zsiv.[Invoice Date],zsih.CREDAT_0) as [Invoice Date],
zsih.NUM_0 as [Invoice],
isnull(zsoh.[Sales Order],'') as [Sales Order],
isnull(zsiv.[Source],'Direct') as [Source],
isnull(zbpd.[Cost Center],'') as [Cost Center],
case zsih.SNS_0
	when 1 then 'Invoice'
	when -1 then 'Credit Memo'
end as [Type],
isnull(zsiv.[Purchase Order],'') as [Purchase Invoice],
isnull(zsiv.[Sales Rep],''),
isnull(isnull(cast(zsoh.[Route]as varchar),cast(zbpd.[Route] as varchar)),'') as [Route],
zsih.PTE_0 as [Payment Terms],
isnull(zsoh.[Shipping Instructions],'') as [Shipping Instructions],
zsih.VAC_0 as [Tax Rule],




/* Bill-to*/
ISNULL(zsiv.[Bill-to], zsih.BPRPAY_0) as [Bill-to],
edd.EDD as [Send EDD],

ISNULL(
    isnull(zsoh.[Bill-to Name 1], zbpa1.[Customer Name]),
    zbpa3.[Customer Name]
) as [Bill-to Name 1],

ISNULL(
    isnull(zsoh.[Bill-to Name 2], zbpa1.[Customer Description]),
    zbpa3.[Customer Description]
) as [Bill-to Name 2],

ISNULL(
    isnull(
        case when zsoh.[Bill-to Addr 1] in ('~','*') then '' else zsoh.[Bill-to Addr 1] end,
        case when zbpa1.[Address 1] in ('~','*') then '' else zbpa1.[Address 1] end
    ),
    case when zbpa3.[Address 1] in ('~','*') then '' else zbpa3.[Address 1] end
) as [Bill-to Addr 1],

ISNULL(
    isnull(
        case when zsoh.[Bill-to Addr 2] in ('~','*') then '' else zsoh.[Bill-to Addr 2] end,
        case when zbpa1.[Address 2] in ('~','*') then '' else zbpa1.[Address 2] end
    ),
    case when zbpa3.[Address 2] in ('~','*') then '' else zbpa3.[Address 2] end
) as [Bill-to Addr 2],

ISNULL(
    isnull(
        case when zsoh.[Bill-to Addr 3] in ('~','*') then '' else zsoh.[Bill-to Addr 3] end,
        case when zbpa1.[Address 3] in ('~','*') then '' else zbpa1.[Address 3] end
    ),
    case when zbpa3.[Address 3] in ('~','*') then '' else zbpa3.[Address 3] end
) as [Bill-to Addr 3],

ISNULL(
    isnull(zsoh.[Bill-to Country Code], zbpa1.[Country Code]),
    zbpa3.[Country Code]
) as [Bill-to Country Code],

ISNULL(
    isnull(zsoh.[Bill-to Country], zbpa1.[Country]),
    zbpa3.[Country]
) as [Bill-to Country],

ISNULL(
    isnull(zsoh.[Bill-to City], zbpa1.[City]),
    zbpa3.[City]
) as [Bill-to City],

ISNULL(
    isnull(zsoh.[Bill-to Province], zbpa1.[Province]),
    zbpa3.[Province]
) as [Bill-to Province],

ISNULL(
    isnull(zsoh.[Bill-to Postal Code], zbpa1.[Postal Code]),
    zbpa3.[Postal Code]
) as [Bill-to Postal Code],

ISNULL(zbpa1.[Email], zbpa3.[Email]) as [Bill-to Email],

/* Ship-to */
ISNULL(zsiv.[Ship-to], '') as [Ship-to],

ISNULL(
    isnull(zsoh.[Ship-to Name 1], zbpa2.[Customer Name]),
    ''
) as [Ship-to Name 1],

ISNULL(
    isnull(zsoh.[Ship-to Name 2], zbpa2.[Customer Description]),
    ''
) as [Ship-to Name 2],

ISNULL(
    isnull(
        case when zsoh.[Ship-to Addr 1] in ('~','*') then '' else zsoh.[Ship-to Addr 1] end,
        case when zbpa2.[Address 1] in ('~','*') then '' else zbpa2.[Address 1] end
    ),
    ''
) as [Ship-to Addr 1],

ISNULL(
    isnull(
        case when zsoh.[Ship-to Addr 2] in ('~','*') then '' else zsoh.[Ship-to Addr 2] end,
        case when zbpa2.[Address 2] in ('~','*') then '' else zbpa2.[Address 2] end
    ),
    ''
) as [Ship-to Addr 2],

ISNULL(
    isnull(
        case when zsoh.[Ship-to Addr 3] in ('~','*') then '' else zsoh.[Ship-to Addr 3] end,
        case when zbpa2.[Address 3] in ('~','*') then '' else zbpa2.[Address 3] end
    ),
    ''
) as [Ship-to Addr 3],

ISNULL(
    isnull(zsoh.[Ship-to Country Code], zbpa2.[Country Code]),
    ''
) as [Ship-to Country Code],

ISNULL(
    isnull(zsoh.[Ship-to Country], zbpa2.[Country]),
    ''
) as [Ship-to Country],

ISNULL(
    isnull(zsoh.[Ship-to City], zbpa2.[City]),
    ''
) as [Ship-to City],

ISNULL(
    isnull(zsoh.[Ship-to Province], zbpa2.[Province]),
    ''
) as [Ship-to Province],

ISNULL(
    isnull(zsoh.[Ship-to Postal Code], zbpa2.[Postal Code]),
    ''
) as [Ship-to Postal Code],

ISNULL(zbpa2.[Email], '') as [Ship-to Email],

/* Pay-by */
zsih.BPRPAY_0 as [Pay-by],
zbpa3.[Customer Name] as [Pay-by Name],
zbpa3.[Customer Description] as [Pay-by Description],
case when zbpa3.[Address 1] in ('~','*') then '' else zbpa3.[Address 1] end as [Pay-by Addr 1],
case when zbpa3.[Address 2] in ('~','*') then '' else zbpa3.[Address 2] end as [Pay-by Addr 2],
case when zbpa3.[Address 3] in ('~','*') then '' else zbpa3.[Address 3] end as [Pay-by Addr 3],
zbpa3.[Country Code] as [Pay-by Country Code],
zbpa3.[Country] as [Pay-by Country],
zbpa3.[City] as [Pay-by City],
zbpa3.[Province] as [Pay-by Province],
zbpa3.[Postal Code] as [Pay-by Postal Code],
zbpa3.[Email],

/* Line Total */
isnull(zsid.[Line Amount (Before Discounts)]*zsih.SNS_0,0) as [Line Amount],

/* Discounts */
isnull(zsid.[Line Discounts]*zsih.SNS_0,0) as [Line Discounts],
isnull(zsiv.[Invoice $ Discount]*zsih.SNS_0,0) as [Invoice $ Discounts],
isnull(Case when zsiv.[Discount Percent]>0 then
(zsid.[Line Amount (After Discounts)]-zsih.AMTNOT_0)*zsih.SNS_0 else 0 end,0) as [Invoice % Discount (Amount)],
isnull(Case when zsiv.[Discount Percent]>0 then
(zsid.[Line Amount (After Discounts)]-zsih.AMTNOT_0)*zsih.SNS_0 else 0 end+(zsiv.[Invoice $ Discount]+zsid.[Line Discounts])*zsih.SNS_0,0) as [Total Discounts],

/* Invoicing Elements */
isnull(zsiv.[Freight Charge]*zsih.SNS_0,0) as [Freight Charge],
isnull(zsiv.[Fuel Surharge]*zsih.SNS_0,0) as [Fuel surcharge],
isnull(zsiv.[Restock Fee Amount]*zsih.SNS_0,0) as [Restocking fee],

/* Totals */
isnull((zsih.AMTNOT_0-zsiv.[Freight Charge]-zsiv.[Fuel Surharge])*zsih.SNS_0,0) as [Subtotal],

/* EHF */
isnull(zsid.[Line EHF],0) as [Line EHF],

/* GST */
CASE
	when TAX_0='GST' and TAX_1<>'TAX' and TAX_2<>'TAX' and TAX_3<>'TAX' then AMTTAX_0*zsih.SNS_0
	when TAX_0='GST' and 'TAX' in (TAX_1,TAX_2,TAX_3) then (AMTTAX_0+(zsiv.[Fuel Surharge]*0.05))*zsih.SNS_0
	else 0
end as [GST Amount],

/* PST */
CASE
	when TAX_1='BCPST' and TAX_2<>'TAX' and TAX_3<>'TAX' then AMTTAX_1*zsih.SNS_0
	when TAX_2='BCPST' and TAX_3<>'TAX' then AMTTAX_2*zsih.SNS_0
	when TAX_1='BCPST' and 'TAX' in (TAX_2,TAX_3) then (AMTTAX_1+(zsiv.[Fuel Surharge]*0.07))*zsih.SNS_0
	when TAX_2='BCPST' and TAX_3='TAX' then (AMTTAX_2+(zsiv.[Fuel Surharge]*0.07))*zsih.SNS_0
	else 0
end as [PST Amount],

zsih.AMTATI_0*zsih.SNS_0 as [Total+Tax],

/* Invoice Status */
zdud.[Remaining]*zsih.SNS_0,
case
	when zdud.[Remaining]<>0 then 2
	when zdud.[Remaining]=0 then 1
end as [Outstanding],
zsih.GTE_0 as [Type],
'',

/* Comments */
zsih.BPRVCR_0,
zsih.DES_0+' '+zsih.DES_1+' '+zsih.DES_2+' '+zsih.DES_3+' '+zsih.DES_4

from LIVE.SINVOICE zsih
left join SINVOICEV zsiv on zsih.NUM_0=zsiv.[Invoice]
left join SINVOICED zsid on zsih.NUM_0=zsid.[Invoice]
left join SORDER zsoh on zsih.NUM_0=zsoh.[Invoice]
left join BPADDRESS zbpa1 on zsiv.[Address Code]=zbpa1.[Address Code] and zsiv.[Bill-to]=zbpa1.[Customer Number]
left join BPADDRESS zbpa2 on zsiv.[Address Code]=zbpa2.[Address Code] and zsiv.[Ship-to]=zbpa2.[Customer Number]
inner join BPADDRESS zbpa3 on zsih.BPAPAY_0=zbpa3.[Address Code] and zsih.BPRPAY_0=zbpa3.[Customer Number]
inner join GACCDUDATE zdud on zsih.NUM_0=zdud.NUM_0 and zsih.GTE_0=zdud.TYP_0
left join BPDLVCUST zbpd on zsiv.[Address Code]=zbpd.[Address Code] and zsiv.[Ship-to]=zbpd.[Customer Number]
inner join EDD edd on ISNULL(zsiv.[Bill-to], zsih.BPRPAY_0)=edd.[Customer]