CREATE TABLE Reporting.DIM_activity_type (
activity_type_id [int] IDENTITY(1,1) PRIMARY KEY,
activity_type VARCHAR(50),
date_created DATETIME DEFAULT GETDATE()
);
