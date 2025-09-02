with gaccdudate as (
	select
		d.NUM_0 as [Number],
		TYP_0 as [Type],
		d.BPR_0 as [Business Partner],
		b.BPCNAM_0 as [BP Name],
		DUDDAT_0 as [Due Date],
		(AMTCUR_0-(PAYCUR_0+TMPCUR_0))*d.SNS_0 as [Owing],
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
		b.OSTCTL_0<>3 and (AMTCUR_0-(PAYCUR_0+TMPCUR_0))*d.SNS_0>0 and TYP_0 in ('CSDIR','CSINV') and DUDDAT_0<dateadd(day,-10,cast(GETDATE() as date)) and b.ZCOLLEC_0<>2 
		and ((s.ZCOLLECT1_0<>2 and d.DUDDAT_0 between dateadd(day,-30,cast(GETDATE() as date)) and dateadd(day,-11,cast(GETDATE() as date))) or (s.ZCOLLCET2_0<>2 and d.DUDDAT_0 between dateadd(day,-45,cast(GETDATE() as date)) and dateadd(day,-31,cast(GETDATE() as date))) 
		or (s.ZCOLLECT3_0<>2 and d.DUDDAT_0<dateadd(day,-45,cast(GETDATE() as date))))
),
gaccdudatesum as (
	select
		BPR_0 as [Business Partner],
		sum((AMTCUR_0-(PAYCUR_0+TMPCUR_0))*SNS_0) as [Tot. Amt>$100 & 45d]
	from
		LIVE.GACCDUDATE d
	inner join LIVE.BPCUSTOMER b on d.BPR_0=b.BPCNUM_0
	where DUDDAT_0<dateadd(day,-45,cast(GETDATE() as date)) and b.OSTCTL_0<>3 and (AMTCUR_0-(PAYCUR_0+TMPCUR_0))*SNS_0>0 and TYP_0 in ('CSDIR','CSINV')
	group by
		BPR_0 having sum((AMTCUR_0-(PAYCUR_0+TMPCUR_0))*SNS_0)>=100
)
select
d.[Business Partner],
d.[BP Name],
isnull(s.[Tot. Amt>$100 & 45d],0) as [Tot. Amt>=$100 & 45d],
d.[Number],
d.[Due Date],
d.[Collections Type],
d.[Owing] as [Owing],
d.[Collections Email]
from gaccdudate d
left join gaccdudatesum s on d.[Business Partner]=s.[Business Partner]