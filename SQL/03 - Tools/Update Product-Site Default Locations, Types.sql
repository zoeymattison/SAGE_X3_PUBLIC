-- NOTE: This only works if the default location setup already exists.
-- 1. Updates default status by Category/Facility/Transaction Type
-- Note: This applies to ALL items sharing these categories at DC30
UPDATE LIVE.TABSTORUL
SET DEFSTA_0 = 'A'
WHERE STOFCY_0 = 'DC30'
  AND TRSTYP_0 = 3
  AND TCLCOD_0 IN (
      SELECT DISTINCT i.TCLCOD_0
      FROM LIVE.ITMMASTER i
      INNER JOIN LIVE.ITMBPS b 
          ON i.ITMREF_0 = b.ITMREF_0
          AND b.PIO_0 = 0
          AND b.BPSNUM_0 = 'V6501'
          AND b.CTMBPSFLG_0 = 2
      WHERE i.ITMREF_0 NOT IN ('14421', '40BOXPLC')
  );

-- 2. Updates default location & type for DC30 specifically
UPDATE LIVE.ITMFACILIT
SET DEFLOCTYP_0 = 'WHS2',
    DEFLOC_0 = 'B2BRC'
WHERE STOFCY_0 = 'DC30'
  AND ITMREF_0 IN (
      SELECT DISTINCT i.ITMREF_0
      FROM LIVE.ITMMASTER i
      INNER JOIN LIVE.ITMBPS b 
          ON i.ITMREF_0 = b.ITMREF_0
          AND b.PIO_0 = 0
          AND b.BPSNUM_0 = 'V6501'
          AND b.CTMBPSFLG_0 = 2
      WHERE i.ITMREF_0 NOT IN ('14421', '40BOXPLC')
  );