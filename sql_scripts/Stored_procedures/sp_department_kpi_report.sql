/*=============================================================================
  STORED PROCEDURE: sp_department_kpi_report
  Purpose  : Generates parameterized department KPI report for Tableau/Power BI
  Parameters:
    @Department   VARCHAR(50)  -- Filter by department (NULL = all)
    @StartDate    DATE         -- Report start date
    @EndDate      DATE         -- Report end date
    @StatusFilter VARCHAR(20)  -- Filter by status (NULL = all)
  Author   : Bernice Kidiiga · Senior Data Analyst
  
  ALTERYX CONVERSION: See alteryx_workflows/04_sp_kpi_report_conversion.md
=============================================================================*/

CREATE OR ALTER PROCEDURE dbo.sp_department_kpi_report
    @Department   VARCHAR(50) = NULL,
    @StartDate    DATE        = NULL,
    @EndDate      DATE        = NULL,
    @StatusFilter VARCHAR(20) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    /* Default date range to current quarter if not supplied */
    IF @StartDate IS NULL
        SET @StartDate = DATEADD(QUARTER,
                         DATEDIFF(QUARTER, 0, GETDATE()), 0);
    IF @EndDate IS NULL
        SET @EndDate = GETDATE();

    SELECT
        rm.DEPARTMENT,
        rm.METRIC_TYPE,
        rm.METRIC_NAME,
        rm.TARGET_VALUE,
        rm.ACTUAL_VALUE,
        rm.ACHIEVEMENT_PCT,
        rm.STATUS,
        rm.REPORT_DATE,
        rm.OWNER,
        rm.FREQUENCY,
        rm.VARIANCE,

        /* Running average achievement by department */
        AVG(rm.ACHIEVEMENT_PCT) OVER (
            PARTITION BY rm.DEPARTMENT
            ORDER BY rm.REPORT_DATE
            ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
        ) AS Rolling_3_Avg_Achievement,

        /* Rank within department */
        RANK() OVER (
            PARTITION BY rm.DEPARTMENT
            ORDER BY rm.ACHIEVEMENT_PCT DESC
        ) AS Dept_Rank,

        /* RAG status */
        CASE
            WHEN rm.ACHIEVEMENT_PCT >= 100 THEN 'Green'
            WHEN rm.ACHIEVEMENT_PCT >= 85  THEN 'Yellow'
            ELSE 'Red'
        END AS RAG_Status

    FROM dbo.reporting_metrics rm
    WHERE
        (@Department   IS NULL OR rm.DEPARTMENT = @Department)
        AND rm.REPORT_DATE BETWEEN @StartDate AND @EndDate
        AND (@StatusFilter IS NULL OR rm.STATUS = @StatusFilter)
    ORDER BY
        rm.DEPARTMENT,
        rm.ACHIEVEMENT_PCT DESC;

END;
GO

/*=============================================================================
  USAGE EXAMPLES:
  
  -- All departments, current quarter
  EXEC dbo.sp_department_kpi_report;
  
  -- Risk department only, specific date range
  EXEC dbo.sp_department_kpi_report
      @Department = 'Risk',
      @StartDate  = '2024-01-01',
      @EndDate    = '2024-03-31';
  
  -- At Risk metrics across all departments
  EXEC dbo.sp_department_kpi_report
      @StatusFilter = 'At Risk';
=============================================================================*/
