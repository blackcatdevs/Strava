CREATE PROCEDURE Landing.SP_get_historic_activities 
AS

/*
Repeatedly call SP_get_activities to get all historic activities to date
Rate limits are 100 requests every 15 minutes, 1000 daily

Clear the Activities tables out when running this *for the first time*
If the first run does not get all activity data due to rate limits, this can be re-run and 
will continually to add data sequentially from that added by the previous runC:\Users\simon\source\repos\Strava\Strava DB Objects\Stored Procedures\config.SP_get_access_refresh_token.sql
*/

--TRUNCATE TABLE Staging.Activities
--TRUNCATE TABLE Landing.Activities


DECLARE @max_activity_date DATETIME = COALESCE((SELECT MAX(start_date) FROM Landing.Activities), '20090101'),
		@new_max_activity_date DATETIME,
		@return_value INT

WHILE @max_activity_date < GETDATE() 
BEGIN

	EXEC	@return_value = [Landing].[SP_get_activities]
			@before_date = NULL,
			@after_date = @max_activity_date, 
			@page = N'',
			@per_page = N'200'

	SELECT MAX(start_date) FROM Landing.Activities

	SET @new_max_activity_date = COALESCE((SELECT MAX(start_date) FROM Landing.Activities), @max_activity_date)

	--break condition will be triggered when no update has been made due to exceeding rate limits or other error 
	IF @max_activity_date = @new_max_activity_date BREAK

	SET	@max_activity_date = @new_max_activity_date

END


RETURN 0
