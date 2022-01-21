SELECT S.name as 'Schema',
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
ORDER BY T.name asc 




DBCC DBREINDEX ( LIGNESBORDEREAUBNQ);


SELECT OBJECT_NAME(IX.object_id) as db_name, si.name, extent_page_id, allocated_page_page_id, previous_page_page_id, next_page_page_id
FROM sys.dm_db_database_page_allocations(DB_ID('Y2_C4_PROD'), OBJECT_ID('LISTE'),NULL, NULL, 'DETAILED') IX
INNER JOIN sys.indexes si on IX.object_id = si.object_id AND IX.index_id = si.index_id
WHERE si.name = 'LI_CLE1'
ORDER BY allocated_page_page_id



ALTER INDEX LI_CLE1 ON LISTE REORGANIZE