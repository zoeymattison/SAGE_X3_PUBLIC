/*

•	Bin/Location (if separate data models for misc issue/receipt and stock count)
•	Created by user

*/

select
	h.CREDAT_0 as [Movement Date],
	case h.VCRTYP_0
		when 19 then 'Receipt'
		when 20 then 'Issue'
	end as [Type],
	h.STOFCY_0 as [Stock Site],
	h.VCRNUM_0 as [Entry Number],
	h.VCRDES_0 as [Entry Description],
	d.ITMREF_0 as [Product],
	d.ITMDES1_0 as [Description],
	d.PCU_0 as [Unit],
	case h.VCRTYP_0
		when 19 then d.QTYPCU_0
		when 20 then d.QTYPCU_0*-1
	end as [Qty Adjustment],
	d.PRI_0 as [Product Cost],
	case h.VCRTYP_0
		when 19 then d.QTYPCU_0*d.PRI_0
		when 20 then d.QTYPCU_0*d.PRI_0*-1
	end as [Cost Adjustment],
	i.TSICOD_0 as [Monk Status],
	j.LOC_0 as [Location],
	a.TEXTE_0 as [Creation User]

from LIVE.SMVTH h
inner join LIVE.SMVTD d on h.VCRNUM_0=d.VCRNUM_0 and h.VCRTYP_0=d.VCRTYP_0
inner join LIVE.ITMMASTER i on d.ITMREF_0=i.ITMREF_0
inner join LIVE.STOJOU j on d.VCRNUM_0=j.VCRNUM_0 and d.VCRLIN_0=j.VCRLIN_0 and d.VCRTYP_0=j.VCRTYP_0
inner join LIVE.ATEXTRA a on h.CREUSR_0=a.IDENT1_0 and a.LANGUE_0='ENG' and ZONE_0='INTUSR' and CODFIC_0='AUTILIS'

where h.VCRTYP_0 in (19,20)