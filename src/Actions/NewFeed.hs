{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE OverloadedStrings #-}

module Actions.NewFeed (newFeedPostAction, newFeedGetAction) where

import Controllers.Feed
import Data.Text
import Database.Feed
import Database.Item
import Database.SQLite.Simple
import Lucid.Base (renderText)
import Views.NewFeed
import Text.Feed.Query
import Web.Scotty

newFeedGetAction :: ActionM ()
newFeedGetAction = html $ renderText newFeedView

newFeedPostAction :: Connection -> ActionM ()
newFeedPostAction conn = do
  feed_url :: Text <- param "feed_url"
  maybeFeed <- liftAndCatchIO $ readRemoteFeed feed_url
  case maybeFeed of
    Nothing -> raise "Not a valid atom/rss feed"
    Just feed -> do
      feedId <- liftAndCatchIO $ insertNewFeed conn (getFeedTitle feed) feed_url
      liftAndCatchIO $ refreshFeedItems conn $ toInteger feedId
      redirect "/"