/*=============================================================================
  VIEW: vw_department_kpi_summary
  Purpose : Summarizes KPI achievement by department for dashboard reporting
  Source  : reporting_metrics table
  Used in : Tableau KPI Dashboard · Monthly Executive Report
  Author  : Bernice Kidiiga · Senior Data Analyst
  Created : 2024-01-15
  
  ALTERYX CONVERSION: See alteryx_workflows/01_department_kpi_summary.md
=============================================================================*/

CREATE OR ALTER VIEW dbo.vw_department_kpi_summary AS

SELECT
    rm.DEPARTMENT,
    rm.METRIC_TYPE,
    COUNT(*)                                          AS Total_Metrics,
    SUM(CASE WHEN rm.STATUS = 'On Track'   THEN 1 ELSE 0 END) AS On_Track,
    SUM(CASE WHEN rm.STATUS = 'At Risk'    THEN 1 ELSE 0 END) AS At_Risk,
    SUM(CASE WHEN rm.STATUS = 'Off Track'  THEN 1 ELSE 0 END) AS Off_Track,
    SUM(CASE WHEN rm.STATUS = 'Exceeded'   THEN 1 ELSE 0 END) AS Exceeded,
    ROUND(AVG(rm.ACHIEVEMENT_PCT), 2)                AS Avg_Achievement_Pct,
    ROUND(AVG(rm.VARIANCE), 2)                       AS Avg_Variance,
    MAX(rm.REPORT_DATE)                              AS Latest_Report_Date,

    /* Achievement tier for dashboard color coding */
    CASE
        WHEN AVG(rm.ACHIEVEMENT_PCT) >= 100 THEN 'Green'
        WHEN AVG(rm.ACHIEVEMENT_PCT) >= 85  THEN 'Yellow'
        ELSE 'Red'
    END AS RAG_Status

FROM dbo.reporting_metrics rm
WHERE rm.REPORT_DATE >= DATEADD(MONTH, -3, GETDATE())   -- rolling 3 months
GROUP BY rm.DEPARTMENT, rm.METRIC_TYPE;

GO
