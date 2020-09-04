{-# LANGUAGE OverloadedStrings #-}

module Actions.HomePage (homePageGetAction, refreshFeedsPostAction) where

import Actions.Types (Pagination (..))
import Actions.Utils (paginateItems)
import Database.Feed (FeedData (id), getAllFeeds)
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