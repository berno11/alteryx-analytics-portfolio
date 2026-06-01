# ⚙️ Analytics Consultant Portfolio — Alteryx · SQL Server · Tableau · Power BI

<div align="center">

**Bernice Kidiiga** · Senior Data Analyst · Charlotte, NC

[![License: CC BY-NC 4.0](https://img.shields.io/badge/License-CC%20BY--NC%204.0-lightgrey.svg)](https://creativecommons.org/licenses/by-nc/4.0/)
![Alteryx](https://img.shields.io/badge/Alteryx-Workflows-blue)
![SQL Server](https://img.shields.io/badge/SQL_Server-Views_%26_SPs-darkred)
![Tableau](https://img.shields.io/badge/Tableau-Dashboards-orange)
![Power BI](https://img.shields.io/badge/Power_BI-DAX-yellow)
![Status](https://img.shields.io/badge/Status-Active-brightgreen)

📧 berno77@gmail.com · 📍 Charlotte, NC · 💼 [View Portfolio](https://berno11.github.io/alteryx-analytics-portfolio/)

</div>

---

## About

This repository demonstrates applied **Alteryx, SQL Server, Tableau, and Power BI** skills using mock analytics datasets — covering the exact workflows required for Data Analytics Consultant roles in financial services and enterprise environments.

Each exercise maps to a real deliverable: converting SQL views and stored procedures to Alteryx workflows, building stakeholder dashboards, automating recurring reports, and presenting data findings to cross-functional teams.

> 🔒 Dataset files are not included in this public repository.
> See [`DATA_DICTIONARY.md`](DATA_DICTIONARY.md) for full column definitions.
> Dataset access: **[Purchase on Gumroad](https://1699917831060.gumroad.com/l/kwxstv)**

---

## Repository Structure

```
alteryx-analytics-portfolio/
│
├── README.md
├── LICENSE
├── DATA_DICTIONARY.md
│
├── sql_scripts/
│   ├── views/
│   │   ├── vw_department_kpi_summary.sql
│   │   ├── vw_workflow_health.sql
│   │   └── vw_stakeholder_sla.sql
│   └── stored_procedures/
│       ├── sp_department_kpi_report.sql
│       └── sp_workflow_governance_report.sql
│
├── alteryx_workflows/
│   ├── 01_department_kpi_summary.md
│   └── 02_stored_procedure_conversion.md
│
├── setup/
│   └── ssms_setup_guide.md
│
└── exercises/
    └── 25_analytics_consultant_exercises.md
```

---

## SQL → Alteryx Conversion Quick Reference

| SQL Clause | Alteryx Tool |
|-----------|-------------|
| `FROM table` | Input Data Tool |
| `WHERE condition` | Filter Tool |
| `GROUP BY + aggregates` | Summarize Tool |
| `CASE WHEN` | Formula Tool |
| `JOIN` | Join Tool |
| `UNION ALL` | Union Tool |
| `ORDER BY` | Sort Tool |
| `RANK() OVER` | Rank Tool |
| `AVG() OVER (ROWS BETWEEN)` | Multi-Row Formula Tool |
| Stored Proc `@parameters` | Interface Tools (Analytic App) |
| Scheduled SQL Agent job | Alteryx Scheduler / Server |

---

## Skills Demonstrated

| Category | Tools & Concepts |
|----------|-----------------|
| **Alteryx** | Input Data, Filter, Summarize, Formula, Join, Union, Multi-Row Formula, Rank, Analytic Apps, Scheduler |
| **SQL Server** | Views, Stored Procedures, Window Functions, CTEs, Dynamic SQL, SSMS |
| **Tableau** | Dashboard design, calculated fields, actions, filters, Tableau Server |
| **Power BI** | DAX measures, calculated columns, relationships, scheduled refresh |
| **Reporting** | KPI scorecards, SLA tracking, executive summaries, stakeholder presentations |
| **Governance** | Workflow inventory, data quality gates, automation ROI |
| **Collaboration** | JIRA tracking, Confluence documentation, cross-functional reporting |

---

## Exercise Index

| # | Exercise | Key Skill |
|---|----------|-----------|
| 01–10 | SQL Server Exercises | Views, SPs, Window Functions, CTEs |
| 11–20 | Alteryx Exercises | SQL→Alteryx conversion, automation |
| 21–23 | Tableau + Power BI | Dashboard design, DAX measures |
| 24 | Stakeholder Presentation | Data storytelling, executive reporting |
| **25** | **★ End-to-End Pipeline** | **SQL → Alteryx → Tableau → Stakeholder** |

---

## Professional Background

12+ years enterprise data analytics · Financial services & healthcare
- **Bank of America** — SQL analytics, ETL validation, regulatory reporting
- **Wells Fargo** — Data governance, reconciliation, AML analytics

*Tools: Alteryx · SAS · SQL · Tableau · Power BI · Python · Oracle · Teradata · JIRA · Confluence*

---

© 2024 Bernice Kidiiga · [CC BY-NC 4.0](LICENSE) · Not for commercial redistribution
