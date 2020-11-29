{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE QuasiQuotes       #-}
module Database.Init
  ( initTables
  )
where

import           Database.SQLite.Simple
import           Database.SQLite.Simple.QQ      ( sql )

initTables :: Connection -> IO ()
initTables conn =
  initFeedsTable conn >> initItemsTable conn >> initSettingsTable conn

initFeedsTable :: Connection -> IO ()
initFeedsTable conn = execute_
  conn
  [sql|
    CREATE TABLE IF NOT EXISTS feeds (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    title TEXT NOT NULL,
    feed_url TEXT UNIQUE
)|]

initItemsTable :: Connection -> IO ()
initItemsTable conn = execute_
  conn
  [sql|CREATE TABLE IF NOT EXISTS items (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    item_url TEXT UNIQUE,
    date_published TEXT,
    author TEXT,
    feed_id INTEGER NOT NULL,
    summary TEXT,
    description TEXT,
    is_read INTEGER,
    deleted INTEGER
)|]

initSettingsTable :: Connection -> IO ()
initSettingsTable conn = execute_
  conn
  [sql|CREATE TABLE IF NOT EXISTS settings (
    id INTEGER PRIMARY KEY CHECK (id = 1),
    mark_read_on_next_page INTEGER NOT NULL DEFAULT 0
);
INSERT
    OR IGNORE INTO settings (mark_read_on_next_page)
VALUES (0);
|]
