 ( USRDAT_0 , SITE_0 , ROUTE_0 , PIC_0 , PLN_0 , SDHNUM_0 , SOHNUM_0 
 , NEXTSTEP_0 , PBCNAM_0 , REP_0 , NUMLIN_0 ) As 

SELECT        CREDAT_0, STOFCY_0, '' as 'Route', '' as 'PIC', '' AS 'PLN', SDHNUM_0, SOHNUM_0, '0.Validate intersite' AS 'STA', BPCORD_0 + ',' + BPDNAM_0 AS'BP', REP_0, 0 AS'#'
FROM            LIVE.SDELIVERY
WHERE        BETFCY_0 = 2 AND CFMFLG_0 = 1
UNION
SELECT        CREDAT_0, STOFCY_0, '', '', PRLNUM_0, '', 'more than 1', '1.Create pick', 'more than 1', '', 0
FROM            LIVE.STOPRELIS
WHERE        PRHNUM_0 = ''
UNION
SELECT        CREDAT_0, STOFCY_0, '', PRHNUM_0, PRLNUM_0, SDHNUM_0, isnull
                             ((SELECT        TOP 1 ORINUM_0
                                 FROM            LIVE.STOPRELIS
                                 WHERE        STOPRELIS.PRHNUM_0 = STOPREH.PRHNUM_0), ''), '2.Invoice' AS [Next Step], ISNULL
                             ((SELECT        BPCORD_0 + ',' + BPDNAM_0
                                 FROM            LIVE.SDELIVERY
                                 WHERE        SDELIVERY.SDHNUM_0 = STOPREH.SDHNUM_0), ''), ISNULL
                             ((SELECT        REP_0
                                 FROM            LIVE.SDELIVERY
                                 WHERE        SDELIVERY.SDHNUM_0 = STOPREH.SDHNUM_0), ''), 0
FROM            LIVE.STOPREH
WHERE        SDHNUM_0 <> '' AND SDHTYP_0 = 'SDH'
GROUP BY CREDAT_0, STOFCY_0, PRHNUM_0, PRLNUM_0, SDHNUM_0
HAVING        ISNULL
                             ((SELECT        INVFLG_0
                                 FROM            LIVE.SDELIVERY
                                 WHERE        SDELIVERY.SDHNUM_0 = STOPREH.SDHNUM_0), 1) = 1 AND ISNULL
                             ((SELECT        BETFCY_0
                                 FROM            LIVE.SDELIVERY
                                 WHERE        SDELIVERY.SDHNUM_0 = STOPREH.SDHNUM_0), 1) = 1
UNION
SELECT        CREDAT_0, STOFCY_0, DRN_0, PRHNUM_0, PRLNUM_0, SDHNUM_0, isnull
                             ((SELECT        TOP 1 ORINUM_0
                                 FROM            LIVE.STOPRELIS
                                 WHERE        STOPRELIS.PRHNUM_0 = STOPREH.PRHNUM_0), ''), '3.Deliver' AS [Next Step],
                             (SELECT        BPCORD_0 + ',' + BPDNAM_0
                               FROM            LIVE.SORDER
                               WHERE        SOHNUM_0 =
                                                             (SELECT        TOP 1 ORINUM_0
                                                               FROM            LIVE.STOPRELIS
                                                               WHERE        STOPRELIS.PRHNUM_0 = STOPREH.PRHNUM_0)),
                             (SELECT        REP_0
                               FROM            LIVE.SORDER
                               WHERE        SOHNUM_0 =
                                                             (SELECT        TOP 1 ORINUM_0
                                                               FROM            LIVE.STOPRELIS
                                                               WHERE        STOPRELIS.PRHNUM_0 = STOPREH.PRHNUM_0)),
                             (SELECT        count(*)
                               FROM            LIVE.STOPRED
                               WHERE        PRHNUM_0 = STOPREH.PRHNUM_0)
FROM            LIVE.STOPREH
WHERE        SDHNUM_0 = '' AND DLVFLG_0 <> 4
