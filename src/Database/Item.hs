{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE QuasiQuotes       #-}

module Database.Item
  ( ItemData(..)
  , refreshFeedItems
  , markItemAsRead
  , getItems
  )
where

import           Controllers.Item               ( readRemoteFeedItems )
import           Data.Maybe                     ( isNothing )
import           Data.Text                      ( Text
                                                , pack
                                                , unpack
                                                )
import           Data.Time.Clock                ( UTCTime(..) )
import           Data.Time.Format               ( defaultTimeLocale
                                                , parseTimeM
                                                )
import           Database.Feed                  ( FeedData(feed_url)
                                                , getFeed
                                                )
import           Database.SQLite.Simple         ( Connection
                                                , FromRow(..)
                                                , Only(Only)
                                                , execute
                                                , executeMany
                                                , field
                                                , query
                                                , query_
                                                )
import           Database.SQLite.Simple.QQ      ( sql )
import           Text.Feed.Query                ( getItemAuthor
                                                , getItemDescription
                                                , getItemLink
                                                , getItemPublishDateString
                                                , getItemSummary
                                                , getItemTitle
                                                )
import           Text.Feed.Types                ( Item )

data ItemData = ItemData
  { id             :: Integer,
    name           :: Text,
    item_url       :: Text,
    date_published :: Maybe Text,
    author         :: Maybe Text,
    feed_id        :: Integer,
    summary        :: Maybe Text,
    description    :: Maybe Text,
    is_read        :: Bool,
    feed_title     :: Text
  }
  deriving (Show)

type InsertableItem
  = ( Maybe Text
    , Maybe Text
    , Maybe Text
    , Maybe Text
    , Integer
    , Maybe Text
    , Maybe Text
    )

instance FromRow ItemData where
  fromRow =
    ItemData
      <$> field
      <*> field
      <*> field
      <*> field
      <*> field
      <*> field
      <*> field
      <*> field
      <*> field
      <*> field

type ShowAll = Bool

type FeedID = Integer

getItems :: Connection -> Maybe FeedID -> ShowAll -> IO [ItemData]
getItems conn Nothing       True  = getAllItems conn
getItems conn Nothing       False = getUnreadItems conn
getItems conn (Just feedID) False = getUnreadItemsForFeed conn feedID
getItems conn (Just feedID) True  = getItemsForFeed conn feedID

getItemsForFeed :: Connection -> Integer -> IO [ItemData]
getItemsForFeed conn feedID = query
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
        feeds.title FROM items INNER JOIN feeds ON items.feed_id=feeds.id WHERE items.feed_id=? AND items.deleted=0 ORDER BY items.date_published DESC
|]
  (Only feedID)

getUnreadItemsForFeed :: Connection -> Integer -> IO [ItemData]
getUnreadItemsForFeed conn feedID = query
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
        feeds.title FROM items INNER JOIN feeds ON items.feed_id=feeds.id WHERE items.feed_id=? AND items.deleted=0 AND items.is_read=0 ORDER BY items.date_published DESC
|]
  (Only feedID)

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
        feeds.title FROM items INNER JOIN feeds ON items.feed_id=feeds.id WHERE items.deleted=0 ORDER BY items.date_published DESC
|] :: IO
      [ItemData]

getUnreadItems :: Connection -> IO [ItemData]
getUnreadItems conn =
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
        feeds.title FROM items INNER JOIN feeds ON items.feed_id=feeds.id WHERE items.deleted=0 AND items.is_read=0 ORDER BY items.date_published DESC
|] :: IO
      [ItemData]

refreshFeedItems :: Connection -> Integer -> IO ()
refreshFeedItems conn feedId = do
  (feed : _) <- getFeed conn feedId
  items      <- readRemoteFeedItems $ feed_url feed
  executeMany
    conn
    "INSERT OR IGNORE INTO items (name, item_url, date_published, author, feed_id, summary, description, is_read, deleted) VALUES (?, ?, ?, ?, ?, ?, ?, 0, 0)"
    (Prelude.map ((\a -> a feedId) . tuplefyItem) items)
  execute
    conn
    "DELETE FROM TABLE items WHERE is_read=1 AND date_published < (SELECT DATETIME('now', '-30 day')) AND feed_id=?"
    [feedId]
 where
  tuplefyItem :: Item -> Integer -> InsertableItem
  tuplefyItem item feedId =
    ( getItemTitle item
    , getItemLink item
    , textUTCTime $ dateToUTC $ getItemPublishDateString item
    , getItemAuthor item
    , feedId
    , getItemSummary item
    , getItemDescription item
    )

  textUTCTime :: Maybe UTCTime -> Maybe Text
  textUTCTime Nothing    = Nothing
  textUTCTime (Just utc) = Just (pack $ show utc)

dateToUTC :: Maybe Text -> Maybe UTCTime
dateToUTC Nothing = Nothing
dateToUTC (Just datestring) =
  let
    formats =
      ["%a, %d %b %Y %H:%M:%S %z", "%Y-%m-%dT%H:%M:%S%z", "%Y-%m-%dT%H:%M:%SZ"]
    tries =
      map (\f -> parseTimeM False defaultTimeLocale f (unpack datestring))
          formats :: [Maybe UTCTime]
  in
    findJust tries
 where
  findJust :: [Maybe UTCTime] -> Maybe UTCTime
  findJust []       = Nothing
  findJust (x : xs) = if isNothing x then findJust xs else x

markItemAsRead :: Connection -> Integer -> IO ()
markItemAsRead conn item_id = do
  execute conn "UPDATE items SET is_read=1 WHERE id=?" [item_id]
