-- ============================================================
-- setup.sql
-- Customer Support Quality Data Analysis
--
-- Dialect: PostgreSQL 15 (uses NUMERIC, CHECK constraints, and
-- standard SQL:2016 syntax; also runs unchanged on PostgreSQL 13+).
-- ============================================================

DROP TABLE IF EXISTS tickets;
DROP TABLE IF EXISTS teams;

-- ------------------------------------------------------------
-- teams: 4 rows, one per support team
-- ------------------------------------------------------------
CREATE TABLE teams (
    team_id     VARCHAR(10)  PRIMARY KEY,
    team        VARCHAR(50)  NOT NULL,
    department  VARCHAR(50)  NOT NULL
);

-- ------------------------------------------------------------
-- tickets: 12 clean rows (exact duplicate of ticket_id 12 removed)
-- team_id is a foreign key to teams(team_id)
-- ------------------------------------------------------------
CREATE TABLE tickets (
    ticket_id         INTEGER        PRIMARY KEY,
    month             VARCHAR(3)     NOT NULL CHECK (month IN ('Jan','Feb','Mar')),
    team_id           VARCHAR(10)    NOT NULL,
    channel           VARCHAR(10)    NOT NULL CHECK (channel IN ('Email','Chat','Phone')),
    resolution_hours  NUMERIC(6,2)   NOT NULL,
    satisfaction      NUMERIC(3,1)   NOT NULL CHECK (satisfaction BETWEEN 1 AND 5),
    CONSTRAINT fk_tickets_team
        FOREIGN KEY (team_id) REFERENCES teams(team_id)
);

-- ------------------------------------------------------------
-- Load teams (4 rows)
-- ------------------------------------------------------------
INSERT INTO teams (team_id, team, department) VALUES
    ('T1', 'AccountCare', 'Service'),
    ('T2', 'BillingHelp', 'Service'),
    ('T3', 'AppSupport',  'Technical'),
    ('T4', 'DeviceHelp',  'Technical');

-- ------------------------------------------------------------
-- Load tickets (12 clean rows; duplicate ticket_id 12 removed)
-- ------------------------------------------------------------
INSERT INTO tickets (ticket_id, month, team_id, channel, resolution_hours, satisfaction) VALUES
    (1,  'Jan', 'T1', 'Email', 12, 4),
    (2,  'Jan', 'T2', 'Chat',  28, 3),
    (3,  'Jan', 'T3', 'Phone', 36, 2),
    (4,  'Jan', 'T4', 'Email', 20, 4),
    (5,  'Feb', 'T1', 'Chat',   8, 5),
    (6,  'Feb', 'T2', 'Phone', 30, 3),
    (7,  'Feb', 'T3', 'Email', 18, 4),
    (8,  'Feb', 'T4', 'Chat',  40, 2),
    (9,  'Mar', 'T1', 'Phone', 16, 4),
    (10, 'Mar', 'T2', 'Email', 22, 4),
    (11, 'Mar', 'T3', 'Chat',  32, 3),
    (12, 'Mar', 'T4', 'Phone', 24, 5);

-- Sanity checks (informational only, not part of the schema)
-- SELECT COUNT(*) FROM teams;    -- expect 4
-- SELECT COUNT(*) FROM tickets;  -- expect 12
