CREATE TABLE IF NOT EXISTS settings (
    id INTEGER PRIMARY KEY CHECK (id = 1),
    mark_read_on_next_page INTEGER NOT NULL DEFAULT 0
);
INSERT
    OR IGNORE INTO settings (mark_read_on_next_page)
VALUES (0);