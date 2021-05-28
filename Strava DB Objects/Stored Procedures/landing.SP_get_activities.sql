CREATE PROCEDURE Landing.SP_get_activities 
 		@before_date DATETIME = NULL, 
		@after_date DATETIME = NULL, 
		@page VARCHAR(5) = NULL,
		@per_page VARCHAR(5) = NULL --max is 200
AS

--get activities, for last 7 days if not called with parameters 
--this requires a valid access token - if the current token has expired then run SP_get_access_token to generate a new one

--declare variables

--Set the value for @refresh_token using the value generated at the end of section 3 or 4
DECLARE @access_token NVARCHAR(64) = (SELECT access_token FROM Config.API_credentials)

--request paramters
DECLARE @before VARCHAR(50) = NULL, --date passed as string
		@after VARCHAR(50) = NULL --date passed as string

--OLE automation Object and error information
DECLARE @token INT,
		@ret INT,
		@error_source VARCHAR(250),
		@error_description VARCHAR(500)

--request parameters 
DECLARE @url NVARCHAR(MAX),
		@authHeader NVARCHAR(84),
		@contentType NVARCHAR(64) = 'application/json',
		@ResponseText AS VARCHAR(4000)

--JSON object
DECLARE @json_activities AS TABLE(Json_Table NVARCHAR(MAX))


--refresh access_token if expired
IF((SELECT access_token_expires_at FROM Config.API_credentials) < GETDATE()) 
	BEGIN
		EXEC Config.SP_refresh_access_token		
	END

SET @access_token = (SELECT access_token FROM Config.API_credentials)


--now get activities
SET @authHeader = 'Bearer ' + @access_token 

--before / after need to be passed as UNIX timestamps
--default: 2 days ago for after		
IF @before_date IS NOT NULL SET @before = CAST(DATEDIFF(s, '19700101', @before_date) AS VARCHAR(50))

IF @after_date IS NOT NULL SET @after = CAST(DATEDIFF(s, '19700101', @after_date) AS VARCHAR(50))
	ELSE SET @after = CAST(DATEDIFF(s, '19700101', DATEADD(D, -2, GETDATE())) AS VARCHAR(50))  
 
SET @url = 'https://www.strava.com/api/v3/athlete/activities?after=' + @after							
									+ CASE WHEN COALESCE(@before, '') <> '' THEN '&before=' + @before ELSE '' END  
									+ CASE WHEN COALESCE(@page, '') <> '' THEN '&page=' + @page ELSE '' END  
									+ CASE WHEN COALESCE(@per_page, '') <> '' THEN '&per_page=' + @per_page ELSE '' END   


-- This creates a new instance of the OLE Automation object
EXEC @ret = sp_OACreate 'MSXML2.XMLHTTP', @token OUT;
IF @ret <> 0 RAISERROR('Unable to open HTTP connection', 10, 1);

--GET method
--GET carries request parameter appended in URL string 
EXEC @ret = sp_OAMethod @token, 'open', NULL, 'GET', @url, 'false';
EXEC @ret = sp_OAMethod @token, 'setRequestHeader', NULL, 'Authorization', @authHeader;
EXEC @ret = sp_OAMethod @token, 'setRequestHeader', NULL, 'Content-type', @contentType;

EXEC @ret = sp_OAMethod @token, 'send'
IF @ret <> 0 EXEC sp_OAGetErrorInfo @token


-- Grab the responseText property, and insert the JSON string into a table temporarily. This is very important, if you don't do this step you'll run into problems.
INSERT into @json_activities (Json_Table) EXEC sp_OAGetProperty @token, 'responseText'

--convert Json values and put into Activities table
INSERT INTO Landing.Activities
	(
	resource_state,
	athlete_id,
	athlete_resource_state,
	[name],
	distance,
	moving_time,
	elapsed_time,
	total_elevation_gain,
	activity_type,
	workout_type,
	activity_id,
	external_id,
	upload_id,
	[start_date],
	start_date_local,
	timezone,
	utc_offset,
	start_latlng,
	end_latlng,
	location_city,
	location_state,
	location_country,
	achievement_count,
	kudos_count,
	comment_count,
	athlete_count,
	photo_count,
	map_id,
	map_summary_polyline,
	map_resource_state,
	trainer,
	commute,
	[manual],
	[private],
	flagged,
	gear_id,
	from_accepted_tag,
	average_speed,
	max_speed,
	average_cadence,
	average_watts,
	weighted_average_watts,
	kilojoules,
	device_watts,
	has_heartrate,
	average_heartrate,
	max_heartrate,
	max_watts,
	pr_count,
	total_photo_count,
	has_kudoed,
	suffer_score
	)
SELECT	JSON_VALUE(js.[value], '$.resource_state'),
		JSON_VALUE(js.[value], '$.athlete.id'),
		JSON_VALUE(js.[value], '$.athlete.resource_state'),
		JSON_VALUE(js.[value], '$.name'),
		JSON_VALUE(js.[value], '$.distance'),
		JSON_VALUE(js.[value], '$.moving_time'),
		JSON_VALUE(js.[value], '$.elapsed_time'),
		JSON_VALUE(js.[value], '$.total_elevation_gain'),
		JSON_VALUE(js.[value], '$.type'),
		JSON_VALUE(js.[value], '$.workout_type'),
		JSON_VALUE(js.[value], '$.id'),
		JSON_VALUE(js.[value], '$.external_id'),
		JSON_VALUE(js.[value], '$.upload_id'),
		JSON_VALUE(js.[value], '$.start_date'),
		JSON_VALUE(js.[value], '$.start_date_local'),
		JSON_VALUE(js.[value], '$.timezone'),
		JSON_VALUE(js.[value], '$.utc_offset'),
		JSON_VALUE(js.[value], '$.start_latlng'),
		JSON_VALUE(js.[value], '$.end_latlng'),
		JSON_VALUE(js.[value], '$.location_city'),
		JSON_VALUE(js.[value], '$.location_state'),
		JSON_VALUE(js.[value], '$.location_country'),
		JSON_VALUE(js.[value], '$.achievement_count'),
		JSON_VALUE(js.[value], '$.kudos_count'),
		JSON_VALUE(js.[value], '$.comment_count'),
		JSON_VALUE(js.[value], '$.athlete_count'),
		JSON_VALUE(js.[value], '$.photo_count'),
		JSON_VALUE(js.[value], '$.map.id'),
		JSON_VALUE(js.[value], '$.map.summary_polyline'),
		JSON_VALUE(js.[value], '$.map.resource_state'),
		JSON_VALUE(js.[value], '$.trainer'),
		JSON_VALUE(js.[value], '$.commute'),
		JSON_VALUE(js.[value], '$.manual'),
		JSON_VALUE(js.[value], '$.private'),
		JSON_VALUE(js.[value], '$.flagged'),
		JSON_VALUE(js.[value], '$.gear_id'),
		JSON_VALUE(js.[value], '$.from_accepted_tag'),
		JSON_VALUE(js.[value], '$.average_speed'),
		JSON_VALUE(js.[value], '$.max_speed'),
		JSON_VALUE(js.[value], '$.average_cadence'),
		JSON_VALUE(js.[value], '$.average_watts'),
		JSON_VALUE(js.[value], '$.weighted_average_watts'),
		JSON_VALUE(js.[value], '$.kilojoules'),
		JSON_VALUE(js.[value], '$.device_watts'),
		JSON_VALUE(js.[value], '$.has_heartrate'),
		JSON_VALUE(js.[value], '$.average_heartrate'),
		JSON_VALUE(js.[value], '$.max_heartrate'),
		JSON_VALUE(js.[value], '$.max_watts'),
		JSON_VALUE(js.[value], '$.pr_count'),
		JSON_VALUE(js.[value], '$.total_photo_count'),
		JSON_VALUE(js.[value], '$.has_kudoed'),
		JSON_VALUE(js.[value], '$.suffer_score')
FROM	OPENJSON((SELECT * FROM @json_activities)) js


RETURN 0
