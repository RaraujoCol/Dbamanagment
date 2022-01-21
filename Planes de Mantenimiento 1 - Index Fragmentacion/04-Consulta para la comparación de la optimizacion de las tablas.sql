-- Query para saber la mejora de los indices fragmentados

SELECT 
    S.name as 'Schema',
    T.name as 'Table',
    I.name as 'Index',
    m.fragmentacion  fragmentacion_AntesFrag,
    m.page page_AntesFrag,  m.duracion TiempoFragmentacion,
	m.rows,
    cast (    DDIPS.avg_fragmentation_in_percent as decimal(16,0)  ) fragmentacion_Actual,
    DDIPS.page_count
 
FROM sys.dm_db_index_physical_stats (DB_ID(), NULL, NULL, NULL, NULL) AS DDIPS

    INNER JOIN sys.tables T on T.object_id = DDIPS.object_id
    INNER JOIN sys.schemas S on T.schema_id = S.schema_id
    INNER JOIN sys.indexes I ON I.object_id = DDIPS.object_id
    INNER JOIN 
            ztbl_controlMantenimiento m on 
                    m.Tabla  = T.name   COLLATE DATABASE_DEFAULT and 
                    m.Indice = I.name   COLLATE DATABASE_DEFAULT AND DDIPS.index_id = I.index_id
					and  FechaFin > '2022-01-21 04:48:48.760'
    WHERE DDIPS.database_id = DB_ID()
        and I.name is not null
        AND DDIPS.avg_fragmentation_in_percent >= 0
        ORDER BY DDIPS.avg_fragmentation_in_percent desc


