-- ============================================================
-- queries.sql
-- Customer Support Quality Data Analysis
-- Dialect: PostgreSQL 15
-- Run after setup.sql has created and populated teams/tickets.
-- ============================================================

-- ------------------------------------------------------------
-- Diagnostic: LEFT JOIN check for unmatched team_id values
-- (tickets whose team_id has no matching row in teams)
-- Expected: 0 rows, since the foreign key already enforces this
-- for any data that loaded successfully.
-- ------------------------------------------------------------
SELECT
    t.ticket_id,
    t.team_id AS ticket_team_id,
    tm.team_id AS matched_team_id
FROM tickets t
LEFT JOIN teams tm ON t.team_id = tm.team_id
WHERE tm.team_id IS NULL;


-- ------------------------------------------------------------
-- Q2A: Average resolution_hours by department, highest to lowest
-- ------------------------------------------------------------
SELECT
    tm.department,
    ROUND(AVG(t.resolution_hours), 2) AS avg_resolution_hours
FROM tickets t
JOIN teams tm ON t.team_id = tm.team_id
GROUP BY tm.department
ORDER BY avg_resolution_hours DESC;


-- ------------------------------------------------------------
-- Q2B: Teams whose average resolution_hours is greater than 24
-- (GROUP BY + HAVING)
-- ------------------------------------------------------------
SELECT
    tm.team_id,
    tm.team,
    ROUND(AVG(t.resolution_hours), 2) AS avg_resolution_hours
FROM tickets t
JOIN teams tm ON t.team_id = tm.team_id
GROUP BY tm.team_id, tm.team
HAVING AVG(t.resolution_hours) > 24
ORDER BY avg_resolution_hours DESC;


-- ------------------------------------------------------------
-- Q2C: Top 2 channels by number of SLA-breached tickets
-- (breach = resolution_hours > 24; exactly 24 is not a breach)
-- Ties broken alphabetically by channel.
-- ------------------------------------------------------------
SELECT
    t.channel,
    COUNT(*) AS breached_tickets
FROM tickets t
WHERE t.resolution_hours > 24
GROUP BY t.channel
ORDER BY breached_tickets DESC, t.channel ASC
LIMIT 2;
