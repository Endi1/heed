{-# LANGUAGE OverloadedStrings #-}

module Views.Settings (settingsView) where

import Data.Text (pack, unpack)
import Database.Feed (FeedData (..))
import Lucid.Base (Attribute, Html, ToHtml (toHtml), With (with))
import Lucid.Html5
import Views.Mixins.Head (pageHead)
import Views.Mixins.TopBar (topBar)

settingsView :: [FeedData] -> Html ()
settingsView feeds = html_ $ do
  head_ $ do
    pageHead "Heed - Settings"
  body_ $ do
    div_ [class_ "container"] $ do
      topBar
      ul_ [class_ "feed-list"] $ do
        mapM_
          ( \feed -> do
              li_ [class_ "feed"] $ do
                with button_ [onclick_ $ pack $ "deleteFeed(" ++ show (Database.Feed.id feed) ++ ")"] $ toHtml $ pack ("Delete " ++ unpack (title feed))
          )
          feeds