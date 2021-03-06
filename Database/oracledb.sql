/*============================================================================
  File:     oracle.sql

  Summary:  Creates the Oracle sample database.

  Date:     April 30, 2015

  SQL Server Version: 12.0.2000.80

------------------------------------------------------------------------------
  This file is part of the BOOBOOKE T-SQL Training of Microsoft SQL Server Code Samples.

  Copyright (C) Boobooke Corporation.  All rights reserved.

  This source code is intended only as a supplement to Microsoft
  Development Tools and/or on-line documentation.  See these other
  materials for detailed information regarding Microsoft code samples.

  All data in this database is ficticious.
  
  THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY
  KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
  IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A
  PARTICULAR PURPOSE.
============================================================================*/

PRINT '';
PRINT 'Started - ' + CONVERT(varchar, GETDATE(), 121);
GO

USE [master];
GO

-- *********************************
-- Drop Database
-- *********************************
PRINT '';
PRINT '*** Dropping Database';
GO

IF EXISTS (SELECT [name] FROM [master].[sys].[databases] WHERE [name]= N'OracleDB')
    DROP DATABASE [OracleDB];

-- If the database has any other open connection close the network connection
IF @@ERROR = 3702
	RAISERROR('[OracleDB] database cannot be dropped because there are still other open connections', 127, 127) WITH NOWAIT, LOG;
GO

-- *********************************
-- Create Database
-- *********************************
PRINT '';
PRINT '*** Creating Database';
GO

CREATE DATABASE [OracleDB]
	ON (NAME = 'OracleDB_Data', FILENAME = N'C:\SQLData\OracleDB_Data.mdf', SIZE = 10, FILEGROWTH = 8)
	LOG ON (NAME = 'OracleDB_Log', FILENAME= N'C:\SQLData\OracleDB_Log.ldf', SIZE = 2, FILEGROWTH = 96);
GO

PRINT '';
PRINT '*** Checking for OracleDB Database';

/* CHECK FOR DATABASE IF IT DOESN'T EXISTS, DO NOT RUN THE REST OF THE SCRIPT */
IF NOT EXISTS (SELECT TOP 1 1 FROM sys.databases WHERE name = N'OracleDB')
BEGIN
PRINT '*******************************************************************************************************************************************************************'
+char(10)+'********OracleDB Database does not exist.  I cannot go ahead.*********'
+char(10)+'*******************************************************************************************************************************************************************';
SET NOEXEC ON;
END
GO

ALTER DATABASE [OracleDB] 
SET RECOVERY SIMPLE, 
    ANSI_NULLS ON, 
    ANSI_PADDING ON, 
    ANSI_WARNINGS ON, 
    ARITHABORT ON, 
    CONCAT_NULL_YIELDS_NULL ON, 
    QUOTED_IDENTIFIER ON, 
    NUMERIC_ROUNDABORT OFF, 
    PAGE_VERIFY CHECKSUM, 
    ALLOW_SNAPSHOT_ISOLATION OFF;
GO

USE [OracleDB];
GO

---------------------------------------------------------------------
-- Create Schemas
---------------------------------------------------------------------
CREATE SCHEMA hr AUTHORIZATION dbo;
GO

---------------------------------------------------------------------
-- Create Tables
---------------------------------------------------------------------

-- Create table HR.regions
CREATE TABLE hr.regions
(
	  region_id	INT NOT NULL
	, region_name NVARCHAR(25)
	, CONSTRAINT PK_Regions PRIMARY KEY(region_id)
);
GO

-- Create table HR.countries
CREATE TABLE hr.countries
(
	  country_id    NCHAR(2) NOT NULL
	, country_name  NVARCHAR(40)
	, region_id     INT
	, CONSTRAINT PK_Countries PRIMARY KEY(country_id)
	, CONSTRAINT FK_Countries FOREIGN KEY(region_id) REFERENCES hr.regions(region_id)
);
GO

CREATE TABLE hr.locations
(
	  location_id    INT NOT NULL
	, street_address NVARCHAR(40)
	, postal_code    NVARCHAR(12)
	, city           NVARCHAR(30) NOT NULL
	, state_province NVARCHAR(25)
	, country_id     NCHAR(2)
	, CONSTRAINT PK_Locations PRIMARY KEY(location_id)
	, CONSTRAINT FK_Locations FOREIGN KEY(country_id) REFERENCES hr.countries(country_id)
);
GO

CREATE TABLE hr.departments
(
	  department_id    INT NOT NULL
	, department_name  NVARCHAR(30) NOT NULL
	, manager_id       INT
	, location_id      INT
	, CONSTRAINT PK_Departments PRIMARY KEY(department_id)
	, CONSTRAINT FK_Departments FOREIGN KEY(location_id) REFERENCES hr.locations(location_id)
);
GO

CREATE TABLE hr.jobs
(
	  job_id     NVARCHAR(10) NOT NULL
	, job_title  NVARCHAR(35) NOT NULL
	, min_salary MONEY
	, max_salary MONEY
	, CONSTRAINT PK_Jobs PRIMARY KEY(job_id)
)
GO

CREATE TABLE hr.employees
(
	  employee_id    INT NOT NULL
	, first_name     NVARCHAR(20)
	, last_name      NVARCHAR(25) NOT NULL
	, email          NVARCHAR(25) NOT NULL UNIQUE
	, phone_number   NVARCHAR(20)
	, hire_date      DATETIME     NOT NULL
	, job_id         NVARCHAR(10) NOT NULL
	, salary         MONEY
	, commission_pct DECIMAL(2, 2)
	, manager_id     INT
	, department_id  INT
	, CONSTRAINT emp_salary_min CHECK(salary > 0)
	, CONSTRAINT PK_Employees PRIMARY KEY(employee_id)
	, CONSTRAINT FK_Emp_Dept FOREIGN KEY(department_id) REFERENCES hr.departments(department_id)
	, CONSTRAINT FK_Emp_Jobs FOREIGN KEY(job_id) REFERENCES hr.jobs(job_id)
	, CONSTRAINT FK_Emp_Mgr  FOREIGN KEY(manager_id) REFERENCES hr.employees(employee_id)
)
GO

CREATE TABLE hr.job_history
(
	  employee_id    INT NOT NULL
	, start_date     DATETIME NOT NULL
	, end_date       DATETIME NOT NULL
	, job_id         NVARCHAR(10) NOT NULL
	, department_id  INT
	, CONSTRAINT jhist_date_interval CHECK(end_date > start_date)
	, CONSTRAINT PK_Jobhist PRIMARY KEY(employee_id, start_date)
	, CONSTRAINT FK_Jhist_Dept FOREIGN KEY(department_id) REFERENCES hr.departments(department_id)
	, CONSTRAINT FK_Jhist_Job FOREIGN KEY(job_id) REFERENCES hr.jobs(job_id)
	, CONSTRAINT FK_Jhist_Emp  FOREIGN KEY(employee_id) REFERENCES hr.employees(employee_id)
);
GO


PRINT '';
PRINT '*** Now populate the data into the tables';
GO

INSERT INTO hr.regions VALUES 
        ( 1
        , 'Europe' 
        );

INSERT INTO hr.regions VALUES 
        ( 2
        , 'Americas' 
        );

INSERT INTO hr.regions VALUES 
        ( 3
        , 'Asia' 
        );

INSERT INTO hr.regions VALUES 
        ( 4
        , 'Middle East and Africa' 
        );

----------------------------------------------------------------------------------
INSERT INTO hr.countries VALUES 
        ( 'IT'
        , 'Italy'
        , 1 
        );

INSERT INTO hr.countries VALUES 
        ( 'JP'
        , 'Japan'
	, 3 
        );

INSERT INTO hr.countries VALUES 
        ( 'US'
        , 'United States of America'
        , 2 
        );

INSERT INTO hr.countries VALUES 
        ( 'CA'
        , 'Canada'
        , 2 
        );

INSERT INTO hr.countries VALUES 
        ( 'CN'
        , 'China'
        , 3 
        );

INSERT INTO hr.countries VALUES 
        ( 'IN'
        , 'India'
        , 3 
        );

INSERT INTO hr.countries VALUES 
        ( 'AU'
        , 'Australia'
        , 3 
        );

INSERT INTO hr.countries VALUES 
        ( 'ZW'
        , 'Zimbabwe'
        , 4 
        );

INSERT INTO hr.countries VALUES 
        ( 'SG'
        , 'Singapore'
        , 3 
        );

INSERT INTO hr.countries VALUES 
        ( 'UK'
        , 'United Kingdom'
        , 1 
        );

INSERT INTO hr.countries VALUES 
        ( 'FR'
        , 'France'
        , 1 
        );

INSERT INTO hr.countries VALUES 
        ( 'DE'
        , 'Germany'
        , 1 
        );

INSERT INTO hr.countries VALUES 
        ( 'ZM'
        , 'Zambia'
        , 4 
        );

INSERT INTO hr.countries VALUES 
        ( 'EG'
        , 'Egypt'
        , 4 
        );

INSERT INTO hr.countries VALUES 
        ( 'BR'
        , 'Brazil'
        , 2 
        );

INSERT INTO hr.countries VALUES 
        ( 'CH'
        , 'Switzerland'
        , 1 
        );

INSERT INTO hr.countries VALUES 
        ( 'NL'
        , 'Netherlands'
        , 1 
        );

INSERT INTO hr.countries VALUES 
        ( 'MX'
        , 'Mexico'
        , 2 
        );

INSERT INTO hr.countries VALUES 
        ( 'KW'
        , 'Kuwait'
        , 4 
        );

INSERT INTO hr.countries VALUES 
        ( 'IL'
        , 'Israel'
        , 4 
        );

INSERT INTO hr.countries VALUES 
        ( 'DK'
        , 'Denmark'
        , 1 
        );

INSERT INTO hr.countries VALUES 
        ( 'HK'
        , 'HongKong'
        , 3 
        );

INSERT INTO hr.countries VALUES 
        ( 'NG'
        , 'Nigeria'
        , 4 
        );

INSERT INTO hr.countries VALUES 
        ( 'AR'
        , 'Argentina'
        , 2 
        );

INSERT INTO hr.countries VALUES 
        ( 'BE'
        , 'Belgium'
        , 1 
        );
----------------------------------------------------------------------------------
INSERT INTO hr.locations VALUES 
        ( 1000 
        , '1297 Via Cola di Rie'
        , '00989'
        , 'Roma'
        , NULL
        , 'IT'
        );

INSERT INTO hr.locations VALUES 
        ( 1100 
        , '93091 Calle della Testa'
        , '10934'
        , 'Venice'
        , NULL
        , 'IT'
        );

INSERT INTO hr.locations VALUES 
        ( 1200 
        , '2017 Shinjuku-ku'
        , '1689'
        , 'Tokyo'
        , 'Tokyo Prefecture'
        , 'JP'
        );

INSERT INTO hr.locations VALUES 
        ( 1300 
        , '9450 Kamiya-cho'
        , '6823'
        , 'Hiroshima'
        , NULL
        , 'JP'
        );

INSERT INTO hr.locations VALUES 
        ( 1400 
        , '2014 Jabberwocky Rd'
        , '26192'
        , 'Southlake'
        , 'Texas'
        , 'US'
        );

INSERT INTO hr.locations VALUES 
        ( 1500 
        , '2011 Interiors Blvd'
        , '99236'
        , 'South San Francisco'
        , 'California'
        , 'US'
        );

INSERT INTO hr.locations VALUES 
        ( 1600 
        , '2007 Zagora St'
        , '50090'
        , 'South Brunswick'
        , 'New Jersey'
        , 'US'
        );

INSERT INTO hr.locations VALUES 
        ( 1700 
        , '2004 Charade Rd'
        , '98199'
        , 'Seattle'
        , 'Washington'
        , 'US'
        );

INSERT INTO hr.locations VALUES 
        ( 1800 
        , '147 Spadina Ave'
        , 'M5V 2L7'
        , 'Toronto'
        , 'Ontario'
        , 'CA'
        );

INSERT INTO hr.locations VALUES 
        ( 1900 
        , '6092 Boxwood St'
        , 'YSW 9T2'
        , 'Whitehorse'
        , 'Yukon'
        , 'CA'
        );

INSERT INTO hr.locations VALUES 
        ( 2000 
        , '40-5-12 Laogianggen'
        , '190518'
        , 'Beijing'
        , NULL
        , 'CN'
        );

INSERT INTO hr.locations VALUES 
        ( 2100 
        , '1298 Vileparle (E)'
        , '490231'
        , 'Bombay'
        , 'Maharashtra'
        , 'IN'
        );

INSERT INTO hr.locations VALUES 
        ( 2200 
        , '12-98 Victoria Street'
        , '2901'
        , 'Sydney'
        , 'New South Wales'
        , 'AU'
        );

INSERT INTO hr.locations VALUES 
        ( 2300 
        , '198 Clementi North'
        , '540198'
        , 'Singapore'
        , NULL
        , 'SG'
        );

INSERT INTO hr.locations VALUES 
        ( 2400 
        , '8204 Arthur St'
        , NULL
        , 'London'
        , NULL
        , 'UK'
        );

INSERT INTO hr.locations VALUES 
        ( 2500 
        , 'Magdalen Centre, The Oxford Science Park'
        , 'OX9 9ZB'
        , 'Oxford'
        , 'Oxford'
        , 'UK'
        );

INSERT INTO hr.locations VALUES 
        ( 2600 
        , '9702 Chester Road'
        , '09629850293'
        , 'Stretford'
        , 'Manchester'
        , 'UK'
        );

INSERT INTO hr.locations VALUES 
        ( 2700 
        , 'Schwanthalerstr. 7031'
        , '80925'
        , 'Munich'
        , 'Bavaria'
        , 'DE'
        );

INSERT INTO hr.locations VALUES 
        ( 2800 
        , 'Rua Frei Caneca 1360 '
        , '01307-002'
        , 'Sao Paulo'
        , 'Sao Paulo'
        , 'BR'
        );

INSERT INTO hr.locations VALUES 
        ( 2900 
        , '20 Rue des Corps-Saints'
        , '1730'
        , 'Geneva'
        , 'Geneve'
        , 'CH'
        );

INSERT INTO hr.locations VALUES 
        ( 3000 
        , 'Murtenstrasse 921'
        , '3095'
        , 'Bern'
        , 'BE'
        , 'CH'
        );

INSERT INTO hr.locations VALUES 
        ( 3100 
        , 'Pieter Breughelstraat 837'
        , '3029SK'
        , 'Utrecht'
        , 'Utrecht'
        , 'NL'
        );

INSERT INTO hr.locations VALUES 
        ( 3200 
        , 'Mariano Escobedo 9991'
        , '11932'
        , 'Mexico City'
        , 'Distrito Federal,'
        , 'MX'
        );

----------------------------------------------------------------------------------
INSERT INTO hr.departments VALUES 
        ( 10
        , 'Administration'
        , 200
        , 1700
        );

INSERT INTO hr.departments VALUES 
        ( 20
        , 'Marketing'
        , 201
        , 1800
        );
                                
INSERT INTO hr.departments VALUES 
        ( 30
        , 'Purchasing'
        , 114
        , 1700
	);
                
INSERT INTO hr.departments VALUES 
        ( 40
        , 'Human Resources'
        , 203
        , 2400
        );

INSERT INTO hr.departments VALUES 
        ( 50
        , 'Shipping'
        , 121
        , 1500
        );
                
INSERT INTO hr.departments VALUES 
        ( 60 
        , 'IT'
        , 103
        , 1400
        );
                
INSERT INTO hr.departments VALUES 
        ( 70 
        , 'Public Relations'
        , 204
        , 2700
        );
                
INSERT INTO hr.departments VALUES 
        ( 80 
        , 'Sales'
        , 145
        , 2500
        );
                
INSERT INTO hr.departments VALUES 
        ( 90 
        , 'Executive'
        , 100
        , 1700
        );

INSERT INTO hr.departments VALUES 
        ( 100 
        , 'Finance'
        , 108
        , 1700
        );
                
INSERT INTO hr.departments VALUES 
        ( 110 
        , 'Accounting'
        , 205
        , 1700
        );

INSERT INTO hr.departments VALUES 
        ( 120 
        , 'Treasury'
        , NULL
        , 1700
        );

INSERT INTO hr.departments VALUES 
        ( 130 
        , 'Corporate Tax'
        , NULL
        , 1700
        );

INSERT INTO hr.departments VALUES 
        ( 140 
        , 'Control And Credit'
        , NULL
        , 1700
        );

INSERT INTO hr.departments VALUES 
        ( 150 
        , 'Shareholder Services'
        , NULL
        , 1700
        );

INSERT INTO hr.departments VALUES 
        ( 160 
        , 'Benefits'
        , NULL
        , 1700
        );

INSERT INTO hr.departments VALUES 
        ( 170 
        , 'Manufacturing'
        , NULL
        , 1700
        );

INSERT INTO hr.departments VALUES 
        ( 180 
        , 'Construction'
        , NULL
        , 1700
        );

INSERT INTO hr.departments VALUES 
        ( 190 
        , 'Contracting'
        , NULL
        , 1700
        );

INSERT INTO hr.departments VALUES 
        ( 200 
        , 'Operations'
        , NULL
        , 1700
        );

INSERT INTO hr.departments VALUES 
        ( 210 
        , 'IT Support'
        , NULL
        , 1700
        );

INSERT INTO hr.departments VALUES 
        ( 220 
        , 'NOC'
        , NULL
        , 1700
        );

INSERT INTO hr.departments VALUES 
        ( 230 
        , 'IT Helpdesk'
        , NULL
        , 1700
        );

INSERT INTO hr.departments VALUES 
        ( 240 
        , 'Government Sales'
        , NULL
        , 1700
        );

INSERT INTO hr.departments VALUES 
        ( 250 
        , 'Retail Sales'
        , NULL
        , 1700
        );

INSERT INTO hr.departments VALUES 
        ( 260 
        , 'Recruiting'
        , NULL
        , 1700
        );

INSERT INTO hr.departments VALUES 
        ( 270 
        , 'Payroll'
        , NULL
        , 1700
        );

----------------------------------------------------------------------------------
INSERT INTO hr.jobs VALUES 
        ( 'AD_PRES'
        , 'President'
        , 20000
        , 40000
        );
INSERT INTO hr.jobs VALUES 
        ( 'AD_VP'
        , 'Administration Vice President'
        , 15000
        , 30000
        );

INSERT INTO hr.jobs VALUES 
        ( 'AD_ASST'
        , 'Administration Assistant'
        , 3000
        , 6000
        );

INSERT INTO hr.jobs VALUES 
        ( 'FI_MGR'
        , 'Finance Manager'
        , 8200
        , 16000
        );

INSERT INTO hr.jobs VALUES 
        ( 'FI_ACCOUNT'
        , 'Accountant'
        , 4200
        , 9000
        );

INSERT INTO hr.jobs VALUES 
        ( 'AC_MGR'
        , 'Accounting Manager'
        , 8200
        , 16000
        );

INSERT INTO hr.jobs VALUES 
        ( 'AC_ACCOUNT'
        , 'Public Accountant'
        , 4200
        , 9000
        );
INSERT INTO hr.jobs VALUES 
        ( 'SA_MAN'
        , 'Sales Manager'
        , 10000
        , 20000
        );

INSERT INTO hr.jobs VALUES 
        ( 'SA_REP'
        , 'Sales Representative'
        , 6000
        , 12000
        );

INSERT INTO hr.jobs VALUES 
        ( 'PU_MAN'
        , 'Purchasing Manager'
        , 8000
        , 15000
        );

INSERT INTO hr.jobs VALUES 
        ( 'PU_CLERK'
        , 'Purchasing Clerk'
        , 2500
        , 5500
        );

INSERT INTO hr.jobs VALUES 
        ( 'ST_MAN'
        , 'Stock Manager'
        , 5500
        , 8500
        );
INSERT INTO hr.jobs VALUES 
        ( 'ST_CLERK'
        , 'Stock Clerk'
        , 2000
        , 5000
        );

INSERT INTO hr.jobs VALUES 
        ( 'SH_CLERK'
        , 'Shipping Clerk'
        , 2500
        , 5500
        );

INSERT INTO hr.jobs VALUES 
        ( 'IT_PROG'
        , 'Programmer'
        , 4000
        , 10000
        );

INSERT INTO hr.jobs VALUES 
        ( 'MK_MAN'
        , 'Marketing Manager'
        , 9000
        , 15000
        );

INSERT INTO hr.jobs VALUES 
        ( 'MK_REP'
        , 'Marketing Representative'
        , 4000
        , 9000
        );

INSERT INTO hr.jobs VALUES 
        ( 'HR_REP'
        , 'Human Resources Representative'
        , 4000
        , 9000
        );

INSERT INTO hr.jobs VALUES 
        ( 'PR_REP'
        , 'Public Relations Representative'
        , 4500
        , 10500
        );

----------------------------------------------------------------------------------
INSERT INTO hr.employees VALUES 
        ( 100
        , 'Steven'
        , 'King'
        , 'SKING'
        , '515.123.4567'
        , CONVERT(DATETIME, '17-JUN-1987')
        , 'AD_PRES'
        , 24000
        , NULL
        , NULL
        , 90
        );

INSERT INTO hr.employees VALUES 
        ( 101
        , 'Neena'
        , 'Kochhar'
        , 'NKOCHHAR'
        , '515.123.4568'
        , CONVERT(DATETIME, '21-SEP-1989')
        , 'AD_VP'
        , 17000
        , NULL
        , 100
        , 90
        );

INSERT INTO hr.employees VALUES 
        ( 102
        , 'Lex'
        , 'De Haan'
        , 'LDEHAAN'
        , '515.123.4569'
        , CONVERT(DATETIME, '13-JAN-1993')
        , 'AD_VP'
        , 17000
        , NULL
        , 100
        , 90
        );

INSERT INTO hr.employees VALUES 
        ( 103
        , 'Alexander'
        , 'Hunold'
        , 'AHUNOLD'
        , '590.423.4567'
        , CONVERT(DATETIME, '03-JAN-1990')
        , 'IT_PROG'
        , 9000
        , NULL
        , 102
        , 60
        );

INSERT INTO hr.employees VALUES 
        ( 104
        , 'Bruce'
        , 'Ernst'
        , 'BERNST'
        , '590.423.4568'
        , CONVERT(DATETIME, '21-MAY-1991')
        , 'IT_PROG'
        , 6000
        , NULL
        , 103
        , 60
        );

INSERT INTO hr.employees VALUES 
        ( 105
        , 'David'
        , 'Austin'
        , 'DAUSTIN'
        , '590.423.4569'
        , CONVERT(DATETIME, '25-JUN-1997')
        , 'IT_PROG'
        , 4800
        , NULL
        , 103
        , 60
        );

INSERT INTO hr.employees VALUES 
        ( 106
        , 'Valli'
        , 'Pataballa'
        , 'VPATABAL'
        , '590.423.4560'
        , CONVERT(DATETIME, '05-FEB-1998')
        , 'IT_PROG'
        , 4800
        , NULL
        , 103
        , 60
        );

INSERT INTO hr.employees VALUES 
        ( 107
        , 'Diana'
        , 'Lorentz'
        , 'DLORENTZ'
        , '590.423.5567'
        , CONVERT(DATETIME, '07-FEB-1999')
        , 'IT_PROG'
        , 4200
        , NULL
        , 103
        , 60
        );

INSERT INTO hr.employees VALUES 
        ( 108
        , 'Nancy'
        , 'Greenberg'
        , 'NGREENBE'
        , '515.124.4569'
        , CONVERT(DATETIME, '17-AUG-1994')
        , 'FI_MGR'
        , 12000
        , NULL
        , 101
        , 100
        );

INSERT INTO hr.employees VALUES 
        ( 109
        , 'Daniel'
        , 'Faviet'
        , 'DFAVIET'
        , '515.124.4169'
        , CONVERT(DATETIME, '16-AUG-1994')
        , 'FI_ACCOUNT'
        , 9000
        , NULL
        , 108
        , 100
        );

INSERT INTO hr.employees VALUES 
        ( 110
        , 'John'
        , 'Chen'
        , 'JCHEN'
        , '515.124.4269'
        , CONVERT(DATETIME, '28-SEP-1997')
        , 'FI_ACCOUNT'
        , 8200
        , NULL
        , 108
        , 100
        );

INSERT INTO hr.employees VALUES 
        ( 111
        , 'Ismael'
        , 'Sciarra'
        , 'ISCIARRA'
        , '515.124.4369'
        , CONVERT(DATETIME, '30-SEP-1997')
        , 'FI_ACCOUNT'
        , 7700
        , NULL
        , 108
        , 100
        );

INSERT INTO hr.employees VALUES 
        ( 112
        , 'Jose Manuel'
        , 'Urman'
        , 'JMURMAN'
        , '515.124.4469'
        , CONVERT(DATETIME, '07-MAR-1998')
        , 'FI_ACCOUNT'
        , 7800
        , NULL
        , 108
        , 100
        );

INSERT INTO hr.employees VALUES 
        ( 113
        , 'Luis'
        , 'Popp'
        , 'LPOPP'
        , '515.124.4567'
        , CONVERT(DATETIME, '07-DEC-1999')
        , 'FI_ACCOUNT'
        , 6900
        , NULL
        , 108
        , 100
        );

INSERT INTO hr.employees VALUES 
        ( 114
        , 'Den'
        , 'Raphaely'
        , 'DRAPHEAL'
        , '515.127.4561'
        , CONVERT(DATETIME, '07-DEC-1994')
        , 'PU_MAN'
        , 11000
        , NULL
        , 100
        , 30
        );

INSERT INTO hr.employees VALUES 
        ( 115
        , 'Alexander'
        , 'Khoo'
        , 'AKHOO'
        , '515.127.4562'
        , CONVERT(DATETIME, '18-MAY-1995')
        , 'PU_CLERK'
        , 3100
        , NULL
        , 114
        , 30
        );

INSERT INTO hr.employees VALUES 
        ( 116
        , 'Shelli'
        , 'Baida'
        , 'SBAIDA'
        , '515.127.4563'
        , CONVERT(DATETIME, '24-DEC-1997')
        , 'PU_CLERK'
        , 2900
        , NULL
        , 114
        , 30
        );

INSERT INTO hr.employees VALUES 
        ( 117
        , 'Sigal'
        , 'Tobias'
        , 'STOBIAS'
        , '515.127.4564'
        , CONVERT(DATETIME, '24-JUL-1997')
        , 'PU_CLERK'
        , 2800
        , NULL
        , 114
        , 30
        );

INSERT INTO hr.employees VALUES 
        ( 118
        , 'Guy'
        , 'Himuro'
        , 'GHIMURO'
        , '515.127.4565'
        , CONVERT(DATETIME, '15-NOV-1998')
        , 'PU_CLERK'
        , 2600
        , NULL
        , 114
        , 30
        );

INSERT INTO hr.employees VALUES 
        ( 119
        , 'Karen'
        , 'Colmenares'
        , 'KCOLMENA'
        , '515.127.4566'
        , CONVERT(DATETIME, '10-AUG-1999')
        , 'PU_CLERK'
        , 2500
        , NULL
        , 114
        , 30
        );

INSERT INTO hr.employees VALUES 
        ( 120
        , 'Matthew'
        , 'Weiss'
        , 'MWEISS'
        , '650.123.1234'
        , CONVERT(DATETIME, '18-JUL-1996')
        , 'ST_MAN'
        , 8000
        , NULL
        , 100
        , 50
        );

INSERT INTO hr.employees VALUES 
        ( 121
        , 'Adam'
        , 'Fripp'
        , 'AFRIPP'
        , '650.123.2234'
        , CONVERT(DATETIME, '10-APR-1997')
        , 'ST_MAN'
        , 8200
        , NULL
        , 100
        , 50
        );

INSERT INTO hr.employees VALUES 
        ( 122
        , 'Payam'
        , 'Kaufling'
        , 'PKAUFLIN'
        , '650.123.3234'
        , CONVERT(DATETIME, '01-MAY-1995')
        , 'ST_MAN'
        , 7900
        , NULL
        , 100
        , 50
        );

INSERT INTO hr.employees VALUES 
        ( 123
        , 'Shanta'
        , 'Vollman'
        , 'SVOLLMAN'
        , '650.123.4234'
        , CONVERT(DATETIME, '10-OCT-1997')
        , 'ST_MAN'
        , 6500
        , NULL
        , 100
        , 50
        );

INSERT INTO hr.employees VALUES 
        ( 124
        , 'Kevin'
        , 'Mourgos'
        , 'KMOURGOS'
        , '650.123.5234'
        , CONVERT(DATETIME, '16-NOV-1999')
        , 'ST_MAN'
        , 5800
        , NULL
        , 100
        , 50
        );

INSERT INTO hr.employees VALUES 
        ( 125
        , 'Julia'
        , 'Nayer'
        , 'JNAYER'
        , '650.124.1214'
        , CONVERT(DATETIME, '16-JUL-1997')
        , 'ST_CLERK'
        , 3200
        , NULL
        , 120
        , 50
        );

INSERT INTO hr.employees VALUES 
        ( 126
        , 'Irene'
        , 'Mikkilineni'
        , 'IMIKKILI'
        , '650.124.1224'
        , CONVERT(DATETIME, '28-SEP-1998')
        , 'ST_CLERK'
        , 2700
        , NULL
        , 120
        , 50
        );

INSERT INTO hr.employees VALUES 
        ( 127
        , 'James'
        , 'Landry'
        , 'JLANDRY'
        , '650.124.1334'
        , CONVERT(DATETIME, '14-JAN-1999')
        , 'ST_CLERK'
        , 2400
        , NULL
        , 120
        , 50
        );

INSERT INTO hr.employees VALUES 
        ( 128
        , 'Steven'
        , 'Markle'
        , 'SMARKLE'
        , '650.124.1434'
        , CONVERT(DATETIME, '08-MAR-2000')
        , 'ST_CLERK'
        , 2200
        , NULL
        , 120
        , 50
        );

INSERT INTO hr.employees VALUES 
        ( 129
        , 'Laura'
        , 'Bissot'
        , 'LBISSOT'
        , '650.124.5234'
        , CONVERT(DATETIME, '20-AUG-1997')
        , 'ST_CLERK'
        , 3300
        , NULL
        , 121
        , 50
        );

INSERT INTO hr.employees VALUES 
        ( 130
        , 'Mozhe'
        , 'Atkinson'
        , 'MATKINSO'
        , '650.124.6234'
        , CONVERT(DATETIME, '30-OCT-1997')
        , 'ST_CLERK'
        , 2800
        , NULL
        , 121
        , 50
        );

INSERT INTO hr.employees VALUES 
        ( 131
        , 'James'
        , 'Marlow'
        , 'JAMRLOW'
        , '650.124.7234'
        , CONVERT(DATETIME, '16-FEB-1997')
        , 'ST_CLERK'
        , 2500
        , NULL
        , 121
        , 50
        );

INSERT INTO hr.employees VALUES 
        ( 132
        , 'TJ'
        , 'Olson'
        , 'TJOLSON'
        , '650.124.8234'
        , CONVERT(DATETIME, '10-APR-1999')
        , 'ST_CLERK'
        , 2100
        , NULL
        , 121
        , 50
        );

INSERT INTO hr.employees VALUES 
        ( 133
        , 'Jason'
        , 'Mallin'
        , 'JMALLIN'
        , '650.127.1934'
        , CONVERT(DATETIME, '14-JUN-1996')
        , 'ST_CLERK'
        , 3300
        , NULL
        , 122
        , 50
        );

INSERT INTO hr.employees VALUES 
        ( 134
        , 'Michael'
        , 'Rogers'
        , 'MROGERS'
        , '650.127.1834'
        , CONVERT(DATETIME, '26-AUG-1998')
        , 'ST_CLERK'
        , 2900
        , NULL
        , 122
        , 50
        );

INSERT INTO hr.employees VALUES 
        ( 135
        , 'Ki'
        , 'Gee'
        , 'KGEE'
        , '650.127.1734'
        , CONVERT(DATETIME, '12-DEC-1999')
        , 'ST_CLERK'
        , 2400
        , NULL
        , 122
        , 50
        );

INSERT INTO hr.employees VALUES 
        ( 136
        , 'Hazel'
        , 'Philtanker'
        , 'HPHILTAN'
        , '650.127.1634'
        , CONVERT(DATETIME, '06-FEB-2000')
        , 'ST_CLERK'
        , 2200
        , NULL
        , 122
        , 50
        );

INSERT INTO hr.employees VALUES 
        ( 137
        , 'Renske'
        , 'Ladwig'
        , 'RLADWIG'
        , '650.121.1234'
        , CONVERT(DATETIME, '14-JUL-1995')
        , 'ST_CLERK'
        , 3600
        , NULL
        , 123
        , 50
        );

INSERT INTO hr.employees VALUES 
        ( 138
        , 'Stephen'
        , 'Stiles'
        , 'SSTILES'
        , '650.121.2034'
        , CONVERT(DATETIME, '26-OCT-1997')
        , 'ST_CLERK'
        , 3200
        , NULL
        , 123
        , 50
        );

INSERT INTO hr.employees VALUES 
        ( 139
        , 'John'
        , 'Seo'
        , 'JSEO'
        , '650.121.2019'
        , CONVERT(DATETIME, '12-FEB-1998')
        , 'ST_CLERK'
        , 2700
        , NULL
        , 123
        , 50
        );

INSERT INTO hr.employees VALUES 
        ( 140
        , 'Joshua'
        , 'Patel'
        , 'JPATEL'
        , '650.121.1834'
        , CONVERT(DATETIME, '06-APR-1998')
        , 'ST_CLERK'
        , 2500
        , NULL
        , 123
        , 50
        );

INSERT INTO hr.employees VALUES 
        ( 141
        , 'Trenna'
        , 'Rajs'
        , 'TRAJS'
        , '650.121.8009'
        , CONVERT(DATETIME, '17-OCT-1995')
        , 'ST_CLERK'
        , 3500
        , NULL
        , 124
        , 50
        );

INSERT INTO hr.employees VALUES 
        ( 142
        , 'Curtis'
        , 'Davies'
        , 'CDAVIES'
        , '650.121.2994'
        , CONVERT(DATETIME, '29-JAN-1997')
        , 'ST_CLERK'
        , 3100
        , NULL
        , 124
        , 50
        );

INSERT INTO hr.employees VALUES 
        ( 143
        , 'Randall'
        , 'Matos'
        , 'RMATOS'
        , '650.121.2874'
        , CONVERT(DATETIME, '15-MAR-1998')
        , 'ST_CLERK'
        , 2600
        , NULL
        , 124
        , 50
        );

INSERT INTO hr.employees VALUES 
        ( 144
        , 'Peter'
        , 'Vargas'
        , 'PVARGAS'
        , '650.121.2004'
        , CONVERT(DATETIME, '09-JUL-1998')
        , 'ST_CLERK'
        , 2500
        , NULL
        , 124
        , 50
        );

INSERT INTO hr.employees VALUES 
        ( 145
        , 'John'
        , 'Russell'
        , 'JRUSSEL'
        , '011.44.1344.429268'
        , CONVERT(DATETIME, '01-OCT-1996')
        , 'SA_MAN'
        , 14000
        , .4
        , 100
        , 80
        );

INSERT INTO hr.employees VALUES 
        ( 146
        , 'Karen'
        , 'Partners'
        , 'KPARTNER'
        , '011.44.1344.467268'
        , CONVERT(DATETIME, '05-JAN-1997')
        , 'SA_MAN'
        , 13500
        , .3
        , 100
        , 80
        );

INSERT INTO hr.employees VALUES 
        ( 147
        , 'Alberto'
        , 'Errazuriz'
        , 'AERRAZUR'
        , '011.44.1344.429278'
        , CONVERT(DATETIME, '10-MAR-1997')
        , 'SA_MAN'
        , 12000
        , .3
        , 100
        , 80
        );

INSERT INTO hr.employees VALUES 
        ( 148
        , 'Gerald'
        , 'Cambrault'
        , 'GCAMBRAU'
        , '011.44.1344.619268'
        , CONVERT(DATETIME, '15-OCT-1999')
        , 'SA_MAN'
        , 11000
        , .3
        , 100
        , 80
        );

INSERT INTO hr.employees VALUES 
        ( 149
        , 'Eleni'
        , 'Zlotkey'
        , 'EZLOTKEY'
        , '011.44.1344.429018'
        , CONVERT(DATETIME, '29-JAN-2000')
        , 'SA_MAN'
        , 10500
        , .2
        , 100
        , 80
        );

INSERT INTO hr.employees VALUES 
        ( 150
        , 'Peter'
        , 'Tucker'
        , 'PTUCKER'
        , '011.44.1344.129268'
        , CONVERT(DATETIME, '30-JAN-1997')
        , 'SA_REP'
        , 10000
        , .3
        , 145
        , 80
        );

INSERT INTO hr.employees VALUES 
        ( 151
        , 'David'
        , 'Bernstein'
        , 'DBERNSTE'
        , '011.44.1344.345268'
        , CONVERT(DATETIME, '24-MAR-1997')
        , 'SA_REP'
        , 9500
        , .25
        , 145
        , 80
        );

INSERT INTO hr.employees VALUES 
        ( 152
        , 'Peter'
        , 'Hall'
        , 'PHALL'
        , '011.44.1344.478968'
        , CONVERT(DATETIME, '20-AUG-1997')
        , 'SA_REP'
        , 9000
        , .25
        , 145
        , 80
        );

INSERT INTO hr.employees VALUES 
        ( 153
        , 'Christopher'
        , 'Olsen'
        , 'COLSEN'
        , '011.44.1344.498718'
        , CONVERT(DATETIME, '30-MAR-1998')
        , 'SA_REP'
        , 8000
        , .2
        , 145
        , 80
        );

INSERT INTO hr.employees VALUES 
        ( 154
        , 'Nanette'
        , 'Cambrault'
        , 'NCAMBRAU'
        , '011.44.1344.987668'
        , CONVERT(DATETIME, '09-DEC-1998')
        , 'SA_REP'
        , 7500
        , .2
        , 145
        , 80
        );

INSERT INTO hr.employees VALUES 
        ( 155
        , 'Oliver'
        , 'Tuvault'
        , 'OTUVAULT'
        , '011.44.1344.486508'
        , CONVERT(DATETIME, '23-NOV-1999')
        , 'SA_REP'
        , 7000
        , .15
        , 145
        , 80
        );

INSERT INTO hr.employees VALUES 
        ( 156
        , 'Janette'
        , 'King'
        , 'JKING'
        , '011.44.1345.429268'
        , CONVERT(DATETIME, '30-JAN-1996')
        , 'SA_REP'
        , 10000
        , .35
        , 146
        , 80
        );

INSERT INTO hr.employees VALUES 
        ( 157
        , 'Patrick'
        , 'Sully'
        , 'PSULLY'
        , '011.44.1345.929268'
        , CONVERT(DATETIME, '04-MAR-1996')
        , 'SA_REP'
        , 9500
        , .35
        , 146
        , 80
        );

INSERT INTO hr.employees VALUES 
        ( 158
        , 'Allan'
        , 'McEwen'
        , 'AMCEWEN'
        , '011.44.1345.829268'
        , CONVERT(DATETIME, '01-AUG-1996')
        , 'SA_REP'
        , 9000
        , .35
        , 146
        , 80
        );

INSERT INTO hr.employees VALUES 
        ( 159
        , 'Lindsey'
        , 'Smith'
        , 'LSMITH'
        , '011.44.1345.729268'
        , CONVERT(DATETIME, '10-MAR-1997')
        , 'SA_REP'
        , 8000
        , .3
        , 146
        , 80
        );

INSERT INTO hr.employees VALUES 
        ( 160
        , 'Louise'
        , 'Doran'
        , 'LDORAN'
        , '011.44.1345.629268'
        , CONVERT(DATETIME, '15-DEC-1997')
        , 'SA_REP'
        , 7500
        , .3
        , 146
        , 80
        );

INSERT INTO hr.employees VALUES 
        ( 161
        , 'Sarath'
        , 'Sewall'
        , 'SSEWALL'
        , '011.44.1345.529268'
        , CONVERT(DATETIME, '03-NOV-1998')
        , 'SA_REP'
        , 7000
        , .25
        , 146
        , 80
        );

INSERT INTO hr.employees VALUES 
        ( 162
        , 'Clara'
        , 'Vishney'
        , 'CVISHNEY'
        , '011.44.1346.129268'
        , CONVERT(DATETIME, '11-NOV-1997')
        , 'SA_REP'
        , 10500
        , .25
        , 147
        , 80
        );

INSERT INTO hr.employees VALUES 
        ( 163
        , 'Danielle'
        , 'Greene'
        , 'DGREENE'
        , '011.44.1346.229268'
        , CONVERT(DATETIME, '19-MAR-1999')
        , 'SA_REP'
        , 9500
        , .15
        , 147
        , 80
        );

INSERT INTO hr.employees VALUES 
        ( 164
        , 'Mattea'
        , 'Marvins'
        , 'MMARVINS'
        , '011.44.1346.329268'
        , CONVERT(DATETIME, '24-JAN-2000')
        , 'SA_REP'
        , 7200
        , .10
        , 147
        , 80
        );

INSERT INTO hr.employees VALUES 
        ( 165
        , 'David'
        , 'Lee'
        , 'DLEE'
        , '011.44.1346.529268'
        , CONVERT(DATETIME, '23-FEB-2000')
        , 'SA_REP'
        , 6800
        , .1
        , 147
        , 80
        );

INSERT INTO hr.employees VALUES 
        ( 166
        , 'Sundar'
        , 'Ande'
        , 'SANDE'
        , '011.44.1346.629268'
        , CONVERT(DATETIME, '24-MAR-2000')
        , 'SA_REP'
        , 6400
        , .10
        , 147
        , 80
        );

INSERT INTO hr.employees VALUES 
        ( 167
        , 'Amit'
        , 'Banda'
        , 'ABANDA'
        , '011.44.1346.729268'
        , CONVERT(DATETIME, '21-APR-2000')
        , 'SA_REP'
        , 6200
        , .10
        , 147
        , 80
        );

INSERT INTO hr.employees VALUES 
        ( 168
        , 'Lisa'
        , 'Ozer'
        , 'LOZER'
        , '011.44.1343.929268'
        , CONVERT(DATETIME, '11-MAR-1997')
        , 'SA_REP'
        , 11500
        , .25
        , 148
        , 80
        );

INSERT INTO hr.employees VALUES 
        ( 169  
        , 'Harrison'
        , 'Bloom'
        , 'HBLOOM'
        , '011.44.1343.829268'
        , CONVERT(DATETIME, '23-MAR-1998')
        , 'SA_REP'
        , 10000
        , .20
        , 148
        , 80
        );

INSERT INTO hr.employees VALUES 
        ( 170
        , 'Tayler'
        , 'Fox'
        , 'TFOX'
        , '011.44.1343.729268'
        , CONVERT(DATETIME, '24-JAN-1998')
        , 'SA_REP'
        , 9600
        , .20
        , 148
        , 80
        );

INSERT INTO hr.employees VALUES 
        ( 171
        , 'William'
        , 'Smith'
        , 'WSMITH'
        , '011.44.1343.629268'
        , CONVERT(DATETIME, '23-FEB-1999')
        , 'SA_REP'
        , 7400
        , .15
        , 148
        , 80
        );

INSERT INTO hr.employees VALUES 
        ( 172
        , 'Elizabeth'
        , 'Bates'
        , 'EBATES'
        , '011.44.1343.529268'
        , CONVERT(DATETIME, '24-MAR-1999')
        , 'SA_REP'
        , 7300
        , .15
        , 148
        , 80
        );

INSERT INTO hr.employees VALUES 
        ( 173
        , 'Sundita'
        , 'Kumar'
        , 'SKUMAR'
        , '011.44.1343.329268'
        , CONVERT(DATETIME, '21-APR-2000')
        , 'SA_REP'
        , 6100
        , .10
        , 148
        , 80
        );

INSERT INTO hr.employees VALUES 
        ( 174
        , 'Ellen'
        , 'Abel'
        , 'EABEL'
        , '011.44.1644.429267'
        , CONVERT(DATETIME, '11-MAY-1996')
        , 'SA_REP'
        , 11000
        , .30
        , 149
        , 80
        );

INSERT INTO hr.employees VALUES 
        ( 175
        , 'Alyssa'
        , 'Hutton'
        , 'AHUTTON'
        , '011.44.1644.429266'
        , CONVERT(DATETIME, '19-MAR-1997')
        , 'SA_REP'
        , 8800
        , .25
        , 149
        , 80
        );

INSERT INTO hr.employees VALUES 
        ( 176
        , 'Jonathon'
        , 'Taylor'
        , 'JTAYLOR'
        , '011.44.1644.429265'
        , CONVERT(DATETIME, '24-MAR-1998')
        , 'SA_REP'
        , 8600
        , .20
        , 149
        , 80
        );

INSERT INTO hr.employees VALUES 
        ( 177
        , 'Jack'
        , 'Livingston'
        , 'JLIVINGS'
        , '011.44.1644.429264'
        , CONVERT(DATETIME, '23-APR-1998')
        , 'SA_REP'
        , 8400
        , .20
        , 149
        , 80
        );

INSERT INTO hr.employees VALUES 
        ( 178
        , 'Kimberely'
        , 'Grant'
        , 'KGRANT'
        , '011.44.1644.429263'
        , CONVERT(DATETIME, '24-MAY-1999')
        , 'SA_REP'
        , 7000
        , .15
        , 149
        , NULL
        );

INSERT INTO hr.employees VALUES 
        ( 179
        , 'Charles'
        , 'Johnson'
        , 'CJOHNSON'
        , '011.44.1644.429262'
        , CONVERT(DATETIME, '04-JAN-2000')
        , 'SA_REP'
        , 6200
        , .10
        , 149
        , 80
        );

INSERT INTO hr.employees VALUES 
        ( 180
        , 'Winston'
        , 'Taylor'
        , 'WTAYLOR'
        , '650.507.9876'
        , CONVERT(DATETIME, '24-JAN-1998')
        , 'SH_CLERK'
        , 3200
        , NULL
        , 120
        , 50
        );

INSERT INTO hr.employees VALUES 
        ( 181
        , 'Jean'
        , 'Fleaur'
        , 'JFLEAUR'
        , '650.507.9877'
        , CONVERT(DATETIME, '23-FEB-1998')
        , 'SH_CLERK'
        , 3100
        , NULL
        , 120
        , 50
        );

INSERT INTO hr.employees VALUES 
        ( 182
        , 'Martha'
        , 'Sullivan'
        , 'MSULLIVA'
        , '650.507.9878'
        , CONVERT(DATETIME, '21-JUN-1999')
        , 'SH_CLERK'
        , 2500
        , NULL
        , 120
        , 50
        );

INSERT INTO hr.employees VALUES 
        ( 183
        , 'Girard'
        , 'Geoni'
        , 'GGEONI'
        , '650.507.9879'
        , CONVERT(DATETIME, '03-FEB-2000')
        , 'SH_CLERK'
        , 2800
        , NULL
        , 120
        , 50
        );

INSERT INTO hr.employees VALUES 
        ( 184
        , 'Nandita'
        , 'Sarchand'
        , 'NSARCHAN'
        , '650.509.1876'
        , CONVERT(DATETIME, '27-JAN-1996')
        , 'SH_CLERK'
        , 4200
        , NULL
        , 121
        , 50
        );

INSERT INTO hr.employees VALUES 
        ( 185
        , 'Alexis'
        , 'Bull'
        , 'ABULL'
        , '650.509.2876'
        , CONVERT(DATETIME, '20-FEB-1997')
        , 'SH_CLERK'
        , 4100
        , NULL
        , 121
        , 50
        );

INSERT INTO hr.employees VALUES 
        ( 186
        , 'Julia'
        , 'Dellinger'
        , 'JDELLING'
        , '650.509.3876'
        , CONVERT(DATETIME, '24-JUN-1998')
        , 'SH_CLERK'
        , 3400
        , NULL
        , 121
        , 50
        );

INSERT INTO hr.employees VALUES 
        ( 187
        , 'Anthony'
        , 'Cabrio'
        , 'ACABRIO'
        , '650.509.4876'
        , CONVERT(DATETIME, '07-FEB-1999')
        , 'SH_CLERK'
        , 3000
        , NULL
        , 121
        , 50
        );

INSERT INTO hr.employees VALUES 
        ( 188
        , 'Kelly'
        , 'Chung'
        , 'KCHUNG'
        , '650.505.1876'
        , CONVERT(DATETIME, '14-JUN-1997')
        , 'SH_CLERK'
        , 3800
        , NULL
        , 122
        , 50
        );

INSERT INTO hr.employees VALUES 
        ( 189
        , 'Jennifer'
        , 'Dilly'
        , 'JDILLY'
        , '650.505.2876'
        , CONVERT(DATETIME, '13-AUG-1997')
        , 'SH_CLERK'
        , 3600
        , NULL
        , 122
        , 50
        );

INSERT INTO hr.employees VALUES 
        ( 190
        , 'Timothy'
        , 'Gates'
        , 'TGATES'
        , '650.505.3876'
        , CONVERT(DATETIME, '11-JUL-1998')
        , 'SH_CLERK'
        , 2900
        , NULL
        , 122
        , 50
        );

INSERT INTO hr.employees VALUES 
        ( 191
        , 'Randall'
        , 'Perkins'
        , 'RPERKINS'
        , '650.505.4876'
        , CONVERT(DATETIME, '19-DEC-1999')
        , 'SH_CLERK'
        , 2500
        , NULL
        , 122
        , 50
        );

INSERT INTO hr.employees VALUES 
        ( 192
        , 'Sarah'
        , 'Bell'
        , 'SBELL'
        , '650.501.1876'
        , CONVERT(DATETIME, '04-FEB-1996')
        , 'SH_CLERK'
        , 4000
        , NULL
        , 123
        , 50
        );

INSERT INTO hr.employees VALUES 
        ( 193
        , 'Britney'
        , 'Everett'
        , 'BEVERETT'
        , '650.501.2876'
        , CONVERT(DATETIME, '03-MAR-1997')
        , 'SH_CLERK'
        , 3900
        , NULL
        , 123
        , 50
        );

INSERT INTO hr.employees VALUES 
        ( 194
        , 'Samuel'
        , 'McCain'
        , 'SMCCAIN'
        , '650.501.3876'
        , CONVERT(DATETIME, '01-JUL-1998')
        , 'SH_CLERK'
        , 3200
        , NULL
        , 123
        , 50
        );

INSERT INTO hr.employees VALUES 
        ( 195
        , 'Vance'
        , 'Jones'
        , 'VJONES'
        , '650.501.4876'
        , CONVERT(DATETIME, '17-MAR-1999')
        , 'SH_CLERK'
        , 2800
        , NULL
        , 123
        , 50
        );

INSERT INTO hr.employees VALUES 
        ( 196
        , 'Alana'
        , 'Walsh'
        , 'AWALSH'
        , '650.507.9811'
        , CONVERT(DATETIME, '24-APR-1998')
        , 'SH_CLERK'
        , 3100
        , NULL
        , 124
        , 50
        );

INSERT INTO hr.employees VALUES 
        ( 197
        , 'Kevin'
        , 'Feeney'
        , 'KFEENEY'
        , '650.507.9822'
        , CONVERT(DATETIME, '23-MAY-1998')
        , 'SH_CLERK'
        , 3000
        , NULL
        , 124
        , 50
        );

INSERT INTO hr.employees VALUES 
        ( 198
        , 'Donald'
        , 'OConnell'
        , 'DOCONNEL'
        , '650.507.9833'
        , CONVERT(DATETIME, '21-JUN-1999')
        , 'SH_CLERK'
        , 2600
        , NULL
        , 124
        , 50
        );

INSERT INTO hr.employees VALUES 
        ( 199
        , 'Douglas'
        , 'Grant'
        , 'DGRANT'
        , '650.507.9844'
        , CONVERT(DATETIME, '13-JAN-2000')
        , 'SH_CLERK'
        , 2600
        , NULL
        , 124
        , 50
        );

INSERT INTO hr.employees VALUES 
        ( 200
        , 'Jennifer'
        , 'Whalen'
        , 'JWHALEN'
        , '515.123.4444'
        , CONVERT(DATETIME, '17-SEP-1987')
        , 'AD_ASST'
        , 4400
        , NULL
        , 101
        , 10
        );

INSERT INTO hr.employees VALUES 
        ( 201
        , 'Michael'
        , 'Hartstein'
        , 'MHARTSTE'
        , '515.123.5555'
        , CONVERT(DATETIME, '17-FEB-1996')
        , 'MK_MAN'
        , 13000
        , NULL
        , 100
        , 20
        );

INSERT INTO hr.employees VALUES 
        ( 202
        , 'Pat'
        , 'Fay'
        , 'PFAY'
        , '603.123.6666'
        , CONVERT(DATETIME, '17-AUG-1997')
        , 'MK_REP'
        , 6000
        , NULL
        , 201
        , 20
        );

INSERT INTO hr.employees VALUES 
        ( 203
        , 'Susan'
        , 'Mavris'
        , 'SMAVRIS'
        , '515.123.7777'
        , CONVERT(DATETIME, '07-JUN-1994')
        , 'HR_REP'
        , 6500
        , NULL
        , 101
        , 40
        );

INSERT INTO hr.employees VALUES 
        ( 204
        , 'Hermann'
        , 'Baer'
        , 'HBAER'
        , '515.123.8888'
        , CONVERT(DATETIME, '07-JUN-1994')
        , 'PR_REP'
        , 10000
        , NULL
        , 101
        , 70
        );

INSERT INTO hr.employees VALUES 
        ( 205
        , 'Shelley'
        , 'Higgins'
        , 'SHIGGINS'
        , '515.123.8080'
        , CONVERT(DATETIME, '07-JUN-1994')
        , 'AC_MGR'
        , 12000
        , NULL
        , 101
        , 110
        );

INSERT INTO hr.employees VALUES 
        ( 206
        , 'William'
        , 'Gietz'
        , 'WGIETZ'
        , '515.123.8181'
        , CONVERT(DATETIME, '07-JUN-1994')
        , 'AC_ACCOUNT'
        , 8300
        , NULL
        , 205
        , 110
        );

----------------------------------------------------------------------------------
INSERT INTO hr.job_history
VALUES (102
       , CONVERT(DATETIME, '13-JAN-1993')
       , CONVERT(DATETIME, '24-JUL-1998')
       , 'IT_PROG'
       , 60);

INSERT INTO hr.job_history
VALUES (101
       , CONVERT(DATETIME, '21-SEP-1989')
       , CONVERT(DATETIME, '27-OCT-1993')
       , 'AC_ACCOUNT'
       , 110);

INSERT INTO hr.job_history
VALUES (101
       , CONVERT(DATETIME, '28-OCT-1993')
       , CONVERT(DATETIME, '15-MAR-1997')
       , 'AC_MGR'
       , 110);

INSERT INTO hr.job_history
VALUES (201
       , CONVERT(DATETIME, '17-FEB-1996')
       , CONVERT(DATETIME, '19-DEC-1999')
       , 'MK_REP'
       , 20);

INSERT INTO hr.job_history
VALUES  (114
        , CONVERT(DATETIME, '24-MAR-1998')
        , CONVERT(DATETIME, '31-DEC-1999')
        , 'ST_CLERK'
        , 50
        );

INSERT INTO hr.job_history
VALUES  (122
        , CONVERT(DATETIME, '01-JAN-1999')
        , CONVERT(DATETIME, '31-DEC-1999')
        , 'ST_CLERK'
        , 50
        );

INSERT INTO hr.job_history
VALUES  (200
        , CONVERT(DATETIME, '17-SEP-1987')
        , CONVERT(DATETIME, '17-JUN-1993')
        , 'AD_ASST'
        , 90
        );

INSERT INTO hr.job_history
VALUES  (176
        , CONVERT(DATETIME, '24-MAR-1998')
        , CONVERT(DATETIME, '31-DEC-1998')
        , 'SA_REP'
        , 80
        );

INSERT INTO hr.job_history
VALUES  (176
        , CONVERT(DATETIME, '01-JAN-1999')
        , CONVERT(DATETIME, '31-DEC-1999')
        , 'SA_MAN'
        , 80
        );

INSERT INTO hr.job_history
VALUES  (200
        , CONVERT(DATETIME, '01-JUL-1994')
        , CONVERT(DATETIME, '31-DEC-1998')
        , 'AC_ACCOUNT'
        , 90
        );

----------------------------------------------------------------------------------
