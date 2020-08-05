{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE ScopedTypeVariables #-}

module Main where

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
  post "/new-feed" $ newFeedAction conn

newFeedAction :: Connection -> ActionM ()
newFeedAction conn = do
  feed_url :: Text <- param "feed_url"
  maybeFeed <- liftAndCatchIO $ readRemoteFeed feed_url
  case maybeFeed of
    Nothing -> raise "Not a valid atom/rss feed"
    Just feed -> do
      feedId <- liftAndCatchIO $ insertNewFeed conn (getFeedTitle feed) feed_url
      liftAndCatchIO $ refreshFeedItems conn $ toInteger feedId
      redirect "/"

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