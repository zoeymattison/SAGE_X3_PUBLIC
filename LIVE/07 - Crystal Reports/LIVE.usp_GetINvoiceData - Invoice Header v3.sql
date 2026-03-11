USE [x3]
GO
/****** Object:  StoredProcedure [LIVE].[usp_GetInvoiceData]    Script Date: 3/10/2026 3:35:26 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [LIVE].[usp_GetInvoiceData]
    @InvoiceStart VARCHAR(50) = '0',
    @InvoiceEnd VARCHAR(50) = 'ZZZZZZZZZZZZZZZZZ',
    @CustomerStart VARCHAR(50) = '0',
    @CustomerEnd VARCHAR(50) = 'ZZZZZZZZZZZZZZZZZ',
    @InvoiceDateStart DATE = '2000-01-01',
    @InvoiceDateEnd DATE = '2099-12-31',
    @DueDateStart DATE = '2000-01-01',
    @DueDateEnd DATE = '2099-12-31',
	@BalanceFilter INT = 3
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Pre-filter the base SINVOICE table FIRST before any joins
    WITH FilteredInvoices AS (
        SELECT 
            zsih.NUM_0,
            zsih.CREDAT_0,
            zsih.ACCDAT_0,
            zsih.SNS_0,
            zsih.PTE_0,
            zsih.VAC_0,
            zsih.BPRPAY_0,
            zsih.BPAPAY_0,
            zsih.AMTNOT_0,
            zsih.AMTATI_0,
            zsih.GTE_0,
            zsih.BPRVCR_0,
            zsih.DES_0,
            zsih.DES_1,
            zsih.DES_2,
            zsih.DES_3,
            zsih.DES_4
        FROM LIVE.SINVOICE zsih
        INNER JOIN LIVE.GACCDUDATE zdud 
            ON zsih.NUM_0 = zdud.NUM_0 
            AND zsih.GTE_0 = zdud.TYP_0
        WHERE 
            -- Customer filter (most selective - filter this FIRST)
            zsih.BPRPAY_0 BETWEEN @CustomerStart AND @CustomerEnd
            
            -- Invoice number range
            AND (@InvoiceStart = '0' OR zsih.NUM_0 >= @InvoiceStart)
            AND (@InvoiceEnd = 'ZZZZZZZZZZZZZ' OR zsih.NUM_0 <= @InvoiceEnd)
            
            -- Due date range (check against GACCDUDATE)
            AND (@DueDateStart = '2000-01-01' OR zdud.DUDDAT_0 >= @DueDateStart)
            AND (@DueDateEnd = '2099-12-31' OR zdud.DUDDAT_0 <= @DueDateEnd)
            
            -- Balance filter
		AND (
			(@BalanceFilter = 1 AND (zdud.AMTCUR_0 - (zdud.PAYCUR_0 + zdud.TMPCUR_0)) = 0)
			OR 
			(@BalanceFilter = 2 AND (zdud.AMTCUR_0 - (zdud.PAYCUR_0 + zdud.TMPCUR_0)) <> 0)
			OR 
			(@BalanceFilter = 3 AND (zdud.AMTCUR_0 - (zdud.PAYCUR_0 + zdud.TMPCUR_0)) IS NOT NULL) 
		)
    ),
    SINVOICEV as (
        SELECT
            siv.NUM_0 as [Invoice],
            siv.SALFCY_0 as [Sales Site],
            siv.INVDAT_0 as [Invoice Date],
            siv.INVREF_0 as [Purchase Order],
            CASE 
                WHEN siv.SIHORINUM_0='' THEN 'Direct'
                WHEN siv.SIHORINUM_0<>'' THEN siv.SIHORINUM_0
            END as [Source],
            rep.REPNAM_0 as [Sales Rep],
            siv.BPCINV_0 as [Bill-to],
            siv.BPCORD_0 as [Ship-to],
            siv.BPAADD_0 as [Address Code],
            SUM(CASE WHEN DTA_0 = 1 THEN DTAAMT_0 ELSE 0 END) as [Invoice $ Discount],
            SUM(CASE WHEN DTA_0 = 10 THEN DTAAMT_0 ELSE 0 END) as [Discount Percent], 
            SUM(CASE WHEN DTA_0 = 10 THEN DTANOT_0 *-1 ELSE 0 END) as [Discount Percent-Amount], 
            SUM(CASE WHEN DTA_0 = 7 THEN DTAAMT_0 ELSE 0 END) as [Restock Fee Amount],
            SUM(CASE WHEN DTA_0 = 9 THEN DTAAMT_0 ELSE 0 END) as [Fuel Surharge],
            SUM(CASE WHEN DTA_0 = 8 THEN DTAAMT_0 ELSE 0 END) as [Freight Charge],
            SUM(CASE WHEN DTA_0 = 5 THEN DTAAMT_0 ELSE 0 END) as [EHF Fees],
            SUM(CASE WHEN DTA_0 = 97 THEN DTAAMT_0*-1 ELSE 0 END) as [Web Discount]
        FROM LIVE.SINVOICEV siv
        INNER JOIN FilteredInvoices fi ON siv.NUM_0 = fi.NUM_0  -- Only process filtered invoices
        LEFT JOIN LIVE.SALESREP rep ON siv.REP_0=rep.REPNUM_0
        LEFT JOIN LIVE.SVCRFOOT svf ON siv.NUM_0=svf.VCRNUM_0
        GROUP BY
            siv.NUM_0,
            siv.SALFCY_0,
            siv.INVDAT_0,
            siv.INVREF_0,
            siv.SIHORINUM_0,
            rep.REPNAM_0,
            siv.BPCINV_0,
            siv.BPCORD_0,
            siv.BPAADD_0
    ),
    SVCRVAT as (
        SELECT DISTINCT
            VCRNUM_0,
            VCRTYP_0,
            SUM(CASE WHEN VAT_0='TAX' AND VATRAT_0=12 THEN 0.25 ELSE 0 END) as [Fuel Tax GST],
            SUM(CASE WHEN VAT_0='TAX' AND VATRAT_0=12 THEN 0.35 ELSE 0 END) as [Fuel Tax PST],
            SUM(CASE WHEN VAT_0='GST' THEN AMTTAX_0 ELSE 0 END) as [GST],
            SUM(CASE WHEN VAT_0='BCPST' THEN AMTTAX_0 ELSE 0 END) as [PST]
        FROM LIVE.SVCRVAT
        WHERE EXISTS (SELECT 1 FROM FilteredInvoices fi WHERE fi.NUM_0 = VCRNUM_0)  -- Only process filtered invoices
        GROUP BY VCRNUM_0, VCRTYP_0
    ),
    EDD as (
        SELECT
            BPCNUM_0 as [Customer],
            YSENDEMAIL_0 as [EDD]
        FROM LIVE.BPCUSTOMER
        WHERE BPCNUM_0 BETWEEN @CustomerStart AND @CustomerEnd  -- Only get relevant customers
    ),
    SINVOICED as (
        SELECT
            NUM_0 as [Invoice],
            SUM(GROPRI_0*QTY_0) as [Line Amount (Before Discounts)],
            SUM(AMTNOTLIN_0) as [Line Amount (After Discounts)],
            SUM(CASE WHEN VAT_2='EHF' THEN AMTTAXLIN_2 ELSE 0 END) as [Line EHF],
            SUM(CASE WHEN (DISCRGVAL1_0<>0 OR DISCRGVAL2_0<>0) THEN (GROPRI_0-NETPRI_0)*QTY_0 ELSE 0 END) as [Line Discounts]
        FROM LIVE.SINVOICED
        WHERE EXISTS (SELECT 1 FROM FilteredInvoices fi WHERE fi.NUM_0 = SINVOICED.NUM_0)  -- Only process filtered invoices
        GROUP BY NUM_0
    ),
    SORDER as (
        SELECT
            sid.NUM_0 as [Invoice],
            sid.SOHNUM_0 as [Sales Order],
            apl.LANMES_0 as [Route],
            soh.YPICKNOTE_0 as [Shipping Instructions],
            soh.BPINAM_0 as [Bill-to Name 1],
            soh.BPINAM_1 as [Bill-to Name 2],
            soh.BPIADDLIG_0 as [Bill-to Addr 1],
            soh.BPIADDLIG_1 as [Bill-to Addr 2],
            soh.BPIADDLIG_2 as [Bill-to Addr 3],
            soh.BPICRY_0 as [Bill-to Country Code],
            soh.BPICRYNAM_0 as [Bill-to Country],
            soh.BPICTY_0 as [Bill-to City],
            soh.BPISAT_0 as [Bill-to Province],
            soh.BPIPOSCOD_0 as [Bill-to Postal Code],
            soh.BPDNAM_0 as [Ship-to Name 1],
            soh.BPDNAM_1 as [Ship-to Name 2],
            soh.BPDADDLIG_0 as [Ship-to Addr 1],
            soh.BPDADDLIG_1 as [Ship-to Addr 2],
            soh.BPDADDLIG_2 as [Ship-to Addr 3],
            soh.BPDCRY_0 as [Ship-to Country Code],
            soh.BPDCRYNAM_0 as [Ship-to Country],
            soh.BPDCTY_0 as [Ship-to City],
            soh.BPDSAT_0 as [Ship-to Province],
            soh.BPDPOSCOD_0 as [Ship-to Postal Code]
        FROM LIVE.SINVOICED sid
        INNER JOIN FilteredInvoices fi ON sid.NUM_0 = fi.NUM_0  -- Only process filtered invoices
        LEFT JOIN LIVE.SORDER soh ON sid.SOHNUM_0=soh.SOHNUM_0
        LEFT JOIN LIVE.APLSTD apl ON soh.DRN_0 = apl.LANNUM_0
            AND apl.LANCHP_0 = '409'
            AND apl.LAN_0 = 'ENG'
        WHERE sid.SIDLIN_0=1000
    ),
    BPADDRESS as (
        SELECT
            bpc.BPCNAM_0 as [Customer Name],
            bpa.BPADES_0 as [Customer Description],
            bpa.BPAADD_0 as [Address Code],
            BPANUM_0 as [Customer Number],
            BPAADDLIG_0 as [Address 1],
            BPAADDLIG_1 as [Address 2],
            BPAADDLIG_2 as [Address 3],
            CRY_0 as [Country Code],
            CRYNAM_0 as [Country],
            SAT_0 as [Province],
            POSCOD_0 as [Postal Code],
            CTY_0 as [City],
            WEB_0 as [Email]
        FROM LIVE.BPADDRESS bpa
        LEFT JOIN LIVE.BPCUSTOMER bpc ON bpa.BPANUM_0=bpc.BPCNUM_0
        WHERE bpa.BPATYP_0=1
    ),
    GACCDUDATE as (
	select
		NUM_0,
		TYP_0,
		sum(AMTCUR_0-(PAYCUR_0+TMPCUR_0)) as [Remaining],
		DUDDAT_0 as [Due Date]
	from
		LIVE.GACCDUDATE
	WHERE EXISTS (SELECT 1 FROM FilteredInvoices fi WHERE fi.NUM_0 = GACCDUDATE.NUM_0)  -- Only process filtered invoices
	group by
		NUM_0,
		TYP_0,
		DUDDAT_0
    ),
    BPDLVCUST as (
        SELECT
            BPCNUM_0 as [Customer Number],
            BPAADD_0 as [Address Code],
            LANMES_0 as [Route],
            YCOSTCENTRE_0 as [Cost Center]
        FROM LIVE.BPDLVCUST
        LEFT JOIN LIVE.APLSTD apl ON DRN_0 = apl.LANNUM_0
            AND apl.LANCHP_0 = '409'
            AND apl.LAN_0 = 'ENG'
        WHERE BPCNUM_0 BETWEEN @CustomerStart AND @CustomerEnd  -- Only get relevant customers
    )
    
    SELECT distinct
        ISNULL(zsiv.[Sales Site],'MAIN') as SALFCY_0,
        zsih.CREDAT_0 as CREDAT_0,
        zsih.ACCDAT_0 as ACCDAT_0,
        ISNULL(zsiv.[Invoice Date],zsih.CREDAT_0) as INVDAT_0,
        ISNULL(zdud.[Due Date],zsih.CREDAT_0) as DUEDATE_0,
        zsih.NUM_0 as NUM_0,
        ISNULL(zsoh.[Sales Order],'') as SOHNUM_0,
        ISNULL(zsiv.[Source],'Direct') as SIHORINUM_0,
        ISNULL(zbpd.[Cost Center],'') as COSTCNTR_0,
        CASE zsih.SNS_0
            WHEN 1 THEN 'Invoice'
            WHEN -1 THEN 'Credit Memo'
        END as SNSTYP_0,
        ISNULL(zsiv.[Purchase Order],'') as POHNUM_0,
        ISNULL(zsiv.[Sales Rep],'') as SALESREP_0,
        ISNULL(ISNULL(CAST(zsoh.[Route] AS VARCHAR),CAST(zbpd.[Route] AS VARCHAR)),'') as ROUTE_0,
        zsih.PTE_0 as PAYTRM_0,
        ISNULL(zsoh.[Shipping Instructions],'') as PIKTIKNTE_0,
        zsih.VAC_0 as TAXRULE_0,
        
        /* Bill-to*/
        ISNULL(zsiv.[Bill-to], zsih.BPRPAY_0) as BILLTO_0,
        edd.EDD as EDD_0,
        ISNULL(ISNULL(zsoh.[Bill-to Name 1], zbpa1.[Customer Name]), zbpa3.[Customer Name]) as BILLTO_NAME1_0,
        ISNULL(ISNULL(zsoh.[Bill-to Name 2], zbpa1.[Customer Description]), zbpa3.[Customer Description]) as BILLTO_NAME2_0,
        ISNULL(ISNULL(CASE WHEN zsoh.[Bill-to Addr 1] IN ('~','*') THEN '' ELSE zsoh.[Bill-to Addr 1] END, CASE WHEN zbpa1.[Address 1] IN ('~','*') THEN '' ELSE zbpa1.[Address 1] END), CASE WHEN zbpa3.[Address 1] IN ('~','*') THEN '' ELSE zbpa3.[Address 1] END) as BILLTO_ADDR1_0,
        ISNULL(ISNULL(CASE WHEN zsoh.[Bill-to Addr 2] IN ('~','*') THEN '' ELSE zsoh.[Bill-to Addr 2] END, CASE WHEN zbpa1.[Address 2] IN ('~','*') THEN '' ELSE zbpa1.[Address 2] END), CASE WHEN zbpa3.[Address 2] IN ('~','*') THEN '' ELSE zbpa3.[Address 2] END) as BILLTO_ADDR2_0,
        ISNULL(ISNULL(CASE WHEN zsoh.[Bill-to Addr 3] IN ('~','*') THEN '' ELSE zsoh.[Bill-to Addr 3] END, CASE WHEN zbpa1.[Address 3] IN ('~','*') THEN '' ELSE zbpa1.[Address 3] END), CASE WHEN zbpa3.[Address 3] IN ('~','*') THEN '' ELSE zbpa3.[Address 3] END) as BILLTO_ADDR3_0,
        ISNULL(ISNULL(zsoh.[Bill-to Country Code], zbpa1.[Country Code]), zbpa3.[Country Code]) as BILLTO_CRYCD_0,
        ISNULL(ISNULL(zsoh.[Bill-to Country], zbpa1.[Country]), zbpa3.[Country]) as BILLTO_CRYNM_0,
        ISNULL(ISNULL(zsoh.[Bill-to City], zbpa1.[City]), zbpa3.[City]) as BILLTO_CTYNM_0,
        ISNULL(ISNULL(zsoh.[Bill-to Province], zbpa1.[Province]), zbpa3.[Province]) as BILLTO_PRVCD_0,
        ISNULL(ISNULL(zsoh.[Bill-to Postal Code], zbpa1.[Postal Code]), zbpa3.[Postal Code]) as BILLTO_POSCD_0,
        ISNULL(zbpa1.[Email], zbpa3.[Email]) as BILLTO_EMAIL_0,
        
        /* Ship-to */
        ISNULL(zsiv.[Ship-to], '') as SHPTO_0,
        ISNULL(IIF(LTRIM(RTRIM(zsoh.[Ship-to Name 1]))='',zbpa2.[Customer Name], zsoh.[Ship-to Name 1]), zbpa2.[Customer Name]) as SHPTO_NAME1_0,
        ISNULL(IIF(LTRIM(RTRIM(zsoh.[Ship-to Name 2]))='',zbpa2.[Customer Description],zsoh.[Ship-to Name 2]), zbpa2.[Customer Description]) as SHPTO_NAME2_0,
        ISNULL(ISNULL(CASE WHEN zsoh.[Ship-to Addr 1] IN ('~','*') THEN '' ELSE zsoh.[Ship-to Addr 1] END, CASE WHEN zbpa2.[Address 1] IN ('~','*') THEN '' ELSE zbpa2.[Address 1] END), '') as SHPTO_ADDR1_0,
        ISNULL(ISNULL(CASE WHEN zsoh.[Ship-to Addr 2] IN ('~','*') THEN '' ELSE zsoh.[Ship-to Addr 2] END, CASE WHEN zbpa2.[Address 2] IN ('~','*') THEN '' ELSE zbpa2.[Address 2] END), '') as SHPTO_ADDR2_0,
        ISNULL(ISNULL(CASE WHEN zsoh.[Ship-to Addr 3] IN ('~','*') THEN '' ELSE zsoh.[Ship-to Addr 3] END, CASE WHEN zbpa2.[Address 3] IN ('~','*') THEN '' ELSE zbpa2.[Address 3] END), '') as SHPTO_ADDR3_0,
        ISNULL(ISNULL(zsoh.[Ship-to Country Code], zbpa2.[Country Code]), '') as SHPTO_CRYCD_0,
        ISNULL(ISNULL(zsoh.[Ship-to Country], zbpa2.[Country]), '') as SHPTO_CRYNM_0,
        ISNULL(ISNULL(zsoh.[Ship-to City], zbpa2.[City]), '') as SHPTO_CTYNM_0,
        ISNULL(ISNULL(zsoh.[Ship-to Province], zbpa2.[Province]), '') as SHPTO_PRVCD_0,
        ISNULL(ISNULL(zsoh.[Ship-to Postal Code], zbpa2.[Postal Code]), '') as SHPTO_POSCD_0,
        ISNULL(zbpa2.[Email], '') as SHIPT_EMAIL_0,
        
        /* Pay-by */
        zsih.BPRPAY_0 as PAYBY_0,
        zbpa3.[Customer Name] as PAYBY_NAME1_0,
        zbpa3.[Customer Description] as PAYBY_NAME2_0,
        CASE WHEN zbpa3.[Address 1] IN ('~','*') THEN '' ELSE zbpa3.[Address 1] END as PAYBY_ADDR1_0,
        CASE WHEN zbpa3.[Address 2] IN ('~','*') THEN '' ELSE zbpa3.[Address 2] END as PAYBY_ADDR2_0,
        CASE WHEN zbpa3.[Address 3] IN ('~','*') THEN '' ELSE zbpa3.[Address 3] END as PAYBY_ADDR3_0,
        zbpa3.[Country Code] as PAYBY_CRYCD_0,
        zbpa3.[Country] as PAYBY_CRYNM_0,
        zbpa3.[City] as PAYBY_CTYNM_0,
        zbpa3.[Province] as PAYBY_PRVCD_0,
        zbpa3.[Postal Code] as PAYBY_POSCD_0,
        zbpa3.[Email] as PAYBY_EMAIL_0,
        
        /* Line Total */
        ISNULL(zsid.[Line Amount (Before Discounts)]*zsih.SNS_0,0) as LINESUBTOT_0,
        
        /* Discounts */
        ISNULL(zsid.[Line Discounts]*zsih.SNS_0,0) as LINEDISCOUNT_0,
        ISNULL((zsiv.[Web Discount]+zsiv.[Invoice $ Discount])*zsih.SNS_0,0) as INVDISCAMT_0,
        ISNULL(CASE WHEN zsiv.[Discount Percent]>0 THEN (zsid.[Line Amount (After Discounts)]-zsih.AMTNOT_0)*zsih.SNS_0 ELSE 0 END,0) as INVDISCPAMT_0,
        ISNULL(CASE WHEN zsiv.[Discount Percent]>0 THEN (zsid.[Line Amount (After Discounts)]-zsih.AMTNOT_0)*zsih.SNS_0 ELSE 0 END+(zsiv.[Web Discount]+zsiv.[Invoice $ Discount]+zsid.[Line Discounts])*zsih.SNS_0,0) as INVDISCTOT_0,
        
        /* Invoicing Elements */
        ISNULL(zsiv.[Freight Charge]*zsih.SNS_0,0) as INV_ELM_FRT_0,
        ISNULL(zsiv.[Fuel Surharge]*zsih.SNS_0,0) as INV_ELM_FSC_0,
        ISNULL(zsiv.[Restock Fee Amount]*zsih.SNS_0,0) as INV_ELM_RSF_0,
        
        /* Totals */
        ISNULL((zsih.AMTNOT_0-isnull(zsiv.[Freight Charge],0)-isnull(zsiv.[Fuel Surharge],0))*zsih.SNS_0,0) as INV_SUBTOTAL_0,
        
        /* EHF */
        ISNULL(zsid.[Line EHF],0) as TAX_EHF_0,
        
        /* Taxes */
        ISNULL(svt.[GST]+svt.[Fuel Tax GST],0)*zsih.SNS_0 as TAX_GST_0,
        ISNULL(svt.[PST]+svt.[Fuel Tax PST],0)*zsih.SNS_0 as TAX_PST_0,
        
        zsih.AMTATI_0*zsih.SNS_0 as INV_TOTAL_0,
        
        /* Invoice Status */
        zdud.[Remaining]*zsih.SNS_0 as INV_REMAIN_0,
        CASE
            WHEN zdud.[Remaining]<>0 THEN 2
            WHEN zdud.[Remaining]=0 THEN 1
        END as INV_OWINGBAL_0,
        zsih.GTE_0 as TYPE_INV_0,
        '' as TYPE_SOH_0,
        
        /* Comments */
        zsih.BPRVCR_0 as BPRVCR_0,
        zsih.DES_0+' '+zsih.DES_1+' '+zsih.DES_2+' '+zsih.DES_3+' '+zsih.DES_4 as COMMENTS_0
        
    FROM FilteredInvoices zsih
    LEFT JOIN SINVOICEV zsiv ON zsih.NUM_0=zsiv.[Invoice]
    LEFT JOIN SINVOICED zsid ON zsih.NUM_0=zsid.[Invoice]
    LEFT JOIN SORDER zsoh ON zsih.NUM_0=zsoh.[Invoice]
    LEFT JOIN BPADDRESS zbpa1 ON zsiv.[Address Code]=zbpa1.[Address Code] AND zsiv.[Bill-to]=zbpa1.[Customer Number]
    LEFT JOIN BPADDRESS zbpa2 ON zsiv.[Address Code]=zbpa2.[Address Code] AND zsiv.[Ship-to]=zbpa2.[Customer Number]
    INNER JOIN BPADDRESS zbpa3 ON zsih.BPAPAY_0=zbpa3.[Address Code] AND zsih.BPRPAY_0=zbpa3.[Customer Number]
    INNER JOIN GACCDUDATE zdud ON zsih.NUM_0=zdud.NUM_0 AND zsih.GTE_0=zdud.TYP_0
    LEFT JOIN BPDLVCUST zbpd ON zsiv.[Address Code]=zbpd.[Address Code] AND zsiv.[Ship-to]=zbpd.[Customer Number]
    INNER JOIN EDD edd ON ISNULL(zsiv.[Bill-to], zsih.BPRPAY_0)=edd.[Customer]
    LEFT JOIN SVCRVAT svt ON zsih.NUM_0=svt.VCRNUM_0 AND svt.VCRTYP_0=4
    WHERE 
        -- Invoice date filter (applied here because it references a computed column from CTE)
        (@InvoiceDateStart = '2000-01-01' OR ISNULL(zsiv.[Invoice Date], zsih.CREDAT_0) >= @InvoiceDateStart)
        AND (@InvoiceDateEnd = '2099-12-31' OR ISNULL(zsiv.[Invoice Date], zsih.CREDAT_0) <= @InvoiceDateEnd)
    
    OPTION (RECOMPILE);  -- Dynamic query plans based on parameters
END
