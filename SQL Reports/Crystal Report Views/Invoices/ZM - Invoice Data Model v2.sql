with SINVOICEV as (
	select
		siv.NUM_0 as [Invoice],
		siv.SALFCY_0 as [Sales Site],
		siv.INVDAT_0 as [Invoice Date],
		siv.INVREF_0 as [Purchase Order],
		siv.SIHORINUM_0 as [Source],
		rep.REPNAM_0 as [Sales Rep],
		siv.BPCINV_0 as [Bill-to],
		siv.BPCORD_0 as [Ship-to],
		siv.BPAADD_0 as [Address Code],
		sum(case when DTA_0 = 1 then DTAAMT_0 else 0 end) as [Discount Amount],
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
SINVOICED as (
	select
		NUM_0 as [Invoice],
		sum(AMTNOTLIN_0) as [Line Amount],
		sum(case when VAT_0='GST' then AMTNOTLIN_0*0.05 else 0 end) as [Line GST],
		sum(case when VAT_1='BCPST' then AMTNOTLIN_0*0.07 else 0 end) as [Line PST],
		sum(case when VAT_2='EHF' then AMTTAXLIN_2 else 0 end) as [Line EHF]
	from
		LIVE.SINVOICED
	group by
		NUM_0
),
SORDER as (
	select
		NUM_0 as [Invoice],
		sid.SOHNUM_0 as [Sales Order],
		apl.LANNUM_0 as [Route],
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
zsiv.[Sales Site],
zsih.CREDAT_0 as [Creation Date],
zsih.ACCDAT_0 as [Accounting Date],
zsiv.[Invoice Date],
zsih.NUM_0 as [Invoice],
zsoh.[Sales Order],
zsiv.[Source],
zbpd.[Cost Center],
case zsih.SNS_0
	when 1 then 'Invoice'
	when -1 then 'Credit Memo'
end as [Type],
zsiv.[Purchase Order],
isnull(zsiv.[Sales Rep],''),
isnull(cast(zsoh.[Route]as varchar),cast(zbpd.[Route] as varchar)) as [Route],
zsih.PTE_0 as [Payment Terms],
isnull(zsoh.[Shipping Instructions],'') as [Shipping Instructions],
zsih.VAC_0 as [Tax Rule],




/* Bill-to*/
zsiv.[Bill-to],
isnull(zsoh.[Bill-to Name 1],zbpa1.[Customer Name]) as [Bill-to Name 1],
isnull(zsoh.[Bill-to Name 2],zbpa1.[Customer Description]) as [Bill-to Name 2],
isnull(case when zsoh.[Bill-to Addr 1] in ('~','*') then '' else zsoh.[Bill-to Addr 1] end,case when zbpa1.[Address 1] in ('~','*') then '' else zbpa1.[Address 1] end) as [Bill-to Addr 1],
isnull(case when zsoh.[Bill-to Addr 2] in ('~','*') then '' else zsoh.[Bill-to Addr 2] end,case when zbpa1.[Address 2] in ('~','*') then '' else zbpa1.[Address 2] end) as [Bill-to Addr 2],
isnull(case when zsoh.[Bill-to Addr 3] in ('~','*') then '' else zsoh.[Bill-to Addr 3] end,case when zbpa1.[Address 3] in ('~','*') then '' else zbpa1.[Address 3] end) as [Bill-to Addr 3],
isnull(zsoh.[Bill-to Country Code],zbpa1.[Country Code]) as [Bill-to Country Code],
isnull(zsoh.[Bill-to Country],zbpa1.[Country]) as [Bill-to Country],
isnull(zsoh.[Bill-to City],zbpa1.[City]) as [Bill-to City],
isnull(zsoh.[Bill-to Province],zbpa1.[Province]) as [Bill-to Province],
isnull(zsoh.[Bill-to Postal Code],zbpa1.[Postal Code]) as [Bill-to Postal code],
zbpa1.[Email],

/* Ship-to */
zsiv.[Ship-to],
isnull(zsoh.[Ship-to Name 1],zbpa2.[Customer Name]) [Ship-to Name 1],
isnull(zsoh.[Ship-to Name 2],zbpa2.[Customer Description]) as [Ship-to Name 2],
isnull(case when zsoh.[Ship-to Addr 1] in ('~','*') then '' else zsoh.[Ship-to Addr 1] end,case when zbpa2.[Address 1] in ('~','*') then '' else zbpa2.[Address 1] end) as [Ship-to Addr 1],
isnull(case when zsoh.[Ship-to Addr 2] in ('~','*') then '' else zsoh.[Ship-to Addr 2] end,case when zbpa2.[Address 2] in ('~','*') then '' else zbpa2.[Address 2] end) as [Ship-to Addr 2],
isnull(case when zsoh.[Ship-to Addr 3] in ('~','*') then '' else zsoh.[Ship-to Addr 3] end,case when zbpa2.[Address 3] in ('~','*') then '' else zbpa2.[Address 3] end) as [Ship-to Addr 3],
isnull(zsoh.[Ship-to Country Code],zbpa2.[Country Code]) as [Ship-to Country Code],
isnull(zsoh.[Ship-to Country],zbpa2.[Country]) as [Ship-to Country],
isnull(zsoh.[Ship-to City],zbpa2.[City]) as [Ship-to City],
isnull(zsoh.[Ship-to Province],zbpa2.[Province]) as [Ship-to Province],
isnull(zsoh.[Ship-to Postal Code],zbpa2.[Postal Code]) as [Ship-to Postal Code],
zbpa2.[Email],

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

/* Invoicing Elements */
zsiv.[Discount Amount],
zsiv.[Discount Percent],
zsiv.[Discount Percent-Amount],
zsiv.[EHF Fees],
zsiv.[Freight Charge],
zsiv.[Fuel Surharge],

/* Taxes */
/*round(zsid.[Line GST],2) as [Line GST],
round(zsid.[Line PST],2) as [Line PST],*/
round(zsid.[Line EHF],2) as [Line EHF],/*
round(case when zsih.VAC_0 in ('BC','BCX') then zsid.[Line EHF]*0.05 end,2) as [EHF GST],
round(isnull(case zsih.VAC_0 when 'BC' then zsid.[Line EHF]*0.07 end,0),2) as [EHF PST],
round(case when zsih.VAC_0 in ('BC','BCX') then zsiv.[Fuel Surharge]*0.05 end,2) as [Fuel Charge GST],
round(isnull(case zsih.VAC_0 when 'BC' then zsiv.[Fuel Surharge]*0.07 end,0),2) as [Fuel Charge PST],
round(case when zsih.VAC_0 in ('BC','BCX') then zsiv.[Freight Charge]*0.05 end,2) as [Freight Charge GST],*/
round(zsid.[Line GST]+case when zsih.VAC_0 in ('BC','BCX') then zsiv.[Fuel Surharge]*0.05 end+case when zsih.VAC_0 in ('BC','BCX') then zsiv.[Freight Charge]*0.05 end+case when zsih.VAC_0 in ('BC','BCX') then zsid.[Line EHF]*0.05 end,2) as [GST Total],
round(zsid.[Line PST]+isnull(case zsih.VAC_0 when 'BC' then zsiv.[Fuel Surharge]*0.07 end,0)+isnull(case zsih.VAC_0 when 'BC' then zsid.[Line EHF]*0.07 end,0),2) as [PST Total],
/*round(zsid.[Line GST]+case when zsih.VAC_0 in ('BC','BCX') then zsiv.[Fuel Surharge]*0.05 end+case when zsih.VAC_0 in ('BC','BCX') then zsiv.[Freight Charge]*0.05 end+zsid.[Line PST]+isnull(case zsih.VAC_0 when 'BC' then zsiv.[Fuel Surharge]*0.07 end,0)+case when zsih.VAC_0 in ('BC','BCX') then zsid.[Line EHF]*0.05 end+isnull(case zsih.VAC_0 when 'BC' then zsid.[Line EHF]*0.07 end,0),2) as [Tax Total],*/

/* Totals */
zsid.[Line Amount],
zsih.AMTATI_0 as [Total+Tax],

/* Invoice Status */
zdud.[Remaining],
case
	when zdud.[Remaining]<>0 then 2
	when zdud.[Remaining]=0 then 1
end as [Outstanding],
zsih.GTE_0 as [Type]

from LIVE.SINVOICE zsih
inner join SINVOICEV zsiv on zsih.NUM_0=zsiv.[Invoice]
inner join SINVOICED zsid on zsih.NUM_0=zsid.[Invoice]
left join SORDER zsoh on zsih.NUM_0=zsoh.[Invoice]
inner join BPADDRESS zbpa1 on zsiv.[Address Code]=zbpa1.[Address Code] and zsiv.[Bill-to]=zbpa1.[Customer Number]
inner join BPADDRESS zbpa2 on zsiv.[Address Code]=zbpa2.[Address Code] and zsiv.[Ship-to]=zbpa2.[Customer Number]
inner join BPADDRESS zbpa3 on zsih.BPAPAY_0=zbpa3.[Address Code] and zsih.BPRPAY_0=zbpa3.[Customer Number]
inner join GACCDUDATE zdud on zsih.NUM_0=zdud.NUM_0 and zsih.GTE_0=zdud.TYP_0
left join BPDLVCUST zbpd on zsiv.[Address Code]=zbpd.[Address Code] and zsiv.[Ship-to]=zbpd.[Customer Number]
/*
where zsih.NUM_0 in ('DIR469534','DIR469534R','DIR472621','DIR472344','DIR472958')

order by zsih.CREDAT_0 desc
*/