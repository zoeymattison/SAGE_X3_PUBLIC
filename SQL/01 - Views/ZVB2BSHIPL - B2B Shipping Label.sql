 ( CREDAT_0 , PTHNUM_0 , POHNUM_0 , SOHNUM_0 , BPDNAM1_0 , BPDNAM2_0 
 , BPDADDLIG1_0 , BPDADDLIG2_0 , BPDADDLIG3_0 , BPDCTY_0 , BPDSAT_0 
 , BPDPOSCOD_0 , BPDCRYNAM_0 , RTE_0 , CUSORDREF_0 , YPICKNOTE_0 , SOHTXH_0 
 , SOHTXF_0 ) As 
with receipts as (
	select distinct
		r.CREDAT_0,
		r.PTHNUM_0,
		q.POHNUM_0,
		q.SOHNUM_0,
		q.ORI_0,
		s.BPDNAM_0,
		s.BPDNAM_1,
		s.BPDADDLIG_0,
		s.BPDADDLIG_1,
		s.BPDADDLIG_2,
		s.BPDCTY_0,
		s.BPDSAT_0,
		s.BPDPOSCOD_0,
		s.BPDCRYNAM_0,
		a.LANMES_0,
		s.CUSORDREF_0,
		s.YPICKNOTE_0,
		isnull(th.TEXTE_0,'') as SOHTXH_0,
		isnull(tf.TEXTE_0,'') as SOHTXF_0
	from
		LIVE.PRECEIPT r
	inner join
		LIVE.PORDERQ q on r.ZPOHNUM_0=q.POHNUM_0
	inner join
		LIVE.SORDER s on q.SOHNUM_0=s.SOHNUM_0
	inner join 
		LIVE.APLSTD a ON s.DRN_0 = a.LANNUM_0
		and a.LANCHP_0 = '409'
		and a.LAN_0 = 'ENG'
	left join
		LIVE.TEXCLOB th on s.SOHTEX1_0=th.CODE_0
	left join
		LIVE.TEXCLOB tf on s.SOHTEX2_0=tf.CODE_0
)
select
rc.CREDAT_0,
rc.PTHNUM_0,
rc.POHNUM_0,
rc.SOHNUM_0,
upper(rc.BPDNAM_0),
upper(rc.BPDNAM_1),
upper(iif(rc.BPDADDLIG_0 in ('~','*'),'',rc.BPDADDLIG_0)),
upper(iif(rc.BPDADDLIG_1 in ('~','*'),'',rc.BPDADDLIG_1)),
upper(iif(rc.BPDADDLIG_2 in ('~','*'),'',rc.BPDADDLIG_2)),
upper(rc.BPDCTY_0),
upper(rc.BPDSAT_0),
upper(rc.BPDPOSCOD_0),
upper(rc.BPDCRYNAM_0),
upper(rc.LANMES_0),
rc.CUSORDREF_0,
rc.YPICKNOTE_0,
rc.SOHTXH_0,
rc.SOHTXF_0
from
	receipts rc
