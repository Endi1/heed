{-# LANGUAGE OverloadedStrings #-}

module Views.NewFeed
  ( newFeedView
  )
where

import           Lucid.Base
import           Lucid.Html5
import           Views.Mixins.Head              ( pageHead )
import           Views.Mixins.TopBar            ( topBar )

newFeedView :: Html ()
newFeedView = html_ $ do
  head_ $ do
    pageHead "Heed - Add New Feed"
  body_ $ do
    div_ [class_ "container"] $ do
      topBar
      div_ [class_ "main center"] $ do
        form_ [action_ "/new-feed", method_ "post"] $ do
          h2_ "Add new feed"
          input_ [type_ "text", name_ "feed_url"]
          input_ [class_ "button primary", type_ "submit", value_ "Add feed"]
