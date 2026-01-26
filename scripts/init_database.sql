USE master;
GO

--Checks if DataWarehouse database already exists
IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'DataWarehouse')
BEGIN 
	ALTER DATABASE DataWarehouse SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
	DROP DATABASE DataWarehouse;
END;
GO

-- Create 'DataWarehouse' database
CREATE DATABASE DataWarehouse;
GO 
USE DataWarehouse;
GO

-- Create Schemas (Bronze, Silver, Gold)
CREATE SCHEMA bronze;
GO
CREATE SCHEMA silver;
GO
CREATE SCHEMA gold;
