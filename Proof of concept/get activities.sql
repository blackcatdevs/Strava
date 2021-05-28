-- thanks to https://github.com/areed1192/sigma_coding_youtube (walkthrough https://www.youtube.com/watch?v=93q8joTcRpQ&t=1007s) for the original script
-- also to https://www.zealousweb.com/calling-rest-api-from-sql-server-stored-procedure/
-- and to https://www.markhneedham.com/blog/2020/12/15/strava-authorization-error-missing-read-permission/

/*
Step 1 SQL Server configuration, do this once
Step 2 - Strava initial setup, to grant access, do this once
Step 3 - get access token and refresh token, run this once as the authorization code can only be used once
Step 4 - get new access token using refresh token, repeat when access token has expired
Step 5 - get activities, run as required
Replace 'YOUR_' (eg YOUR_CLIENT_ID) with correct value
Run these sequentially
If Strava reauthorisation is required then start again from step 2
If the access token expires then start again from step 4
*/

/*
-----------------------------------------------------------------------------------------------------------------------------------------------------------------
Step 1
SQL Server configuration - run this once
-- check current config values to see what needs to be changed 
EXEC sp_configure
UNDERSTANDING THE Show Advanced Options
------------------------------------------------------------------------------------------------------------------
Some configuration options, such as affinity mask and recovery interval, are designated as advanced options. By 
default, these options are not available for viewing and changing. To make them available, set the ShowAdvancedOptions 
configuration option to 1.
EXEC sp_configure 'show advanced options', 1
RECONFIGURE
UNDERSTANDING THE OLE Automation Procedue
------------------------------------------------------------------------------------------------------------------
Use the Ole Automation Procedures option to specify whether OLE Automation objects can be instantiated within 
Transact-SQL batches. This option can also be configured using the Policy-Based Management or the sp_configure stored 
procedure. The Ole Automation Procedures option can be set to the following values.
Value: 0
Definition: OLE Automation Procedures are disabled. Default for new instances of SQL Server.
Value: 1
Definition: OLE Automation Procedures are enabled.
  
When OLE Automation Procedures are enabled, a call to sp_OACreate will start the OLE shared execution environment. The current 
value of the Ole Automation Procedures option can be viewed and changed by using the sp_configure system stored procedure.
EXEC sp_configure 'Ole Automation Procedures', 1
RECONFIGURE
-----------------------------------------------------------------------------------------------------------------------------------------------------------------
*/


/* 
-----------------------------------------------------------------------------------------------------------------------------------------------------------------
Step 2
Strava initial setup, to grant access - do this once
Log in to your Strava account
Go to https://www.strava.com/settings/api and note the client ID 
Paste the client ID into the URL below - note that the scope requested is read_all:
https://www.strava.com/oauth/authorize?client_id=[REPLACE_WITH_YOUR_CLIENT_ID]&response_type=code&redirect_uri=http://localhost/exchange_token&approval_prompt=force&scope=activity:read_all
This will load a page where authorisation can be given, doing so will generate this dummy URL that contains an authorisation code that can be used to generate an access token:
http://localhost/exchange_token?state=&code=Authorizationcode&scope=read,activity:read_all
Make a note of the authorisation code as it will be needed later!!! 
-----------------------------------------------------------------------------------------------------------------------------------------------------------------
*/

-----------------------------------------------------------------------------------------------------------------------------------------------------------------
--Step 3
--get access token and refresh token
--run this once as the authorization code can only be used once 
--make a note of the access token and refresh token and 
--thereafter use Section 4 to generate a new access token using refresh token

--declare variables

--Set the values for @client_ID and @client_secret by referring to https://www.strava.com/settings/api
--Set the value for @authorization_code using the value in the dummy URL generated at the end of section 2
DECLARE @client_ID NVARCHAR(64) = 'YOUR_CLIENT_ID',
		@client_secret NVARCHAR(64) = 'YOUR_CLIENT_SECRET',
		@authorization_code NVARCHAR(64) = 'YOUR_CLIENT_AUTHORIZATION_CODE'

--Variable declaration related to the Object.
DECLARE @token INT,
		@ret INT;

--Variable declaration related to the Request.
DECLARE @url NVARCHAR(MAX),
		@authHeader NVARCHAR(84),
		@contentType NVARCHAR(64) = 'application/json',
		@ResponseText as Varchar(4000)

--JSON object
DECLARE @json_token AS NVARCHAR(MAX)

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
SET @json_token = (Select @ResponseText)

--exit if not valid Json
IF ISJSON(@json_token) <> 1 RAISERROR('Not valid JSON', 10, 1)

--temp table to hold values for access and refresh tokens
IF OBJECT_ID('tempdb..#access_refresh') IS NOT NULL DROP TABLE #access_refresh

--convert Json values and put into temp table
SELECT	JSON_VALUE(@json_token, '$.access_token') AS access_token,
		DATEADD(S, CAST(JSON_VALUE(@json_token, '$.expires_at') AS INT), '1970-01-01') AS access_token_expires_at,
		JSON_VALUE(@json_token, '$.refresh_token') AS refresh_token
INTO	#access_refresh

--access and refresh token details
SELECT * FROM #access_refresh

--make a note of the @refresh_token as it will be needed after the session has ended and the temp table no longer exists!!!!
--otherwise you will need to reauthorise
-----------------------------------------------------------------------------------------------------------------------------------------------------------------


-----------------------------------------------------------------------------------------------------------------------------------------------------------------
--Step 4
--get new access token using refresh token
--see https://developers.strava.com/docs/authentication/#refreshingexpiredaccesstokens

--declare variables

--Set the values for @client_ID and @client_secret by referring to https://www.strava.com/settings/api
--Set the value for @refresh_token using the value in the dummy URL generated at the end of section 2
DECLARE @client_ID NVARCHAR(64) ='65953', --YOUR_CLIENT_ID
		@client_secret NVARCHAR(64) = 'YOUR_CLIENT_SECRET',
		@refresh_token NVARCHAR(64) = (SELECT refresh_token FROM #access_refresh)

--Variable declaration related to the Object.
DECLARE @token INT,
		@ret INT;

--Variable declaration related to the Request.
DECLARE @url NVARCHAR(MAX),
		@authHeader NVARCHAR(84),
		@contentType NVARCHAR(64) = 'application/json',
		@ResponseText as Varchar(4000)

--JSON object
DECLARE @json_token AS NVARCHAR(MAX)

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
SET @json_token = (Select @ResponseText)

--exit if not valid Json
IF ISJSON(@json_token) <> 1 RAISERROR('Not valid JSON', 10, 1)

--temp table to hold values for access and refresh tokens
IF OBJECT_ID('tempdb..#access_refresh') IS NOT NULL DROP TABLE #access_refresh

--convert Json values and put into temp table
SELECT	JSON_VALUE(@json_token, '$.access_token') AS access_token,
		DATEADD(S, CAST(JSON_VALUE(@json_token, '$.expires_at') AS INT), '1970-01-01') AS access_token_expires_at,
		JSON_VALUE(@json_token, '$.refresh_token') AS refresh_token
INTO	#access_refresh

--new access token details
SELECT * FROM #access_refresh

-----------------------------------------------------------------------------------------------------------------------------------------------------------------


-----------------------------------------------------------------------------------------------------------------------------------------------------------------
--Step 5 
--get activities for last 7 days
--this requires a valid access token - if the current token has expired then run step 4 to generate a new one

--declare variables

--Set the value for @refresh_token using the value generated at the end of section 3 or 4
DECLARE @access_token NVARCHAR(64) = (SELECT access_token FROM #access_refresh)

--Variable declaration related to the Object.
DECLARE @token INT,
		@ret INT;

--Variable declaration related to the Request.
DECLARE @url NVARCHAR(MAX),
		@authHeader NVARCHAR(84),
		@contentType NVARCHAR(64) = 'application/json',
		@ResponseText AS VARCHAR(4000),
		@after AS VARCHAR(50)


--JSON object
DECLARE @json_activities AS TABLE(Json_Table NVARCHAR(MAX))

--now get activities
SET @authHeader = 'Bearer ' + @access_token 

--calculate UNIX timestamp for 7 days ago		
SET @after =  DATEDIFF(s, '1970-01-01', DATEADD(D, -7, GETDATE())) 

SET @url = 'https://www.strava.com/api/v3/athlete/activities?after=' + @after 

-- This creates a new instance of the OLE Automation object
EXEC @ret = sp_OACreate 'MSXML2.XMLHTTP', @token OUT;
IF @ret <> 0 RAISERROR('Unable to open HTTP connection.', 10, 1);

--GET method
--GET carries request parameter appended in URL string 
EXEC @ret = sp_OAMethod @token, 'open', NULL, 'GET', @url, 'false';

--changed this from 'authentication' to 'authorization'
-- thanks to https://stackoverflow.com/questions/53989825/square-api-authentication-error-when-called-from-sql-server
EXEC @ret = sp_OAMethod @token, 'setRequestHeader', NULL, 'Authorization', @authHeader;
EXEC @ret = sp_OAMethod @token, 'setRequestHeader', NULL, 'Content-type', @contentType;
EXEC @ret = sp_OAMethod @token, 'send'

IF @ret <> 0 EXEC sp_OAGetErrorInfo @token ELSE PRINT 'Succesfully connected'

	--Exec sp_OAMethod @token, 'responseText', @ResponseText OUTPUT
	--SET @json_activities = (Select @ResponseText)

-- Grab the responseText property, and insert the JSON string into a table temporarily. This is very important, if you don't do this step you'll run into problems.
INSERT into @json_activities (Json_Table) EXEC sp_OAGetProperty @token, 'responseText'

--temp table to hold values from Json table
IF OBJECT_ID('tempdb..#activities') IS NOT NULL DROP TABLE #activities

--convert Json values and put into temp table
SELECT	JSON_VALUE(js.[value], '$.athlete.id') AS athlete_id,
		JSON_VALUE(js.[value], '$.name') AS [name],
		JSON_VALUE(js.[value], '$.distance') AS distance,
		JSON_VALUE(js.[value], '$.moving_time') AS moving_time,
		JSON_VALUE(js.[value], '$.elapsed_time') AS elapsed_time

INTO	#activities

FROM	OPENJSON((SELECT * FROM @json_activities)) js


SELECT * FROM #activities

-----------------------------------------------------------------------------------------------------------------------------------------------------------------