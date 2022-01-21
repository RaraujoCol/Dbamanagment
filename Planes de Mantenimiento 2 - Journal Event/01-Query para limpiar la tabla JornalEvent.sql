use Y2_C4_PROD

-- Declaración de variables involucradas

DECLARE @Counter INT 
DECLARE @FechaInicio date 
DECLARE @FechaFin  date
Declare @FechaLimite date

DECLARE @GHE_NIVEAU1 nvarchar(10)
DECLARE @GHE_NIVEAU2 nvarchar(10)


SET @Counter=1

Select  @FechaInicio =    MIN(GHE_DATECREATION)    from JOURNALEVENT

Set @FechaLimite= '2021-09-30'

if @FechaInicio > @FechaLimite  set @Counter = 10000

-- Si es 1 o 15 de cada mes, ese día se omite para guardarlo
if  (day(@FechaInicio) = 1 or  day(@FechaInicio) = 15 )  set  @FechaInicio = DATEADD(DD,1,@FechaInicio)


WHILE ( @Counter <=5000)
	BEGIN
		Set @FechaFin =   DATEADD(DD,1,@FechaInicio)  
			-- Se hace un cursor interno para segmentar la información del dia y borrar segmentado
			   DECLARE db_cursor CURSOR FOR
					Select   GHE_NIVEAU1,  GHE_NIVEAU2  
							from JOURNALEVENT 
								where 
									  GHE_DATECREATION  BETWEEN  @FechaInicio and  @FechaFin 
    					group by GHE_NIVEAU1,GHE_NIVEAU2

			OPEN db_cursor  
				FETCH NEXT FROM db_cursor INTO  @GHE_NIVEAU1, @GHE_NIVEAU2

			WHILE @@FETCH_STATUS = 0  
				BEGIN
					print @FechaInicio
					print @FechaFin
					print @GHE_NIVEAU2

						-- Se borra por día y por tipo @GHE_NIVEAU1 y @GHE_NIVEAU2 para segmentar la información
						 Delete from JOURNALEVENT 
								where 
									GHE_DATECREATION  
										BETWEEN  @FechaInicio and  @FechaFin 
										and  GHE_NIVEAU1 = @GHE_NIVEAU1 and GHE_NIVEAU2 = @GHE_NIVEAU2

					FETCH NEXT FROM db_cursor INTO @GHE_NIVEAU1, @GHE_NIVEAU2
				END
			CLOSE db_cursor  
			DEALLOCATE db_cursor
	
		PRINT 'The counter value is = ' + CONVERT(VARCHAR(50),@FechaInicio)
    
		SET @Counter  = @Counter  + 1
		set @FechaInicio = @FechaFin

		-- Si es 1 o 15 de cada mes, ese día se omite para guardarlo
		if  (day(@FechaInicio) = 1 or  day(@FechaInicio) = 15 )  set  @FechaInicio = DATEADD(DD,1,@FechaInicio)
		if @FechaInicio > @FechaLimite  set @Counter = 10000

	END
