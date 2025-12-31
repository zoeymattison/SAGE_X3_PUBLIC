DECLARE @Today DATE = CAST(GETDATE()-7 AS DATE);
DECLARE @MonthStart DATE = DATEFROMPARTS(YEAR(@Today), MONTH(@Today), 1);

WITH retail_sales AS (
    SELECT
        a.CCE_0,
        CASE 
            WHEN a.CCE_0 IN ('DC30','DC33') THEN 'DC30/DC33'
            ELSE a.CCE_0
        END AS CCE_Group,
        a.CCE_1,
        d.ACCDAT_0,
        CASE
			WHEN CCE_0 IN ('COUR','FORT','SID','OAK') AND a.CCE_1 = 'COPYCENTRE' THEN '3 - Copycenter'
            WHEN CCE_0 IN ('FORT','SID') AND a.CCE_1 = 'FR' THEN '4 - Framing'
            WHEN CCE_0 IN ('COUR','FORT','SID') THEN '1 - Retail'
            WHEN CCE_0 IN ('DC30','DC33','OAK') THEN '2 - Commercial'
        END AS [Row],
        a.AMTCUR_0 * (a.SNS_0 * -1) AS Amount,
        CASE WHEN d.ACCDAT_0 = @Today THEN 1 ELSE 0 END AS IsToday,

        -- Flags
        CASE 
            WHEN a.CCE_1 IN ('DIRTT','FURN','FURNSERVC') THEN 1 ELSE 0
        END AS IsFurn,
        CASE 
            WHEN a.CCE_1 IN ('OM','CO','ET','SS','CPC','TS') THEN 1 ELSE 0
        END AS IsTech,
        CASE 
            WHEN a.CCE_1 IN ('OP','CRD','DB','CB','FAC','TP','TCR','STAMPS','COPYCENTRE','CPRNTCOPY','AE','FR') THEN 1 ELSE 0
        END AS IsStat,
        CASE 
            WHEN a.CCE_1 = 'COPYCENTRE' THEN 1 ELSE 0
        END AS IsCopy,
        CASE 
            WHEN a.CCE_1 = 'FR' THEN 1 ELSE 0
        END AS IsFrame,

        -- Commercial flags
        CASE 
            WHEN a.CCE_1 IN ('OP','CRD','DB','CB','FAC','TP','TCR','STAMPS','COPYCENTRE','CPRNTCOPY') THEN 1 ELSE 0
        END AS IsStatEx,
        CASE 
            WHEN a.CCE_1 IN ('AE','FR') THEN 1 ELSE 0
        END AS IsArt,
        CASE 
            WHEN a.CCE_1 IN ('OM','CO','ET','SS') THEN 1 ELSE 0
        END AS IsTechEx,
        CASE 
            WHEN a.CCE_1 IN ('CPC','TS') THEN 1 ELSE 0
        END AS IsService

    FROM
        LIVE.GACCENTRYD d WITH (NOLOCK)
        INNER JOIN LIVE.GACCENTRYA a WITH (NOLOCK)
            ON d.TYP_0 = a.TYP_0
            AND d.NUM_0 = a.NUM_0
            AND d.LIN_0 = a.LIN_0
            AND d.LEDTYP_0 = a.LEDTYP_0
            AND d.ACC_0 = a.ACC_0
    WHERE
        d.ACC_0 in ('41100','41900')
        AND d.CPY_0 = 'MONK'
        AND d.ACCDAT_0 between @MonthStart and '2025-09-30'
        AND a.CCE_0 IN ('COUR','SID','FORT','DC30','DC33','OAK')
)
SELECT
    @Today AS QueryDate,
    @MonthStart AS MonthStart,
    [Row] AS Section,
    CCE_Group AS CCE_0,

    -- Retail
    SUM(CASE WHEN [Row] = '1 - Retail' AND IsToday = 1 AND IsFurn = 1 THEN Amount ELSE 0 END) AS [RET_FURN_T],
    SUM(CASE WHEN [Row] = '1 - Retail' AND IsToday = 1 AND IsTech = 1 THEN Amount ELSE 0 END) AS [RET_TECH_T],
    SUM(CASE WHEN [Row] = '1 - Retail' AND IsToday = 1 AND IsStat = 1 THEN Amount ELSE 0 END) AS [RET_STAT_T],
    SUM(CASE WHEN [Row] = '1 - Retail' AND (IsFurn = 1 OR IsTech = 1 OR IsStat = 1) THEN Amount ELSE 0 END) AS [RET_M],
    SUM(CASE WHEN [Row] = '1 - Retail' AND IsFurn = 1 THEN Amount ELSE 0 END) AS [RET_FURN_M],
    SUM(CASE WHEN [Row] = '1 - Retail' AND IsTech = 1 THEN Amount ELSE 0 END) AS [RET_TECH_M],
    SUM(CASE WHEN [Row] = '1 - Retail' AND IsStat = 1 THEN Amount ELSE 0 END) AS [RET_STAT_M],

    -- Commercial
    SUM(CASE WHEN [Row] = '2 - Commercial' AND IsToday = 1 AND (IsStatEx=1 OR IsArt=1 OR IsFurn=1 OR IsTechEx=1 OR IsService=1) THEN Amount ELSE 0 END) AS [COM_T],
    SUM(CASE WHEN [Row] = '2 - Commercial' AND IsStatEx=1 THEN Amount ELSE 0 END) AS [COM_STAT_M],
    SUM(CASE WHEN [Row] = '2 - Commercial' AND IsArt=1 THEN Amount ELSE 0 END) AS [COM_ART_M],
    SUM(CASE WHEN [Row] = '2 - Commercial' AND IsFurn=1 THEN Amount ELSE 0 END) AS [COM_FURN_M],
    SUM(CASE WHEN [Row] = '2 - Commercial' AND IsTechEx=1 THEN Amount ELSE 0 END) AS [COM_TECH_M],
    SUM(CASE WHEN [Row] = '2 - Commercial' AND IsService=1 THEN Amount ELSE 0 END) AS [COM_SERV_M],

    -- Copycenter
    SUM(CASE WHEN [Row] = '3 - Copycenter' AND IsToday = 1 AND IsCopy = 1 THEN Amount ELSE 0 END) AS [COPY_T],
    SUM(CASE WHEN [Row] = '3 - Copycenter' AND IsCopy = 1 THEN Amount ELSE 0 END) AS [COPY_M],

    -- Framing
    SUM(CASE WHEN [Row] = '4 - Framing' AND IsToday = 1 AND IsFrame = 1 THEN Amount ELSE 0 END) AS [FRAME_T],
    SUM(CASE WHEN [Row] = '4 - Framing' AND IsFrame = 1 THEN Amount ELSE 0 END) AS [FRAME_M]

FROM retail_sales
GROUP BY [Row],CCE_Group
ORDER BY [Row],CCE_Group;
