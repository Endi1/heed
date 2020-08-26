{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE ScopedTypeVariables #-}

module Actions.MarkRead (markReadPostAction) where

import Controllers.Feed
import Data.Text
import Database.Feed
import Database.Item (markItemAsRead)
import Database.SQLite.Simple
import Lucid.Base (renderText)
import Text.Feed.Query
import Views.NewFeed
import Web.Scotty

markReadPostAction :: Connection -> ActionM ()
markReadPostAction conn = do
  item_id :: Integer <- param "item_id"
  liftAndCatchIO $ markItemAsRead conn item_id
  html "Ok"