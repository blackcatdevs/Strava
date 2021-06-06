﻿CREATE TABLE Staging.Activities (
ID UNIQUEIDENTIFIER NOT NULL PRIMARY KEY,
athlete_id NVARCHAR(50) NOT NULL,
name NVARCHAR(250) NOT NULL,
distance NUMERIC(10, 2) ,
moving_time INT ,
elapsed_time INT ,
total_elevation_gain NUMERIC(5, 1) ,
activity_type_id INT ,
workout_type INT ,
activity_id NVARCHAR(50) NOT NULL,
external_id NVARCHAR(100) ,
start_date DATETIME NOT NULL,
achievement_count INT ,
kudos_count INT ,
comment_count INT ,
athlete_count INT ,
photo_count INT ,
private BIT NOT NULL ,
gear_id NVARCHAR(50) ,
average_speed NUMERIC(3, 1) ,
max_speed NUMERIC(3, 1) ,
average_heartrate NUMERIC(4, 1) ,
max_heartrate NUMERIC(4, 1) ,
pr_count INT ,
suffer_score NUMERIC(4, 1) ,
date_created DATETIME DEFAULT GETDATE(),
date_processed DATETIME DEFAULT GETDATE()
);

