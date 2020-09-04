{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE ScopedTypeVariables #-}

module Actions.FeedList (feedListGetAction) where

import Actions.Utils (paginateItems)
import Database.Feed (getAllFeeds)
import Database.Item (getItems)
import Database.SQLite.Simple (Connection)
import Lucid.Base (renderText)
import Views.ItemList (itemListGetView)
import Web.Scotty (ActionM, html, liftAndCatchIO, param, rescue)

feedListGetAction :: Connection -> ActionM ()
feedListGetAction conn = do
  f_id <- param "feed_id"
  items <- liftAndCatchIO $ getItems conn (Just f_id)
  feeds <- liftAndCatchIO $ getAllFeeds conn
  page <- rescue (param "page") (\t -> return 1)
  html $ renderText $ itemListGetView feeds (paginateItems items page)