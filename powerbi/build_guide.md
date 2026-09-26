# Building dashboard.pbix

This environment cannot run Power BI Desktop, and `.pbix` is a
proprietary binary format with no reliable way to author it from a
script — so this folder contains everything needed to build it
yourself in a few minutes, rather than a fake or broken `.pbix` file.

## Steps

1. **Open Power BI Desktop** → Get Data → Blank Query (or Text/CSV,
   then switch to Advanced Editor) → paste in the `tickets` query
   from `power_query.m`, then repeat for `teams`. Update the file
   paths to point at `data/raw/tickets.csv` and `data/raw/teams.csv`.
   Close & Apply.

2. **Data model**: In Model view, drag `teams[team_id]` onto
   `tickets[team_id]` to create the relationship. Set it to
   **one-to-many, single direction, filtering from teams to tickets**
   (this is the default Power BI proposes for this shape).

3. **Measures table**: Model view → New Table → enter
   `Measures = {BLANK()}` to create an empty table to hold the
   measures cleanly. Then Home → New Measure for each formula in
   `measures.dax`.

4. **Dashboard page** — add these visuals to one page:
   - Card: `[Ticket Count]`
   - Card: `[Avg Satisfaction]`
   - Card: `[SLA Breach Rate]` (format as percentage)
   - Clustered column chart: Axis = `teams[department]`,
     Values = `[SLA Breach Rate]` (or `[Avg Satisfaction]`)
   - Line chart: Axis = `tickets[month]`, Values = average of
     `tickets[resolution_hours]`. Sort the axis by the `Month Sort`
     measure/column (or the `month_sort` helper column from the
     query) so it reads Jan → Feb → Mar instead of alphabetically.
   - Slicer: `tickets[channel]` — set to filter all visuals on the
     page (default behavior; no extra config needed).

5. **Save as** `dashboard.pbix` in this `powerbi/` folder.

## What's already done for you
- `power_query.m` — the exact M code for both queries, including
  the duplicate-removal step (13 → 12 rows) and the `breach_flag`
  / `month_sort` helper columns.
- `measures.dax` — all three required DAX measures plus an optional
  `Month Sort` helper measure.
