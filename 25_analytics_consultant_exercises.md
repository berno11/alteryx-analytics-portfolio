# Analytics Consultant — 25 Practice Exercises
### Alteryx · SQL Server · Tableau · Power BI
#### Bernice Kidiiga | Data Analytics Consultant | Charlotte, NC

---

## DATASETS USED
- `reporting_metrics.csv` — 300 rows | KPI tracking by department
- `workflow_inventory.csv` — 200 rows | Alteryx/BI tool inventory
- `stakeholder_requests.csv` — 250 rows | Reporting request tracking

---

## SQL SERVER EXERCISES (1–10)

### EXERCISE 01 — Basic SELECT with Date Filter
**Role relevance:** Extracting metrics for stakeholder reporting
**Question:** Pull all Risk department metrics that are At Risk or Off Track in the last 90 days.
```sql
SELECT METRIC_ID, METRIC_NAME, METRIC_TYPE, TARGET_VALUE,
       ACTUAL_VALUE, ACHIEVEMENT_PCT, STATUS, REPORT_DATE, OWNER
FROM dbo.reporting_metrics
WHERE DEPARTMENT = 'Risk'
  AND STATUS IN ('At Risk', 'Off Track')
  AND REPORT_DATE >= DATEADD(DAY, -90, GETDATE())
ORDER BY ACHIEVEMENT_PCT ASC;
```
**Output:** At-risk metrics for the Risk department — first input for an executive dashboard.

---

### EXERCISE 02 — GROUP BY with CASE Aggregation
**Role relevance:** Building summary data for Tableau/Power BI dashboards
**Question:** Count metrics by department and RAG status with achievement averages.
```sql
SELECT
    DEPARTMENT,
    COUNT(*) AS Total_Metrics,
    SUM(CASE WHEN STATUS = 'On Track'  THEN 1 ELSE 0 END) AS On_Track,
    SUM(CASE WHEN STATUS = 'At Risk'   THEN 1 ELSE 0 END) AS At_Risk,
    SUM(CASE WHEN STATUS = 'Off Track' THEN 1 ELSE 0 END) AS Off_Track,
    ROUND(AVG(ACHIEVEMENT_PCT), 2) AS Avg_Achievement,
    CASE
        WHEN AVG(ACHIEVEMENT_PCT) >= 100 THEN 'Green'
        WHEN AVG(ACHIEVEMENT_PCT) >= 85  THEN 'Yellow'
        ELSE 'Red'
    END AS RAG_Status
FROM dbo.reporting_metrics
GROUP BY DEPARTMENT
ORDER BY Avg_Achievement DESC;
```
**Output:** Department KPI scorecard — direct feed for Tableau dashboard.

---

### EXERCISE 03 — Window Functions (RANK + ROW_NUMBER)
**Role relevance:** Ranking metrics for executive reporting
**Question:** Rank each metric within its department by achievement percentage.
```sql
SELECT
    METRIC_ID, DEPARTMENT, METRIC_NAME, ACHIEVEMENT_PCT,
    RANK() OVER (
        PARTITION BY DEPARTMENT
        ORDER BY ACHIEVEMENT_PCT DESC
    ) AS Dept_Rank,
    ROW_NUMBER() OVER (
        PARTITION BY DEPARTMENT
        ORDER BY ACHIEVEMENT_PCT DESC
    ) AS Row_Num,
    NTILE(4) OVER (
        PARTITION BY DEPARTMENT
        ORDER BY ACHIEVEMENT_PCT DESC
    ) AS Quartile
FROM dbo.reporting_metrics
ORDER BY DEPARTMENT, Dept_Rank;
```
**Output:** Ranked metric list per department — used in performance league tables.

---

### EXERCISE 04 — Rolling Average (Window Function)
**Role relevance:** Trend analysis for stakeholder presentations
**Question:** Calculate a 3-period rolling average achievement by department over time.
```sql
SELECT
    DEPARTMENT,
    REPORT_DATE,
    ACHIEVEMENT_PCT,
    ROUND(AVG(ACHIEVEMENT_PCT) OVER (
        PARTITION BY DEPARTMENT
        ORDER BY REPORT_DATE
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ), 2) AS Rolling_3_Avg,
    ROUND(ACHIEVEMENT_PCT - AVG(ACHIEVEMENT_PCT) OVER (
        PARTITION BY DEPARTMENT
        ORDER BY REPORT_DATE
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ), 2) AS Variance_From_Rolling_Avg
FROM dbo.reporting_metrics
ORDER BY DEPARTMENT, REPORT_DATE;
```
**Output:** Trend data for line charts — key visual for executive reporting sessions.

---

### EXERCISE 05 — SLA Breach Detection (DATEDIFF)
**Role relevance:** SLA compliance reporting for operations
**Question:** Identify stakeholder requests that breached their SLA deadline.
```sql
SELECT
    REQUEST_ID, DEPARTMENT, STAKEHOLDER, REQUEST_TYPE,
    PRIORITY, SUBMIT_DATE, DUE_DATE, COMPLETION_DATE,
    DATEDIFF(DAY, DUE_DATE,
        ISNULL(COMPLETION_DATE, GETDATE())) AS Days_Overdue,
    CASE
        WHEN COMPLETION_DATE > DUE_DATE                    THEN 'Breached — Completed Late'
        WHEN COMPLETION_DATE IS NULL AND GETDATE() > DUE_DATE THEN 'Breached — Still Open'
        WHEN COMPLETION_DATE <= DUE_DATE                   THEN 'Met'
        ELSE 'In Progress'
    END AS SLA_Status
FROM dbo.stakeholder_requests
WHERE PRIORITY IN ('High', 'Critical')
ORDER BY Days_Overdue DESC;
```
**Output:** SLA compliance report for operations review — presented in stakeholder meetings.

---

### EXERCISE 06 — Stored Procedure Execution
**Role relevance:** Running parameterized reports for different stakeholders
**Question:** Execute the KPI report stored procedure for the Compliance department.
```sql
-- Basic execution — all Compliance metrics current quarter
EXEC dbo.sp_department_kpi_report
    @Department = 'Compliance';

-- Filtered execution — At Risk only, specific date range
EXEC dbo.sp_department_kpi_report
    @Department   = 'Compliance',
    @StartDate    = '2024-01-01',
    @EndDate      = '2024-06-30',
    @StatusFilter = 'At Risk';
```
**Output:** Parameterized report output — same SP, different parameters for each stakeholder.

---

### EXERCISE 07 — Creating a SQL View
**Role relevance:** Building reusable data objects for reporting layers
**Question:** Create a view that shows workflow health status with automation opportunity flags.
```sql
CREATE OR ALTER VIEW dbo.vw_automation_candidates AS
SELECT
    WORKFLOW_ID, WORKFLOW_NAME, TOOL, DEPARTMENT,
    COMPLEXITY, TOTAL_RUNS, AVG_RUNTIME_MINS, ERROR_COUNT, AUTOMATED,
    TOTAL_RUNS * AVG_RUNTIME_MINS / 60             AS Total_Hours_Spent,
    CASE
        WHEN AUTOMATED = 'No' AND COMPLEXITY IN ('High','Very High')
        THEN 'High Priority Automation Candidate'
        WHEN AUTOMATED = 'No' AND TOTAL_RUNS > 100
        THEN 'Medium Priority — High Volume'
        WHEN AUTOMATED = 'No'
        THEN 'Low Priority'
        ELSE 'Already Automated'
    END AS Automation_Priority
FROM dbo.workflow_inventory
WHERE STATUS = 'Active';
GO
```
**Output:** Automation opportunity register — input for continuous improvement initiatives.

---

### EXERCISE 08 — JOIN + Aggregation
**Role relevance:** Connecting workflow data with request data for governance reporting
**Question:** Match workflow tool usage to stakeholder request tool requirements and find gaps.
```sql
SELECT
    sr.TOOL_REQUIRED,
    COUNT(sr.REQUEST_ID)                           AS Total_Requests,
    COUNT(wi.WORKFLOW_ID)                          AS Available_Workflows,
    COUNT(sr.REQUEST_ID) - COUNT(wi.WORKFLOW_ID)   AS Gap,
    ROUND(AVG(sr.ACTUAL_HOURS), 1)                AS Avg_Hours_Per_Request
FROM dbo.stakeholder_requests sr
LEFT JOIN dbo.workflow_inventory wi
    ON sr.TOOL_REQUIRED = wi.TOOL
   AND wi.STATUS = 'Active'
GROUP BY sr.TOOL_REQUIRED
ORDER BY Total_Requests DESC;
```
**Output:** Tool capacity vs demand gap analysis — used in resource planning meetings.

---

### EXERCISE 09 — CTE + Recursive Logic
**Role relevance:** Complex multi-step reporting logic
**Question:** Use a CTE to find departments with above-average SLA breach rates.
```sql
WITH SLA_Summary AS (
    SELECT
        DEPARTMENT,
        COUNT(*) AS Total_Requests,
        SUM(CASE
            WHEN COMPLETION_DATE > DUE_DATE THEN 1
            WHEN COMPLETION_DATE IS NULL AND GETDATE() > DUE_DATE THEN 1
            ELSE 0
        END) AS Breached_Count,
        ROUND(SUM(CASE
            WHEN COMPLETION_DATE > DUE_DATE THEN 1.0
            WHEN COMPLETION_DATE IS NULL AND GETDATE() > DUE_DATE THEN 1.0
            ELSE 0
        END) / COUNT(*) * 100, 2) AS Breach_Rate_Pct
    FROM dbo.stakeholder_requests
    GROUP BY DEPARTMENT
)
SELECT s.DEPARTMENT, s.Total_Requests, s.Breached_Count, s.Breach_Rate_Pct
FROM SLA_Summary s
WHERE s.Breach_Rate_Pct > (SELECT AVG(Breach_Rate_Pct) FROM SLA_Summary)
ORDER BY s.Breach_Rate_Pct DESC;
```
**Output:** Departments needing SLA improvement — input for process improvement initiatives.

---

### EXERCISE 10 — Dynamic SQL for Parameterized Reports
**Role relevance:** Building flexible reporting stored procedures
**Question:** Build a dynamic SQL report that accepts any column as a grouping dimension.
```sql
CREATE OR ALTER PROCEDURE dbo.sp_dynamic_metric_summary
    @GroupByColumn NVARCHAR(50) = 'DEPARTMENT'
AS
BEGIN
    DECLARE @SQL NVARCHAR(MAX);
    SET @SQL = N'
    SELECT
        ' + QUOTENAME(@GroupByColumn) + ' AS Group_Dimension,
        COUNT(*) AS Total_Metrics,
        ROUND(AVG(ACHIEVEMENT_PCT), 2) AS Avg_Achievement,
        SUM(CASE WHEN STATUS = ''On Track'' THEN 1 ELSE 0 END) AS On_Track_Count
    FROM dbo.reporting_metrics
    GROUP BY ' + QUOTENAME(@GroupByColumn) + '
    ORDER BY Avg_Achievement DESC';
    EXEC sp_executesql @SQL;
END;
GO
-- Usage:
EXEC dbo.sp_dynamic_metric_summary @GroupByColumn = 'METRIC_TYPE';
EXEC dbo.sp_dynamic_metric_summary @GroupByColumn = 'OWNER';
```
**Output:** Flexible pivot-style summary — adaptable to any stakeholder grouping request.

---

## ALTERYX EXERCISES (11–20)

### EXERCISE 11 — Input Data + Filter (Basic Alteryx)
**Role relevance:** Connecting to SQL Server and filtering data in Alteryx
**Alteryx Tools:** Input Data → Filter → Output Data
```
STEP 1 — Input Data Tool:
  Connection: SQL Server
  Query: SELECT * FROM dbo.reporting_metrics

STEP 2 — Filter Tool:
  Expression: [STATUS] == "At Risk" OR [STATUS] == "Off Track"

STEP 3 — Output Data Tool:
  Output: AtRisk_Metrics.xlsx
```
**Alteryx vs SQL equivalent:**
```sql
SELECT * FROM dbo.reporting_metrics
WHERE STATUS IN ('At Risk', 'Off Track')
```
**Output:** Filtered metrics file delivered to stakeholder mailbox via Alteryx email tool.

---

### EXERCISE 12 — Summarize Tool (Replaces GROUP BY)
**Role relevance:** Building aggregated datasets for Power BI/Tableau
**Alteryx Tools:** Input Data → Summarize → Output Data
```
STEP 1 — Input Data: reporting_metrics table

STEP 2 — Summarize Tool:
  Group By: DEPARTMENT
  Group By: METRIC_TYPE
  Count:    METRIC_ID    → Total_Metrics
  Average:  ACHIEVEMENT_PCT → Avg_Achievement
  Sum:      (use pre-formula flags for STATUS counts)
  Max:      REPORT_DATE  → Latest_Report

STEP 3 — Output: Tableau Extract (.hyper)
```
**Output:** Aggregated dataset ready for Tableau dashboard connection.

---

### EXERCISE 13 — Formula Tool (Replaces CASE WHEN)
**Role relevance:** Adding business logic without touching SQL Server
**Alteryx Tools:** Input Data → Formula → Output Data
```
STEP 1 — Input Data: reporting_metrics

STEP 2 — Formula Tool (add 3 new fields):

  RAG_Status (String):
  IF [ACHIEVEMENT_PCT] >= 100 THEN "Green"
  ELSEIF [ACHIEVEMENT_PCT] >= 85 THEN "Yellow"
  ELSE "Red"
  ENDIF

  Performance_Tier (String):
  IF [ACHIEVEMENT_PCT] >= 110 THEN "Exceeds Target"
  ELSEIF [ACHIEVEMENT_PCT] >= 100 THEN "Meets Target"
  ELSEIF [ACHIEVEMENT_PCT] >= 85 THEN "Near Target"
  ELSE "Below Target"
  ENDIF

  Variance_Flag (Bool):
  [VARIANCE] > 5
```
**Output:** Enriched dataset with business logic fields — feeds directly into dashboards.

---

### EXERCISE 14 — Join Tool (Replaces SQL JOIN)
**Role relevance:** Blending workflow data with request data
**Alteryx Tools:** 2x Input Data → Join → Formula → Output
```
LEFT INPUT:  workflow_inventory  (on TOOL field)
RIGHT INPUT: stakeholder_requests (on TOOL_REQUIRED field)

JOIN TYPE: Left Join (keep all workflows even if no requests)

Post-Join Formula:
  Request_Coverage:
  IF ISNULL([REQUEST_ID]) THEN "No Requests" ELSE "Has Requests" ENDIF
```
**Output:** Workflow-to-request mapping — capacity planning report.

---

### EXERCISE 15 — Multi-Row Formula (Replaces Window Functions)
**Role relevance:** Converting SQL window functions to Alteryx
**Alteryx Tools:** Input → Sort → Multi-Row Formula → Output
```
STEP 1 — Sort Tool:
  Sort By: DEPARTMENT (Ascending), REPORT_DATE (Ascending)

STEP 2 — Multi-Row Formula Tool:
  Group By: DEPARTMENT
  New Field: Rolling_3_Avg (Double)

  Expression:
  (IFNULL([Row-2:ACHIEVEMENT_PCT], [ACHIEVEMENT_PCT]) +
   IFNULL([Row-1:ACHIEVEMENT_PCT], [ACHIEVEMENT_PCT]) +
   [ACHIEVEMENT_PCT]) / 3
```
**SQL Equivalent:**
```sql
AVG(ACHIEVEMENT_PCT) OVER (
    PARTITION BY DEPARTMENT
    ORDER BY REPORT_DATE
    ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
)
```
**Output:** Rolling trend data for time-series line charts in Tableau.

---

### EXERCISE 16 — Rank Tool (Replaces RANK() OVER)
**Role relevance:** Performance ranking for executive dashboards
**Alteryx Tools:** Input → Rank → Select → Output
```
STEP 1 — Sort: DEPARTMENT (Asc), ACHIEVEMENT_PCT (Desc)

STEP 2 — Rank Tool:
  Group By Field: DEPARTMENT
  Rank Field:     ACHIEVEMENT_PCT
  Rank Type:      Standard (matches SQL RANK())
  Output Field:   Dept_Rank
```
**SQL Equivalent:**
```sql
RANK() OVER (PARTITION BY DEPARTMENT ORDER BY ACHIEVEMENT_PCT DESC)
```
**Output:** Ranked performance list — used in monthly performance review decks.

---

### EXERCISE 17 — Union Tool (Replaces UNION ALL)
**Role relevance:** Combining data from multiple sources
**Alteryx Tools:** 2x Input → Union → Output
```
INPUT 1: High priority requests (Filter: PRIORITY = "Critical")
INPUT 2: Breached SLA requests (Filter: SLA_Status = "Breached")

Union Tool:
  Mode: Auto (match by field name)
  Add: Source_Flag field to identify which input each row came from
```
**SQL Equivalent:**
```sql
SELECT *, 'Critical' AS Source FROM stakeholder_requests WHERE PRIORITY = 'Critical'
UNION ALL
SELECT *, 'Breached' AS Source FROM stakeholder_requests WHERE SLA_Status = 'Breached'
```
**Output:** Combined priority exception list for stakeholder escalation report.

---

### EXERCISE 18 — Analytic App (Parameterized Report)
**Role relevance:** Replacing stored procedure parameters with self-service Alteryx app
**Alteryx Tools:** Interface Tools → Filter → Summarize → Output
```
Interface Tool 1 — Drop Down (Department):
  Values: Risk, Compliance, Operations, Finance, All
  Action: Update Filter Expression

Interface Tool 2 — Date Range (Start/End Date):
  Action: Update Filter Expression

Interface Tool 3 — Drop Down (Status):
  Values: On Track, At Risk, Off Track, All
  Action: Update Filter Expression

Workflow:
  [Dept Dropdown] → [Filter: Department]
  [Date Range]    → [Filter: Date]
  [Status Drop]   → [Filter: Status]
                         ↓
                    [Summarize]
                         ↓
                    [Output: Excel/Tableau]
```
**Output:** Self-service report app — replaces the sp_department_kpi_report stored procedure.

---

### EXERCISE 19 — Scheduled Workflow (Automation)
**Role relevance:** Automating recurring reports — reducing manual effort by 80%
**Alteryx Tools:** Input → Transform → Output → Email Tool
```
WORKFLOW DESIGN:
  Input Data:    SQL Server reporting_metrics (auto-refresh)
  Filter:        Last 7 days of data
  Summarize:     Weekly KPI summary by department
  Formula:       RAG status + trend vs prior week
  Output:        Weekly_KPI_Report.xlsx to SharePoint
  Email Tool:    Send to stakeholder distribution list

SCHEDULE:
  Alteryx Server or Alteryx Scheduler
  Frequency: Every Monday 7:00 AM
  Recipients: Department heads distribution list
```
**Output:** Fully automated weekly KPI report — zero manual intervention after setup.

---

### EXERCISE 20 — Data Quality Check Workflow
**Role relevance:** Validating data before it reaches dashboards
**Alteryx Tools:** Input → Data Cleansing → Field Summary → Filter → Output
```
STEP 1 — Input Data: reporting_metrics

STEP 2 — Data Cleansing Tool:
  Remove leading/trailing whitespace from all string fields
  Replace nulls in ACHIEVEMENT_PCT with 0
  Standardize date formats

STEP 3 — Field Summary Tool:
  Check % null, % empty, min/max for numeric fields

STEP 4 — Filter (Flag Bad Records):
  Expression: ISNULL([ACHIEVEMENT_PCT]) OR
              [TARGET_VALUE] <= 0 OR
              [REPORT_DATE] > DateTimeNow()

STEP 5 — Output:
  True anchor  → Clean_Metrics.csv (good records)
  False anchor → Bad_Records_Log.csv (exceptions for review)
```
**Output:** Data quality gate — ensures only clean data reaches Tableau dashboards.

---

## TABLEAU + POWER BI EXERCISES (21–25)

### EXERCISE 21 — KPI Scorecard Dashboard Design
**Role relevance:** "Design intuitive dashboards using Tableau and other BI tools"
```
DASHBOARD: Department KPI Scorecard

DATA SOURCE: vw_department_kpi_summary (SQL View)
             OR Alteryx output from Exercise 12

SHEETS TO BUILD:
  Sheet 1: KPI Summary Table
    Rows:    DEPARTMENT
    Columns: On_Track | At_Risk | Off_Track | Avg_Achievement
    Color:   RAG_Status (Green/Yellow/Red)

  Sheet 2: Achievement Bar Chart
    X-axis:  DEPARTMENT
    Y-axis:  Avg_Achievement_Pct
    Color:   RAG_Status
    Reference Line: 100% target line

  Sheet 3: Trend Line
    X-axis:  REPORT_DATE (Month)
    Y-axis:  Avg_Achievement
    Color:   DEPARTMENT
    Mark:    Line

DASHBOARD LAYOUT:
  Top:    KPI Summary Table (full width)
  Middle: Achievement Bar Chart (left) | Trend Line (right)
  Bottom: Filter panel — Department, Date Range, Status
```
**Output:** Executive KPI dashboard — presented in monthly steering committee meetings.

---

### EXERCISE 22 — SLA Compliance Dashboard
**Role relevance:** Presenting SLA data to operations stakeholders
```
DASHBOARD: Stakeholder Request SLA Tracker

DATA SOURCE: vw_stakeholder_sla (SQL View)

SHEETS:
  Sheet 1: SLA Gauge / KPI Card
    Metric: % Requests Met SLA (big number)
    Color:  Green if > 90%, Yellow if > 75%, Red otherwise

  Sheet 2: Breach Heatmap
    Rows:    DEPARTMENT
    Columns: MONTH(DUE_DATE)
    Color:   Count of Breached requests (light → dark red)

  Sheet 3: Priority Breakdown
    Chart:   Stacked bar — Met vs Breached by Priority
    Filter:  REQUEST_TYPE, DEPARTMENT

ACTIONS:
  Click department in heatmap → filter all other sheets
  Click bar → show detailed request list
```
**Output:** SLA operations dashboard — used in weekly ops review meetings.

---

### EXERCISE 23 — Power BI DAX Measures
**Role relevance:** "2+ years in Power BI" — DAX for calculated metrics
```
KEY DAX MEASURES:

-- Achievement Rate
Achievement Rate =
AVERAGE(reporting_metrics[ACHIEVEMENT_PCT])

-- RAG Status (calculated column)
RAG Status =
IF(reporting_metrics[ACHIEVEMENT_PCT] >= 100, "Green",
   IF(reporting_metrics[ACHIEVEMENT_PCT] >= 85, "Yellow", "Red"))

-- SLA Compliance Rate
SLA Compliance % =
DIVIDE(
    COUNTROWS(FILTER(stakeholder_requests,
        stakeholder_requests[SLA_Status] = "Met")),
    COUNTROWS(stakeholder_requests),
    0
) * 100

-- Month over Month Change
MoM Change =
VAR CurrentMonth = [Achievement Rate]
VAR PriorMonth =
    CALCULATE([Achievement Rate],
        DATEADD(stakeholder_requests[REPORT_DATE], -1, MONTH))
RETURN
    DIVIDE(CurrentMonth - PriorMonth, PriorMonth, 0) * 100
```
**Output:** Power BI report with calculated metrics — replaces manual Excel calculations.

---

### EXERCISE 24 — Stakeholder Presentation Data Summary
**Role relevance:** "Present data findings through demos and reporting sessions"
```
SCENARIO: Monthly business review — you are the reporting proxy

PREPARE THESE SLIDES:

Slide 1: Executive Summary (3 KPIs)
  • Overall Achievement Rate: [AVG of ACHIEVEMENT_PCT]
  • SLA Compliance: [% requests meeting SLA]
  • Active Workflows: [COUNT where STATUS = 'Active']

Slide 2: Department Spotlight
  • Best performing: [MAX Avg_Achievement_Pct]
  • Needs attention: [MIN Avg_Achievement_Pct + reason]
  • Month over month trend

Slide 3: Action Items
  • [Dept] — At Risk metrics require intervention by [DATE]
  • [X] SLA breaches in [Dept] — root cause: [REASON]
  • Recommendation: Automate [Workflow] to reduce manual hours

SQL TO PULL SLIDE DATA:
SELECT TOP 1 DEPARTMENT, ROUND(AVG(ACHIEVEMENT_PCT),2) AS Avg
FROM dbo.reporting_metrics
WHERE REPORT_DATE >= DATEADD(MONTH,-1,GETDATE())
GROUP BY DEPARTMENT
ORDER BY Avg DESC; -- Best performer

SELECT TOP 1 DEPARTMENT, ROUND(AVG(ACHIEVEMENT_PCT),2) AS Avg
FROM dbo.reporting_metrics
WHERE REPORT_DATE >= DATEADD(MONTH,-1,GETDATE())
GROUP BY DEPARTMENT
ORDER BY Avg ASC; -- Needs attention
```
**Output:** Data-backed presentation slides — delivered in stakeholder review meetings.

---

### EXERCISE 25 — CAPSTONE: End-to-End Analytics Pipeline ★
**Role relevance:** Full workflow from SQL Server → Alteryx → Tableau → Stakeholder
```
FULL PIPELINE:

STEP 1 — SQL SERVER (Data Layer)
  Run: EXEC dbo.sp_department_kpi_report (all departments)
  Run: SELECT * FROM dbo.vw_stakeholder_sla
  Run: SELECT * FROM dbo.vw_workflow_health

STEP 2 — ALTERYX (Transform Layer)
  Workflow 1: KPI report → clean → add RAG flags → output to Tableau
  Workflow 2: SLA data → calculate breach rates → output to Power BI
  Workflow 3: Workflow health → flag automation candidates → email to IT
  Schedule:   Every Monday 6:00 AM (before business hours)

STEP 3 — TABLEAU (Visualization Layer)
  Dashboard 1: Executive KPI Scorecard (auto-refreshes from Alteryx output)
  Dashboard 2: SLA Compliance Tracker
  Dashboard 3: Workflow Governance Report
  Publish:     Tableau Server — department heads have view access

STEP 4 — STAKEHOLDER DELIVERY
  Email:       Automated summary email via Alteryx Email Tool
  Meeting:     Present Tableau dashboards in Monday 9am review
  JIRA:        Log action items for At Risk metrics as JIRA tickets
  Confluence:  Update weekly metrics page with latest numbers

TOTAL AUTOMATION SAVINGS:
  Before: 8 hours/week manual report preparation
  After:  30 minutes/week — review and exception handling only
  Savings: 7.5 hours/week = 390 hours/year
```
**Output:** Fully automated analytics pipeline — the core deliverable of the Data Analytics Consultant role.

---

## INTERVIEW TIPS FOR THIS ROLE

1. **Lead with automation impact.** Every answer about Alteryx should end with "and this saved X hours per week of manual effort."

2. **SQL → Alteryx is a key differentiator.** Practice walking through the conversion step by step — Input tool, Filter, Summarize, Formula, Output. That's the core of what they want.

3. **JIRA and Confluence.** Mention you track reporting requests as JIRA tickets and document workflows in Confluence — even if your experience is limited.

4. **Power BI requirement.** You have Tableau — bridge it: "My primary tool is Tableau but I'm actively building Power BI skills — the DAX logic is similar to calculated fields I've built in Tableau."

5. **Bank of America experience.** You have it — emphasize it strongly. "Previous Bank of America experience" is listed as a desired qualification and you have it.

6. **Stakeholder communication.** This role is 50% technical, 50% communication. Always tie technical skills to stakeholder outcomes.
