/*=============================================================================
  SQL SERVER SETUP SCRIPT
  Project  : Analytics Consultant Portfolio
  Author   : Bernice Kidiiga | berno77@gmail.com
  GitHub   : github.com/berno11/alteryx-analytics-portfolio

  PURPOSE:
  This script sets up the AnalyticsPortfolio database and all three tables
  required to run the SQL views, stored procedures, and Alteryx exercises
  in this repository.

  PRE-REQUISITE:
  You must first purchase and download the practice datasets from:
  https://1699917831060.gumroad.com/l/kwxstv

  The dataset package contains:
    - reporting_metrics.csv       (300 rows)
    - workflow_inventory.csv      (200 rows)
    - stakeholder_requests.csv    (250 rows)

  STEPS:
  1. Purchase and download datasets from Gumroad link above
  2. Save CSV files to a folder e.g. C:\AnalyticsPortfolio\data\
  3. Open SSMS and connect to your SQL Server instance
  4. Run SECTION 1 — creates the database
  5. Run SECTION 2 — creates all three tables
  6. Run SECTION 3 — imports CSV data into tables
  7. Run SECTION 4 — verifies the import
  8. Then run the view and stored procedure scripts in sql_scripts/ folder

  TESTED ON: SQL Server 2019, SQL Server 2022, SQL Server Express
=============================================================================*/


/*=============================================================================
  SECTION 1 — CREATE DATABASE
=============================================================================*/

-- Create the database (skip if already exists)
IF NOT EXISTS (
    SELECT name FROM sys.databases WHERE name = 'AnalyticsPortfolio'
)
BEGIN
    CREATE DATABASE AnalyticsPortfolio;
    PRINT 'Database AnalyticsPortfolio created successfully.';
END
ELSE
    PRINT 'Database AnalyticsPortfolio already exists — skipping creation.';
GO

-- Switch to the new database
USE AnalyticsPortfolio;
GO


/*=============================================================================
  SECTION 2 — CREATE TABLES
=============================================================================*/

-- ── TABLE 1: reporting_metrics ───────────────────────────────────────────────
IF OBJECT_ID('dbo.reporting_metrics', 'U') IS NOT NULL
    DROP TABLE dbo.reporting_metrics;
GO

CREATE TABLE dbo.reporting_metrics (
    METRIC_ID        VARCHAR(6)      NOT NULL,
    DEPARTMENT       VARCHAR(50)     NOT NULL,
    METRIC_TYPE      VARCHAR(50)     NOT NULL,
    METRIC_NAME      VARCHAR(100)    NOT NULL,
    TARGET_VALUE     DECIMAL(10,2)   NOT NULL,
    ACTUAL_VALUE     DECIMAL(10,2)   NOT NULL,
    ACHIEVEMENT_PCT  DECIMAL(10,2)   NOT NULL,
    STATUS           VARCHAR(20)     NOT NULL,
    REPORT_DATE      DATE            NOT NULL,
    OWNER            VARCHAR(50)     NOT NULL,
    FREQUENCY        VARCHAR(20)     NOT NULL,
    VARIANCE         DECIMAL(10,2)   NOT NULL,
    SOURCE           VARCHAR(100)    NULL,

    CONSTRAINT PK_reporting_metrics PRIMARY KEY (METRIC_ID)
);
PRINT 'Table dbo.reporting_metrics created.';
GO


-- ── TABLE 2: workflow_inventory ──────────────────────────────────────────────
IF OBJECT_ID('dbo.workflow_inventory', 'U') IS NOT NULL
    DROP TABLE dbo.workflow_inventory;
GO

CREATE TABLE dbo.workflow_inventory (
    WORKFLOW_ID          VARCHAR(6)      NOT NULL,
    WORKFLOW_NAME        VARCHAR(100)    NOT NULL,
    TOOL                 VARCHAR(50)     NOT NULL,
    DEPARTMENT           VARCHAR(50)     NOT NULL,
    COMPLEXITY           VARCHAR(20)     NOT NULL,
    STATUS               VARCHAR(30)     NOT NULL,
    CREATED_DATE         DATE            NOT NULL,
    LAST_RUN_DATE        DATE            NOT NULL,
    OWNER                VARCHAR(50)     NOT NULL,
    PRIMARY_DATA_SOURCE  VARCHAR(50)     NOT NULL,
    TOTAL_RUNS           INT             NOT NULL,
    AVG_RUNTIME_MINS     DECIMAL(10,1)   NOT NULL,
    AUTOMATED            VARCHAR(3)      NOT NULL,
    ERROR_COUNT          INT             NOT NULL,
    SOURCE               VARCHAR(100)    NULL,

    CONSTRAINT PK_workflow_inventory PRIMARY KEY (WORKFLOW_ID)
);
PRINT 'Table dbo.workflow_inventory created.';
GO


-- ── TABLE 3: stakeholder_requests ────────────────────────────────────────────
IF OBJECT_ID('dbo.stakeholder_requests', 'U') IS NOT NULL
    DROP TABLE dbo.stakeholder_requests;
GO

CREATE TABLE dbo.stakeholder_requests (
    REQUEST_ID        VARCHAR(7)      NOT NULL,
    DEPARTMENT        VARCHAR(50)     NOT NULL,
    STAKEHOLDER       VARCHAR(50)     NOT NULL,
    REQUEST_TYPE      VARCHAR(50)     NOT NULL,
    PRIORITY          VARCHAR(20)     NOT NULL,
    STATUS            VARCHAR(20)     NOT NULL,
    SUBMIT_DATE       DATE            NOT NULL,
    DUE_DATE          DATE            NOT NULL,
    COMPLETION_DATE   DATE            NULL,
    ASSIGNED_ANALYST  VARCHAR(50)     NOT NULL,
    TOOL_REQUIRED     VARCHAR(50)     NOT NULL,
    ESTIMATED_HOURS   INT             NOT NULL,
    ACTUAL_HOURS      INT             NOT NULL,
    RECURRING_FLAG    VARCHAR(3)      NOT NULL,
    SOURCE            VARCHAR(100)    NULL,

    CONSTRAINT PK_stakeholder_requests PRIMARY KEY (REQUEST_ID)
);
PRINT 'Table dbo.stakeholder_requests created.';
GO


/*=============================================================================
  SECTION 3 — IMPORT CSV DATA
  
  ⚠️  IMPORTANT: Update the file paths below to match where you saved
      your CSV files. Example: 'C:\AnalyticsPortfolio\data\reporting_metrics.csv'
      
  ⚠️  BULK INSERT requires the CSV files to be accessible by the SQL Server
      service account. Save files to a local drive on the SQL Server machine.
      
  ⚠️  If BULK INSERT is blocked by your DBA, use the Import Wizard instead:
      Right-click database → Tasks → Import Data → Flat File Source
=============================================================================*/

-- ── IMPORT reporting_metrics ─────────────────────────────────────────────────
BULK INSERT dbo.reporting_metrics
FROM 'C:\AnalyticsPortfolio\data\reporting_metrics.csv'
WITH (
    FORMAT          = 'CSV',
    FIRSTROW        = 2,           -- Skip header row
    FIELDTERMINATOR = ',',
    ROWTERMINATOR   = '\n',
    TABLOCK
);
PRINT 'reporting_metrics imported: ' +
      CAST((SELECT COUNT(*) FROM dbo.reporting_metrics) AS VARCHAR) + ' rows.';
GO


-- ── IMPORT workflow_inventory ─────────────────────────────────────────────────
BULK INSERT dbo.workflow_inventory
FROM 'C:\AnalyticsPortfolio\data\workflow_inventory.csv'
WITH (
    FORMAT          = 'CSV',
    FIRSTROW        = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR   = '\n',
    TABLOCK
);
PRINT 'workflow_inventory imported: ' +
      CAST((SELECT COUNT(*) FROM dbo.workflow_inventory) AS VARCHAR) + ' rows.';
GO


-- ── IMPORT stakeholder_requests ───────────────────────────────────────────────
BULK INSERT dbo.stakeholder_requests
FROM 'C:\AnalyticsPortfolio\data\stakeholder_requests.csv'
WITH (
    FORMAT          = 'CSV',
    FIRSTROW        = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR   = '\n',
    TABLOCK
);
PRINT 'stakeholder_requests imported: ' +
      CAST((SELECT COUNT(*) FROM dbo.stakeholder_requests) AS VARCHAR) + ' rows.';
GO


/*=============================================================================
  SECTION 4 — VERIFY IMPORT
=============================================================================*/

SELECT 'reporting_metrics'    AS Table_Name,
       COUNT(*)               AS Row_Count
FROM dbo.reporting_metrics

UNION ALL

SELECT 'workflow_inventory',  COUNT(*)
FROM dbo.workflow_inventory

UNION ALL

SELECT 'stakeholder_requests', COUNT(*)
FROM dbo.stakeholder_requests;

/*
  Expected output:
  Table_Name               Row_Count
  reporting_metrics        300
  workflow_inventory       200
  stakeholder_requests     250
*/
GO


/*=============================================================================
  SECTION 5 — QUICK DATA PREVIEW
=============================================================================*/

-- Preview each table (first 5 rows)
SELECT TOP 5 * FROM dbo.reporting_metrics;
SELECT TOP 5 * FROM dbo.workflow_inventory;
SELECT TOP 5 * FROM dbo.stakeholder_requests;
GO


/*=============================================================================
  SECTION 6 — NEXT STEPS
  
  Once data is loaded, run the following scripts in order:
  
  1. sql_scripts/views/vw_department_kpi_summary.sql
  2. sql_scripts/views/vw_workflow_health.sql
  3. sql_scripts/views/vw_stakeholder_sla.sql
  4. sql_scripts/stored_procedures/sp_department_kpi_report.sql
  5. sql_scripts/stored_procedures/sp_workflow_governance_report.sql
  
  Then open exercises/25_analytics_consultant_exercises.md and begin
  working through the exercises in SSMS.
  
  For Alteryx exercises, connect Alteryx to this SQL Server instance:
  Server:   [your server name]
  Database: AnalyticsPortfolio
  Auth:     Windows Authentication (recommended)
=============================================================================*/

PRINT '
================================================
  Setup Complete! AnalyticsPortfolio is ready.
  
  Next: Run the view and stored procedure scripts
  in the sql_scripts/ folder.
================================================
';
GO
