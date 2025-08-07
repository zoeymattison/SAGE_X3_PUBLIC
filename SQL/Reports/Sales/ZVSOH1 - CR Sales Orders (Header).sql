with BPDLVCUST as (
	select
		BPCNUM_0 as [Customer Number],
		BPAADD_0 as [Address Code],
		YCOSTCENTRE_0 as [Cost Center]
	from
		LIVE.BPDLVCUST
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
SORDERLINE as (
	select
		soq.SOHNUM_0 as [Sales Order],
		sum(sop.GROPRI_0*soq.QTY_0) as [Line Amount (Before Discounts)],
		sum(sop.NETPRI_0*soq.QTY_0) as [Line Amount (After Discounts)],
		sum(case when VACITM_2='EHF' then CLCAMT1_0 else 0 end) as [Line EHF],
		sum(Case when DISCRGVAL1_0<>0 then (GROPRI_0-NETPRI_0)*QTY_0 else 0 end) as [Line Discounts]
	from
		LIVE.SORDERQ soq
	inner join
		LIVE.SORDERP sop on soq.SOHNUM_0=sop.SOHNUM_0 and soq.SOPLIN_0=sop.SOPLIN_0 and soq.SOQSEQ_0=sop.SOPSEQ_0
	group by
		soq.SOHNUM_0
),
SVCRFOOT as (
	select
		VCRNUM_0,
		sum(case when DTA_0 = 1 then DTAAMT_0 else 0 end) as [SO Discount],
		sum(case when DTA_0 = 10 then DTAAMT_0 else 0 end) as [SO Discount Percent], 
		sum(case when DTA_0 = 10 then DTANOT_0 *-1 else 0 end) as [SO Discount Percent-Amount], 
		sum(case when DTA_0 = 9 then DTAAMT_0 else 0 end) as [SO Fuel Surharge],
		sum(case when DTA_0 = 8 then DTAAMT_0 else 0 end) as [SO Freight Charge],
		sum(case when DTA_0 = 5 then DTAAMT_0 else 0 end) as [SO EHF Fees]
	from
		LIVE.SVCRFOOT
	group by VCRNUM_0
),
SVCRVAT as (
	select
		VCRNUM_0,
		sum(case when VAT_0='TAX' and VATRAT_0=12 then 0.25 else 0 end) as [Fuel Tax GST],
		sum(case when VAT_0='TAX' and VATRAT_0=12 then 0.35 else 0 end) as [Fuel Tax PST],
		sum(case when VAT_0='GST' then AMTTAX_0 else 0 end) as [GST],
		sum(case when VAT_0='BCPST' then AMTTAX_0 else 0 end) as [PST]
	from
		LIVE.SVCRVAT
	group by
		VCRNUM_0
),
TEXCLOB as (
	select
		CODE_0,
		TEXTE_0
	from LIVE.TEXCLOB
),
GACCDUDATE as (
	select
		NUM_0,
		TYP_0,
		AMTCUR_0-(PAYCUR_0+TMPCUR_0) as [Remaining]
	from
		LIVE.GACCDUDATE
	where TYP_0='*SO'
)

select
	soh.SALFCY_0 as [Sales Site],
	soh.CREDAT_0 as [Creation Date],
	soh.ORDDAT_0 as [Order Date],
	soh.SHIDAT_0 as [Shipping Date],
	soh.SOHNUM_0 as [Order Number],
	isnull(bpd.[Cost Center],'') as [Cost Center],
	soh.CUSORDREF_0 as [Purchase Order],
	isnull(rep.REPNAM_0,'') as [Sales Rep],
	apl.LANMES_0 as [Route],
	soh.PTE_0 as [Payment Term],
	soh.YPICKNOTE_0 as [Shipping Instructions],
	soh.VACBPR_0 as [Tax Rule],

	/* BILL-TO */

	case soh.BPCINV_0
		when soh.BPCPYR_0 then soh.BPCINV_0
		else soh.BPCPYR_0
	end as [Bill To],

	case soh.BPCINV_0
		when soh.BPCPYR_0 then soh.BPINAM_0
		else bpa.[Customer Name]
	end as [Bill-to Name 1],

	case soh.BPCINV_0
		when soh.BPCPYR_0 then soh.BPINAM_1
		else bpa.[Customer Description]
	end as [Bill-to Name 2],

	case soh.BPCINV_0
		when soh.BPCPYR_0 then case when soh.BPIADDLIG_0 in ('~','*') then '' else soh.BPIADDLIG_0 end
		else case when bpa.[Address 1] in ('~','*') then '' else bpa.[Address 1] end
	end as [Bill-to Address 1],

	case soh.BPCINV_0
		when soh.BPCPYR_0 then case when soh.BPIADDLIG_1 in ('~','*') then '' else soh.BPIADDLIG_1 end
		else case when bpa.[Address 2] in ('~','*') then '' else bpa.[Address 2] end
	end as [Bill-to Address 2],

	case soh.BPCINV_0
		when soh.BPCPYR_0 then case when soh.BPIADDLIG_2 in ('~','*') then '' else soh.BPIADDLIG_2 end
		else case when bpa.[Address 3] in ('~','*') then '' else bpa.[Address 3] end
	end as [Bill-to Address 3],

	case soh.BPCINV_0
		when soh.BPCPYR_0 then soh.BPICRY_0
		else bpa.[Country Code]
	end as [Bill-to Country Code],

	case soh.BPCINV_0
		when soh.BPCPYR_0 then soh.BPICRYNAM_0
		else bpa.[Country]
	end as [Bill-to Country],

	case soh.BPCINV_0
		when soh.BPCPYR_0 then soh.BPICTY_0
		else bpa.[City]
	end as [Bill-to City],

	case soh.BPCINV_0
		when soh.BPCPYR_0 then soh.BPISAT_0
		else bpa.[Province]
	end as [Bill-to Province],

	case soh.BPCINV_0
		when soh.BPCPYR_0 then soh.BPIPOSCOD_0
		else bpa.[Postal Code]
	end as [Bill-to Postal Code],

	case soh.BPCINV_0
		when soh.BPCPYR_0 then bpa2.[Email]
		else bpa.[Email]
	end as [Bill-to Email],

	/* SHIP-TO*/

	soh.BPCORD_0 as [Ship-to],
	case when soh.BPDNAM_0 in ('~','*') then '' else soh.BPDNAM_0 end as [Ship-to Name 1],
	case when soh.BPDNAM_1 in ('~','*') then '' else soh.BPDNAM_1 end as [Ship-to Name 2],
	case when soh.BPDADDLIG_0 in ('~','*') then '' else soh.BPDADDLIG_0 end as [Ship-to Address 1],
	case when soh.BPDADDLIG_1 in ('~','*') then '' else soh.BPDADDLIG_1 end as [Ship-to Address 2],
	case when soh.BPDADDLIG_2 in ('~','*') then '' else soh.BPDADDLIG_2 end as [Ship-to Address 3],
	soh.BPDCRY_0 as [Ship-to Country Code],
	soh.BPDCRYNAM_0 as [Ship-to Country],
	soh.BPDCTY_0 as [Ship-to City],
	soh.BPDSAT_0 as [Ship-to Province],
	soh.BPDPOSCOD_0 as [Ship-to Postal Code],
	bpa3.[Email],

	/* DISCOUNTS */
	sol.[Line Discounts],
	isnull(svf.[SO Discount]+svf.[SO Discount Percent-Amount],0) as [SO Discounts],
	isnull(sol.[Line Discounts]+svf.[SO Discount]+svf.[SO Discount Percent-Amount],0) as [Total Discounts],

	/* INVOICING ELEMENTS */
	isnull(svf.[SO Freight Charge],0),
	isnull(svf.[SO Fuel Surharge],0),

	/* TOTALS */
	sol.[Line Amount (Before Discounts)] as [Lines Before Discounts],
	soh.ORDINVNOT_0 as [Subtotal After Discounts],
	sol.[Line EHF],
	isnull(svt.[GST]+svt.[Fuel Tax GST],0) as [GST],
	isnull(svt.[PST]+svt.[Fuel Tax PST],0) as [PST],
	soh.ORDINVATI_0 as [Total],
	isnull(dud.Remaining,soh.ORDINVATI_0) as [Owing],

	/* TEXT */
	isnull(texh.TEXTE_0,'') as [Header Text],
	isnull(texf.TEXTE_0,'') as [Footer Text]


from
	LIVE.SORDER soh
left join
	SALESREP rep on soh.REP_0=rep.REPNUM_0
left join
	BPDLVCUST bpd on soh.BPAADD_0=bpd.[Address Code] and soh.BPCORD_0=bpd.[Customer Number]
left join
	BPADDRESS bpa on soh.BPAPYR_0=bpa.[Address Code] and soh.BPCPYR_0=bpa.[Customer Number]
left join
	BPADDRESS bpa2 on soh.BPAINV_0=bpa2.[Address Code] and soh.BPCINV_0=bpa2.[Customer Number]
left join
	BPADDRESS bpa3 on soh.BPAADD_0=bpa3.[Address Code] and soh.BPCORD_0=bpa3.[Customer Number]
left join 
	LIVE.APLSTD apl ON soh.DRN_0 = apl.LANNUM_0
	and apl.LANCHP_0 = '409'
	and apl.LAN_0 = 'ENG'
left join
	SORDERLINE sol on soh.SOHNUM_0=sol.[Sales Order]
left join
	SVCRFOOT svf on soh.SOHNUM_0=svf.VCRNUM_0
left join
	SVCRVAT svt on soh.SOHNUM_0=svt.VCRNUM_0
left join
	TEXCLOB texh on soh.SOHTEX1_0=texh.CODE_0
left join
	TEXCLOB texf on soh.SOHTEX2_0=texf.CODE_0
left join
	GACCDUDATE dud on soh.SOHNUM_0=dud.NUM_0