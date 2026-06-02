# Alteryx Conversion Guide 01
## SQL View → Alteryx Workflow: Department KPI Summary

**Source SQL View:** `vw_department_kpi_summary`  
**Alteryx Output:** Department KPI Summary for Tableau Dashboard  
**Resume Context:** "Translate SQL Server views and stored procedures into efficient Alteryx workflows" — Data Analytics Consultant Role

---

## Why Convert This View to Alteryx?

| SQL View | Alteryx Workflow |
|----------|-----------------|
| Runs on SQL Server only | Connects to any data source |
| Requires DBA access to modify | Business analyst can maintain |
| Static scheduled refresh | On-demand or scheduled |
| No visual audit trail | Full tool-by-tool documentation |
| Hard to add Excel/CSV inputs | Easily blends multiple sources |

---

## Step-by-Step Alteryx Conversion

### ORIGINAL SQL LOGIC
```sql
SELECT
    DEPARTMENT, METRIC_TYPE,
    COUNT(*) AS Total_Metrics,
    SUM(CASE WHEN STATUS = 'On Track' THEN 1 ELSE 0 END) AS On_Track,
    ROUND(AVG(ACHIEVEMENT_PCT), 2) AS Avg_Achievement_Pct,
    CASE
        WHEN AVG(ACHIEVEMENT_PCT) >= 100 THEN 'Green'
        WHEN AVG(ACHIEVEMENT_PCT) >= 85  THEN 'Yellow'
        ELSE 'Red'
    END AS RAG_Status
FROM reporting_metrics
WHERE REPORT_DATE >= DATEADD(MONTH, -3, GETDATE())
GROUP BY DEPARTMENT, METRIC_TYPE
```

---

### ALTERYX TOOL MAPPING

```
[Input Data] → [Filter] → [Summarize] → [Formula] → [Output Data]
     ↓              ↓           ↓              ↓            ↓
  Connect to    Date filter   GROUP BY    RAG Status    Tableau /
  SQL Server    last 90 days  + COUNT     CASE logic    Excel / CSV
  reporting_    equivalent    + AVG
  metrics
```

---

### TOOL 1 — Input Data Tool
**Purpose:** Replaces the `FROM dbo.reporting_metrics` clause

**Configuration:**
```
Connection: SQL Server
Server:     [Your SQL Server instance]
Database:   [Your database name]
Table:      dbo.reporting_metrics

-- OR use a direct query:
SELECT * FROM dbo.reporting_metrics
WHERE REPORT_DATE >= DATEADD(MONTH, -3, GETDATE())
```

**Tip:** Use the query option to push the date filter to SQL Server — faster than pulling all rows into Alteryx first.

---

### TOOL 2 — Filter Tool
**Purpose:** Replaces the `WHERE REPORT_DATE >= DATEADD(MONTH, -3, GETDATE())` clause

**Configuration:**
```
Expression: DateTimeDiff(DateTimeNow(), [REPORT_DATE], "days") <= 90
```

If you used a query in Tool 1 to filter, skip this tool.

---

### TOOL 3 — Summarize Tool
**Purpose:** Replaces `GROUP BY DEPARTMENT, METRIC_TYPE` with all aggregate columns

**Configuration:**
```
Group By:   DEPARTMENT
Group By:   METRIC_TYPE

Count:      METRIC_ID  → rename to Total_Metrics

Sum (with condition — use a prior Formula tool):
  On_Track_Flag  → rename to On_Track
  At_Risk_Flag   → rename to At_Risk
  Off_Track_Flag → rename to Off_Track
  Exceeded_Flag  → rename to Exceeded

Average:    ACHIEVEMENT_PCT → rename to Avg_Achievement_Pct
Average:    VARIANCE        → rename to Avg_Variance
Max:        REPORT_DATE     → rename to Latest_Report_Date
```

**Pre-Summarize Formula Tool (for CASE flags):**
```
On_Track_Flag:  IF [STATUS] == "On Track" THEN 1 ELSE 0 ENDIF
At_Risk_Flag:   IF [STATUS] == "At Risk"  THEN 1 ELSE 0 ENDIF
Off_Track_Flag: IF [STATUS] == "Off Track" THEN 1 ELSE 0 ENDIF
Exceeded_Flag:  IF [STATUS] == "Exceeded"  THEN 1 ELSE 0 ENDIF
```

---

### TOOL 4 — Formula Tool
**Purpose:** Replaces the `CASE WHEN AVG(ACHIEVEMENT_PCT)...` RAG status logic

**Configuration:**
```
New Field: RAG_Status  (String, size 10)

Expression:
IF [Avg_Achievement_Pct] >= 100 THEN "Green"
ELSEIF [Avg_Achievement_Pct] >= 85 THEN "Yellow"
ELSE "Red"
ENDIF
```

---

### TOOL 5 — Output Data Tool
**Purpose:** Sends results to downstream reporting

**Options:**
```
Option A — Tableau: Use Tableau Output tool → publish to Tableau Server
Option B — Excel:   Output to .xlsx for stakeholder distribution  
Option C — SQL:     Write back to SQL Server staging table
Option D — CSV:     Flat file for email distribution
```

---

## Complete Workflow Summary

```
Input Data (SQL Server)
    ↓
Formula Tool (create flag columns for CASE logic)
    ↓
Filter Tool (last 90 days — if not pushed to SQL)
    ↓
Summarize Tool (GROUP BY DEPARTMENT, METRIC_TYPE + all aggregates)
    ↓
Formula Tool (RAG_Status CASE logic)
    ↓
Select Tool (reorder/rename columns for clean output)
    ↓
Output Data (Tableau / Excel / SQL Server)
```

**Tool Count:** 6 tools  
**Estimated Build Time:** 20–30 minutes  
**Maintenance Level:** Low — stakeholders can update date ranges without SQL access

---

## Interview Talking Point

> "In this project I converted a SQL Server view that required DBA involvement every time the date range or department filter changed. By rebuilding it in Alteryx, I gave the business team full control — they could run it on demand, swap in an Excel file if the SQL connection was down, and the output went directly to Tableau without manual steps. That's the kind of efficiency gain that directly supports the role's requirement to reduce manual processing."

