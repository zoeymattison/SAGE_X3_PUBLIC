 ( NUM_0 , PTHNUM_0 , BPR_0 , BPRNAM_0 ) As 
SELECT distinct
	g.NUM_0,
    LEFT(g.DES_0, CHARINDEX('/', g.DES_0 + '/') - 1) AS ReceiptNumber,
    p.BPSNUM_0,
	b.BPRNAM_0
FROM LIVE.GACCENTRYD g
inner JOIN LIVE.PRETURN p
    ON LEFT(g.DES_0, CHARINDEX('/', g.DES_0 + '/') - 1) = p.PNHNUM_0
left join LIVE.BPARTNER b on p.BPSNUM_0=b.BPRNUM_0
