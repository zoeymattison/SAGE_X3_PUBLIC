with salesordernumber as (
	select distinct
		NUM_0,
		SOHNUM_0
	from
		LIVE.SINVOICED
),
invoicelines as (
	select
		NUM_0,
		sid.ITMREF_0 as [Invoice Prouct],
		itm.ITMDES1_0+' '+itm.ITMDES2_0 as [Invoice Description],
		itm.SEAKEY_0 as [Invoice Catelogue],
		sid.QTY_0 as [Invoice QTY],
		sid.SAU_0 as [Invoice Sales Unit],
		sid.GROPRI_0 as [Invoice Gross Price],
		(sid.DISCRGVAL1_0) as [Invoice Line Discount],
		sid.NETPRI_0 as [Invoice Net Price],
		tex.TEXTE_0 as [Invoice Line Text],
		sid.SIDLIN_0 as [Invoice Line Number]
	from
		LIVE.SINVOICED sid
	inner join
		LIVE.ITMMASTER itm on sid.ITMREF_0=itm.ITMREF_0
	left join 
		LIVE.TEXCLOB tex ON sid.SIDTEX_0=tex.CODE_0
        where
            left(sid.ITMREF_0,4)<>'EHF-'

),
salesorderlines as (
	select
		soq.SOHNUM_0,
		soq.ITMREF_0 as [Sales Order Product],
		case
			when sop.ITMDES_0<>itm.ITMDES1_0 then sop.ITMDES_0
			when sop.ITMDES_0=itm.ITMDES1_0 then itm.ITMDES1_0+' '+itm.ITMDES2_0
		end as [Sales Order Description],
		itm.SEAKEY_0 as [Sales Order Catalogue],
		sid.QTY_0 as [Sales Order INV QTY],
		sid.NUM_0 as [Sales order INV NUM],
		soq.QTY_0-soq.DLVQTY_0 as [Sales Order BO QTY],
		soq.QTY_0 as [Sales Order QTY],
		sop.SAU_0 as [Sales Order Sales Unit],
		sop.GROPRI_0 as [Sales Order Gross Price],
		(sop.DISCRGVAL1_0) as [Sales Order Discount],
		sop.NETPRI_0 as [Sales Order Net Price],
		tex.TEXTE_0 as [Sales Order Line Text]
	from
		LIVE.SORDERQ soq
	inner join
		LIVE.SORDERP sop on soq.SOHNUM_0=sop.SOHNUM_0 and soq.SOPLIN_0=sop.SOPLIN_0
	inner join
		LIVE.ITMMASTER itm on soq.ITMREF_0=itm.ITMREF_0
	left join
		LIVE.SINVOICED sid on soq.SOHNUM_0=sid.SOHNUM_0 and soq.SOPLIN_0=sid.SOPLIN_0 and soq.SOQSEQ_0=sid.SOQSEQ_0
	left join 
		LIVE.TEXCLOB tex ON soq.SOQTEX_0=tex.CODE_0
        where
            left(soq.ITMREF_0,4)<>'EHF-'
),
interestlines as (
	select
		NUM_0,
		'Interest Charged for Overdue Account' as [Description],
		AMTATILIN_0 as [Amount]
	from
		LIVE.BPCINVLIG
	where
		left(NUM_0,3)='INT'
)

SELECT DISTINCT
	sih.NUM_0 as [Invoice],
	case son.SOHNUM_0
		when '' then ivl.[Invoice Line Number]
		else 0
	end as [Line Number],
	case
		when son.SOHNUM_0='' then 'N/A'
		when son.SOHNUM_0 is null then sih.DES_0
		else son.SOHNUM_0
	end as [Sales Order],
	case
		when son.SOHNUM_0='' then ivl.[Invoice Prouct]
		when son.SOHNUM_0 is null then sih.DES_0
		else sol.[Sales Order Product]
	End as [Product],
	case
		when son.SOHNUM_0='' then ivl.[Invoice Description]
		when son.SOHNUM_0 is null then interest.[Description]
		else sol.[Sales Order Description]
	end as [Description],
	isnull(case son.SOHNUM_0
		when '' then ivl.[Invoice Catelogue]
		else sol.[Sales Order Catalogue]
	end,'') as [Catalogue],
	isnull(case son.SOHNUM_0
		when '' then 0
		else sol.[Sales Order QTY]
	end,0) as [Ordered QTY],
	case son.SOHNUM_0
		when '' then ivl.[Invoice QTY]*sih.SNS_0
		else case sol.[Sales order INV NUM]
				when sih.NUM_0 then sol.[Sales Order INV QTY]*sih.SNS_0
				else 0
			end
	end as [Invoiced Qty],
	isnull(case son.SOHNUM_0
		when '' then 0
		else sol.[Sales Order BO QTY]*sih.SNS_0
	end,0) as [Backordered QTY],
	isnull(case son.SOHNUM_0
		when '' then ivl.[Invoice Sales Unit]
		else sol.[Sales Order Sales Unit]
	end,'') as [Salse Unit],
	case
		when son.SOHNUM_0='' then ivl.[Invoice Gross Price]*sih.SNS_0
		when son.SOHNUM_0 is null then interest.[Amount]*sih.SNS_0
		else sol.[Sales Order Gross Price]*sih.SNS_0
	end as [Gross Price],
	isnull(case son.SOHNUM_0
		when '' then ivl.[Invoice Line Discount]*sih.SNS_0
		else sol.[Sales Order Discount]*sih.SNS_0
	end,0) as [Discount Percent],
	case
		when son.SOHNUM_0='' then ivl.[Invoice Net Price]*sih.SNS_0
		when son.SOHNUM_0 is null then interest.[Amount]*sih.SNS_0
		else sol.[Sales Order Net Price]*sih.SNS_0
	end as [Net Price],
	case
		when son.SOHNUM_0='' then ivl.[Invoice Net Price]*ivl.[Invoice QTY]*sih.SNS_0
		when son.SOHNUM_0 is null then interest.[Amount]*sih.SNS_0
		else case sol.[Sales order INV NUM]
				when sih.NUM_0 then sol.[Sales Order Net Price]*sol.[Sales Order INV QTY]*sih.SNS_0
				else 0
			end
	end as [Total],
	isnull(case son.SOHNUM_0
		when '' then ivl.[Invoice Line Text]
		else sol.[Sales Order Line Text]
	end,'') as [Line Text]

from
	LIVE.SINVOICE sih

left join
	salesordernumber son on sih.NUM_0=son.NUM_0
left join
	salesorderlines sol on son.SOHNUM_0=sol.SOHNUM_0
left join
	invoicelines ivl on sih.NUM_0=ivl.NUM_0
left join
	interestlines interest on sih.NUM_0=interest.NUM_0