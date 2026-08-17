USE [x3]
GO
/****** Object:  StoredProcedure [LIVE].[usp_UpdateQTYNVX]    Script Date: 8/17/2026 1:29:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- Creates or updates the stored procedure (SQL Server 2016 SP1 or newer)
ALTER   PROCEDURE [LIVE].[usp_UpdateQTYNVX]
AS
BEGIN
    -- Suppress row count messages for cleaner execution logs
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        -- Table variable to capture altered rows
        DECLARE @UpdatedRows TABLE (
            ITMREF_0 VARCHAR(20),
            OLD_QTY  NUMERIC(28, 8),
            NEW_QTY  NUMERIC(28, 8)
        );

        -- Perform set-based update and capture changed states
        UPDATE mvt
        SET mvt.ZQTYNVX_0   = mst.ZQTYNVX_0 + mvt.PHYSTO_0,
            mvt.UPDDAT_0    = CAST(GETDATE() AS DATE),
            mvt.UPDDATTIM_0 = GETDATE(),
            mvt.UPDUSR_0    = 'ADMIN'
        OUTPUT 
            inserted.ITMREF_0,
            deleted.ZQTYNVX_0,
            inserted.ZQTYNVX_0
        INTO @UpdatedRows (ITMREF_0, OLD_QTY, NEW_QTY)
        FROM LIVE.ITMMVT mvt WITH (UPDLOCK)
        INNER JOIN LIVE.ITMMASTER mst WITH (NOLOCK)
            ON mvt.ITMREF_0 = mst.ITMREF_0
        WHERE mvt.STOFCY_0 = 'DC30'
          AND mvt.ZQTYNVX_0 <> (mst.ZQTYNVX_0 + mvt.PHYSTO_0);

        COMMIT TRANSACTION;

        -- Iterate captured rows and output messages to the buffer
        DECLARE @ItmRef VARCHAR(20);
        DECLARE @OldQty NUMERIC(28, 8);
        DECLARE @NewQty NUMERIC(28, 8);
        DECLARE @Msg    NVARCHAR(255);

        DECLARE msg_cursor CURSOR LOCAL FAST_FORWARD FOR
            SELECT ITMREF_0, OLD_QTY, NEW_QTY
            FROM @UpdatedRows;

        OPEN msg_cursor;
        FETCH NEXT FROM msg_cursor INTO @ItmRef, @OldQty, @NewQty;

        WHILE @@FETCH_STATUS = 0
        BEGIN
            -- Format: mst.ITMREF_0: OLD_QTY >> NEW_QTY
            -- RTRIM handles trailing spaces common in Sage X3 CHAR/VARCHAR fields
            SET @Msg = RTRIM(@ItmRef) + ': ' 
                     + CAST(@OldQty AS VARCHAR(50)) 
                     + ' >> ' 
                     + CAST(@NewQty AS VARCHAR(50));

            -- RAISERROR WITH NOWAIT pushes the message to the client buffer without waiting for execution completion
            RAISERROR(@Msg, 0, 1) WITH NOWAIT;

            FETCH NEXT FROM msg_cursor INTO @ItmRef, @OldQty, @NewQty;
        END;

        CLOSE msg_cursor;
        DEALLOCATE msg_cursor;

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        -- Re-throw error so SQL Server Agent logs the step as Failed
        THROW;
    END CATCH
END;
