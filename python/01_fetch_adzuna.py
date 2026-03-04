import requests
import pandas as pd
import time
from pathlib import Path

# ✅ Put your credentials here
APP_ID = "8fc3911e"
APP_KEY = "2f3ea021038e5663e72af1625b36e1d9"

BASE_URL = "https://api.adzuna.com/v1/api/jobs/us/search/"
KEYWORDS = ["python", "sql", "aws", "data engineer", "machine learning"]
MAX_PAGES = 3          # start small
RESULTS_PER_PAGE = 50  # max is usually 50

raw_dir = Path("01_Data_Raw")
raw_dir.mkdir(parents=True, exist_ok=True)

all_rows = []

for keyword in KEYWORDS:
    for page in range(1, MAX_PAGES + 1):
        url = f"{BASE_URL}{page}"
        params = {
            "app_id": APP_ID,
            "app_key": APP_KEY,
            "what": keyword,
            "results_per_page": RESULTS_PER_PAGE,
            "content-type": "application/json"
        }

        r = requests.get(url, params=params, timeout=30)

        if r.status_code != 200:
            print(f"❌ Error {r.status_code} for '{keyword}' page {page}")
            print(r.text[:300])
            break

        results = r.json().get("results", [])
        if not results:
            print(f"⚠️ No results for '{keyword}' page {page}")
            break

        all_rows.extend(results)
        time.sleep(1)  # be polite to API

df = pd.DataFrame(all_rows)

# Safe dedupe only on unique id (no dict hashing)
if "id" in df.columns:
    df = df.drop_duplicates(subset=["id"])
elif "redirect_url" in df.columns:
    df = df.drop_duplicates(subset=["redirect_url"])



out_path = raw_dir / "adzuna_jobs_raw.csv"
df.to_csv(out_path, index=False)

print(f"✅ Saved {len(df)} rows to {out_path.resolve()}")
print("Columns:", list(df.columns)[:15])
