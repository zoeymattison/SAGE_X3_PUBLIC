UPDATE i
SET i.ZNETEXCL_0 = 2
FROM LIVE.ITMMASTER i
WHERE 
    -- Condition 1: Item exists in ITMBPS with specific vendors and PIO=0
    EXISTS (
        SELECT 1 
        FROM LIVE.ITMBPS b 
        WHERE b.ITMREF_0 = i.ITMREF_0 
          AND b.BPSNUM_0 IN ('V950','V1990','V2382','V2181','V33000','V6160','V2373') 
          AND b.PIO_0 = 0
    )
    OR 
    -- Condition 2: Item does not exist in ITMBPS at all
    NOT EXISTS (
        SELECT 1 
        FROM LIVE.ITMBPS b2 
        WHERE b2.ITMREF_0 = i.ITMREF_0
    );