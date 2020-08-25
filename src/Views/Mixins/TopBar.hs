{-# LANGUAGE OverloadedStrings #-}

module Views.Mixins.TopBar (topBar) where

import Lucid.Base
import Lucid.Html5

topBar :: Html ()
topBar = do
  div_ [class_ "top-bar"] $ do
    a_ [href_ "/new-feed", class_ "button"] "Add new feed"