/*=============================================================================
  VIEW: vw_stakeholder_sla
  Purpose : Tracks SLA compliance for stakeholder reporting requests
  Source  : stakeholder_requests table
  Used in : Operations Dashboard · SLA Compliance Report · JIRA tracking
  Author  : Bernice Kidiiga · Senior Data Analyst
  Created : 2024-03-01

  ALTERYX CONVERSION: See alteryx_workflows/03_stakeholder_sla_report.md
=============================================================================*/

CREATE OR ALTER VIEW dbo.vw_stakeholder_sla AS

SELECT
    sr.REQUEST_ID,
    sr.DEPARTMENT,
    sr.STAKEHOLDER,
    sr.REQUEST_TYPE,
    sr.PRIORITY,
    sr.STATUS,
    sr.SUBMIT_DATE,
    sr.DUE_DATE,
    sr.COMPLETION_DATE,
    sr.ASSIGNED_ANALYST,
    sr.TOOL_REQUIRED,
    sr.ESTIMATED_HOURS,
    sr.ACTUAL_HOURS,
    sr.RECURRING_FLAG,

    /* Days to complete */
    CASE
        WHEN sr.COMPLETION_DATE IS NOT NULL
        THEN DATEDIFF(DAY, sr.SUBMIT_DATE, sr.COMPLETION_DATE)
        ELSE DATEDIFF(DAY, sr.SUBMIT_DATE, GETDATE())
    END AS Days_To_Complete,

    /* SLA breach flag */
    CASE
        WHEN sr.COMPLETION_DATE IS NOT NULL
             AND sr.COMPLETION_DATE > sr.DUE_DATE THEN 'Breached'
        WHEN sr.COMPLETION_DATE IS NULL
             AND GETDATE() > sr.DUE_DATE          THEN 'Breached'
        WHEN sr.COMPLETION_DATE IS NOT NULL       THEN 'Met'
        ELSE 'In Progress'
    END AS SLA_Status,

    /* Hours variance */
    CASE
        WHEN sr.ACTUAL_HOURS IS NOT NULL
        THEN sr.ACTUAL_HOURS - sr.ESTIMATED_HOURS
        ELSE NULL
    END AS Hours_Variance,

    /* Priority weight for sorting */
    CASE sr.PRIORITY
        WHEN 'Critical' THEN 1
        WHEN 'High'     THEN 2
        WHEN 'Medium'   THEN 3
        WHEN 'Low'      THEN 4
    END AS Priority_Rank

FROM dbo.stakeholder_requests sr;

GO
