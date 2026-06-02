# ⚙️ Analytics Consultant Portfolio — Alteryx · SQL Server · Tableau · Power BI

<div align="center">

**Bernice Kidiiga** · Senior Data Analyst · Charlotte, NC

[![License](https://img.shields.io/badge/License-All%20Rights%20Reserved-red.svg)](LICENSE)
![Alteryx](https://img.shields.io/badge/Alteryx-Workflows-blue)
![SQL Server](https://img.shields.io/badge/SQL_Server-Views_%26_SPs-darkred)
![Tableau](https://img.shields.io/badge/Tableau-Dashboards-orange)
![Power BI](https://img.shields.io/badge/Power_BI-DAX-yellow)
![Status](https://img.shields.io/badge/Status-Active-brightgreen)

📧 berno77@gmail.com · 📍 Charlotte, NC · 💼 [View Portfolio Page](https://berno11.github.io/alteryx-analytics-portfolio/landing.html)

</div>

---

## 👋 New Here? Read This First

This repository contains **SQL Server scripts, Alteryx conversion guides, and 25 practice exercises** for Analytics Consultant roles in financial services.

**The practice datasets are not included here** — they are available for purchase and are required to run the exercises. Follow the journey below in order and you will be fully set up in under 30 minutes.

---

## 🗺️ Your Learning Journey — Follow These Steps in Order

```
╔══════════════════════════════════════════════════════════════════╗
║  STEP 1 — Purchase the datasets (required first)                 ║
║  👉 https://1699917831060.gumroad.com/l/qagln                    ║
╠══════════════════════════════════════════════════════════════════╣
║  STEP 2 — Set up SQL Server                                      ║
║  📄 setup/ssms_setup_guide.md    ← read this                    ║
║  💾 setup/sql_server_setup.sql   ← run this in SSMS             ║
╠══════════════════════════════════════════════════════════════════╣
║  STEP 3 — Create the SQL views (run in SSMS)                     ║
║  📄 sql_scripts/views/vw_department_kpi_summary.sql             ║
║  📄 sql_scripts/views/vw_workflow_health.sql                    ║
║  📄 sql_scripts/views/vw_stakeholder_sla.sql                    ║
╠══════════════════════════════════════════════════════════════════╣
║  STEP 4 — Create the stored procedures (run in SSMS)             ║
║  📄 sql_scripts/stored_procedures/sp_department_kpi_report.sql  ║
║  📄 sql_scripts/stored_procedures/sp_workflow_governance_report.sql ║
╠══════════════════════════════════════════════════════════════════╣
║  STEP 5 — Connect Alteryx to your SQL Server database            ║
║  📄 alteryx_workflows/01_department_kpi_summary_conversion.md   ║
║  📄 alteryx_workflows/02_stored_procedure_conversion.md         ║
╠══════════════════════════════════════════════════════════════════╣
║  STEP 6 — Work through all 25 exercises                          ║
║  📄 exercises/25_analytics_consultant_exercises.md              ║
╠══════════════════════════════════════════════════════════════════╣
║  STEP 7 — Build Tableau / Power BI dashboards on your live data  ║
╚══════════════════════════════════════════════════════════════════╝
```

> 💡 **Why SQL Server first?** The SQL views and stored procedures run on live data in your database. Once they're working, you then convert them into Alteryx workflows — which is the core skill this portfolio teaches. You can't convert what doesn't exist yet!

---

## ⚠️ Step 1 — Purchase the Datasets

The practice datasets must be purchased before you can run anything.

### 👉 [Purchase Practice Datasets — $15](https://1699917831060.gumroad.com/l/qagln)

**What you receive after purchase:**

| File | Rows | Used In |
|------|------|---------|
| `reporting_metrics.csv` | 300 | SQL exercises 01–07, Alteryx 11–15, Tableau 21–22 |
| `workflow_inventory.csv` | 200 | SQL exercises 07–08, Alteryx 16–20, governance report |
| `stakeholder_requests.csv` | 250 | SQL exercises 05–06, SLA dashboard, capstone |
| `25_analytics_consultant_exercises.md` | — | All 25 exercises with full answers |
| `01_department_kpi_summary_conversion.md` | — | SQL View → Alteryx step-by-step |
| `02_stored_procedure_conversion.md` | — | Stored Proc → Alteryx step-by-step |
| `sql_server_setup.sql` | — | Creates database + imports all 3 CSVs |

---

## 📁 Repository Structure

```
alteryx-analytics-portfolio/
│
├── README.md                                    ← You are here — start here
├── LICENSE                                      ← All rights reserved
│
├── setup/
│   ├── ssms_setup_guide.md                     ← STEP 2: Full setup walkthrough
│   └── sql_server_setup.sql                    ← STEP 2: Run to create DB + import CSVs
│
├── sql_scripts/
│   ├── views/                                  ← STEP 3: Run these in SSMS
│   │   ├── vw_department_kpi_summary.sql       ← KPI summary by department
│   │   ├── vw_workflow_health.sql              ← Workflow health check
│   │   └── vw_stakeholder_sla.sql              ← SLA breach tracking
│   └── stored_procedures/                      ← STEP 4: Run these in SSMS
│       ├── sp_department_kpi_report.sql        ← Parameterized KPI report
│       └── sp_workflow_governance_report.sql   ← Governance audit report
│
├── alteryx_workflows/                          ← STEP 5: SQL → Alteryx conversion
│   ├── 01_department_kpi_summary_conversion.md ← View → Alteryx tool-by-tool
│   └── 02_stored_procedure_conversion.md       ← SP → Alteryx Analytic App
│
└── exercises/                                  ← STEP 6: Practice here
    └── 25_analytics_consultant_exercises.md    ← All 25 exercises + answers
```

---

## ⚡ SQL → Alteryx Conversion Quick Reference

| SQL Clause | Alteryx Tool | Exercise |
|-----------|-------------|---------|
| `FROM table / view` | Input Data Tool | Ex 11 |
| `WHERE condition` | Filter Tool | Ex 11 |
| `GROUP BY + aggregates` | Summarize Tool | Ex 12 |
| `CASE WHEN` | Formula Tool | Ex 13 |
| `JOIN` | Join Tool | Ex 14 |
| `UNION ALL` | Union Tool | Ex 17 |
| `ORDER BY` | Sort Tool | Ex 11 |
| `RANK() OVER` | Rank Tool | Ex 16 |
| `AVG() OVER (ROWS BETWEEN)` | Multi-Row Formula Tool | Ex 15 |
| Stored Proc `@parameters` | Interface Tools → Analytic App | Ex 18 |
| SQL Agent scheduled job | Alteryx Scheduler / Server | Ex 19 |

---

## 📊 Exercise Index

| # | Exercise | Key Skill | Datasets Used |
|---|----------|-----------|--------------|
| 01 | Basic SELECT + date filter | WHERE, AND conditions | reporting_metrics |
| 02 | GROUP BY with CASE aggregation | Aggregation, RAG status | reporting_metrics |
| 03 | Window functions (RANK, ROW_NUMBER) | OVER, PARTITION BY | reporting_metrics |
| 04 | Rolling average | ROWS BETWEEN | reporting_metrics |
| 05 | SLA breach detection | DATEDIFF, CASE | stakeholder_requests |
| 06 | Stored procedure execution | EXEC, parameters | all 3 tables |
| 07 | Creating SQL views | CREATE VIEW | workflow_inventory |
| 08 | JOIN + aggregation | Tool capacity vs demand | all 3 tables |
| 09 | CTE + correlated logic | WITH clause, HAVING | stakeholder_requests |
| 10 | Dynamic SQL | sp_executesql, QUOTENAME | reporting_metrics |
| 11 | Input Data + Filter | SQL → Alteryx start | reporting_metrics |
| 12 | Summarize Tool | GROUP BY equivalent | reporting_metrics |
| 13 | Formula Tool | CASE WHEN equivalent | reporting_metrics |
| 14 | Join Tool | SQL JOIN equivalent | all 3 tables |
| 15 | Multi-Row Formula | Window function equivalent | reporting_metrics |
| 16 | Rank Tool | RANK() OVER equivalent | reporting_metrics |
| 17 | Union Tool | UNION ALL equivalent | stakeholder_requests |
| 18 | Analytic App | SP parameters equivalent | all 3 tables |
| 19 | Scheduled workflow | Automation | all 3 tables |
| 20 | Data quality check | Profiling + validation | all 3 tables |
| 21 | KPI scorecard dashboard | Tableau design | reporting_metrics |
| 22 | SLA compliance dashboard | Tableau actions | stakeholder_requests |
| 23 | Power BI DAX measures | DAX, calculated columns | all 3 tables |
| 24 | Stakeholder presentation | Data storytelling | all 3 tables |
| **★25** | **End-to-end pipeline** | **SQL → Alteryx → Tableau → Stakeholder** | **all 3 tables** |

---

## 🛠️ Skills Demonstrated

| Category | Tools & Concepts |
|----------|-----------------|
| **Alteryx** | Input Data, Filter, Summarize, Formula, Join, Union, Multi-Row Formula, Rank, Analytic Apps, Scheduler |
| **SQL Server** | Views, Stored Procedures, Window Functions, CTEs, Dynamic SQL, SSMS, BULK INSERT |
| **Tableau** | Dashboard design, calculated fields, actions, filters, Tableau Server |
| **Power BI** | DAX measures, calculated columns, relationships, scheduled refresh |
| **Reporting** | KPI scorecards, SLA tracking, executive summaries, stakeholder presentations |
| **Governance** | Workflow inventory, data quality gates, automation ROI |
| **Collaboration** | JIRA tracking, Confluence documentation, cross-functional reporting |

---

## 👩🏾‍💼 Professional Background

12+ years enterprise data analytics · Financial services & healthcare
- **Bank of America** — SQL analytics, ETL validation, regulatory reporting
- **Wells Fargo** — Data governance, reconciliation, AML analytics, $350B portfolio

*Tools: Alteryx · SAS · SQL · Tableau · Power BI · Python · Oracle · Teradata · JIRA · Confluence*

---

© 2024 Bernice Kidiiga · All Rights Reserved · See [LICENSE](LICENSE)
Unauthorized copying, redistribution, or commercial use is strictly prohibited.
Questions: berno77@gmail.com
