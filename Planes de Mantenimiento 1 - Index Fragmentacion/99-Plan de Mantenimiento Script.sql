--SELECT S.name as 'Schema',
--T.name as 'Table',
--I.name as 'Index',
--DDIPS.avg_fragmentation_in_percent,
--DDIPS.page_count
--FROM sys.dm_db_index_physical_stats (DB_ID(), NULL, NULL, NULL, NULL) AS DDIPS
--INNER JOIN sys.tables T on T.object_id = DDIPS.object_id
--INNER JOIN sys.schemas S on T.schema_id = S.schema_id
--INNER JOIN sys.indexes I ON I.object_id = DDIPS.object_id
--AND DDIPS.index_id = I.index_id
--WHERE DDIPS.database_id = DB_ID()
--and I.name is not null
--AND DDIPS.avg_fragmentation_in_percent > 0
--ORDER BY DDIPS.avg_fragmentation_in_percent desc
----

DECLARE @Tabla VARCHAR(50) -- database name 
Declare @Indice decimal(16,0) 
Declare @HoraInicio datetime
Declare @NombreIndice varchar(100)
Declare @Tipo varchar(100) =''
Declare @page int =0

DECLARE db_cursor CURSOR FOR 
	SELECT TOP 100
		T.name as 'Table',
		I.name as 'Index',
		DDIPS.avg_fragmentation_in_percent,
		DDIPS.page_count

	FROM sys.dm_db_index_physical_stats (DB_ID(), NULL, NULL, NULL, NULL) AS DDIPS
		INNER JOIN sys.tables T on T.object_id = DDIPS.object_id
		INNER JOIN sys.schemas S on T.schema_id = S.schema_id
		INNER JOIN sys.indexes I ON I.object_id = DDIPS.object_id
		AND DDIPS.index_id = I.index_id
		WHERE DDIPS.database_id = DB_ID()
		and I.name is not null
		AND DDIPS.avg_fragmentation_in_percent > 0
	ORDER BY DDIPS.avg_fragmentation_in_percent desc

OPEN db_cursor  
FETCH NEXT FROM db_cursor INTO @Tabla, @NombreIndice  , @Indice, @page

WHILE @@FETCH_STATUS = 0  
BEGIN
  set @HoraInicio = GETDATE();
	set @Tipo = ''

	  if  @Indice >  30 
		Begin 
			Print 'Rebuld'
			Print @Indice
			Print @Tabla
			set @Tipo = 'Rebuld'
			DBCC DBREINDEX(@Tabla)
		End 
		  else
		    if  @Indice  between  1  and  30 
			  Begin
			  Print 'Reorganize'
			  Print @Indice
			  Print @Tabla
			  set @Tipo = 'Reorganize'
			   DBCC INDEXDEFRAG(Y2_C4_PROD,@Tabla);
			  End 
	  insert into 
	      [PROCESOS].[tbl_controlMantenimiento]
		   (fechaInicio, FechaFin, tabla , Indice, Fragmentacion , Tipo , page, Duracion )
		  select @HoraInicio, GETDATE(), @Tabla, @NombreIndice , @Indice , @Tipo, @page , DATEDIFF(MINUTE,  @HoraInicio, GETDATE() )	      
      FETCH NEXT FROM db_cursor INTO @Tabla, @NombreIndice ,@Indice , @page
END 

CLOSE db_cursor  
DEALLOCATE db_cursor 
