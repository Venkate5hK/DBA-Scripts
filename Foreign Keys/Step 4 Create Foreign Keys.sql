USE MYDATABASE -- CHANGE THE NAME OF THE DB
SET NOCOUNT ON;

-- RECREATE FK CONSTRAINTS
DECLARE @MaxFKid INT,
		@Str NVARCHAR(1024);

SELECT	@MaxFKid = MAX(FKid)
FROM	dbo.FKCreate;

WHILE	@MaxFKid > 0
	BEGIN
		SELECT	@Str = '';
		SELECT	@Str = [Str]
		FROM	dbo.FKCreate
		WHERE	FKid = @MaxFKid;

		PRINT	@Str;

		EXEC sp_executesql @stmt = @Str;
		
		SELECT	@MaxFKid = @MaxFKid - 1;

	END
