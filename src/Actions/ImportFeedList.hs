{-# LANGUAGE OverloadedStrings #-}
module Actions.ImportFeedList where

import           Actions.NewFeed
import           Controllers.Feed
import           Database.Feed
import           Database.Item
import           Database.SQLite.Simple
import           Web.Scotty
import           Data.Text
import qualified Data.Text.Lazy                as L
import           Text.Feed.Query

importFeedListPostAction :: Connection -> ActionM ()
importFeedListPostAction conn = do
  feedlist <- param "feedlist"
  let urls = splitOn " " $ L.toStrict feedlist
  liftAndCatchIO $ mapM_ (importFeedFromUrl conn) urls
  redirect "/"
