With LastInvoice As (
	SELECT
		BPCORD_0,
		max(INVDAT_0) as [Last invoice]
	from LIVE.SINVOICEV
	Group by
		BPCORD_0
),
LastOrder As (
	SELECT
		BPCORD_0,
		max(ORDDAT_0) as [Last order]
	from LIVE.SORDER
	Group by
		BPCORD_0
)

SELECT
AST.LANMES_0 AS [Route],
DLV.BPCNUM_0 as [Customer],
DLV.BPDNAM_0 as [Ship-to],
BPC2.BPCNAM_0 as [Bill-to],
Case BPC.BPCSTA_0
    When 1 then 'Not active'
	When 2 then 'Active'
End as [Status],
    LORD.[Last order] AS [Last Order],
    isnull(DATEDIFF(DAY, LORD.[Last order], GETDATE()),999999) AS [Days Since Last Order],
    LINV.[Last invoice] AS [Last Invoice],
    isnull(DATEDIFF(DAY, LINV.[Last invoice], GETDATE()),999999) AS [Days Since Last Invoice]


FROM LIVE.BPDLVCUST DLV
left join LIVE.BPCUSTOMER BPC ON DLV.BPCNUM_0=BPC.BPCNUM_0
left join LIVE.BPCUSTOMER BPC2 ON BPC.BPCINV_0=BPC2.BPCNUM_0
left join LIVE.APLSTD AST ON AST.LANNUM_0=DLV.DRN_0 AND AST.LANCHP_0=409 AND AST.LAN_0='ENG'
LEFT JOIN LastInvoice LINV ON DLV.BPCNUM_0=LINV.BPCORD_0
left join LastOrder LORD on DLV.BPCNUM_0=LORD.BPCORD_0

WHERE 
DLV.BPCNUM_0 LIKE '%-%'

