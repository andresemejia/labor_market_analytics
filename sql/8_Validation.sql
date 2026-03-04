SELECT TOP 50 *
FROM dbo.v_skill_demand_monthly
ORDER BY month_start DESC, skill_postings DESC;
