CREATE TABLE Reporting.DIM_activity_type (
activity_type_id UNIQUEIDENTIFIER NOT NULL PRIMARY KEY,
activity_type NVARCHAR(50),
date_created DATETIME DEFAULT GETDATE()
);
