CREATE TABLE reporting.DIM_time (
    [TimeId] [int] IDENTITY(1,1) NOT NULL,
    [Time] [time](0) NULL,
    [Hour] [int] NULL,
    [Minute] [int] NULL,
    [MilitaryHour] int NOT null,
    [MilitaryMinute] int NOT null,
    [AMPM] [varchar](2) NOT NULL,
    [DayPartEN] [varchar](10) NULL,
    [DayPartNL] [varchar](10) NULL,
    [HourFromTo12] [varchar](17) NULL,
    [HourFromTo24] [varchar](13) NULL,
    [Notation12] [varchar](10) NULL,
    [Notation24] [varchar](10) NULL
);
