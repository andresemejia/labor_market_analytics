USE TechLaborMarket;
GO

EXEC sp_rename 'dbo.jobs_clean', 'stg_jobs_clean';
EXEC sp_rename 'dbo.job_skills', 'stg_job_skills';
GO
