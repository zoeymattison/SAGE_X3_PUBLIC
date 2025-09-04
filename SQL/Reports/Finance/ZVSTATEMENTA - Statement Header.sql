with gaccdudate as (
	select
		NUM_0 as [Number],
		TYP_0 as [Type],
		BPR_0 as [Pay-by],
		DUDDAT_0 as [Due Date],
		sum((AMTCUR_0-(TMPCUR_0+PAYCUR_0))*SNS_0) as [Owing]
	from
		LIVE.GACCDUDATE
	where
		TYP_0 not in ('*PO','*SO','NEWPR','SPINV','SPMEM','PAYMT') and left(NUM_0,3)<>'INT'
	group by
		DUDDAT_0,
		NUM_0,
		TYP_0,
		BPR_0
	having
		sum((AMTCUR_0-(TMPCUR_0+PAYCUR_0))*SNS_0)<>0
),
invoices as (
	select
		NUM_0 as [Number],
		SOHNUM_0 as [Sales Order],
		POHNUM_0 as [Purchase Order],
		LINESUBTOT_0 as [Line Subtotal],
		INVDISCTOT_0 as [Discont Total],
		INV_ELM_FRT_0 as [Freigt],
		INV_ELM_FSC_0 as [Fuel Surcharge],
		INV_SUBTOTAL_0 as [Subtotal],
		TAX_EHF_0 as [EHF Fee],
		TAX_GST_0 as [GST],
		TAX_PST_0 as [PST],
		INV_TOTAL_0 as [Total]
	from
		LIVE.ZVINV1B
		
)
select
g.[Due Date],
g.[Number],
g.[Type],
coalesce(i.[Sales Order],'') as [Sales Order],
g.[Pay-by],
coalesce(i.[Purchase Order], '') as [Purchase Order],
coalesce(i.[Line Subtotal], 0) as [Line Subtotal],
coalesce(i.[Discont Total], 0) as [Discont Total],
coalesce(i.[Freigt], 0) as [Freigt],
coalesce(i.[Fuel Surcharge], 0) as [Fuel Surcharge],
coalesce(i.[Subtotal], 0) as [Subtotal],
coalesce(i.[EHF Fee], 0) as [EHF Fee],
coalesce(i.[GST], 0) as [GST],
coalesce(i.[PST], 0) as [PST],
coalesce(i.[Total], 0) as [Total],
g.[Owing]
from gaccdudate g
left join invoices i on g.[Number]=i.[Number]