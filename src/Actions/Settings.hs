module Actions.Settings (settingsGetAction) where

import Database.Feed (getAllFeeds)
import Database.SQLite.Simple (Connection)
import Lucid.Base (renderText)
import Views.Settings (settingsView)
import Web.Scotty (ActionM, html, liftAndCatchIO, param, rescue)

settingsGetAction :: Connection -> ActionM ()
settingsGetAction conn = do
  feeds <- liftAndCatchIO $ getAllFeeds conn
  html $ renderText (settingsView feeds)