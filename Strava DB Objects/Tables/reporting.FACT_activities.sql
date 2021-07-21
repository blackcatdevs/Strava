﻿CREATE TABLE Reporting.FACT_activities (
ID UNIQUEIDENTIFIER NOT NULL PRIMARY KEY REFERENCES Staging.Activities(ID),
athlete_id VARCHAR(50) NOT NULL,
[name] NVARCHAR(250) NOT NULL,
distance NUMERIC(10, 2) ,
moving_time INT ,
elapsed_time INT ,
total_elevation_gain NUMERIC(5, 1) ,
activity_type_id UNIQUEIDENTIFIER FOREIGN KEY REFERENCES Reporting.DIM_activity_type(activity_type_id),
workout_type_id INT ,
activity_id VARCHAR(50) ,
external_id VARCHAR(100) ,
start_date_id UNIQUEIDENTIFIER,-- FOREIGN KEY REFERENCES Reporting.DIM_date(date_id),
achievement_count INT ,
kudos_count INT ,
comment_count INT ,
athlete_count INT ,
photo_count INT ,
private BIT NOT NULL ,
gear_id VARCHAR(50) ,
average_speed NUMERIC(3, 1) ,
max_speed NUMERIC(3, 1) ,
average_heartrate NUMERIC(4, 1) ,
max_heartrate NUMERIC(4, 1) ,
pr_count INT ,
suffer_score NUMERIC(4, 1),
date_created DATETIME DEFAULT GETDATE(),
date_amended DATETIME DEFAULT GETDATE()
);
