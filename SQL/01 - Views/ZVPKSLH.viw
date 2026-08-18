 ( SHIDAT_0 , SDHNUM_0 , BPCORD_0 , BPDNAM1_0 , BPDNAM2_0 , BPDADDLIG1_0 
 , BPDADDLIG2_0 , BPDADDLIG3_0 , BPDCTY_0 , BPDSAT_0 , BPDPOSCOD_0 , SOHNUM_0 
 , DRN_0 , INSTRUCT1_0 , INSTRUCT2_0 , INSTRUCT3_0 ) As 
with delivery as (
	select
		sy.SHIDAT_0 as DeliveryDate,
		sy.SDHNUM_0 as DeliveryNumber,
		sy.BPCORD_0 as CustomerNumber,
		sy.BPDNAM_0 as DeliveryName1,
		sy.BPDNAM_1 as DeliveryName2,
		sy.BPDADDLIG_0 as DeliveryAddLine1,
		sy.BPDADDLIG_1 as DeliveryAddLine2,
		sy.BPDADDLIG_2 as DeliveryAddLine3,
		sy.BPDCTY_0 as DeliveryCity,
		sy.BPDSAT_0 as DeliveryProvince,
		sy.BPDPOSCOD_0 as DeliveryPostalCode,
		isnull(sr.SOHNUM_0,'') SalesOrder,
		ad.LANMES_0 as Route,
		isnull(sr.YPICKNOTE_0,'') as DeliveryInstruction1,
		isnull(texh.TEXTE_0,'') as DeliveryInstruction2,
		isnull(texf.TEXTE_0,'') as DeliveryInstruction3
	from
		LIVE.SDELIVERY sy
	CROSS APPLY (
    SELECT TOP 1 *
    FROM LIVE.SDELIVERYD sd
    WHERE sy.SDHNUM_0 = sd.SDHNUM_0
    ORDER BY sd.SDDLIN_0 ASC
) sd
	left join
		LIVE.SORDER sr on sd.SOHNUM_0=sr.SOHNUM_0
	left join 
		LIVE.APLSTD ad ON sy.DRN_0 = ad.LANNUM_0
		and ad.LANCHP_0 = '409'
		and ad.LAN_0 = 'ENG'
left join
	LIVE.TEXCLOB texh on sr.SOHTEX1_0=texh.CODE_0
left join
	LIVE.TEXCLOB texf on sr.SOHTEX2_0=texf.CODE_0
)
select
d.DeliveryDate,
d.DeliveryNumber,
d.CustomerNumber,
d.DeliveryName1,
d.DeliveryName2,
d.DeliveryAddLine1,
d.DeliveryAddLine2,
d.DeliveryAddLine3,
d.DeliveryCity,
d.DeliveryProvince,
d.DeliveryPostalCode,
d.SalesOrder,
d.Route,
d.DeliveryInstruction1,
d.DeliveryInstruction2,
d.DeliveryInstruction3
from
	delivery d
