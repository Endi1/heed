{-# LANGUAGE OverloadedStrings #-}
module Database.Init where

import Database.SQLite.Simple

-- The statements to run in order to build the database the first time.
statements :: [Query]
statements = [
    "CREATE TABLE IF NOT EXISTS feeds (id INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT NOT NULL, feed_url TEXT UNIQUE)",
    "CREATE TABLE IF NOT EXISTS items (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL, item_url TEXT UNIQUE, date_published TEXT, author TEXT, feed_id INTEGER NOT NULL, summary TEXT, description TEXT)"
    ]

-- Run the initializing statements.
initDatabase :: Connection -> IO ()
initDatabase conn = mapM_ (execute_ conn) statements