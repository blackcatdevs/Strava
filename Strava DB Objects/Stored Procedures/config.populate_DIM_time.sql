-- Thanks to https://microsoft-bitools.blogspot.com/2017/01/create-and-populate-time-dimension.html?m=1

CREATE PROCEDURE config.populate_DIM_time AS

-- Create a time and a counter variable for the loop
DECLARE @Time as time;
SET @Time = '0:00';

DECLARE @counter as int;
SET @counter = 0;


-- Two variables to store the day part for two languages
DECLARE @daypartEN as varchar(20);
set @daypartEN = '';

-- Loop 1440 times (24hours * 60minutes)
WHILE @counter < 1440
BEGIN

    -- Determine datepart
    SELECT  @daypartEN = CASE
                         WHEN (@Time >= '0:00' and @Time < '6:00') THEN 'Night'
                         WHEN (@Time >= '6:00' and @Time < '12:00') THEN 'Morning'
                         WHEN (@Time >= '12:00' and @Time < '18:00') THEN 'Afternoon'
                         ELSE 'Evening'
                         END;

    INSERT INTO reporting.DIM_time (
                                     [Time]
                                   , [Hour]
                                   , [Minute]
                                   , [MilitaryHour]
                                   , [MilitaryMinute]
                                   , [AMPM]
                                   , [DayPartEN]
                                   , [HourFromTo12]
                                   , [HourFromTo24]
                                   , [Notation12]
                                   , [Notation24])
                            VALUES (
                                     @Time
                                   , DATEPART(Hour, @Time) + 1
                                   , DATEPART(Minute, @Time) + 1
                                   , DATEPART(Hour, @Time)
                                   , DATEPART(Minute, @Time)
                                   , CASE WHEN (DATEPART(Hour, @Time) < 12) THEN 'AM' ELSE 'PM' END
                                   , @daypartEN
                                   , CONVERT(varchar(10), DATEADD(Minute, -DATEPART(Minute,@Time), @Time),100)  + ' - ' + CONVERT(varchar(10), DATEADD(Hour, 1, DATEADD(Minute, -DATEPART(Minute,@Time), @Time)),100)
                                   , CAST(DATEADD(Minute, -DATEPART(Minute,@Time), @Time) as varchar(5)) + ' - ' + CAST(DATEADD(Hour, 1, DATEADD(Minute, -DATEPART(Minute,@Time), @Time)) as varchar(5))
                                   , CONVERT(varchar(10), @Time,100)
                                   , CAST(@Time as varchar(5))
                               );

    -- Raise time with one minute
    SET @Time = DATEADD(minute, 1, @Time);

    -- Raise counter by one
    SET @counter = @counter + 1;
END

RETURN 0
