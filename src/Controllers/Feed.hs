{-# LANGUAGE DataKinds #-}
{-# LANGUAGE OverloadedStrings #-}

module Controllers.Feed (insertNewFeed) where

import Controllers.RequestHelpers (buildUrl, makeRequestToFeed)
import Data.ByteString (ByteString)
import Data.ByteString.Lazy (fromStrict)
import Data.Text
import Data.Foldable (forM_)
import Database.SQLite.Simple
import Database.Types (FeedDB (..))
import Network.HTTP.Req
import Text.Feed.Import (parseFeedSource)
import Text.Feed.Query (getFeedTitle)

insertNewFeed :: Connection -> Text -> IO ()
insertNewFeed conn u = do
  urlMaybe <- buildUrl u
  forM_ urlMaybe (either parseAndInsertFeed parseAndInsertFeed)
  where
    parseAndInsertFeed :: Url s -> IO ()
    parseAndInsertFeed url = getFeed url >>= mapM_ insertFeedFunc

    insertFeedFunc :: FeedDB -> IO ()
    insertFeedFunc = execute conn "INSERT OR IGNORE INTO feeds (title, feed_url) VALUES (?, ?)"

getFeed :: Url s -> IO (Maybe FeedDB)
getFeed url = do
  feedResponseBody <- makeRequestToFeed url
  let maybeParsedFeed = parseFeedSource $ fromStrict feedResponseBody
  case maybeParsedFeed of
    Nothing -> return Nothing
    Just parsedFeed -> return $ Just FeedDB {title = getFeedTitle parsedFeed, feed_url = renderUrl url}
