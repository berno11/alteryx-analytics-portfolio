# Alteryx Conversion Guide 02
## SQL Stored Procedure → Alteryx Workflow: Parameterized KPI Report

**Source SP:** `sp_department_kpi_report`  
**Alteryx Output:** Dynamic KPI report with parameter-driven filtering  
**Resume Context:** "Strong ability to convert SQL Server views and stored procedures into Alteryx workflows"

---

## The Challenge with Stored Procedures

Stored procedures are harder to convert than views because they:
- Accept **input parameters** (department, date range, status filter)
- Contain **business logic** (window functions, ranking, RAG)
- Are often called by multiple downstream systems

Alteryx handles this through a combination of **App Interface tools** (for parameters) and **Formula/Filter tools** (for logic).

---

## Two Conversion Approaches

### Approach A — Run the SP Directly from Alteryx (Quick)
Call the stored procedure from Alteryx using a SQL query input:

```
Input Data Tool → Pre-SQL Statement:
EXEC dbo.sp_department_kpi_report
    @Department   = '[Department]',
    @StartDate    = '[StartDate]',
    @EndDate      = '[EndDate]',
    @StatusFilter = '[StatusFilter]'
```

**Best for:** When you want to keep the SP logic in SQL Server and just automate the output routing.

---

### Approach B — Full Rebuild in Alteryx (Recommended)
Recreate all SP logic in Alteryx tools — more portable, no SQL Server dependency.

```
[Text Input / Interface Tool (parameters)]
         ↓
[Input Data — reporting_metrics table]
         ↓
[Filter — date range: BETWEEN @StartDate AND @EndDate]
         ↓
[Filter — department: IF @Department provided]
         ↓
[Filter — status: IF @StatusFilter provided]
         ↓
[Multi-Row Formula — Rolling 3-period average]
         ↓
[Rank Tool — rank within department by achievement]
         ↓
[Formula — RAG_Status CASE logic]
         ↓
[Output — Tableau / Excel / SQL Server]
```

---

## Converting Window Functions to Alteryx

The SP uses this SQL window function:
```sql
AVG(rm.ACHIEVEMENT_PCT) OVER (
    PARTITION BY rm.DEPARTMENT
    ORDER BY rm.REPORT_DATE
    ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
) AS Rolling_3_Avg_Achievement
```

**Alteryx Equivalent — Multi-Row Formula Tool:**
```
Group By Field: DEPARTMENT
Sort By:        REPORT_DATE (Ascending)

New Field: Rolling_3_Avg_Achievement (Double)

Expression:
(IFNULL([Row-2:ACHIEVEMENT_PCT], [ACHIEVEMENT_PCT]) +
 IFNULL([Row-1:ACHIEVEMENT_PCT], [ACHIEVEMENT_PCT]) +
 [ACHIEVEMENT_PCT]) / 3
```

---

## Converting RANK() to Alteryx

SQL:
```sql
RANK() OVER (
    PARTITION BY rm.DEPARTMENT
    ORDER BY rm.ACHIEVEMENT_PCT DESC
) AS Dept_Rank
```

**Alteryx Equivalent — Rank Tool:**
```
Group By:   DEPARTMENT
Order By:   ACHIEVEMENT_PCT (Descending)
Rank Type:  Standard (matches SQL RANK())
Output Field: Dept_Rank
```

---

## Converting Parameters to Alteryx Interface

For Alteryx Analytic Apps (interactive parameter inputs):

```
Interface Tool: Drop Down (Department)
    Values: Risk, Compliance, Operations, Finance, Technology, Audit, All
    Action: Update Value in Filter Tool expression

Interface Tool: Date (Start Date)
    Action: Update Value in Filter Tool expression

Interface Tool: Date (End Date)  
    Action: Update Value in Filter Tool expression

Interface Tool: Drop Down (Status Filter)
    Values: On Track, At Risk, Off Track, Exceeded, All
    Action: Update Value in Filter Tool expression
```

---

## Tool Count Comparison

| SQL Stored Procedure | Alteryx Equivalent |
|---------------------|--------------------|
| @Department parameter | Drop Down Interface Tool |
| @StartDate / @EndDate | Date Interface Tools |
| WHERE clause filtering | Filter Tools (x3) |
| Window function (AVG OVER) | Multi-Row Formula Tool |
| RANK() OVER | Rank Tool |
| CASE (RAG Status) | Formula Tool |
| ORDER BY | Sort Tool |
| Result output | Output Data Tool |

**Total Alteryx Tools:** ~12  
**Benefit:** Non-technical stakeholders can run parameterized reports without SQL access

---

## Interview Talking Point

> "When converting stored procedures to Alteryx, I always start by mapping each SQL clause to its Alteryx equivalent. The trickiest parts are window functions and parameters — window functions become Multi-Row Formula tools, and parameters become Interface tools that turn the workflow into a self-service Analytic App. This directly reduces the dependency on the DBA team for every report variation a stakeholder requests."

