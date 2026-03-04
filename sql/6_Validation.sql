SELECT COUNT(*) AS fact_rows   FROM dbo.fact_job_postings;
SELECT COUNT(*) AS dim_rows    FROM dbo.dim_skill;
SELECT COUNT(*) AS bridge_rows FROM dbo.bridge_job_skill;
