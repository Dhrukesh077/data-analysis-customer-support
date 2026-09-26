# 📊 Customer Support Quality Analysis

![Python](https://img.shields.io/badge/Python-3.12-3776AB?logo=python&logoColor=white)
![Pandas](https://img.shields.io/badge/Pandas-2.x-150458?logo=pandas&logoColor=white)
![Matplotlib](https://img.shields.io/badge/Matplotlib-3.x-11557C?logo=plotly&logoColor=white)
![openpyxl](https://img.shields.io/badge/openpyxl-3.x-217346)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-15-4169E1?logo=postgresql&logoColor=white)
![Excel](https://img.shields.io/badge/Excel-365%20%2F%202019%2B-217346?logo=microsoftexcel&logoColor=white)
![Power BI](https://img.shields.io/badge/Power%20BI-Desktop-F2C811?logo=powerbi&logoColor=black)
![License](https://img.shields.io/badge/License-MIT-brightgreen)

**Student:** [REPLACE — Your Name] &nbsp;|&nbsp; **Student ID:** [REPLACE — Your Student ID] &nbsp;|&nbsp; **Set:** E


**Business question:** *Which support team should improve resolution
performance, and how does service quality vary by channel?*

Answered across four tools — Excel, SQL, Python, Power BI — using only the
two supplied source files: `tickets.csv` (13 rows, 1 intentional exact
duplicate) and `teams.csv` (4 rows). No data was added, removed beyond the
duplicate, or modified.

---

## Contents

1. [Dataset & data dictionary](#1-dataset--data-dictionary)
2. [Cleaning steps & metric definitions](#2-cleaning-steps--metric-definitions)
3. [Tools & versions](#3-tools--versions)
4. [Project structure](#4-project-structure)
5. [Quick start](#5-quick-start)
6. [SQL — run instructions](#6-sql--run-instructions)
7. [Python — run instructions](#7-python--run-instructions)
8. [Excel sheet guide](#8-excel-sheet-guide)
9. [Power BI — build & refresh](#9-power-bi--build--refresh)
10. [Findings & recommendation](#10-findings--recommendation)
11. [Cross-tool reconciliation](#11-cross-tool-reconciliation)
12. [Video](#12-video)
13. [Publishing this repo](#13-publishing-this-repo)
14. [References](#14-references)
15. [Authorship declaration](#15-authorship-declaration)

---

## 1. Dataset & data dictionary

Both files live in `data/raw/` and are never edited in place — every module
works from a *copy* with the duplicate removed, while the raw 13-row file
stays untouched for the before/after count.

**🎫 `tickets.csv`** — fact table, 13 rows (12 unique + 1 exact duplicate of `ticket_id 12`)

| Column | Type | Meaning |
|---|---|---|
| `ticket_id` | integer | Unique ticket identifier (duplicated once in the raw file) |
| `month` | text — ordered category, Jan → Feb → Mar | Month the ticket was logged |
| `team_id` | text | Foreign key → `teams.team_id` |
| `channel` | text — Email / Chat / Phone | Channel the ticket came in on |
| `resolution_hours` | numeric | Hours taken to resolve the ticket |
| `satisfaction` | numeric, 1–5 scale | Customer satisfaction rating |

**👥 `teams.csv`** — lookup table, 4 rows

| Column | Type | Meaning |
|---|---|---|
| `team_id` | text | Unique team identifier (primary key) |
| `team` | text | Team name |
| `department` | text — Service / Technical | Department the team belongs to |

## 2. Cleaning steps & metric definitions

| Step | Detail |
|---|---|
| 🧹 Duplicate removal | Row 13 of `tickets.csv` exactly duplicates `ticket_id 12`. Dropped in every module (Excel `Clean` sheet, SQL inserts, Python `drop_duplicates()`, Power BI `Table.Distinct`) → **12 unique records**. |
| 🚩 `breach_flag` | `1` if `resolution_hours > 24`, else `0`. **Exactly 24 hours meets the SLA — not a breach.** |
| 📐 SLA breach rate | breached tickets ÷ total tickets × 100, from underlying counts (never averaged subgroup percentages) |
| 🔢 Rounding | All rates/averages reported to **2 decimal places** |
| 🤝 Ties | Where two or more entities tie for highest/lowest, **all** tied entities are reported |

## 3. Tools & versions

| Tool | Version |
|---|---|
| Excel | Built with `openpyxl` 3.1.5, LibreOffice-verified — opens in Microsoft 365 / Excel 2019+ |
| SQL engine | **PostgreSQL 15** (dialect stated at the top of `sql/setup.sql`) |
| Python | 3.12 · `pandas` ≥2.0 · `matplotlib` ≥3.7 · `openpyxl` ≥3.1 (`requirements.txt`) |
| Power BI | Power BI Desktop (latest) — build files provided, see [§9](#9-power-bi--build--refresh) |
| License | MIT (`LICENSE`) |

## 4. Project structure

```
data-analysis-customer-support/
├── README.md
├── LICENSE
├── requirements.txt
├── .gitignore
│
├── data/raw/
│   ├── tickets.csv              13 raw rows (incl. duplicate), untouched
│   └── teams.csv                4 lookup rows
│
├── excel/
│   └── analysis.xlsx            Raw · Lookup · Clean · Summary sheets + chart, live formulas
│
├── sql/
│   ├── setup.sql                CREATE TABLE + INSERT (12 tickets, 4 teams)
│   └── queries.sql              S2a, S2b, S2c + LEFT JOIN diagnostic
│
├── python/
│   └── analysis.py              Load → clean → merge → derive → chart → export
│
├── powerbi/
│   ├── power_query.m            M code for both queries
│   ├── measures.dax             All required DAX measures
│   ├── build_guide.md           Step-by-step guide to produce dashboard.pbix
│   └── dashboard.pbix           ⚠️ you build this — see §9
│
└── outputs/
    ├── clean_data.csv           12-row merged clean dataset (Python)
    ├── python_summary.csv       Department breach-rate summary (Python)
    ├── python_chart.png         Monthly avg resolution_hours chart (Python)
    ├── powerbi_dashboard.png    ⚠️ you add this screenshot — see §9
    └── sql/
        ├── s2a_avg_resolution_by_department.csv
        ├── s2b_teams_breaching_sla.csv
        └── s2c_top_two_channels.csv
```

## 5. Quick start

```bash
git clone https://github.com/<you>/data-analysis-set-e-<your-id>.git
cd data-analysis-set-e-<your-id>
pip install -r requirements.txt
python python/analysis.py                          # → outputs/*.csv, outputs/python_chart.png
psql -U <user> -d <db> -f sql/setup.sql             # → creates + loads teams, tickets
psql -U <user> -d <db> -f sql/queries.sql           # → S2a, S2b, S2c + diagnostic
open excel/analysis.xlsx                            # Excel / LibreOffice — formulas live
```

## 6. SQL — run instructions

Dialect: **PostgreSQL 15**, stated as a comment at the top of `setup.sql`.

```bash
psql -U <user> -d <database> -f sql/setup.sql       # tables + 4 + 12 rows
psql -U <user> -d <database> -f sql/queries.sql      # diagnostic, then S2a → S2b → S2c
```

Run `setup.sql` **first**. The three labeled result sets are pre-saved under
`outputs/sql/`.

## 7. Python — run instructions

```bash
pip install -r requirements.txt
python python/analysis.py
```

Paths are relative to the **repository root** (`data/raw/tickets.csv`), so
run it as `python python/analysis.py` from the repo root — not from inside
`python/`. It asserts a clean 12-row merge with zero unmatched `team_id`
values, prints the department summary and every team tied for the highest
breach rate, then saves `outputs/clean_data.csv`, `outputs/python_summary.csv`,
`outputs/python_chart.png`.

## 8. Excel sheet guide

| Sheet | Contents |
|---|---|
| `Raw` | Original 13-row `tickets.csv`, unchanged |
| `Lookup` | 4-row `teams.csv`, unchanged |
| `Clean` | 12-row deduplicated tickets + `department` (`INDEX/MATCH` on `team_id`) + `breach_flag` (`=IF(E2>24,1,0)`) |
| `Summary` | Before/after row counts, SLA-breach-by-channel table (`COUNTIFS`), a formula-driven department × month average-resolution table, and a column chart built from it |

All formulas are live — open the file and every value recalculates.
`INDEX/MATCH` is used instead of `XLOOKUP` because this file was
recalculated with LibreOffice, which cannot evaluate `XLOOKUP`; the result
is identical and fully editable in Excel. A native, interactive Excel
PivotTable can't be authored by script — it's built from a live PivotCache
inside Excel itself — so `Summary!F5:I7` carries a formula-equivalent table
(`AVERAGEIFS`) instead, with a note on the two clicks to convert it to a
real PivotTable (select `Clean!A1:H13` → Insert → PivotTable) if needed.

## 9. Power BI — build & refresh

`powerbi/power_query.m` + `powerbi/measures.dax` have everything needed;
`powerbi/build_guide.md` walks through the exact steps. **This environment
cannot run Power BI Desktop** (Windows-only GUI app), so `dashboard.pbix`
and `outputs/powerbi_dashboard.png` are the two files you'll need to
produce yourself — it takes a few minutes following the guide.

**Refreshing on another machine:** the Power Query sources use
`File.Contents("C:\path\to\...\data\raw\tickets.csv")` (and `teams.csv`).
After cloning, open Power Query Editor → click the source step → update the
path to `<your-local-clone-path>\data\raw\tickets.csv` (and `teams.csv`) →
Close & Apply.

## 10. Findings & recommendation

*(12-row clean dataset; SLA breach = `resolution_hours > 24`)*

**🔴 Finding 1 — Team performance (tie reported):** BillingHelp (T2) and
AppSupport (T3) are **tied** for worst SLA breach rate at **66.67%** each
(2 of 3 tickets breached; avg resolution 26.67h and 28.67h). DeviceHelp
(T4) breaches 33.33% (1 of 3); AccountCare (T1) breaches 0% (0 of 3).

**🟡 Finding 2 — Channel performance:** Chat is worst (3 of 4 breached,
75.00%), Phone is next (2 of 4, 50.00%), Email had zero breaches across
all 4 tickets (0.00%).

**✅ Recommendation:** Prioritize a resolution-time review for BillingHelp
and AppSupport specifically — not just "the Technical department" broadly,
since Service-team BillingHelp performs just as poorly — and investigate
why Chat tickets run long: the two slowest Chat resolutions (40h, 32h) also
carry the lowest satisfaction scores in the dataset (2, 3).

**⚠️ Limitation:** each team has only 3 tickets and each channel only 4 in
this 12-row sample — directional, not statistically significant.

## 11. Cross-tool reconciliation

**Aggregate: overall SLA breach rate** (all 12 clean tickets, unfiltered)
= 5 breached ÷ 12 total × 100 = **41.67%**

| Tool | Where shown | Value |
|---|---|---|
| Excel | `Summary` — sum of channel `COUNTIFS` (3+2+0=5) ÷ After row count (12) | 41.67% |
| SQL | Sum of `s2c_top_two_channels.csv` (3+2=5; Email's 0 isn't top-2) ÷ 12 loaded rows | 41.67% |
| Python | Sum of `breached_tickets` in `python_summary.csv` (3+2=5) ÷ 12 | 41.67% |
| Power BI | `[SLA Breach Rate]` KPI card, unfiltered — build per §9 | 41.67% |

No rounding differences: 5⁄12 = 0.41666… → 41.67% identically everywhere.

## 12. Video

**URL:** [REPLACE — unlisted YouTube / Google Drive link, "Anyone with the link" view access]
**Duration:** [REPLACE — mm:ss, 5–10 minutes]

*(This is a face-and-screen webcam recording only you can make — it isn't
produced as part of this file set. Cover: intro + business question →
duplicate-row handling → Excel `INDEX/MATCH` + `breach_flag` + pivot table
→ one live SQL query → Python merge assertion + `breach_flag` + chart →
Power BI DAX measure + channel slicer → close with 2 findings, 1
recommendation, 1 limitation, repo structure.)*

## 13. Publishing this repo

```bash
cd data-analysis-customer-support
git init
git add .
git commit -m "Initial commit: Customer Support Quality Analysis (Set E)"
git remote add origin https://github.com/<you>/data-analysis-set-e-<your-id>.git
git branch -M main
git push -u origin main
git rev-parse HEAD   # record this hash in your submission message
```

Confirm the repo opens while **signed out** of GitHub before submitting.

## 14. References

No external code or datasets were used beyond the supplied `tickets.csv`
and `teams.csv`.

## 15. Authorship declaration

All work in this repository is my own except where cited.
