/*=============================================================================
  STORED PROCEDURE: sp_workflow_governance_report
  Purpose  : Workflow governance audit report — stale, error-prone,
             and unowned workflows for IT and Operations review
  Parameters:
    @Tool         VARCHAR(50)  -- Filter by tool (Alteryx, Tableau, etc.)
    @Department   VARCHAR(50)  -- Filter by department
    @HealthStatus VARCHAR(20)  -- Filter: Healthy/Stale/Needs Review/Monitor
    @DaysSinceRun INT          -- Flag workflows not run in N days
  Author   : Bernice Kidiiga · Senior Data Analyst

  ALTERYX CONVERSION: See alteryx_workflows/05_sp_governance_conversion.md
=============================================================================*/

CREATE OR ALTER PROCEDURE dbo.sp_workflow_governance_report
    @Tool         VARCHAR(50) = NULL,
    @Department   VARCHAR(50) = NULL,
    @HealthStatus VARCHAR(20) = NULL,
    @DaysSinceRun INT         = 90
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        wh.WORKFLOW_ID,
        wh.WORKFLOW_NAME,
        wh.TOOL,
        wh.DEPARTMENT,
        wh.COMPLEXITY,
        wh.STATUS,
        wh.OWNER,
        wh.PRIMARY_DATA_SOURCE,
        wh.TOTAL_RUNS,
        wh.AVG_RUNTIME_MINS,
        wh.ERROR_COUNT,
        wh.ERROR_RATE_PCT,
        wh.DAYS_SINCE_LAST_RUN,
        wh.HEALTH_STATUS,
        wh.AUTOMATED,

        /* Remediation recommendation */
        CASE
            WHEN wh.HEALTH_STATUS = 'Stale'
            THEN 'Review with owner — consider deprecation'
            WHEN wh.HEALTH_STATUS = 'Needs Review'
            THEN 'Error rate exceeds threshold — investigate'
            WHEN wh.HEALTH_STATUS = 'Retired'
            THEN 'Archive and remove from active inventory'
            WHEN wh.COMPLEXITY = 'Very High' AND wh.AUTOMATED = 'No'
            THEN 'Candidate for Alteryx automation'
            ELSE 'No action required'
        END AS Recommendation,

        /* Estimated hours saved if automated */
        CASE
            WHEN wh.AUTOMATED = 'No'
            THEN ROUND(wh.TOTAL_RUNS * wh.AVG_RUNTIME_MINS / 60 * 0.7, 1)
            ELSE 0
        END AS Potential_Hours_Saved

    FROM dbo.vw_workflow_health wh
    WHERE
        (@Tool         IS NULL OR wh.TOOL       = @Tool)
        AND (@Department   IS NULL OR wh.DEPARTMENT = @Department)
        AND (@HealthStatus IS NULL OR wh.HEALTH_STATUS = @HealthStatus)
        AND wh.DAYS_SINCE_LAST_RUN >= @DaysSinceRun
    ORDER BY
        wh.HEALTH_STATUS,
        wh.ERROR_COUNT DESC;

END;
GO
