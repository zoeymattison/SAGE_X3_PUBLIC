WITH LastLetter AS (
    SELECT 
        BPR_0 as Customer,
        MTC_0 as LastMatchingLetter,
        LEN(MTC_0) as [MTC Length]
    FROM LIVE.GACCENTRYD 
    WHERE MTC_0 = UPPER(MTC_0)
        AND MTC_0 <> ''
        AND MTC_0 IS NOT NULL
        AND LEN(MTC_0) > 0
)
SELECT
    Customer,
    LastMatchingLetter as [Last Matching Letter],
    CASE
        WHEN RIGHT(LastMatchingLetter, 1) <> 'Z' THEN
            STUFF(LastMatchingLetter, LEN(LastMatchingLetter), 1, 
                  CHAR(ASCII(RIGHT(LastMatchingLetter, 1)) + 1))
        
        WHEN LastMatchingLetter = REPLICATE('Z', LEN(LastMatchingLetter)) THEN
            REPLICATE('A', LEN(LastMatchingLetter) + 1)
        
        ELSE
            CASE 
                WHEN PATINDEX(CHAR(37) + CHAR(91) + CHAR(94) + 'Z' + CHAR(93) + CHAR(37), REVERSE(LastMatchingLetter)) > 0 THEN
                    LEFT(LastMatchingLetter, 
                         LEN(LastMatchingLetter) - PATINDEX(CHAR(37) + CHAR(91) + CHAR(94) + 'Z' + CHAR(93) + CHAR(37), REVERSE(LastMatchingLetter))) +
                    CHAR(ASCII(SUBSTRING(LastMatchingLetter, 
                                       LEN(LastMatchingLetter) - PATINDEX(CHAR(37) + CHAR(91) + CHAR(94) + 'Z' + CHAR(93) + CHAR(37), REVERSE(LastMatchingLetter)) + 1, 
                                       1)) + 1) +
                    REPLICATE('A', PATINDEX(CHAR(37) + CHAR(91) + CHAR(94) + 'Z' + CHAR(93) + CHAR(37), REVERSE(LastMatchingLetter)) - 1)
                ELSE
                    REPLICATE('A', LEN(LastMatchingLetter) + 1)
            END
    END as [Next Matching Letter],
	[MTC Length]
FROM LastLetter
