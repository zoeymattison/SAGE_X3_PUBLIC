with picktick_header as (
	select
		h.PRHNUM_0 as [Pick Ticket],
		h.PRLNUM_0 as [Plan],
		q.SOHNUM_0 as [Sales Order],
		a.LANMES_0 as [Route],
		h.CREDAT_0 as [Creation Date],
		h.STOFCY_0 as [Shipment Site],
		f.FCYNAM_0 as [Shipment Site Name],
		s.BPCPYR_0 as [Bill-to],
		s.BPINAM_0 as [Bill-to Name 1],
		s.BPINAM_1 as [Bill-to Name 2],
		case when s.BPIADDLIG_0 in ('~','*','ATT:','~~~~~~~~~~~~') then '' else s.BPIADDLIG_0 end as [Bill-to Addr 1],
		case when s.BPIADDLIG_1 in ('~','*','ATT:','~~~~~~~~~~~~') then '' else s.BPIADDLIG_1 end as [Bill-to Addr 2],
		case when s.BPIADDLIG_2 in ('~','*','ATT:','~~~~~~~~~~~~') then '' else s.BPIADDLIG_2 end as [Bill-to Addr 3],
		s.BPICTY_0 as [Bill-to City],
		s.BPISAT_0 as [Bill-to Province],
		s.BPIPOSCOD_0 as [Bill-to Postal Code],
		s.BPICRYNAM_0 as [Bill-to Country],
		h.BPCORD_0 as [Ship-to],
		s.BPDNAM_0 as [Ship-to Name 1],
		s.BPDNAM_1 as [Ship-to Name 2],
		case when s.BPDADDLIG_0 in ('~','*','ATT:','~~~~~~~~~~~~') then '' else s.BPDADDLIG_0 end as [Ship-to Addr 1],
		case when s.BPDADDLIG_1 in ('~','*','ATT:','~~~~~~~~~~~~') then '' else s.BPDADDLIG_1 end as [Ship-to Addr 2],
		case when s.BPDADDLIG_2 in ('~','*','ATT:','~~~~~~~~~~~~') then '' else s.BPDADDLIG_2 end as [Ship-to Addr 3],
		s.BPDCTY_0 as [Ship-to City],
		s.BPDSAT_0 as [Ship-to Province],
		s.BPDPOSCOD_0 as [Ship-to Postal Code],
		s.BPDCRYNAM_0 as [Ship-to Country],
		s.YPICKNOTE_0 as [Delivery Instructions],
		s.YSTUNAM_0 as [Student Name],
		s.YSTUGRA_0 as [Student Grade],
		s.YPARNAM_0 as [Parent Name],
		s.CUSORDREF_0 as [Purchase Order],
		Case s.DLVPIO_0
			when '1' then 'Normal'
			when '2' then 'Same Day'
		End as [Delivery Priority],
		s.YCONTNAME_0 as [Contact Name],
		s.YCONTPHONE_0 as [Contact Phone],
		s.YINSTALLDATE_0 as [Install Date],
		cast(isnull(t1.TEXTE_0,'') as varchar) as [Header Text],
		cast(isnull(t2.TEXTE_0,'') as varchar) as [Footer Text],
		s.ORDDAT_0 as [Order Date],
		r.REPNAM_0 as [Rep Name],
		s.ZWEBNAM_0 as [Web Name],
		s.ZWEBEML_0 as [Web Email],
		s.ZWEBTEL_0 as [Web Telephone]


	from
		LIVE.STOPREH h


    INNER JOIN (
        SELECT PRHNUM_0, PRELIN_0, ORILIN_0, ORINUM_0
        FROM (
            SELECT PRHNUM_0, PRELIN_0, ORILIN_0, ORINUM_0,
                   ROW_NUMBER() OVER (PARTITION BY PRHNUM_0 ORDER BY PRELIN_0) AS rn
            FROM LIVE.STOPRED
        ) t
        WHERE rn = 1
    ) d ON h.PRHNUM_0 = d.PRHNUM_0

	inner join
		LIVE.SORDERQ q on d.ORILIN_0=q.SOPLIN_0 and d.ORINUM_0=q.SOHNUM_0
	inner join
		LIVE.APLSTD a on h.DRN_0 = a.LANNUM_0
			and a.LANCHP_0 = '409'
			and a.LAN_0 = 'ENG'
	inner join
		LIVE.FACILITY f on h.STOFCY_0=f.FCY_0
	inner join
		LIVE.SORDER s on q.SOHNUM_0=s.SOHNUM_0
	left join
		LIVE.TEXCLOB t1 on s.SOHTEX1_0=t1.CODE_0
	left join
		LIVE.TEXCLOB t2 on s.SOHTEX2_0=t2.CODE_0
	left join
		LIVE.SALESREP r on s.REP_0=r.REPNUM_0
	where
		len(h.PRHNUM_0)=12
)
select
	p.[Pick Ticket],
	p.[Plan],
	p.[Sales Order],
	p.[Order Date],
	p.[Route],
	p.[Delivery Priority],
	p.[Delivery Instructions],
	p.[Student Name],
	p.[Student Grade],
	p.[Parent Name],
	p.[Purchase Order],
	p.[Contact Name],
	p.[Contact Phone],
	p.[Install Date],
	p.[Shipment Site],
	upper(p.[Shipment Site Name]),
	p.[Bill-to],
	upper(p.[Bill-to Name 1]),
	iif(upper(p.[Bill-to Name 2])<>upper(p.[Bill-to Name 1]),upper(p.[Bill-to Name 2]),''),
	upper(p.[Bill-to Addr 1]),
	upper(p.[Bill-to Addr 2]),
	upper(p.[Bill-to Addr 3]),
	upper(p.[Bill-to City]),
	upper(p.[Bill-to Province]),
	upper(p.[Bill-to Postal Code]),
	upper(p.[Bill-to Country]),
	p.[Ship-to],
	upper(p.[Ship-to Name 1]),
	iif(upper(p.[Ship-to Name 2])<>upper(p.[Ship-to Name 1]),upper(p.[Ship-to Name 2]),''),
	upper(p.[Ship-to Addr 1]),
	upper(p.[Ship-to Addr 2]),
	upper(p.[Ship-to Addr 3]),
	upper(p.[Ship-to City]),
	upper(p.[Ship-to Province]),
	upper(p.[Ship-to Postal Code]),
	upper(p.[Ship-to Country]),
	isnull(p.[Rep Name],'') as [Rep Name],
	p.[Web Name],
	p.[Web Email],
	p.[Web Telephone],
	p.[Header Text]+iif(p.[Footer Text]<>'',' '+p.[Footer Text],'')
from
	picktick_header p

