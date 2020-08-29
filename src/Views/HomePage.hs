{-# LANGUAGE OverloadedStrings #-}

module Views.HomePage (homePageView) where

import Data.Text (pack)
import Database.Item (ItemData (..))
import Lucid.Base
import Lucid.Html5
import Views.Mixins.TopBar

homePageView :: [ItemData] -> Html ()
homePageView items = html_ $ do
  head_ $ do
    title_ "Heed"
    link_ [href_ "https://fonts.googleapis.com/css2?family=Roboto&display=swap", rel_ "stylesheet"]
    link_ [rel_ "stylesheet", type_ "text/css", href_ "css/style.css"]
    script_ ([src_ "js/app.js"] :: [Attribute]) ("" :: String)
  body_ $ do
    div_ [class_ "container"] $ do
      topBar
      div_ [class_ "items"] $ do
        mapM_
          ( \item -> do
              div_ [class_ "item", class_ (if is_read item then "is-read " else "")] $ do
                with a_ [href_ $ item_url item, target_ "blank_", onclick_ $ pack ("markAsRead(" ++ show (Database.Item.id item) ++ ")")] $ toHtml $ name item
          )
          items