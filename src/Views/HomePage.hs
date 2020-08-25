{-# LANGUAGE OverloadedStrings #-}

module Views.HomePage (homePageView) where

import Database.Item (ItemData (..))
import Lucid.Base
import Lucid.Html5
import Views.Mixins.TopBar

homePageView :: [ItemData] -> Html ()
homePageView items = html_ $ do
  head_ $ do
    title_ "Heed"
    link_ [rel_ "stylesheet", type_ "text/css", href_ "css/style.css"]
  body_ $ do
    div_ [class_ "container"] $ do
      topBar
      div_ [class_ "items"] $ do
        mapM_
          ( \item -> do
              div_ [class_ "item"] $ do
                with a_ [href_ $ item_url item] $ toHtml $ name item
          )
          items