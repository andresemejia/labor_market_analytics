# Labor Market Analytics Project

End-to-end labor market analytics pipeline tracking technology skill demand, wage trends, and workforce gaps across the U.S. tech industry. Built with Python (ETL), SQL Server (star schema data model), and Power BI (interactive dashboards).

## Tech Stack
- **Python** — data ingestion and ETL pipeline
- **SQL Server** — star schema analytical data model
- **Power BI** — interactive dashboards

## Project Structure
```
├── data/               # Raw and cleaned job postings data
├── sql/                # Database creation, schema, and view scripts
├── dashboards/         # Power BI report file (.pbix)
└── README.md
```

## Data Model
- `fact_job_postings` — core job posting records
- `dim_skill` — skill dimension table
- `bridge_job_skill` — many-to-many bridge table
- `v_skill_demand_monthly` — aggregated monthly skill demand view

## Dashboard Pages
1. **Executive Overview** — KPIs, skill demand trends, top skills ranking
2. **Skill Demand Deep Dive** — demand trends, wage vs demand analysis
3. **Regional Labor Market Gaps** — geographic skill demand distribution

## Key Findings
- SQL, AWS, and Python are the most demanded tech skills
- Data covers September 2023 – February 2026
- 99.87% of salary data is model-predicted

## Data Source
Job postings data via Adzuna API — United States, Software/Technology industry
