SET NOCOUNT ON;
--Views Referencing to invalid views
DROP TABLE IF EXISTS #NonExistingReferencedObjects;
WITH cte_views AS (
SELECT O.OBJECT_ID, s.name schemaname, o.name AS objetname, o.type,o.type_desc
FROM	SYS.OBJECTS AS O
	INNER JOIN sys.schemas AS s ON o.schema_id = s.schema_id
WHERE O.TYPE = 'V'
)

SELECT Coalesce(QUOTENAME(Object_Schema_Name(referencing.referencing_id)) + '.', '')
	     + --likely schema name
	QUOTENAME(Object_Name(referencing.referencing_id)) + --definite entity name
	Coalesce('.' + Col_Name(referencing.referencing_id, referencing.referencing_minor_id), '') AS referencing_object_name,
	referencing.referencing_id AS referencing_object_id,
	Coalesce(referencing.referenced_server_name + '.', '')
	+ --possible server name if cross-server
	Coalesce(referencing.referenced_database_name + '.', '')
	+ --possible database name if cross-database
	Coalesce(referencing.referenced_schema_name + '.', '')
	+ --likely schema name
	Coalesce(referencing.referenced_entity_name, '')
	+ --very likely entity name
	Coalesce('.' + Col_Name(referencing.referenced_id, referencing.referenced_minor_id), '') AS referenced_object_name
	--, c.object_id AS Referenced_ojbectId
	--, c.name AS Referenced_column_name
	--, c.column_id
	, referencing.referenced_id
	, c.object_id
	, c.schemaname
	, c.objetname
INTO #NonExistingReferencedObjects
FROM sys.sql_expression_dependencies AS referencing
	INNER JOIN sys.objects AS o ON o.object_id = referencing.referencing_id
	LEFT OUTER JOIN cte_views AS c ON C.OBJECT_ID = referencing.referenced_id
WHERE	o.type = 'V'
AND		referencing.referenced_id IS null
ORDER BY referencing_object_name;

DECLARE @SQLstring NVARCHAR(256)
	, @MaxRowId SMALLINT
	, @RowId SMALLINT = 1;
DECLARE @DropObjects TABLE (
	  RowId SMALLINT IDENTITY (1,1) NOT NULL
	, ObjectName NVARCHAR(256) NOT NULL
	, ObjectType NVARCHAR(32) NOT NULL
	, SQLstring NVARCHAR(512) NULL
	)
INSERT INTO @DropObjects
(
    ObjectName,
    ObjectType,
	SQLstring
)
SELECT	DISTINCT
	  ro.referencing_object_name
	, o.type_desc
	, CASE WHEN o.type_desc = 'VIEW' THEN 'DROP VIEW IF EXISTS ' + ro.referencing_object_name + ';'
		END
FROM	#NonExistingReferencedObjects AS ro
	INNER JOIN sys.objects AS O ON o.object_id = ro.referencing_object_id;

SET @MaxRowId = @@ROWCOUNT;
WHILE @RowId <= @MaxRowId
	BEGIN
		SELECT @SQLstring = SQLstring
		FROM	@DropObjects
		WHERE	RowId = @RowId;

		PRINT (@SQLstring);
		--EXEC sp_executesql @stmt = @SQLstring;

		SET @RowId = @RowId + 1;
	END
