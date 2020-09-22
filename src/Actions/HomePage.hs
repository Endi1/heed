{-# LANGUAGE OverloadedStrings #-}

module Actions.HomePage (homePageGetAction, refreshFeedsPostAction, deleteFeedPostAction) where

import Actions.Types (Pagination (..))
import Actions.Utils (paginateItems)
import Database.Feed (FeedData (id), deleteFeed, getAllFeeds)
import Database.Item (ItemData, getAllItems, refreshFeedItems)
import Database.SQLite.Simple (Connection)
import Lucid.Base (renderText)
import Views.ItemList (itemListGetView)
import Web.Scotty (ActionM, html, liftAndCatchIO, param, rescue)

homePageGetAction :: Connection -> ActionM ()
homePageGetAction conn = do
  items <- liftAndCatchIO $ getAllItems conn
  feeds <- liftAndCatchIO $ getAllFeeds conn
  page <- rescue (param "page") (\t -> return 1)
  html $
    renderText $
      itemListGetView
        feeds
        (paginateItems items page)

refreshFeedsPostAction :: Connection -> ActionM ()
refreshFeedsPostAction conn = do
  feeds <- liftAndCatchIO $ getAllFeeds conn
  liftAndCatchIO $ mapM_ (refreshFeedItems conn . Database.Feed.id) feeds
  html "Ok"

deleteFeedPostAction :: Connection -> ActionM ()
deleteFeedPostAction conn = do
  feed_id <- param "feed_id"
  liftAndCatchIO $ deleteFeed conn feed_id
  html "Ok"