select
	d.CUNDAT_0 as [Count Date],
	d.STOFCY_0 as [Stock Site],
	d.CUNSSSNUM_0  as [Session],
	d.ITMREF_0 as [Product],
	i.ITMDES1_0 as [Description],
	d.PCU_0 as [Unit],
	sum(d.QTYPCU_0) as [Expected Stock],
	sum(d.QTYPCUNEW_0) as [Counted Stock],
	sum(d.QTYPCUNEW_0-d.QTYPCU_0) as [Qty Variance],
	sum((d.QTYPCUNEW_0-d.QTYPCU_0)*d.CUNCST_0) as [Cost Variance],
        sum(d.QTYPCU_0*d.CUNCST_0) as [Expected Cost],
	a.TEXTE_0 as [Created By],
	s.ITMREFSTR_0 as [Prodct Sel. Start],
	s.ITMREFEND_0 as [Product Sel. End],
	s.TCLCODSTR_0 as [Category Sel. Start],
	s.TCLCODEND_0 as [Category Sel. End],
	s.TSICODSTR_1 as [Class Sel. Start],
	s.TSICODEND_1 as [Class Sel. End]

from
	LIVE.CUNLISDET d

inner join LIVE.ITMMASTER i on d.ITMREF_0=i.ITMREF_0
inner join LIVE.ATEXTRA a on d.CREUSR_0=a.IDENT1_0 and a.LANGUE_0='ENG' and ZONE_0='INTUSR' and CODFIC_0='AUTILIS'
inner join LIVE.CUNSESSION s on d.CUNSSSNUM_0=s.CUNSSSNUM_0
inner join LIVE.CUNLISTE c on d.CUNLISNUM_0=c.CUNLISNUM_0

Where c.CUNLISSTA_0=6

group by
	d.CUNDAT_0,
	d.STOFCY_0,
	d.CUNSSSNUM_0,
	d.ITMREF_0,
	i.ITMDES1_0,
	d.PCU_0,
	a.TEXTE_0,
	s.ITMREFSTR_0,
	s.ITMREFEND_0,
	s.TCLCODSTR_0,
	s.TCLCODEND_0,
	s.TSICODSTR_1,
	s.TSICODEND_1