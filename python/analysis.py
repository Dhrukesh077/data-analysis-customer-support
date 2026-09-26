"""
Customer Support Quality Data Analysis
---------------------------------------
Loads tickets.csv and teams.csv, cleans the tickets data (removes the
one exact duplicate), joins on team_id, computes SLA breach flags,
and answers:
  1. Which support team needs improvement in resolution performance?
  2. How does service quality vary by channel?

Run from the repository root (paths are relative to the repo root,
per spec, so the script works unmodified on another machine):
    python python/analysis.py
"""

import os
import pandas as pd
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt

# ------------------------------------------------------------------
# Paths (relative to the repository root — run this script as
# `python python/analysis.py` from the repo root, not from inside
# the python/ folder)
# ------------------------------------------------------------------
DATA_DIR = os.path.join("data", "raw")
OUT_DIR = "outputs"
os.makedirs(OUT_DIR, exist_ok=True)

TICKETS_PATH = os.path.join(DATA_DIR, "tickets.csv")
TEAMS_PATH = os.path.join(DATA_DIR, "teams.csv")

MONTH_ORDER = ["Jan", "Feb", "Mar"]
SLA_THRESHOLD_HOURS = 24  # exactly 24 is NOT a breach


def load_data():
    tickets = pd.read_csv(TICKETS_PATH)
    teams = pd.read_csv(TEAMS_PATH)
    return tickets, teams


def confirm_numeric_types(tickets: pd.DataFrame) -> pd.DataFrame:
    tickets["ticket_id"] = tickets["ticket_id"].astype(int)
    tickets["resolution_hours"] = pd.to_numeric(tickets["resolution_hours"])
    tickets["satisfaction"] = pd.to_numeric(tickets["satisfaction"])
    assert pd.api.types.is_integer_dtype(tickets["ticket_id"])
    assert pd.api.types.is_numeric_dtype(tickets["resolution_hours"])
    assert pd.api.types.is_numeric_dtype(tickets["satisfaction"])
    return tickets


def remove_exact_duplicate(tickets: pd.DataFrame) -> pd.DataFrame:
    before = len(tickets)
    clean = tickets.drop_duplicates().reset_index(drop=True)
    after = len(clean)
    print(f"Raw rows: {before} -> Clean rows (duplicate removed): {after}")
    assert before == 13, f"Expected 13 raw rows, got {before}"
    assert after == 12, f"Expected 12 clean rows, got {after}"
    return clean


def merge_with_teams(clean: pd.DataFrame, teams: pd.DataFrame) -> pd.DataFrame:
    merged = clean.merge(teams, on="team_id", how="left")
    assert len(merged) == 12, f"Merged dataset should have 12 rows, has {len(merged)}"
    unmatched = merged["department"].isna().sum()
    assert unmatched == 0, f"{unmatched} rows have no matching department"
    print("Merge OK: 12 rows, no unmatched department values.")
    return merged


def add_breach_flag(merged: pd.DataFrame) -> pd.DataFrame:
    merged = merged.copy()
    merged["breach_flag"] = (merged["resolution_hours"] > SLA_THRESHOLD_HOURS).astype(int)
    return merged


def department_summary(merged: pd.DataFrame) -> pd.DataFrame:
    grp = merged.groupby("department").agg(
        total_tickets=("ticket_id", "count"),
        breached_tickets=("breach_flag", "sum"),
    ).reset_index()
    grp["sla_breach_rate_pct"] = (grp["breached_tickets"] / grp["total_tickets"] * 100).round(2)
    grp = grp.sort_values("sla_breach_rate_pct", ascending=False).reset_index(drop=True)
    return grp


def team_breach_rates(merged: pd.DataFrame):
    grp = merged.groupby(["team_id", "team"]).agg(
        total_tickets=("ticket_id", "count"),
        breached_tickets=("breach_flag", "sum"),
    ).reset_index()
    grp["sla_breach_rate_pct"] = (grp["breached_tickets"] / grp["total_tickets"] * 100).round(2)
    grp = grp.sort_values("sla_breach_rate_pct", ascending=False).reset_index(drop=True)
    # Report ALL tied entities at the max rate, not just the first row
    max_rate = grp["sla_breach_rate_pct"].max()
    worst = grp[grp["sla_breach_rate_pct"] == max_rate]
    return grp, worst


def monthly_resolution_chart(merged: pd.DataFrame, out_path: str):
    pivot = (
        merged.groupby(["month", "department"])["resolution_hours"]
        .mean()
        .unstack("department")
        .reindex(MONTH_ORDER)
    )
    ax = pivot.plot(kind="bar", figsize=(7, 4.5))
    ax.set_title("Average Resolution Hours by Month and Department")
    ax.set_xlabel("Month")
    ax.set_ylabel("Avg Resolution Hours")
    ax.set_xticklabels(MONTH_ORDER, rotation=0)
    plt.tight_layout()
    plt.savefig(out_path, dpi=150)
    plt.close()
    print(f"Saved chart -> {out_path}")


def main():
    tickets, teams = load_data()
    tickets = confirm_numeric_types(tickets)
    clean = remove_exact_duplicate(tickets)
    merged = merge_with_teams(clean, teams)
    merged = add_breach_flag(merged)

    dept_summary = department_summary(merged)
    team_rates, worst_teams = team_breach_rates(merged)

    print("\n=== Department summary ===")
    print(dept_summary.to_string(index=False))

    print("\n=== Team SLA breach rates ===")
    print(team_rates.to_string(index=False))

    print("\nTeam(s) needing the most improvement (highest breach rate, ties reported):")
    for _, row in worst_teams.iterrows():
        print(
            f"  - {row['team']} ({row['team_id']}) — {int(row['breached_tickets'])} of "
            f"{int(row['total_tickets'])} tickets breached ({row['sla_breach_rate_pct']:.2f}%)."
        )

    # Outputs
    clean_merged_path = os.path.join(OUT_DIR, "clean_data.csv")
    merged.to_csv(clean_merged_path, index=False)
    print(f"\nSaved clean merged data -> {clean_merged_path}")

    summary_path = os.path.join(OUT_DIR, "python_summary.csv")
    dept_summary.to_csv(summary_path, index=False)
    print(f"Saved department summary -> {summary_path}")

    chart_path = os.path.join(OUT_DIR, "python_chart.png")
    monthly_resolution_chart(merged, chart_path)


if __name__ == "__main__":
    main()
