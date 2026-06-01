/*=============================================================================
  VIEW: vw_workflow_health
  Purpose : Workflow inventory health check — identifies stale/error-prone
            workflows for remediation and governance reporting
  Source  : workflow_inventory table
  Used in : Alteryx Governance Dashboard · IT Operations Report
  Author  : Bernice Kidiiga · Senior Data Analyst
  Created : 2024-02-01

  ALTERYX CONVERSION: See alteryx_workflows/02_workflow_health_check.md
=============================================================================*/

CREATE OR ALTER VIEW dbo.vw_workflow_health AS

SELECT
    wi.WORKFLOW_ID,
    wi.WORKFLOW_NAME,
    wi.TOOL,
    wi.DEPARTMENT,
    wi.COMPLEXITY,
    wi.STATUS,
    wi.OWNER,
    wi.PRIMARY_DATA_SOURCE,
    wi.TOTAL_RUNS,
    wi.AVG_RUNTIME_MINS,
    wi.ERROR_COUNT,
    wi.LAST_RUN_DATE,

    /* Days since last run */
    DATEDIFF(DAY, wi.LAST_RUN_DATE, GETDATE())       AS Days_Since_Last_Run,

    /* Error rate */
    CASE
        WHEN wi.TOTAL_RUNS = 0 THEN 0
        ELSE ROUND(CAST(wi.ERROR_COUNT AS FLOAT)
             / wi.TOTAL_RUNS * 100, 2)
    END AS Error_Rate_Pct,

    /* Health classification */
    CASE
        WHEN wi.STATUS = 'Deprecated'                        THEN 'Retired'
        WHEN DATEDIFF(DAY, wi.LAST_RUN_DATE, GETDATE()) > 90 THEN 'Stale'
        WHEN wi.ERROR_COUNT > 10                             THEN 'Needs Review'
        WHEN wi.STATUS = 'Active' AND wi.ERROR_COUNT <= 5    THEN 'Healthy'
        ELSE 'Monitor'
    END AS Health_Status,

    /* Automation flag */
    wi.AUTOMATED

FROM dbo.workflow_inventory wi;

GO
