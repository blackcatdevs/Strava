-- thanks to https://github.com/areed1192/sigma_coding_youtube for this

/*
UNDERSTANDING THE Show Advanced Options
------------------------------------------------------------------------------------------------------------------
Some configuration options, such as affinity mask and recovery interval, are designated as advanced options. By 
default, these options are not available for viewing and changing. To make them available, set the ShowAdvancedOptions 
configuration option to 1.
*/

EXEC sp_configure 'show advanced options', 1
RECONFIGURE
GO

/*
UNDERSTANDING THE OLE Automation Procedue
------------------------------------------------------------------------------------------------------------------
Use the Ole Automation Procedures option to specify whether OLE Automation objects can be instantiated within 
Transact-SQL batches. This option can also be configured using the Policy-Based Management or the sp_configure stored 
procedure. The Ole Automation Procedures option can be set to the following values.
Value: 0
Definition: OLE Automation Procedures are disabled. Default for new instances of SQL Server.
Value: 1
Definition: OLE Automation Procedures are enabled.
  
When OLE Automation Procedures are enabled, a call to sp_OACreate will start the OLE shared execution environment. The current 
value of the Ole Automation Procedures option can be viewed and changed by using the sp_configure system stored procedure.
*/

EXEC sp_configure 'Ole Automation Procedures', 1
RECONFIGURE
GO;