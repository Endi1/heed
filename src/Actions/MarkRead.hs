{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE ScopedTypeVariables #-}

module Actions.MarkRead (markReadPostAction) where

import Database.Item (markItemAsRead)
import Database.SQLite.Simple (Connection)
import Lucid.Base (renderText)
import Web.Scotty (ActionM, html, liftAndCatchIO, param)

markReadPostAction :: Connection -> ActionM ()
markReadPostAction conn = do
  item_id :: Integer <- param "item_id"
  liftAndCatchIO $ markItemAsRead conn item_id
  html "Ok"