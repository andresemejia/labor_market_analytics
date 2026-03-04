USE TechLaborMarket;
GO

IF OBJECT_ID('dbo.v_skill_demand_monthly','V') IS NOT NULL
    DROP VIEW dbo.v_skill_demand_monthly;
GO

CREATE VIEW dbo.v_skill_demand_monthly
AS
WITH base AS
(
    SELECT
        DATEFROMPARTS(YEAR(f.created), MONTH(f.created), 1) AS month_start,
        d.skill,
        f.job_id
    FROM dbo.fact_job_postings f
    JOIN dbo.bridge_job_skill b
        ON b.job_id = f.job_id
    JOIN dbo.dim_skill d
        ON d.skill_id = b.skill_id
    WHERE f.created IS NOT NULL
),
skill_counts AS
(
    SELECT
        month_start,
        skill,
        COUNT(DISTINCT job_id) AS skill_postings
    FROM base
    GROUP BY month_start, skill
),
total_counts AS
(
    SELECT
        DATEFROMPARTS(YEAR(created), MONTH(created), 1) AS month_start,
        COUNT(DISTINCT job_id) AS total_postings
    FROM dbo.fact_job_postings
    WHERE created IS NOT NULL
    GROUP BY DATEFROMPARTS(YEAR(created), MONTH(created), 1)
)
SELECT
    sc.month_start,
    sc.skill,
    sc.skill_postings,
    tc.total_postings,
    CAST(sc.skill_postings * 1.0 / NULLIF(tc.total_postings, 0) AS FLOAT) AS demand_share,
    CAST((sc.skill_postings * 1.0 / NULLIF(tc.total_postings, 0)) * 100.0 AS FLOAT) AS demand_index
FROM skill_counts sc
JOIN total_counts tc
    ON tc.month_start = sc.month_start;
GO
