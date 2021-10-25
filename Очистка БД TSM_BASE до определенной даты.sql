USE [TSM_BASE]

DECLARE @date DATE;
DECLARE @strDate VARCHAR(10);
DECLARE @tableName VARCHAR(400); -- èìÿ òàáëèöû
DECLARE @DELETE BIT;

BEGIN TRY
--------------------------ÏÀÐÀÌÅÒÐÛ-----------------------------------
----------------------------------------------------------------------
	SET @date = '2020-01-01'; --ÃÃÃÃ-ÌÌ-××. ×èñëî, ìåíüøå êîòîðîãî íóæíî óäàëèòü âñå ñòðîêè èç òàáëèö 'HISTORY_*'
	SET @DELETE = 1 -- 0-íå óäàëÿòü ñòðîêè, òîëüêî ïîêàçàòü êàêèå áóäóò óäàëåíû, 1-óäàëèòü ñòðîêè èç òàáëèö.
----------------------------------------------------------------------

	SET @strDate = CONVERT(varchar, @date);
	print 'Ââåäåíà äàòà: ' + @strDate;
	
END TRY
BEGIN CATCH
	DECLARE @ErrorMessage NVARCHAR(4000);
    DECLARE @ErrorSeverity INT;
    DECLARE @ErrorState INT;

    SELECT 
        @ErrorMessage = ERROR_MESSAGE(),
        @ErrorSeverity = ERROR_SEVERITY(),
        @ErrorState = ERROR_STATE();

    RAISERROR (@ErrorMessage, -- Message text.
               @ErrorSeverity, -- Severity.
               @ErrorState -- State.
               );
    RETURN;
END CATCH


-- Îáúÿâëÿåì êóðñîð
DECLARE t_cursor CURSOR FOR 
	SELECT name FROM sys.tables WHERE name like 'HISTORY_%' ORDER BY name
	
-- Îòêðûâàåì êóðñîð
OPEN t_cursor

FETCH NEXT FROM t_cursor INTO @tableName 

WHILE @@FETCH_STATUS = 0  

BEGIN  
	--**********************************************
	--IF @tableName = 'HISTORY_COM32_tMAD8C_011_30008'
	--	BEGIN
			DECLARE @text VARCHAR(MAX)
			DECLARE @SELECTION VARCHAR(MAX)
			
			SET @SELECTION = 'CONVERT(date, time) < CONVERT(date, '''+@strDate+''')'
			
			IF @DELETE = 1
				BEGIN
					print 'Óäàëåíèå ñòðîê ñòàðøå ' + @strDate;
					SET @text = 'DELETE FROM ' + @tableName + ' WHERE ' + @SELECTION;
		  		END;
			 ELSE
				BEGIN
					print 'Ïðîñìîòð ñòðîê êîòîðûå áóäóò óäàëåíû.';
					SET @text = 'SELECT '''+@tableName+''' AS [Èìÿ òàáëèöû], * FROM ' + @tableName + ' WHERE ' + @SELECTION + ' ORDER BY time';
				END;
				
			print 'Âûïîëíåíèå çàïðîñà: ';
			print @text	
			exec (@text)
	
	--	END;
	--**********************************************
	
	FETCH NEXT FROM t_cursor INTO @tableName 

END 

CLOSE t_cursor  

DEALLOCATE t_cursor
