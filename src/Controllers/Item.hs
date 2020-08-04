{-# LANGUAGE KindSignatures #-}
{-# LANGUAGE DataKinds #-}
{-# LANGUAGE OverloadedStrings #-}

module Controllers.Item (getAllItems, ItemDBTuple) where

import Controllers.RequestHelpers (buildUrl, makeRequestToFeed)
import Data.ByteString.Lazy (fromStrict)
import Data.Foldable (forM_)
import Data.Int
import Data.Maybe (fromJust)
import Data.Text
import Database.SQLite.Simple
import Database.Types (ItemDB (..))
import GHC.List (concat)
import Network.HTTP.Req
import Text.Feed.Import (parseFeedSource)
import Text.Feed.Query
import qualified Text.Feed.Types as T (Feed, Item)

-- Represents the ID and url of the feed
type FeedDBTuple = (Integer, Text)

-- Represents the ID, original url, and title of the feed
type ItemDBTuple = (Integer, Text, Text)

getAllItems :: Connection -> IO [ItemDBTuple]
getAllItems conn = query_ conn "SELECT id, name, item_url FROM items" :: IO [ItemDBTuple]

refreshFeeds :: Connection -> IO ()
refreshFeeds conn = do
  feeds <- query_ conn "SELECT id, feed_url FROM feeds" :: IO [FeedDBTuple]
  items <- GHC.List.concat <$> mapM readRemoteItems feeds
  executeMany conn "INSERT OR IGNORE INTO items (name, item_url, date_published, author, feed_id, summary, description) VALUES (?, ?, ?, ?, ?, ?, ?)" items
  return ()

readRemoteItems :: FeedDBTuple -> IO [ItemDB]
readRemoteItems (feedId, feedUrl) = do
  maybeUrl <- buildUrl feedUrl
  remoteItems <- either readFeedItems readFeedItems (fromJust maybeUrl)
  return $ parseItems remoteItems feedId
  where
    readFeedItems :: Url s -> IO [T.Item]
    readFeedItems url = do
      feedResponseBody <- makeRequestToFeed url
      let maybeParseFeed = parseFeedSource $ fromStrict feedResponseBody
      case maybeParseFeed of
        Nothing -> return []
        Just feed -> return $ getFeedItems feed

parseItems :: [T.Item] -> Integer -> [ItemDB]
parseItems remoteItems feed_id = Prelude.map (`parseItem` feed_id) remoteItems
  where
    parseItem :: T.Item -> Integer -> ItemDB
    parseItem item feed_id =
      ItemDB
        { name = getItemTitle item,
          item_url = getItemLink item,
          date_published = getItemDate item,
          author = getItemAuthor item,
          feed_id = feed_id,
          summary = getItemSummary item,
          description = getItemDescription item
        }
