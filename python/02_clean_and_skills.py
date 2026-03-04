import pandas as pd
from pathlib import Path
import re
import os

PROJECT_ROOT = Path(r"C:\Users\User7\Desktop\Labor_Market_Analytics")

raw_path = PROJECT_ROOT / "01_Data_Raw" / "adzuna_jobs_raw.csv"
clean_dir = PROJECT_ROOT / "02_Data_Clean"
clean_dir.mkdir(parents=True, exist_ok=True)

print("WORKING DIR:", os.getcwd())
print("RAW PATH:", raw_path)
print("RAW EXISTS:", raw_path.exists())

df = pd.read_csv(raw_path)
print("RAW ROWS:", len(df))
print("RAW COLS:", df.columns.tolist())

# ---- Flatten dict-like columns saved as text ----
def safe_str(x):
    return "" if pd.isna(x) else str(x)

df["company_name"] = df["company"].apply(safe_str).str.extract(r"'display_name':\s*'([^']+)'", expand=False)
df["location_display"] = df["location"].apply(safe_str).str.extract(r"'display_name':\s*'([^']+)'", expand=False)
df["category_label"] = df["category"].apply(safe_str).str.extract(r"'label':\s*'([^']+)'", expand=False)

# ---- Jobs table ----
jobs = df[[
    "id", "created", "title", "description", "redirect_url",
    "salary_min", "salary_max", "salary_is_predicted",
    "latitude", "longitude",
    "company_name", "location_display", "category_label"
]].copy()

jobs.rename(columns={"id": "job_id"}, inplace=True)
jobs["created"] = pd.to_datetime(jobs["created"], errors="coerce")

jobs_out = clean_dir / "jobs_clean.csv"
jobs.to_csv(jobs_out, index=False)

print("WROTE jobs_clean rows:", len(jobs))
print("OUTPUT PATH:", jobs_out)

# ---- Skill extraction ----
SKILLS = ["python","sql","excel","power bi","tableau","aws","azure","gcp",
          "spark","airflow","machine learning","docker","kubernetes","cybersecurity"]

def extract_skills(text: str):
    t = (text or "").lower()
    found = []
    for s in SKILLS:
        if re.search(r"\b" + re.escape(s) + r"\b", t):
            found.append(s)
    return found

skill_rows = []
for _, row in jobs[["job_id", "title", "description"]].iterrows():
    text = f"{row['title']} {row['description']}"
    for skill in extract_skills(text):
        skill_rows.append({"job_id": row["job_id"], "skill": skill})

job_skills = pd.DataFrame(skill_rows).drop_duplicates()

skills_out = clean_dir / "job_skills.csv"
job_skills.to_csv(skills_out, index=False)

print("WROTE job_skills rows:", len(job_skills))
print("OUTPUT PATH:", skills_out)
print("Top skills:\n", job_skills["skill"].value_counts().head(10))
