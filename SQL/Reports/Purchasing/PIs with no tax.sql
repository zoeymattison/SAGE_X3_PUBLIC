SELECT 
    CREDAT_0, ACCDAT_0, NUM_0, BPR_0, BPRNAM_0, BPRPAY_0, BPYNAM_0, 
    AMTTAX_0, AMTATI_0, VAC_0, TAX_0, TAX_1, CUR_0
FROM 
    LIVE.PINVOICE v 
WHERE 
    AMTTAX_0 = 0 
    AND ACCDAT_0 BETWEEN '2024-07-01' AND '2025-11-30'
    -- This ensures at least one PO exists for the supplier
    AND EXISTS (
        SELECT 1 
        FROM LIVE.PORDER p 
        WHERE p.BPSNUM_0 = v.BPR_0
    )
ORDER BY 
    ACCDAT_0 ASC;