SELECT
POQ.CREDAT_0 as [Date Created],
POQ.POHNUM_0 as [Purchase Order],
POQ.EXTRCPDAT_0 as [Expected Date],
POQ.ITMREF_0 as [Product],
ITM.ITMDES1_0+' '+ITM.ITMDES2_0 as [Description],
POQ.QTYPUU_0 as [QTY Ordered],
POQ.RCPQTYPUU_0 as [QTY Received],
POQ.LINAMT_0 as [Line Value]

FROM LIVE.PORDERQ POQ
LEFT JOIN LIVE.ITMMASTER ITM ON POQ.ITMREF_0=ITM.ITMREF_0

WHERE POQ.LINCLEFLG_0=1 AND POQ.BPSNUM_0='V99630'

ORder by POQ.POHNUM_0, POQ.POPLIN_0