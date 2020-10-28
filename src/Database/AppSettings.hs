{-# LANGUAGE OverloadedStrings #-}
module Database.AppSettings
  ( AppSettings(..)
  , getSettings
  , updateSettings
  )
where

import           Database.SQLite.Simple

newtype AppSettings = AppSettings {markReadOnNextPage :: Bool} deriving (Show)

instance FromRow AppSettings where
  fromRow = AppSettings <$> field

getSettings :: Connection -> IO AppSettings
getSettings conn =
  head <$> query_ conn "SELECT mark_read_on_next_page FROM settings"

updateSettings :: Connection -> AppSettings -> IO ()
updateSettings conn appSettings = execute
  conn
  "UPDATE settings SET mark_read_on_next_page=? WHERE id=1"
  [markReadOnNextPage appSettings]
