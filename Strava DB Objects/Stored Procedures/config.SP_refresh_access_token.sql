CREATE PROCEDURE Config.SP_refresh_access_token AS

--get new access token using refresh token
--see https://developers.strava.com/docs/authentication/#refreshingexpiredaccesstokens

--declare variables
DECLARE @client_ID NVARCHAR(64) =(SELECT client_ID FROM Config.API_credentials),
		@client_secret NVARCHAR(64) = (SELECT client_secret FROM Config.API_credentials),
		@refresh_token NVARCHAR(64) = (SELECT refresh_token FROM Config.API_credentials)

--Variable declaration related to the Object.
DECLARE @token INT,
		@ret INT;

--Variable declaration related to the Request.
DECLARE @url NVARCHAR(MAX),
		@authHeader NVARCHAR(84),
		@contentType NVARCHAR(64) = 'application/json',
		@ResponseText as Varchar(4000)

--JSON object
DECLARE @json AS NVARCHAR(MAX)

SET @url = 'https://www.strava.com/api/v3/oauth/token?client_id=' + @client_ID + '&client_secret=' + @client_secret + '&grant_type=refresh_token&' + 'refresh_token=' + @refresh_token

-- This creates a new instanceof the OLE Automation object
EXEC @ret = sp_OACreate 'MSXML2.XMLHTTP', @token OUT;
IF @ret <> 0 RAISERROR('Unable to open HTTP connection.', 10, 1);

--POST method
--POST carries request parameter in message body 
EXEC @ret = sp_OAMethod @token, 'open', NULL, 'POST', @url, 'false';

--is this required??
EXEC @ret = sp_OAMethod @token, 'setRequestHeader', NULL, 'Content-type', @contentType;

EXEC @ret = sp_OAMethod @token, 'send'

IF @ret <> 0 EXEC sp_OAGetErrorInfo @token ELSE PRINT 'Succesfully connected'

Exec sp_OAMethod @token, 'responseText', @ResponseText OUTPUT
SET @json = (Select @ResponseText)

--exit if not valid Json
IF ISJSON(@json) <> 1 RAISERROR('Not valid JSON', 10, 1)

--temp table to hold values for access and refresh tokens
IF OBJECT_ID('tempdb..#access_refresh') IS NOT NULL DROP TABLE #access_refresh

--convert Json values and put into temp table
SELECT	JSON_VALUE(@json, '$.access_token') AS access_token,
		DATEADD(S, CAST(JSON_VALUE(@json, '$.expires_at') AS INT), '1970-01-01') AS access_token_expires_at,
		JSON_VALUE(@json, '$.refresh_token') AS refresh_token
INTO	#access_refresh

--update table with new access token and expiry
UPDATE	Config.API_credentials 
SET		access_token = at.access_token, 
		access_token_expires_at = at.access_token_expires_at
FROM	(
		SELECT r.access_token, r.access_token_expires_at
		FROM #access_refresh r
		INNER JOIN Config.API_credentials c ON c.refresh_token = r.refresh_token
		) at

RETURN 0
