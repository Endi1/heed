module Actions.HomePage (homePageGetAction) where

import Database.Item
import Database.SQLite.Simple
import Lucid.Base (renderText)
import Views.HomePage (homePageView)
import Web.Scotty

homePageGetAction :: Connection -> ActionM ()
homePageGetAction conn = do
  items <- liftAndCatchIO $ getAllItems conn
  html $ renderText $ homePageView items