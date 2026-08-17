with poline as (
	select
		CAST(POHNUM_0 AS NVARCHAR(MAX)) as POHNUM_0,
		CAST(ITMREF_0 AS NVARCHAR(MAX)) as ITMREF_0,
		CAST(POPLIN_0 AS NVARCHAR(MAX)) as POPLIN_0
	from
		LIVE.PORDERQ
),
salesline as (
	select
		CAST(soq.BPCORD_0 AS NVARCHAR(MAX)) as BPCORD_0,
		CAST(soq.SOHNUM_0 AS NVARCHAR(MAX)) as SOHNUM_0,
		CAST(soh.CUSORDREF_0 AS NVARCHAR(MAX)) as CUSORDREF_0,
		CAST(soq.ITMREF_0 AS NVARCHAR(MAX)) as ITMREF_0,
		soq.SOQSTA_0
	from LIVE.SORDERQ soq
	inner join LIVE.SORDER soh on soq.SOHNUM_0=soh.SOHNUM_0
	where soq.SOHNUM_0 in (
    )
    and soq.ITMREF_0 in (
    )
),
deduplicated_data as (
	select distinct
		soq.CUSORDREF_0,
		pol.POPLIN_0,
		pol.ITMREF_0
	from salesline soq
	inner join poline pol on soq.CUSORDREF_0=pol.POHNUM_0 and soq.ITMREF_0=pol.ITMREF_0
	where soq.SOQSTA_0<>3
),
ranked_data as (
	select 
		CUSORDREF_0,
		POPLIN_0,
		ITMREF_0,
		row_number() over (partition by CUSORDREF_0 order by POPLIN_0) as rn_within_po
	from deduplicated_data
)
select col1, col2, col3, col4, col5, col6 from (
	-- E records (only first occurrence per PO)
	select
		CAST('E' AS NVARCHAR(MAX)) as col1,
		CAST(CUSORDREF_0 AS NVARCHAR(MAX)) as col2,
		CAST('' AS NVARCHAR(MAX)) as col3,
		CAST('' AS NVARCHAR(MAX)) as col4,
		CAST('' AS NVARCHAR(MAX)) as col5,
		CAST('' AS NVARCHAR(MAX)) as col6,
		CUSORDREF_0 + '1' as sort_key
	from ranked_data
	where rn_within_po = 1

	UNION ALL

	-- L records (all records)
	select
		CAST('L' AS NVARCHAR(MAX)) as col1,
		CAST(ISNULL(POPLIN_0, '') AS NVARCHAR(MAX)) as col2,
		CAST(ISNULL(ITMREF_0, '') AS NVARCHAR(MAX)) as col3,
		CAST('2' AS NVARCHAR(MAX)) as col4,
		CAST('' AS NVARCHAR(MAX)) as col5,
		CAST('' AS NVARCHAR(MAX)) as col6,
		CUSORDREF_0 + '2' + RIGHT('000000' + CAST(rn_within_po AS NVARCHAR(6)), 6) as sort_key
	from ranked_data
) combined
order by sort_key