with count_sessions as (
	select
		CUNSSSNUM_0 as [Count Session],
		CUNSSSDES_0 as [Count Description],
		CUNSSSDAT_0 as [Count Date],
		STOFCY_0 as [Stock Site],
		CREUSR_0 as [Creation User],
		case ITMREFSTR_0
			when '' then ''
			else 'Product Start: '+ITMREFSTR_0
		end as [Product Start],
		case ITMREFEND_0
			when '' then ''
			else 'Product End: '+ITMREFEND_0
		end as [Product End],
		case TCLCODSTR_0
			when '' then ''
			else 'Category Start: '+TCLCODSTR_0
		end as [Category Start],
		case TCLCODEND_0
			when '' then ''
			else 'Category End: '+TCLCODEND_0
		end as [Category End],
		case TSICODSTR_1
			when '' then ''
			else 'Class Start: '+TSICODSTR_1
		end as [Class Start],
		case TSICODEND_1
			when '' then ''
			else 'Class End: '+TSICODEND_1
		end as [Class End]
	from
		LIVE.CUNSESSION
)
select
c.[Count Session],
c.[Count Date],
c.[Count Description],
c.[Stock Site],
c.[Creation User],
c.[Product Start],
c.[Product End],
c.[Category Start],
c.[Category End],
c.[Class Start],
c.[Class End]

from
	count_sessions c