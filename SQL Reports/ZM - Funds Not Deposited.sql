SELECT 
    HAE.FIY_0,
    HAE.PER_0,
    DAE.ACC_0,
    DAE.NUM_0,
    HAE.REF_0,
    RIGHT(HAE.REFINT_0, LEN(HAE.REFINT_0) - 4) AS REFINT_0,
    PYD.VCRNUM_0,
    HAE2.NUM_0 AS BANK_NUM_0,
    ISNULL(SDH.SOHNUM_0, '') AS SOHNUM_0,
    DUD.AMTCUR_0 * DUD.SNS_0 AS DUD_AMOUNT,
    DAE.AMTCUR_0 * DAE.SNS_0 AS DAE_AMOUNT,
    HAE.ACCDAT_0

FROM LIVE.GACCENTRYD DAE
LEFT JOIN LIVE.GACCENTRY HAE 
    ON DAE.NUM_0 = HAE.NUM_0 
    AND DAE.TYP_0 = HAE.TYP_0
LEFT JOIN LIVE.PAYMENTD PYD 
    ON RIGHT(HAE.REFINT_0, LEN(HAE.REFINT_0) - 4) = PYD.NUM_0
LEFT JOIN LIVE.SINVOICEV SIV 
    ON PYD.VCRNUM_0 = SIV.NUM_0
LEFT JOIN LIVE.SDELIVERY SDH 
    ON SIV.SIHORINUM_0 = SDH.SDHNUM_0
LEFT JOIN LIVE.GACCDUDATE DUD 
    ON SIV.NUM_0 = DUD.NUM_0
LEFT JOIN LIVE.GACCENTRY HAE2
    ON HAE2.REF_0 = HAE.REF_0 
    AND LEFT(HAE2.NUM_0,4)='BANK' 
    AND HAE2.TYP_0 IN ('RECPT', 'PAYMT')

WHERE
    HAE.REFINT_0 <> ''
    AND HAE.CAT_0 = 1
    AND (
        (LEFT(HAE.NUM_0, 5) = 'DEPOS' AND DAE.ACC_0 = '10400')
        OR (LEFT(HAE.NUM_0, 4) = 'BANK' AND DAE.ACC_0 = '10100' AND LEFT(HAE.REFINT_0, 9) = 'PYH PAYC1')
    );