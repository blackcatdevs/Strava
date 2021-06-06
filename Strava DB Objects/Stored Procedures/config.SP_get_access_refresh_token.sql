CREATE PROCEDURE Config.SP_get_access_refresh_token AS

--get access token and refresh token
--run this once as the authorization code can only be used once 
--thereafter use Section 4 to generate a new access token using refresh token

--declare variables
DECLARE @client_ID NVARCHAR(64) =(SELECT client_ID FROM Config.API_credentials),
		@client_secret NVARCHAR(64) = (SELECT client_secret FROM Config.API_credentials),
		@authorization_code NVARCHAR(64) = (SELECT authorization_code FROM Config.API_credentials)

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

--get access and refresh tokens
SET @url = 'https://www.strava.com/api/v3/oauth/token?client_id=' + @client_ID + '&client_secret=' + @client_secret + '&grant_type=authorization_code&' + 'code=' + @authorization_code

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

--convert Json values and update table 
UPDATE	Config.API_credentials 
SET		refresh_token = JSON_VALUE(@json, '$.refresh_token'),
		access_token = JSON_VALUE(@json, '$.access_token'),
		access_token_expires_at = DATEADD(S, CAST(JSON_VALUE(@json, '$.expires_at') AS INT), '1970-01-01')		 
WHERE	client_ID = @client_ID


RETURN 0
