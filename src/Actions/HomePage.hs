{-# LANGUAGE OverloadedStrings #-}

module Actions.HomePage (homePageGetAction, refreshFeedsPostAction) where

import Data.Void
import Database.Feed
import Database.Item
import Database.SQLite.Simple
import Lucid.Base (renderText)
import Views.ItemList (itemListGetView)
import Web.Scotty

homePageGetAction :: Connection -> ActionM ()
homePageGetAction conn = do
  items <- liftAndCatchIO $ getAllItems conn
  feeds <- liftAndCatchIO $ getAllFeeds conn
  page <- rescue (param "page") (\t -> return 1)
  let currentItemsInPagination = drop (5 * (page - 1)) $ take (5 * page) items
  html $ renderText $ itemListGetView feeds currentItemsInPagination

refreshFeedsPostAction :: Connection -> ActionM ()
refreshFeedsPostAction conn = do
  feeds <- liftAndCatchIO $ getAllFeeds conn
  liftAndCatchIO $ mapM_ (refreshFeedItems conn . Database.Feed.id) feeds
  html "Ok"