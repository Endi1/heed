{-# LANGUAGE OverloadedStrings #-}

module Database.Item (ItemData (..), refreshFeedItems, getAllItems) where

import Controllers.Item (readRemoteFeedItems)
import Data.Text
import Database.Feed
import Database.SQLite.Simple
import GHC.List
import Text.Feed.Types
import Text.Feed.Query

data ItemData = ItemData
  { id :: Integer,
    name :: Text,
    item_url :: Text,
    date_published :: Maybe Text,
    author :: Maybe Text,
    feed_id :: Integer,
    summary :: Maybe Text,
    description :: Maybe Text
  }
  deriving (Show)

type InsertableItem = (Maybe Text, Maybe Text, Maybe Text, Maybe Text, Integer, Maybe Text, Maybe Text)

instance FromRow ItemData where
  fromRow = ItemData <$> field <*> field <*> field <*> field <*> field <*> field <*> field <*> field

getAllItems :: Connection -> IO [ItemData]
getAllItems conn = query_ conn "SELECT * FROM items" :: IO [ItemData]

refreshFeedItems :: Connection -> Integer -> IO ()
refreshFeedItems conn feedId = do
  (feed : feeds) <- getFeed conn feedId
  items <- readRemoteFeedItems $ feed_url feed
  executeMany conn "INSERT OR IGNORE INTO items (name, item_url, date_published, author, feed_id, summary, description) VALUES (?, ?, ?, ?, ?, ?, ?)" (Prelude.map ((\a -> a feedId) . tuplefyItem) items)
  where
    tuplefyItem :: Item -> Integer -> InsertableItem
    tuplefyItem item feedId = (getItemTitle item, getItemLink item, getItemPublishDateString item, getItemAuthor item, feedId, getItemSummary item, getItemDescription item)