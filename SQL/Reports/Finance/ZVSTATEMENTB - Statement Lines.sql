with gaccdudate as (
	select
		BPR_0 as [Pay-by],
		sum(case when CREDAT_0 >= dateadd(day,-30,GETDATE()) then ((AMTCUR_0+TMPCUR_0)-PAYCUR_0)*SNS_0 else 0 end) as [Owing Current],
		sum(case when CREDAT_0 between dateadd(day,-60,GETDATE()) and dateadd(day,-31,GETDATE()) then ((AMTCUR_0+TMPCUR_0)-PAYCUR_0)*SNS_0 else 0 end) as [Owing Over 30],
		sum(case when CREDAT_0 between dateadd(day,-90,GETDATE()) and dateadd(day,-61,GETDATE()) then ((AMTCUR_0+TMPCUR_0)-PAYCUR_0)*SNS_0 else 0 end) as [Owing Over 60],
		sum(case when CREDAT_0 between dateadd(day,-120,GETDATE()) and dateadd(day,-91,GETDATE()) then ((AMTCUR_0+TMPCUR_0)-PAYCUR_0)*SNS_0 else 0 end) as [Owing Over 90],
		sum(case when CREDAT_0 <= dateadd(day,-121,GETDATE()) then ((AMTCUR_0+TMPCUR_0)-PAYCUR_0)*SNS_0 else 0 end) as [Owing Over 120],
		sum(((AMTCUR_0+TMPCUR_0)-PAYCUR_0)*SNS_0) as [Owing Total]
	from
		LIVE.GACCDUDATE
	where
		TYP_0 not in ('*PO','*SO','NEWPR','SPINV','SPMEM','PAYMT')
	group by
		BPR_0
	having 
		sum(((AMTCUR_0+TMPCUR_0)-PAYCUR_0)*SNS_0)<>0
),
invoices as (
	select
		BILLTO_0 as [Pay-by],
		sum(LINESUBTOT_0) as [Line Subtotal],
		sum(INVDISCTOT_0) as [Discount Total],
		sum(INV_ELM_FRT_0) as [Freight],
		sum(INV_ELM_FSC_0) as [Fuel Surcharge],
		sum(INV_SUBTOTAL_0) as [Subtotal],
		sum(TAX_EHF_0) as [EHF Fee],
		sum(TAX_GST_0) as [GST],
		sum(TAX_PST_0) as [PST],
		sum(INV_TOTAL_0) as [Total],
		b.BPCNAM_0 as [Name],
		case when a.BPAADDLIG_0 in ('~','*') then '' else a.BPAADDLIG_0 end as [Address 1],
		case when a.BPAADDLIG_1 in ('~','*') then '' else a.BPAADDLIG_1 end as [Address 2],
		case when a.BPAADDLIG_2 in ('~','*') then '' else a.BPAADDLIG_2 end as [Address 3],
		a.CTY_0 as [City],
		a.SAT_0 as [Province],
		a.POSCOD_0 as [Postal Code]
	from
		LIVE.ZVINV1C
	inner join
		LIVE.BPCUSTOMER b on BILLTO_0=BPCNUM_0
	inner join
		LIVE.BPADDRESS a on b.BPCNUM_0=a.BPANUM_0 and b.BPAADD_0=a.BPAADD_0
	where
		INV_OWINGBAL_0=2
	group by
		BILLTO_0,
		b.BPCNAM_0,
		case when a.BPAADDLIG_0 in ('~','*') then '' else a.BPAADDLIG_0 end,
		case when a.BPAADDLIG_1 in ('~','*') then '' else a.BPAADDLIG_1 end,
		case when a.BPAADDLIG_2 in ('~','*') then '' else a.BPAADDLIG_2 end,
		a.CTY_0,
		a.SAT_0,
		a.POSCOD_0
)
select
g.[Pay-by],
g.[Owing Current],
g.[Owing Over 30],
g.[Owing Over 60],
g.[Owing Over 90],
g.[Owing Over 120],
g.[Owing Total],
i.[Line Subtotal],
i.[Discount Total],
i.[Freight],
i.[Fuel Surcharge],
i.[Subtotal],
i.[EHF Fee],
i.[GST],
i.[PST],
i.[Total],
i.[Name],
i.[Address 1],
i.[Address 2],
i.[Address 3],
i.[City],
i.[Province],
i.[Postal Code]

from gaccdudate g
left join invoices i on g.[Pay-by]=i.[Pay-by]