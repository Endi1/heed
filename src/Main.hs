{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE ScopedTypeVariables #-}

module Main where

import           Actions.ItemList               ( deleteFeedPostAction
                                                , itemListGetAction
                                                , refreshFeedsPostAction
                                                )
import           Actions.ExportFeedList         ( exportFeedListGetAction )
import           Actions.ImportFeedList         ( importFeedListPostAction )
import           Actions.MarkRead               ( markReadPostAction )
import           Actions.NewFeed                ( newFeedGetAction
                                                , newFeedPostAction
                                                )
import           Actions.Settings               ( settingsGetAction
                                                , settingsPostAction
                                                )
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
import           Settings
import           GHC.IO
import           Database.Init

main :: IO ()
main = do
  conn <- getConn
  initTables conn
  scotty 8000 (app conn)

app :: Connection -> ScottyM ()
app conn = do
  middleware
    $ staticPolicy (noDots >-> addBase (unsafePerformIO staticlocation))
  get "/"         (itemListGetAction conn)
  get "/new-feed" newFeedGetAction
  get "/feed/:feed_id" $ itemListGetAction conn
  post "/new-feed" $ newFeedPostAction conn
  post "/mark-read" $ markReadPostAction conn
  post "/refresh-feeds" $ refreshFeedsPostAction conn
  post "/delete-feed" $ deleteFeedPostAction conn
  get "/settings" $ settingsGetAction conn
  post "/settings" $ settingsPostAction conn
  post "/import-feedlist" $ importFeedListPostAction conn
  get "/export-feedlist" $ exportFeedListGetAction conn
