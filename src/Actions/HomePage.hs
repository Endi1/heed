module Actions.HomePage where

import Database.Item
import Database.SQLite.Simple
import Web.Scotty
import Lucid.Base (renderText)

homePageAction :: Connection -> ActionM ()
homePageAction conn = do
  items <- liftAndCatchIO $ getAllItems conn
  html $ renderText $ homePageView items