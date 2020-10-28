{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE OverloadedStrings #-}
module Actions.Settings
  ( settingsGetAction
  , settingsPostAction
  )
where

import           Database.AppSettings           ( getSettings
                                                , AppSettings(..)
                                                , updateSettings
                                                )
import           Database.Feed                  ( getAllFeeds )
import           Database.SQLite.Simple         ( Connection )
import           Lucid.Base                     ( renderText )
import           Views.Settings                 ( settingsView )
import           Web.Scotty                     ( ActionM
                                                , html
                                                , liftAndCatchIO
                                                , rescue
                                                , param
                                                , redirect
                                                )


settingsGetAction :: Connection -> ActionM ()
settingsGetAction conn = do
  feeds       <- liftAndCatchIO $ getAllFeeds conn
  appSettings <- liftAndCatchIO $ getSettings conn
  html $ renderText (settingsView appSettings feeds)

settingsPostAction :: Connection -> ActionM ()
settingsPostAction conn = do
  markReadOnNextPageSetting :: String <- rescue (param "markReadOnNextPage")
                                                (\_ -> return "off")
  case markReadOnNextPageSetting of
    "on"  -> liftAndCatchIO $ updateSettings conn $ AppSettings True
    "off" -> liftAndCatchIO $ updateSettings conn $ AppSettings False
  redirect "/settings"
