USE [TSM_BASE_not_small]

DECLARE @date DATE;
DECLARE @strDate VARCHAR(10);
DECLARE @tableName VARCHAR(400); -- ��� �������
DECLARE @DELETE BIT;

BEGIN TRY
--------------------------���������-----------------------------------
----------------------------------------------------------------------
	SET @date = '2020-01-01'; --����-��-��. �����, ������ �������� ����� ������� ��� ������ �� ������ 'HISTORY_*'
	SET @DELETE = 1 -- 0-�� ������� ������, ������ �������� ����� ����� �������, 1-������� ������ �� ������.
----------------------------------------------------------------------

	SET @strDate = CONVERT(varchar, @date);
	print '������� ����: ' + @strDate;
	
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


-- ��������� ������
DECLARE t_cursor CURSOR FOR 
	SELECT name FROM sys.tables WHERE name like 'HISTORY_%' ORDER BY name
	
-- ��������� ������
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
					print '�������� ����� ������ ' + @strDate;
					SET @text = 'DELETE FROM ' + @tableName + ' WHERE ' + @SELECTION;
		  		END;
			 ELSE
				BEGIN
					print '�������� ����� ������� ����� �������.';
					SET @text = 'SELECT '''+@tableName+''' AS [��� �������], * FROM ' + @tableName + ' WHERE ' + @SELECTION + ' ORDER BY time';
				END;
				
			print '���������� �������: ';
			print @text	
			exec (@text)
	
	--	END;
	--**********************************************
	
	FETCH NEXT FROM t_cursor INTO @tableName 

END 

CLOSE t_cursor  

DEALLOCATE t_cursor
