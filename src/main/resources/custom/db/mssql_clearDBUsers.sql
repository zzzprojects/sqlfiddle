USE [master]
GO

/****** Object:  StoredProcedure [dbo].[clearDBUsers]    Script Date: 8/25/2012 8:39:29 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[clearDBUsers] 
    @dbName SYSNAME 
AS 
BEGIN 
    SET NOCOUNT ON 
 
    DECLARE @spid INT, 
        @cnt INT, 
        @sql VARCHAR(255) 
 
    SELECT @spid = MIN(spid), @cnt = COUNT(*) 
        FROM master..sysprocesses 
        WHERE dbid = DB_ID(@dbname) 
        AND spid != @@SPID 
 
    PRINT 'Starting to KILL '+RTRIM(@cnt)+' processes.' 
     
    WHILE @spid IS NOT NULL 
    BEGIN 
        PRINT 'About to KILL '+RTRIM(@spid)  
        SET @sql = 'KILL '+RTRIM(@spid) 
        EXEC(@sql)  
        SELECT @spid = MIN(spid), @cnt = COUNT(*) 
            FROM master..sysprocesses 
            WHERE dbid = DB_ID(@dbname) 
            AND spid != @@SPID  
        PRINT RTRIM(@cnt)+' processes remain.' 
    END 
END


GO


