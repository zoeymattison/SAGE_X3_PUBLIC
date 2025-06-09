with SINVOICEV as (
	select
		siv.NUM_0 as [Invoice],
		siv.SALFCY_0 as [Sales Site],
		siv.INVDAT_0 as [Invoice Date],
		siv.INVREF_0 as [Purchase Order],
		rep.REPNAM_0 as [Sales Rep],
		siv.BPCINV_0 as [Bill-to],
		siv.BPCORD_0 as [Ship-to],
		siv.BPAADD_0 as [Address Code],
		case when DTA_0 = 1 then DTAAMT_0 else 0 end as [Discount Amount],
		case when DTA_0 = 10 then DTAAMT_0 else 0 end as [Discount Percent], 
		case when DTA_0 = 10 then DTANOT_0 *-1 else 0 end as [Discount Percent-Amount], 
		case when DTA_0 = 7 then DTAAMT_0 else 0 end as [Restock Fee Amount],
		case when DTA_0 = 9 then DTAAMT_0 else 0 end as [Fuel Surharge],
		case when DTA_0 = 8 then DTAAMT_0 else 0 end as [Freight Charge],
		case when DTA_0 = 5 then DTAAMT_0 else 0 end as [EHF Fees]
	from
		LIVE.SINVOICEV siv
	left join
		LIVE.SALESREP rep on siv.REP_0=rep.REPNUM_0
	left join
		LIVE.SVCRFOOT svf on siv.NUM_0=svf.VCRNUM_0
),
SINVOICED as (
	select
		NUM_0 as [Invoice],
		sum(AMTNOTLIN_0) as [Line Amount]
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
		BPDNAM_0 as [Deliver-to Name 1],
		BPDNAM_1 as [Deliver-to Name 2],
		BPDADDLIG_0 as [Deliver-to Addr 1],
		BPDADDLIG_1 as [Deliver-to Addr 2],
		BPDADDLIG_2 as [Deliver-to Addr 3],
		BPDCRY_0 as [Deliver-to Country Code],
		BPDCRYNAM_0 as [Deliver-to Country],
		BPDCTY_0 as [Deliver-to City],
		BPDSAT_0 as [Deliver-to Province],
		BPDPOSCOD_0 as [Deliver-to Postal Code]
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
		POSCOD_0 as [Postal Code]
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
)

select top 100
zsiv.[Sales Site],
zsih.CREDAT_0 as [Creation Date],
zsih.ACCDAT_0 as [Accounting Date],
zsiv.[Invoice Date],
zsih.NUM_0 as [Invoice],
zsoh.[Sales Order],
case zsih.SNS_0
	when 1 then 'Invoice'
	when -1 then 'Credit Memo'
end as [Type],
zsiv.[Purchase Order],
zsiv.[Sales Rep],
zsoh.[Route],
zsih.PTE_0 as [Payment Terms],
zsoh.[Shipping Instructions],
zsih.VAC_0 as [Tax Rule],
zsiv.[Bill-to],
zsiv.[Ship-to],
zsih.BPRPAY_0 as [Pay-by],

/* Invoice Address Info */
/* Pay-By */
zbpa1.[Customer Name] as [INV Bill-to Name],
zbpa1.[Customer Description] as [INV Bill-to Description],
case when zbpa1.[Address 1] in ('~','*') then '' else zbpa1.[Address 1] end as [INV Bill-to Addr 1],
case when zbpa1.[Address 2] in ('~','*') then '' else zbpa1.[Address 2] end as [INV Bill-to Addr 2],
case when zbpa1.[Address 3] in ('~','*') then '' else zbpa1.[Address 3] end as [INV Bill-to Addr 3],
zbpa1.[Country Code] as [INV Bill-to Country Code],
zbpa1.[Country] as [INV Bill-to Country],
zbpa1.[Province] as [INV Bill-to Province],
zbpa1.[Postal Code] as [INV Bill-to Postal Code],

/* Ship-to */
zbpa2.[Customer Name] as [INV Ship-to Name],
zbpa2.[Customer Description] as [INV Ship-to Description],
case when zbpa2.[Address 1] in ('~','*') then '' else zbpa2.[Address 1] end as [INV Ship-to Addr 1],
case when zbpa2.[Address 2] in ('~','*') then '' else zbpa2.[Address 2] end as [INV Ship-to Addr 2],
case when zbpa2.[Address 3] in ('~','*') then '' else zbpa2.[Address 3] end as [INV Ship-to Addr 3],
zbpa2.[Country Code] as [INV Ship-to Country Code],
zbpa2.[Country] as [INV Ship-to Country],
zbpa2.[Province] as [INV Ship-to Province],
zbpa2.[Postal Code] as [INV Ship-to Postal Code],

/* Pay-by */
zbpa3.[Customer Name] as [INV Pay-by Name],
zbpa3.[Customer Description] as [INV Pay-by Description],
case when zbpa3.[Address 1] in ('~','*') then '' else zbpa3.[Address 1] end as [INV Pay-by Addr 1],
case when zbpa3.[Address 2] in ('~','*') then '' else zbpa3.[Address 2] end as [INV Pay-by Addr 2],
case when zbpa3.[Address 3] in ('~','*') then '' else zbpa3.[Address 3] end as [INV Pay-by Addr 3],
zbpa3.[Country Code] as [INV Pay-by Country Code],
zbpa3.[Country] as [INV Pay-by Country],
zbpa3.[Province] as [INV Pay-by Province],
zbpa3.[Postal Code] as [INV Pay-by Postal Code],

/* Sales Order Bill-to*/
zsoh.[Bill-to Name 1],
zsoh.[Bill-to Name 2],
zsoh.[Bill-to Addr 1],
zsoh.[Bill-to Addr 2],
zsoh.[Bill-to Addr 3],
zsoh.[Bill-to Country Code],
zsoh.[Bill-to Country],
zsoh.[Bill-to City],
zsoh.[Bill-to Province],
zsoh.[Bill-to Postal Code],

/* Sales Order Ship-to */
zsoh.[Deliver-to Name 1],
zsoh.[Deliver-to Name 2],
zsoh.[Deliver-to Addr 1],
zsoh.[Deliver-to Addr 2],
zsoh.[Deliver-to Addr 3],
zsoh.[Deliver-to Country Code],
zsoh.[Deliver-to Country],
zsoh.[Deliver-to City],
zsoh.[Deliver-to Province],
zsoh.[Deliver-to Postal Code],

/* Invoicing Elements */
sum(zsiv.[Discount Amount]) as [Discount Amount],
sum(zsiv.[Discount Percent]) as [Discount Percent],
sum(zsiv.[Discount Percent-Amount]) as [Discount Percent-Amount],
sum(zsiv.[EHF Fees]) as [EHF Fees],
sum(zsiv.[Freight Charge]) as [Freight Charge],
sum(zsiv.[Fuel Surharge]) as [Fuel Surharge],

/* Taxes */
case zsih.TAX_0 when 'GST' then zsih.AMTTAX_0 else 0 end as [GST Amount],
case zsih.TAX_1 when 'BCPST' then zsih.AMTTAX_1 else 0 end as [PST Amount],
case zsih.TAX_1 when 'EHF' then zsih.AMTTAX_1 else 0 end+case zsih.TAX_2 when 'EHF' then zsih.AMTTAX_2 else 0 end+case zsih.TAX_3 when 'EHF' then zsih.AMTTAX_3 else 0 end as [EHF Amount],

/* Totals */
zsid.[Line Amount],
sum(zsiv.[Freight Charge])+sum(zsiv.[Fuel Surharge]) as [Invoicing Element Base],
case zsih.TAX_0 when 'GST' then zsih.AMTTAX_0 else 0 end+case zsih.TAX_1 when 'BCPST' then zsih.AMTTAX_1 else 0 end as [Tax Total],
case zsih.VAC_0 When 'BC' then sum(zsiv.[Fuel Surharge])*0.12 else 0 end+case zsih.VAC_0 When 'BCX' then sum(zsiv.[Freight Charge])*0.05 else 0 end as [Fuel surcharge Tax],
zsih.AMTATI_0 as [Total+Tax],

/* Invoice Status */
zdud.[Remaining],
case
	when zdud.[Remaining]>0 then 2
	when zdud.[Remaining]<=0 then 1
end as [Outstanding]

from LIVE.SINVOICE zsih
inner join SINVOICEV zsiv on zsih.NUM_0=zsiv.[Invoice]
inner join SINVOICED zsid on zsih.NUM_0=zsid.[Invoice]
left join SORDER zsoh on zsih.NUM_0=zsoh.[Invoice]
inner join BPADDRESS zbpa1 on zsiv.[Address Code]=zbpa1.[Address Code] and zsiv.[Bill-to]=zbpa1.[Customer Number]
inner join BPADDRESS zbpa2 on zsiv.[Address Code]=zbpa2.[Address Code] and zsiv.[Ship-to]=zbpa2.[Customer Number]
inner join BPADDRESS zbpa3 on zsiv.[Address Code]=zbpa3.[Address Code] and zsih.BPRPAY_0=zbpa3.[Customer Number]
inner join GACCDUDATE zdud on zsih.NUM_0=zdud.NUM_0 and zsih.GTE_0=zdud.TYP_0

where zsih.NUM_0 in ('DIR370609','DIR467352')

GROUP BY
  zsiv.[Sales Site],
  zsih.CREDAT_0,
  zsih.ACCDAT_0,
  zsiv.[Invoice Date],
  zsih.NUM_0,
  zsoh.[Sales Order],
  zsih.SNS_0,
  zsiv.[Purchase Order],
  zsiv.[Sales Rep],
  zsoh.[Route],
  zsih.PTE_0,
  zsoh.[Shipping Instructions],
  zsih.VAC_0,
  zsiv.[Bill-to],
  zsiv.[Ship-to],
  zsih.BPRPAY_0,

  zbpa1.[Customer Name],
  zbpa1.[Customer Description],
  zbpa1.[Address 1],
  zbpa1.[Address 2],
  zbpa1.[Address 3],
  zbpa1.[Country Code],
  zbpa1.[Country],
  zbpa1.[Province],
  zbpa1.[Postal Code],

  zbpa2.[Customer Name],
  zbpa2.[Customer Description],
  zbpa2.[Address 1],
  zbpa2.[Address 2],
  zbpa2.[Address 3],
  zbpa2.[Country Code],
  zbpa2.[Country],
  zbpa2.[Province],
  zbpa2.[Postal Code],

  zbpa3.[Customer Name],
  zbpa3.[Customer Description],
  zbpa3.[Address 1],
  zbpa3.[Address 2],
  zbpa3.[Address 3],
  zbpa3.[Country Code],
  zbpa3.[Country],
  zbpa3.[Province],
  zbpa3.[Postal Code],

  zsoh.[Bill-to Name 1],
  zsoh.[Bill-to Name 2],
  zsoh.[Bill-to Addr 1],
  zsoh.[Bill-to Addr 2],
  zsoh.[Bill-to Addr 3],
  zsoh.[Bill-to Country Code],
  zsoh.[Bill-to Country],
  zsoh.[Bill-to City],
  zsoh.[Bill-to Province],
  zsoh.[Bill-to Postal Code],

  zsoh.[Deliver-to Name 1],
  zsoh.[Deliver-to Name 2],
  zsoh.[Deliver-to Addr 1],
  zsoh.[Deliver-to Addr 2],
  zsoh.[Deliver-to Addr 3],
  zsoh.[Deliver-to Country Code],
  zsoh.[Deliver-to Country],
  zsoh.[Deliver-to City],
  zsoh.[Deliver-to Province],
  zsoh.[Deliver-to Postal Code],

  zsih.TAX_0,
  zsih.TAX_1,
  zsih.TAX_2,
  zsih.TAX_3,
  zsih.TAX_4,
  zsih.AMTTAX_0,
  zsih.AMTTAX_1,
  zsih.AMTTAX_2,
  zsih.AMTTAX_3,
  zsih.AMTTAX_4,

  zsih.AMTATI_0,
  zsih.AMTNOT_0,
  zsid.[Line Amount],

  zdud.Remaining


  order by zsih.CREDAT_0 desc