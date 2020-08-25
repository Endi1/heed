{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE ScopedTypeVariables #-}

module Main where

import Actions.HomePage
import Actions.NewFeed
import Controllers.Feed
import Data.Maybe
import Data.Monoid (mconcat)
import Data.Text
import Database.Conn (getConn)
import Database.Feed
import Database.Item
import Database.SQLite.Simple (Connection)
import Lucid.Base
import Lucid.Html5
import Network.Wai.Middleware.Static
import Text.Feed.Query
import Web.Scotty

main :: IO ()
main = do
  conn <- getConn
  scotty 8080 (app conn)

app :: Connection -> ScottyM ()
app conn = do
  middleware $ staticPolicy (noDots >-> addBase "/home/endi/heed/src/static")
  get "/" (homePageGetAction conn)
  get "/new-feed" newFeedGetAction
  post "/new-feed" $ newFeedPostAction conn
