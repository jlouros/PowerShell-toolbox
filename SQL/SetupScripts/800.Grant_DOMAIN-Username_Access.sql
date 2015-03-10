USE [master]
GO
PRINT 'Adding DOMAIN\username login to master'
IF NOT EXISTS (SELECT 1 FROM master.sys.server_principals where name = 'DOMAIN\username')
BEGIN
  CREATE LOGIN [DOMAIN\username] FROM WINDOWS WITH DEFAULT_DATABASE=[master]
END
GO
USE [DBName]
GO
PRINT 'Adding DOMAIN\username login to DBName'
IF NOT EXISTS (SELECT 1 FROM sys.sysusers where name = 'DOMAIN\username')
BEGIN
  CREATE USER [DOMAIN\username] FOR LOGIN [DOMAIN\username]
END
GO
USE [DBName]
GO
PRINT 'Adding DOMAIN\username db_owner role to DBName'
EXEC sp_addrolemember N'db_owner', N'DOMAIN\username'
GO
