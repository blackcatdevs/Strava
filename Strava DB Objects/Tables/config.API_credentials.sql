CREATE TABLE Config.API_credentials (
client_ID INT  NOT NULL PRIMARY KEY,
client_secret NVARCHAR(64) ,
authorization_code NVARCHAR(64) ,
refresh_token NVARCHAR(64) ,
access_token NVARCHAR(64) ,
access_token_expires_at DATETIME 
);
