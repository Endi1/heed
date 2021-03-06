{-# LANGUAGE OverloadedStrings #-}

module Views.Mixins.TopBar
  ( topBar
  )
where

import           Lucid.Base                     ( Html )
import           Lucid.Html5

topBar :: Html ()
topBar = do
  div_ [class_ "top-bar"] $ do
    div_ [class_ "left"] $ do
      h3_ $ do
        a_ [href_ "/"] "Heed"
    div_ [class_ "right"] $ do
      a_ [class_ "button primary", href_ "/settings"]         "Settings"
      a_ [class_ "button primary", onclick_ "refreshFeeds()"] "Refresh feeds"
      a_ [href_ "/new-feed", class_ "button primary"]         "Add new feed"
