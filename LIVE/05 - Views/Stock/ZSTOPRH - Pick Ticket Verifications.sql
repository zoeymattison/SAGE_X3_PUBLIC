SELECT
PRH.CREDAT_0 as [Date],
PRH.BPCORD_0,
PRH.PRHNUM_0 as [Pick Ticket],
PRH.YMOPICKER_0 as [Picker],
PRE.ITMREF_0 as [Product],
PRE.ITMDES1_0 as [Description],
Case ZITMFLG_0
    When 0 then 'Not Verified'
	When 1 then 'Not Verified'
	When 2 then 'Verified'
End as [Status],
Case ZPKEFLG_0
    When 0 then 'N/A'
	When 1 then 'N/A'
	When 2 then 'Qty Over'
	When 3 then 'Qty Under'
	When 4 then 'Missing'
	When 5 then 'Wrong Product'
End as [Error]

FROM LIVE.STOPRED PRE
INNER JOIN LIVE.STOPREH PRH ON PRE.PRHNUM_0=PRH.PRHNUM_0
INNER JOIN LIVE.ITMMASTER ITM ON PRE.ITMREF_0=ITM.ITMREF_0
WHERE ZITMFLG_0<>0 and PRH.BPCORD_0 NOT IN ('1200','1600','1800','2100','2200','2300','2600') and ITM.ACCCOD_0<>'FURNITURE'