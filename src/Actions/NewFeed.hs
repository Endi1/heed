{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE ScopedTypeVariables #-}

module Actions.NewFeed (newFeedPostAction, newFeedGetAction) where

import Controllers.Feed (readRemoteFeed)
import Data.Text (Text)
import Database.Feed (insertNewFeed)
import Database.Item (refreshFeedItems)
import Database.SQLite.Simple (Connection)
import Lucid.Base (renderText)
import Text.Feed.Query (getFeedTitle)
import Views.NewFeed (newFeedView)
import Web.Scotty
  ( ActionM,
    html,
    liftAndCatchIO,
    param,
    raise,
    redirect,
  )

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