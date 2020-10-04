{-# LANGUAGE OverloadedStrings #-}

module Views.NewFeed
  ( newFeedView
  )
where

import           Lucid.Base
import           Lucid.Html5
import           Views.Mixins.Head              ( pageHead )

newFeedView :: Html ()
newFeedView = html_ $ do
  head_ $ do
    pageHead "Heed - Add New Feed"
  body_ $ do
    div_ $ do
      form_ [action_ "/new-feed", method_ "post"] $ do
        input_ [type_ "text", name_ "feed_url"]
        input_ [type_ "submit", value_ "Add new feed"]
