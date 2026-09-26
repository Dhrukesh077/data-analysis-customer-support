// ============================================================
// Power Query M — paste into Power BI Desktop's Advanced Editor
// (Home -> Transform Data -> select query -> Advanced Editor)
// One query per table. Update the file paths to match where
// data/raw/tickets.csv and data/raw/teams.csv live on disk.
// ============================================================

// ---- Query: tickets ----
let
    Source = Csv.Document(
        File.Contents("C:\path\to\data-analysis-customer-support\data\raw\tickets.csv"),
        [Delimiter=",", Columns=6, Encoding=65001, QuoteStyle=QuoteStyle.None]
    ),
    PromotedHeaders = Table.PromoteHeaders(Source, [PromoteAllScalars=true]),
    SetTypes = Table.TransformColumnTypes(PromotedHeaders, {
        {"ticket_id", Int64.Type},
        {"month", type text},
        {"team_id", type text},
        {"channel", type text},
        {"resolution_hours", type number},
        {"satisfaction", type number}
    }),
    // Remove the exact duplicate row -> 13 rows become 12
    RemoveDuplicates = Table.Distinct(SetTypes),
    // SLA breach flag: exactly 24 hours is NOT a breach
    AddBreachFlag = Table.AddColumn(RemoveDuplicates, "breach_flag",
        each if [resolution_hours] > 24 then 1 else 0, Int64.Type),
    // Fix month sort order (Jan, Feb, Mar) via a helper index column
    AddMonthSort = Table.AddColumn(AddBreachFlag, "month_sort",
        each if [month] = "Jan" then 1 else if [month] = "Feb" then 2 else 3, Int64.Type)
in
    AddMonthSort


// ---- Query: teams ----
let
    Source = Csv.Document(
        File.Contents("C:\path\to\data-analysis-customer-support\data\raw\teams.csv"),
        [Delimiter=",", Columns=3, Encoding=65001, QuoteStyle=QuoteStyle.None]
    ),
    PromotedHeaders = Table.PromoteHeaders(Source, [PromoteAllScalars=true]),
    SetTypes = Table.TransformColumnTypes(PromotedHeaders, {
        {"team_id", type text},
        {"team", type text},
        {"department", type text}
    })
in
    SetTypes
