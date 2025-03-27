SELECT DISTINCT
SOH.CREDAT_0,
SOH.SHIDAT_0,
SOH.SOHNUM_0,
SOH.BPCORD_0,
BPC.BPCNAM_0,
CASE SOH.DRN_0
WHEN '1' THEN 'M'
WHEN '2' THEN '1'
WHEN '3' THEN '2'
WHEN '4' THEN '3'
WHEN '5' THEN '4'
WHEN '6' THEN '5'
WHEN '7' THEN '6'
WHEN '8' THEN '7'
WHEN '9' THEN '8'
WHEN '10' THEN '9'
WHEN '11' THEN 'C'
WHEN '12' THEN 'GAN'
WHEN '13' THEN 'RJH'
WHEN '14' THEN 'SKE'
WHEN '15' THEN '11'
WHEN '16' THEN '12'
WHEN '17' THEN '17'
WHEN '18' THEN '18'
WHEN '19' THEN '3T'
WHEN '20' THEN '1T'
WHEN '21' THEN '3TUI'
WHEN '22' THEN 'MOT'
WHEN '23' THEN 'PU'
WHEN '24' THEN 'OAK'
WHEN '25' THEN 'SID'
WHEN '26' THEN 'RLY'
WHEN '27' THEN 'FRT'
WHEN '28' THEN 'BOL'
WHEN '29' THEN 'BRD'
WHEN '30' THEN 'MAX'
WHEN '31' THEN 'OAK'
WHEN '32' THEN 'TSC'
WHEN '33' THEN 'ACE'
WHEN '34' THEN 'VSS'
WHEN '35' THEN '31'
WHEN '36' THEN 'DS'
WHEN '37' THEN 'MOW'
WHEN '38' THEN 'GEA'
WHEN '39' THEN 'SD'
WHEN '40' THEN '6S'
WHEN '41' THEN 'SSI'
WHEN '42' THEN 'QI'
WHEN '43' THEN 'PA'
WHEN '44' THEN 'CoC'
WHEN '45' THEN 'IBF'
WHEN '46' THEN 'IBS'
WHEN '47' THEN 'PKW'
WHEN '48' THEN 'MIK'
END,
STP.PRHNUM_0,
PRH.SDHNUM_0,
CASE SOH.INVSTA_0
WHEN 1 THEN 'NOT INVOICED'
WHEN 2 THEN 'PARTIALLY INVOICED'
END

FROM LIVE.SORDER SOH
LEFT OUTER JOIN LIVE.STOPRELIS STP ON SOH.SOHNUM_0 = STP.ORINUM_0
LEFT OUTER JOIN LIVE.STOPREH PRH ON STP.PRHNUM_0 = PRH.PRHNUM_0
LEFT OUTER JOIN LIVE.BPCUSTOMER BPC ON SOH.BPCORD_0 = BPC.BPCNUM_0

WHERE SOH.ORDSTA_0 = 1 AND SOH.DME_0 = 3 AND SOH.ALLSTA_0 = 3 AND SOH.BETFCY_0 = 1 and SOH.SHIDAT_0 <= CONVERT(VARCHAR,GETDATE(),101)
AND SOH.REP_0 <> '37'
AND SOH.REP_0 <> '88'
AND SOH.REP_0 <> '2221'
AND SOH.REP_0 <> '54'
AND SOH.REP_0 <> '85'
AND SOH.REP_0 <> '49'
AND SOH.DRN_0 <> '19'
AND SOH.DRN_0 <> '20'
AND SOH.DRN_0 <> '21'
AND SOH.DRN_0 <> '22'