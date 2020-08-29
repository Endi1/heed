{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE QuasiQuotes #-}

module Database.Item (ItemData (..), refreshFeedItems, getAllItems, markItemAsRead, getItems) where

import Controllers.Item (readRemoteFeedItems)
import Data.Text
import Database.Feed
import Database.SQLite.Simple
import Database.SQLite.Simple.QQ
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
    is_read :: Bool,
    feed_title :: Text
  }
  deriving (Show)

type InsertableItem = (Maybe Text, Maybe Text, Maybe Text, Maybe Text, Integer, Maybe Text, Maybe Text)

instance FromRow ItemData where
  fromRow = ItemData <$> field <*> field <*> field <*> field <*> field <*> field <*> field <*> field <*> field <*> field

getItems :: Connection -> Maybe Integer -> IO [ItemData]
getItems conn Nothing = getAllItems conn
getItems conn (Just f_id) = getItemsForFeed conn f_id

getItemsForFeed :: Connection -> Integer -> IO [ItemData]
getItemsForFeed conn f_id =
  query
    conn
    [sql|
      SELECT 
        items.id, 
        items.name, 
        items.item_url, 
        items.date_published, 
        items.author, 
        items.feed_id, 
        items.summary, 
        items.description, 
        items.is_read, 
        feeds.title FROM items INNER JOIN feeds ON items.feed_id=feeds.id WHERE items.feed_id=?
|]
    (Only f_id)

getAllItems :: Connection -> IO [ItemData]
getAllItems conn =
  query_
    conn
    [sql|
      SELECT 
        items.id, 
        items.name, 
        items.item_url, 
        items.date_published, 
        items.author, 
        items.feed_id, 
        items.summary, 
        items.description, 
        items.is_read, 
        feeds.title FROM items INNER JOIN feeds ON items.feed_id=feeds.id
|] ::
    IO [ItemData]

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