SELECT
ITMREF_0,
ITMDES1_0,
TSICOD_0,
UPDUSR_0,
UPDDAT_0,
YDISDAT_0,
Case ITMSTA_0
When 1 then 'Active'
When 2 then 'In development'
When 3 then 'On shortage'
When 4 then 'Not renewed'
When 5 then 'Obsolete'
When 6 then 'Not usable'
End
FROM LIVE.ITMMASTER

WHERE (YDISDAT_0<='19000101' or YDISDAT_0 IS NULL) and TSICOD_0 IN ('DM','DS')