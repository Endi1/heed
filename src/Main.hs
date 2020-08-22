{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE ScopedTypeVariables #-}

module Main where

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
import Text.Feed.Query
import Lucid.Html5
import Web.Scotty

main :: IO ()
main = do
  conn <- getConn
  scotty 8080 (app conn)

app :: Connection -> ScottyM ()
app conn = do
  get "/" (homePageAction conn)
  get "/new-feed" newFeedGetAction
  post "/new-feed" $ newFeedPostAction conn

homePageAction :: Connection -> ActionM ()
homePageAction conn = do
  items <- liftAndCatchIO $ getAllItems conn
  html $ renderText $ homePageView items

homePageView :: [ItemData] -> Html ()
homePageView items = html_ $ do
  head_ $ do
    title_ "Heed"
  body_ $ do
    div_ $ do
      p_ "Hello world"
      ul_ $
        mapM_
          ( \item -> do
              li_ $ do
                with a_ [href_ $ item_url item] $ toHtml $ name item
          )
          items