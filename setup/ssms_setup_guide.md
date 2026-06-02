# SSMS Setup Guide
## How to Load the Practice Datasets into SQL Server

**Author:** Bernice Kidiiga | berno77@gmail.com  
**GitHub:** github.com/berno11/alteryx-analytics-portfolio

---

## ⚠️ Step 0 — Purchase the Datasets First

The CSV files are **not included** in this GitHub repository.  
You must purchase and download them before running any setup steps.

### 👉 [Purchase Practice Datasets — $15](https://1699917831060.gumroad.com/l/kwxstv)

**What you receive after purchase:**
| File | Rows | Description |
|------|------|-------------|
| `reporting_metrics.csv` | 300 | KPI tracking by department |
| `workflow_inventory.csv` | 200 | Alteryx/BI tool inventory |
| `stakeholder_requests.csv` | 250 | Reporting request tracking |
| `25_analytics_consultant_exercises.md` | — | Full exercise guide with answers |

> All datasets include a `SOURCE` watermark column identifying
> © Bernice Kidiiga — berno77@gmail.com.
> Redistribution is strictly prohibited — see LICENSE.

---

## Step 1 — Prerequisites

Before starting, make sure you have:

- ✅ **SQL Server** installed (Express edition is free)
  Download: https://www.microsoft.com/en-us/sql-server/sql-server-downloads
- ✅ **SSMS** (SQL Server Management Studio) installed
  Download: https://aka.ms/ssmsfullsetup
- ✅ **Practice datasets** downloaded from Gumroad
- ✅ **CSV files saved** to a local folder on your PC

Recommended folder path:
```
C:\AnalyticsPortfolio\data\
    reporting_metrics.csv
    workflow_inventory.csv
    stakeholder_requests.csv
```

---

## Step 2 — Open SSMS and Connect

1. Open **SQL Server Management Studio (SSMS)**
2. In the Connect dialog:
   - **Server type:** Database Engine
   - **Server name:** `localhost` or `.\SQLEXPRESS` for Express edition
   - **Authentication:** Windows Authentication
3. Click **Connect**

---

## Step 3 — Run the Setup Script

1. Click **File** → **Open** → **File**
2. Navigate to `setup/sql_server_setup.sql` in this repo
3. Click **Open**
4. **Update the file paths** in Section 3 to match where your CSVs are saved:

```sql
-- Change this:
FROM 'C:\AnalyticsPortfolio\data\reporting_metrics.csv'

-- To match your actual path, e.g.:
FROM 'C:\Users\bkidi\Downloads\reporting_metrics.csv'
```

5. Press **F5** or click **Execute** to run the entire script
6. Check the Messages tab for confirmation:

```
Database AnalyticsPortfolio created successfully.
Table dbo.reporting_metrics created.
Table dbo.workflow_inventory created.
Table dbo.stakeholder_requests created.
reporting_metrics imported: 300 rows.
workflow_inventory imported: 200 rows.
stakeholder_requests imported: 250 rows.
Setup Complete! AnalyticsPortfolio is ready.
```

---

## Step 4 — Verify the Import

Run this quick check to confirm all data loaded correctly:

```sql
USE AnalyticsPortfolio;

SELECT 'reporting_metrics'    AS Table_Name, COUNT(*) AS Row_Count
FROM dbo.reporting_metrics
UNION ALL
SELECT 'workflow_inventory',  COUNT(*) FROM dbo.workflow_inventory
UNION ALL
SELECT 'stakeholder_requests', COUNT(*) FROM dbo.stakeholder_requests;
```

Expected output:
| Table_Name | Row_Count |
|------------|-----------|
| reporting_metrics | 300 |
| workflow_inventory | 200 |
| stakeholder_requests | 250 |

---

## Step 5 — Create the Views

Run each view script in order:

```
sql_scripts/views/vw_department_kpi_summary.sql
sql_scripts/views/vw_workflow_health.sql
sql_scripts/views/vw_stakeholder_sla.sql
```

In SSMS: File → Open → select each .sql file → F5 to execute.

Verify views exist:
```sql
SELECT name FROM sys.views WHERE schema_id = SCHEMA_ID('dbo');
```

Expected:
```
vw_department_kpi_summary
vw_workflow_health
vw_stakeholder_sla
```

---

## Step 6 — Create the Stored Procedures

Run each stored procedure script:

```
sql_scripts/stored_procedures/sp_department_kpi_report.sql
sql_scripts/stored_procedures/sp_workflow_governance_report.sql
```

Test them immediately after:

```sql
-- Test SP 1 — all departments
EXEC dbo.sp_department_kpi_report;

-- Test SP 2 — stale workflows
EXEC dbo.sp_workflow_governance_report @DaysSinceRun = 30;
```

---

## Step 7 — Connect Alteryx to SQL Server

Once SQL Server is loaded, connect Alteryx:

1. Open **Alteryx Designer**
2. Drag **Input Data Tool** onto canvas
3. Click the connection dropdown → **New Data Source**
4. Select **Microsoft SQL Server (OLE DB)**
5. Enter connection details:

```
Server:   localhost  (or .\SQLEXPRESS for Express)
Database: AnalyticsPortfolio
Auth:     Windows Authentication
```

6. Click **Test Connection** → should show green ✅
7. Select table `dbo.reporting_metrics` → **OK**

You are now ready to run all 25 exercises!

---

## Troubleshooting

| Problem | Fix |
|---------|-----|
| BULK INSERT permission error | Use Import Wizard instead: right-click DB → Tasks → Import Data |
| Cannot connect to SQL Server | Make sure SQL Server service is running: Services → SQL Server → Start |
| File path not found | Check your CSV folder path — must match exactly including drive letter |
| Row count is 0 after import | Check FIRSTROW=2 is set (skips header) and FIELDTERMINATOR=',' |
| Alteryx connection fails | Install SQL Server ODBC Driver from Microsoft website |

---

## Full Workflow Summary

```
Purchase datasets (Gumroad)
        ↓
Save CSVs to C:\AnalyticsPortfolio\data\
        ↓
Run sql_server_setup.sql in SSMS
        ↓
Run 3 view scripts
        ↓
Run 2 stored procedure scripts
        ↓
Connect Alteryx to AnalyticsPortfolio database
        ↓
Work through 25 exercises
        ↓
Build Tableau / Power BI dashboards on top
```

---

*© 2024 Bernice Kidiiga · All Rights Reserved · See LICENSE*  
*Datasets: https://1699917831060.gumroad.com/l/kwxstv*
