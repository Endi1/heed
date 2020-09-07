{-# LANGUAGE DataKinds #-}
{-# LANGUAGE OverloadedStrings #-}

module Database.Feed (FeedData (..), insertNewFeed, getAllFeeds, getFeed) where

import Controllers.RequestHelpers (buildUrl, makeRequestToFeed)
import Data.ByteString (ByteString)
import Data.ByteString.Lazy (fromStrict)
import Data.Foldable (forM_)
import Data.Int (Int64)
import Data.Text (Text)
import Database.SQLite.Simple
  ( Connection,
    FromRow (..),
    Only (..),
    execute,
    field,
    lastInsertRowId,
    query,
    query_,
  )
import Text.Feed.Import (parseFeedSource)
import Text.Feed.Query (getFeedTitle)

data FeedData = FeedData {id :: Integer, title :: Text, feed_url :: Text} deriving (Show)

instance FromRow FeedData where
  fromRow = FeedData <$> field <*> field <*> field

insertNewFeed :: Connection -> Text -> Text -> IO Int64
insertNewFeed conn title url = do
  execute conn "INSERT OR IGNORE INTO feeds (title, feed_url) VALUES (?, ?)" (title, url)
  rowId <- lastInsertRowId conn
  case rowId of
    0 -> do
      (x : xs) <- query conn "SELECT id FROM feeds WHERE feed_url = ?" (Only url) :: IO [Only Int64]
      return $ fromOnly x
    _ -> return rowId

getAllFeeds :: Connection -> IO [FeedData]
getAllFeeds conn = query_ conn "SELECT * FROM feeds" :: IO [FeedData]

getFeed :: Connection -> Integer -> IO [FeedData]
getFeed conn feedId = query conn "SELECT * FROM FEEDS WHERE id=?" (Only feedId)