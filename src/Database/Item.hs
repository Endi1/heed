{-# LANGUAGE OverloadedStrings #-}

module Database.Item (ItemData (..), refreshFeedItems, getAllItems, markItemAsRead) where

import Controllers.Item (readRemoteFeedItems)
import Data.Text
import Database.Feed
import Database.SQLite.Simple
import GHC.List
import Text.Feed.Query
import Text.Feed.Types

data ItemData = ItemData
  { id :: Integer,
    name :: Text,
    item_url :: Text,
    date_published :: Maybe Text,
    author :: Maybe Text,
    feed_id :: Integer,
    summary :: Maybe Text,
    description :: Maybe Text,
    is_read :: Bool
  }
  deriving (Show)

type InsertableItem = (Maybe Text, Maybe Text, Maybe Text, Maybe Text, Integer, Maybe Text, Maybe Text)

instance FromRow ItemData where
  fromRow = ItemData <$> field <*> field <*> field <*> field <*> field <*> field <*> field <*> field <*> field

getAllItems :: Connection -> IO [ItemData]
getAllItems conn = query_ conn "SELECT * FROM items ORDER BY date_published ASC" :: IO [ItemData]

refreshFeedItems :: Connection -> Integer -> IO ()
refreshFeedItems conn feedId = do
  (feed : feeds) <- getFeed conn feedId
  items <- readRemoteFeedItems $ feed_url feed
  executeMany conn "INSERT OR IGNORE INTO items (name, item_url, date_published, author, feed_id, summary, description, is_read) VALUES (?, ?, ?, ?, ?, ?, ?, 0)" (Prelude.map ((\a -> a feedId) . tuplefyItem) items)
  where
    tuplefyItem :: Item -> Integer -> InsertableItem
    tuplefyItem item feedId = (getItemTitle item, getItemLink item, getItemPublishDateString item, getItemAuthor item, feedId, getItemSummary item, getItemDescription item)

markItemAsRead :: Connection -> Integer -> IO ()
markItemAsRead conn item_id = do
  execute conn "UPDATE items SET is_read=1 WHERE id=?" [item_id]