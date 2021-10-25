USE [ИМЯ_БД]

DECLARE @date DATE;
DECLARE @strDate VARCHAR(10);
DECLARE @tableName VARCHAR(400);
DECLARE @DELETE BIT;

BEGIN TRY
--------------------------ПАРАМЕТРЫ-----------------------------------
----------------------------------------------------------------------
	SET @date = '2020-01-01'; --ГГГГ-ММ-ЧЧ. Число, меньше которого нужно удалить все строки из таблиц [like 'HISTORY_%']
	SET @DELETE = 0 -- 0-не удалять строки, только показать какие будут удалены, 1-удалить строки из таблиц.
----------------------------------------------------------------------

	SET @strDate = CONVERT(varchar, @date);
	print 'Введена дата: ' + @strDate;
	
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


-- Объявляем курсор
DECLARE t_cursor CURSOR FOR 
	SELECT name FROM sys.tables WHERE name like 'HISTORY_%' ORDER BY name
	
-- Открываем курсор
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
					print 'Удаление строк старше ' + @strDate + ' из таблицы ' +  @tableName;
					SET @text = 'DELETE FROM ' + @tableName + ' WHERE ' + @SELECTION;
		  		END;
			 ELSE
				BEGIN
					print 'Просмотр строк которые будут удалены.';
					SET @text = 'SELECT '''+@tableName+''' AS [Имя таблицы], * FROM ' + @tableName + ' WHERE ' + @SELECTION + ' ORDER BY time';
				END;
				
			print 'Выполнение запроса: ';
			print @text	
			exec (@text)
	
	--	END;
	--**********************************************
	
	FETCH NEXT FROM t_cursor INTO @tableName 

END 

CLOSE t_cursor  

DEALLOCATE t_cursor
