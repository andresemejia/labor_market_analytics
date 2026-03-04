USE TechLaborMarket;
GO

/* Drop model objects if re-running */
IF OBJECT_ID('dbo.bridge_job_skill','U') IS NOT NULL DROP TABLE dbo.bridge_job_skill;
IF OBJECT_ID('dbo.fact_job_postings','U') IS NOT NULL DROP TABLE dbo.fact_job_postings;
IF OBJECT_ID('dbo.dim_skill','U') IS NOT NULL DROP TABLE dbo.dim_skill;
GO

/* DIM */
CREATE TABLE dbo.dim_skill
(
    skill_id INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_dim_skill PRIMARY KEY,
    skill    NVARCHAR(200) NOT NULL
);
CREATE UNIQUE INDEX UX_dim_skill_skill ON dbo.dim_skill(skill);
GO

/* FACT */
CREATE TABLE dbo.fact_job_postings
(
    job_id              BIGINT        NOT NULL CONSTRAINT PK_fact_job_postings PRIMARY KEY,
    created             DATETIME2(0)   NULL,
    title               NVARCHAR(1000) NULL,
    company_name        NVARCHAR(500)  NULL,
    location_display    NVARCHAR(1000) NULL,
    category_label      NVARCHAR(500)  NULL,
    salary_min          FLOAT         NULL,
    salary_max          FLOAT         NULL,
    salary_is_predicted BIT           NULL
);
GO

/* BRIDGE */
CREATE TABLE dbo.bridge_job_skill
(
    job_id  BIGINT NOT NULL,
    skill_id INT   NOT NULL,
    CONSTRAINT PK_bridge_job_skill PRIMARY KEY (job_id, skill_id),
    CONSTRAINT FK_bridge_job_skill_job  FOREIGN KEY (job_id)  REFERENCES dbo.fact_job_postings(job_id),
    CONSTRAINT FK_bridge_job_skill_skill FOREIGN KEY (skill_id) REFERENCES dbo.dim_skill(skill_id)
);
GO

/* Load dim_skill */
INSERT INTO dbo.dim_skill(skill)
SELECT DISTINCT LOWER(LTRIM(RTRIM(skill)))
FROM dbo.stg_job_skills
WHERE skill IS NOT NULL
  AND LTRIM(RTRIM(skill)) <> '';
GO

/* Load fact_job_postings */
INSERT INTO dbo.fact_job_postings
(
    job_id, created, title, company_name, location_display, category_label,
    salary_min, salary_max, salary_is_predicted
)
SELECT
    job_id,
    CAST(TRY_CONVERT(DATETIMEOFFSET, created, 127) AS DATETIME2(0)) AS created,
    title,
    company_name,
    location_display,
    category_label,
    salary_min,
    salary_max,
    CASE WHEN salary_is_predicted IN (0,1) THEN CAST(salary_is_predicted AS BIT) ELSE NULL END
FROM dbo.stg_jobs_clean
WHERE job_id IS NOT NULL;
GO

/* Load bridge_job_skill */
INSERT INTO dbo.bridge_job_skill(job_id, skill_id)
SELECT DISTINCT
    s.job_id,
    d.skill_id
FROM dbo.stg_job_skills s
JOIN dbo.fact_job_postings f
    ON f.job_id = s.job_id
JOIN dbo.dim_skill d
    ON d.skill = LOWER(LTRIM(RTRIM(s.skill)))
WHERE s.skill IS NOT NULL
  AND LTRIM(RTRIM(s.skill)) <> '';
GO
