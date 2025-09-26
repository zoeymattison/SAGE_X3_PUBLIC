with gaccdudate as (
	select
		d.NUM_0 as [Number],
		TYP_0 as [Type],
		d.BPR_0 as [Business Partner],
		b.BPCNAM_0 as [BP Name],
		DUDDAT_0 as [Due Date],
		sum(AMTCUR_0*d.SNS_0) as [Amount],
		sum((AMTCUR_0-(PAYCUR_0+TMPCUR_0))*d.SNS_0) as [Owing],
		a.WEB_0 as [Collections Email],
		Case
			when d.DUDDAT_0 between dateadd(day,-30,cast(GETDATE() as date)) and dateadd(day,-11,cast(GETDATE() as date)) then 'OVER10'
			when d.DUDDAT_0 between dateadd(day,-45,cast(GETDATE() as date)) and dateadd(day,-31,cast(GETDATE() as date)) then 'OVER30'
			when d.DUDDAT_0 < dateadd(day,-45,cast(GETDATE() as date)) then 'OVER45'
		end as [Collections Type]
	from
		LIVE.GACCDUDATE d
	inner join
		LIVE.BPCUSTOMER b on d.BPR_0=b.BPCNUM_0
	inner join
		LIVE.BPADDRESS a on b.BPAADD_0=a.BPAADD_0 and b.BPCNUM_0=a.BPANUM_0
	inner join
		LIVE.SINVOICE s on d.NUM_0=s.NUM_0
	where
		b.OSTCTL_0<>3 and TYP_0 not in ('*PO','*SO','NEWPR','SPINV','SPMEM','PAYMT') and left(d.NUM_0,3)<>'INT' and b.ZCOLLEC_0<>2 
		and ((s.ZCOLLECT1_0<>2 and d.DUDDAT_0 between dateadd(day,-30,cast(GETDATE() as date)) and dateadd(day,-11,cast(GETDATE() as date))) or (s.ZCOLLECT2_0<>2 and d.DUDDAT_0 between dateadd(day,-45,cast(GETDATE() as date)) and dateadd(day,-31,cast(GETDATE() as date))) 
		or (s.ZCOLLECT3_0<>2 and d.DUDDAT_0<dateadd(day,-45,cast(GETDATE() as date))))
	group by
		d.BPR_0,
		d.NUM_0,
		d.TYP_0,
		b.BPCNAM_0,
		DUDDAT_0,
		a.WEB_0
	having sum((AMTCUR_0-(TMPCUR_0+PAYCUR_0))*d.SNS_0)>0

),
gaccdudatesum as (
	select
		BPR_0 as [Business Partner],
		sum((AMTCUR_0-(PAYCUR_0+TMPCUR_0))*SNS_0) as [Tot. Amt>$100 & 45d]
	from
		LIVE.GACCDUDATE d
	inner join LIVE.BPCUSTOMER b on d.BPR_0=b.BPCNUM_0
	where DUDDAT_0<dateadd(day,-45,cast(GETDATE() as date)) and b.OSTCTL_0<>3 and TYP_0 not in ('*PO','*SO','NEWPR','SPINV','SPMEM','PAYMT') and left(d.NUM_0,3)<>'INT'
	group by
		BPR_0 having sum((AMTCUR_0-(PAYCUR_0+TMPCUR_0))*SNS_0)>=100
),
gaccdudatetotal as (
	select
		d.BPR_0,
		sum((AMTCUR_0-(TMPCUR_0+PAYCUR_0))*d.SNS_0) as [Owing]
	from
		LIVE.GACCDUDATE d
	inner join
		LIVE.BPCUSTOMER b on d.BPR_0=b.BPCNUM_0
	where
		b.OSTCTL_0<>3 and TYP_0 not in ('*PO','*SO','NEWPR','SPINV','SPMEM','PAYMT') and left(d.NUM_0,3)<>'INT' and DUDDAT_0<=cast(GETDATE() as date) and b.ZCOLLEC_0<>2
	group by d.BPR_0
)

select
d.[Business Partner],
d.[BP Name],
isnull(s.[Tot. Amt>$100 & 45d],0) as [Tot. Amt>=$100 & 45d],
d.[Number],
d.[Due Date],
d.[Collections Type],
d.[Amount],
d.[Owing],
d.[Collections Email],
isnull(t.Owing,0) as [True Owing],
cast(format(GETDATE(),'yyyy-MM-ddThh:mm:ssZ') as varchar) as [New Update Time]
from gaccdudate d
left join gaccdudatesum s on d.[Business Partner]=s.[Business Partner]
left join gaccdudatetotal t on d.[Business Partner]=t.BPR_0
Where (d.[Collections Type] in ('OVER10','OVER30') or (d.[Collections Type]='OVER45' and s.[Tot. Amt>$100 & 45d]>=100)) 
and t.Owing>=1 and d.Owing>=1