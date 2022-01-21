
Select top 20 
	Def.TableName as 'Table', 
	min(Indice) as 'Index', 
	MIN(avg_fragmentation_in_percent) avg_fragmentation_in_percent,
	MIN(page_count) page_count
from (
		SELECT
		T.name as 'TableName',
		I.name as 'Indice',
		DDIPS.avg_fragmentation_in_percent,
		DDIPS.page_count
	FROM sys.dm_db_index_physical_stats (DB_ID(), NULL, NULL, NULL, NULL) AS DDIPS
		INNER JOIN sys.tables T on T.object_id = DDIPS.object_id
		INNER JOIN sys.schemas S on T.schema_id = S.schema_id
		INNER JOIN sys.indexes I ON I.object_id = DDIPS.object_id
		INNER JOIN sys.partitions p ON i.object_id = p.OBJECT_ID AND i.index_id = p.index_id
		INNER JOIN sys.allocation_units a ON p.partition_id = a.container_id
		AND DDIPS.index_id = I.index_id
		WHERE DDIPS.database_id = DB_ID()
		and I.name is not null
		AND DDIPS.avg_fragmentation_in_percent between 0.1 and 10
	) as Def inner join

	 (
				SELECT top 1000
					t.NAME AS TableName,
					s.Name AS SchemaName,
					p.rows,
				--    SUM(a.total_pages) * 8 AS TotalSpaceKB, 
					CAST(ROUND(((SUM(a.total_pages) * 8) / 1024.00), 2) AS NUMERIC(36, 2)) AS TotalSpaceMB,
				--    SUM(a.used_pages) * 8 AS UsedSpaceKB, 
					CAST(ROUND(((SUM(a.used_pages) * 8) / 1024.00), 2) AS NUMERIC(36, 2)) AS UsedSpaceMB, 
				 --   (SUM(a.total_pages) - SUM(a.used_pages)) * 8 AS UnusedSpaceKB,
					CAST(ROUND(((SUM(a.total_pages) - SUM(a.used_pages)) * 8) / 1024.00, 2) AS NUMERIC(36, 2)) AS UnusedSpaceMB
				FROM 
					sys.tables t
				INNER JOIN      
					sys.indexes i ON t.OBJECT_ID = i.object_id
				INNER JOIN  sys.partitions p ON i.object_id = p.OBJECT_ID AND i.index_id = p.index_id
				INNER JOIN sys.allocation_units a ON p.partition_id = a.container_id
				LEFT OUTER JOIN 
					sys.schemas s ON t.schema_id = s.schema_id
				WHERE 
					t.NAME NOT LIKE 'dt%' 
					AND t.is_ms_shipped = 0
					AND i.OBJECT_ID > 255 
    
				GROUP BY 
					t.Name, s.Name, p.Rows
		) as Size  
			on Def.TableName = Size.TableName
	   group by Def.TableName, Size.rows
order by rows desc
	 
