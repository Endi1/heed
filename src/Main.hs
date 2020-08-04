{-# LANGUAGE OverloadedStrings #-}

module Main where

import Controllers.Item (ItemDBTuple, getAllItems)
import Data.Monoid (mconcat)
import Database.Conn (getConn)
import Database.SQLite.Simple (Connection)
import Lucid.Base
import Lucid.Html5
import Web.Scotty

main :: IO ()
main = do
  conn <- getConn
  scotty 8080 (app conn)

app :: Connection -> ScottyM ()
app conn = do
  get "/" (homePage conn)
  get "/foo" $ do
    html "foo"

homePage :: Connection -> ActionM ()
homePage conn = do
  items <- liftAndCatchIO $ getAllItems conn
  html $ mconcat ["<h1>Hello world!</h1>"]

homePageView :: Html ()
homePageView = html_ $ do
  head_ $ do
    title_ "Heed"
  body_ $ do
    div_ $ do
      p_ "Hello world"