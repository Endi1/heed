{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE ScopedTypeVariables #-}

module Actions.FeedList (feedListGetAction) where

import Data.Text
import Database.Item
import Database.SQLite.Simple
import Lucid.Base (renderText)
import Text.Feed.Query
import Views.ItemList
import Web.Scotty

feedListGetAction :: Connection -> ActionM ()
feedListGetAction conn = do
  f_id <- param "feed_id"
  items <- liftAndCatchIO $ getItems conn (Just f_id)
  html $ renderText $ itemListGetView items