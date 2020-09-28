{-# LANGUAGE OverloadedStrings #-}

module Actions.ItemList (itemListGetAction, refreshFeedsPostAction, deleteFeedPostAction) where

import Actions.Types (Pagination (..))
import Actions.Utils (paginateItems)
import Data.Char (toLower)
import Database.Feed (FeedData (id), deleteFeed, getAllFeeds)
import Database.Item (ItemData, getAllItems, getItems, getUnreadItems, refreshFeedItems)
import Database.SQLite.Simple (Connection)
import Lucid.Base (renderText)
import Views.ItemList (itemListGetView)
import Web.Scotty (ActionM, html, liftAndCatchIO, param, rescue)

itemListGetAction :: Connection -> ActionM ()
itemListGetAction conn = do
  feedID <- rescue (param "feed_id" :: ActionM Integer) (\t -> return 0)
  showAll <- rescue (param "show_all" :: ActionM String) (\t -> return "false")
  let showAllBool = Just True == readStringBool showAll
      feedIDMaybe = if feedID /= 0 then Just feedID else Nothing
  items <- liftAndCatchIO $ getItems conn feedIDMaybe showAllBool
  feeds <- liftAndCatchIO $ getAllFeeds conn
  page <- rescue (param "page") (\t -> return 1)
  html $
    renderText $
      itemListGetView
        feeds
        (paginateItems items page)
        showAllBool

readStringBool :: String -> Maybe Bool
readStringBool string = case map toLower string of
  "true" -> Just True
  "false" -> Just False
  _ -> Nothing

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