CREATE TABLE IF NOT EXISTS items (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    item_url TEXT UNIQUE,
    date_published TEXT,
    author TEXT,
    feed_id INTEGER NOT NULL,
    summary TEXT,
    description TEXT
)