{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE ScopedTypeVariables #-}

module Main where

import           Actions.ItemList               ( deleteFeedPostAction
                                                , itemListGetAction
                                                , refreshFeedsPostAction
                                                )
import           Actions.MarkRead               ( markReadPostAction )
import           Actions.NewFeed                ( newFeedGetAction
                                                , newFeedPostAction
                                                )
import           Actions.Settings               ( settingsGetAction )
import           Database.Conn                  ( getConn )
import           Database.SQLite.Simple         ( Connection )
import           Network.Wai.Middleware.Static  ( addBase
                                                , noDots
                                                , staticPolicy
                                                , (>->)
                                                )
import           Web.Scotty                     ( ScottyM
                                                , get
                                                , middleware
                                                , post
                                                , scotty
                                                )

main :: IO ()
main = do
  conn <- getConn
  scotty 8080 (app conn)

app :: Connection -> ScottyM ()
app conn = do
  middleware $ staticPolicy (noDots >-> addBase "/app/src/static")
  get "/"         (itemListGetAction conn)
  get "/new-feed" newFeedGetAction
  get "/feed/:feed_id" $ itemListGetAction conn
  post "/new-feed" $ newFeedPostAction conn
  post "/mark-read" $ markReadPostAction conn
  post "/refresh-feeds" $ refreshFeedsPostAction conn
  post "/delete-feed" $ deleteFeedPostAction conn
  get "/settings" $ settingsGetAction conn
