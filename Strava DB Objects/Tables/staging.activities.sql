﻿CREATE TABLE Staging.Activities (
ID uniqueidentifier NOT NULL PRIMARY KEY,
resource_state NVARCHAR(250),
athlete_id NVARCHAR(250),
athlete_resource_state NVARCHAR(250),
[name] NVARCHAR(250),
distance NVARCHAR(250),
moving_time NVARCHAR(250),
elapsed_time NVARCHAR(250),
total_elevation_gain NVARCHAR(250),
activity_type NVARCHAR(250),
workout_type NVARCHAR(250),
activity_id NVARCHAR(250) NOT NULL UNIQUE,
external_id NVARCHAR(250),
upload_id NVARCHAR(250),
start_date NVARCHAR(250),
start_date_local NVARCHAR(250),
timezone NVARCHAR(250),
utc_offset NVARCHAR(250),
start_latlng NVARCHAR(250),
end_latlng NVARCHAR(250),
location_city NVARCHAR(250),
location_state NVARCHAR(250),
location_country NVARCHAR(250),
achievement_count NVARCHAR(250),
kudos_count NVARCHAR(250),
comment_count NVARCHAR(250),
athlete_count NVARCHAR(250),
photo_count NVARCHAR(250),
 map_id NVARCHAR(250),
map_summary_polyline NVARCHAR(MAX),
map_resource_state NVARCHAR(250),
trainer NVARCHAR(250),
commute NVARCHAR(250),
[manual] NVARCHAR(250),
private NVARCHAR(250),
flagged NVARCHAR(250),
gear_id NVARCHAR(250),
from_accepted_tag NVARCHAR(250),
average_speed NVARCHAR(250),
max_speed NVARCHAR(250),
average_cadence NVARCHAR(250),
average_watts NVARCHAR(250),
weighted_average_watts NVARCHAR(250),
kilojoules NVARCHAR(250),
device_watts NVARCHAR(250),
has_heartrate NVARCHAR(250),
average_heartrate NVARCHAR(250),
max_heartrate NVARCHAR(250),
max_watts NVARCHAR(250),
pr_count NVARCHAR(250),
total_photo_count NVARCHAR(250),
has_kudoed NVARCHAR(250),
suffer_score NVARCHAR(250),
date_created DATETIME DEFAULT GETDATE(),
date_amended DATETIME DEFAULT GETDATE()
);

