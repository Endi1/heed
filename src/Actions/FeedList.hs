{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE ScopedTypeVariables #-}

module Actions.FeedList (feedListGetAction) where

import Actions.Utils (paginateItems)
import Data.Char (toLower)
import Database.Feed (getAllFeeds)
import Database.Item (getItems)
import Database.SQLite.Simple (Connection)
import Lucid.Base (renderText)
import Views.ItemList (itemListGetView)
import Web.Scotty (ActionM, html, liftAndCatchIO, param, rescue)

-- TODO Merge with Actions.Homepage
feedListGetAction :: Connection -> ActionM ()
feedListGetAction conn = do
  f_id <- param "feed_id"
  showAll <- rescue (param "show_all" :: ActionM String) (\t -> return "false")
  let showAllBool = Just True == readStringBool showAll
  items <- liftAndCatchIO $ getItems conn (Just f_id)
  feeds <- liftAndCatchIO $ getAllFeeds conn
  page <- rescue (param "page") (\t -> return 1)
  html $ renderText $ itemListGetView feeds (paginateItems items page) showAllBool

readStringBool :: String -> Maybe Bool
readStringBool string = case map toLower string of
  "true" -> Just True
  "false" -> Just False
  _ -> Nothing