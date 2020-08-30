{-# LANGUAGE OverloadedStrings #-}

module Actions.HomePage (homePageGetAction, refreshFeedsPostAction) where

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
  html $ renderText $ itemListGetView feeds items

refreshFeedsPostAction :: Connection -> ActionM ()
refreshFeedsPostAction conn = do
  feeds <- liftAndCatchIO $ getAllFeeds conn
  liftAndCatchIO $ mapM_ (refreshFeedItems conn . Database.Feed.id) feeds
  html "Ok"