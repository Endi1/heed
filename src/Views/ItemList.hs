{-# LANGUAGE OverloadedStrings #-}

module Views.ItemList (itemListGetView) where

import Data.Maybe
import Data.Text (pack)
import Database.Feed (FeedData (..))
import Database.Item (ItemData (..))
import Lucid.Base
import Lucid.Html5
import Views.Mixins.TopBar

itemListGetView :: [FeedData] -> [ItemData] -> Html ()
itemListGetView feeds items = html_ $ do
  head_ $ do
    title_ "Heed"
    link_ [href_ "https://fonts.googleapis.com/css2?family=Roboto&display=swap", rel_ "stylesheet"]
    link_ [rel_ "stylesheet", type_ "text/css", href_ "/css/style.css"]
    script_ ([src_ "/js/app.js"] :: [Attribute]) ("" :: String)
  body_ $ do
    div_ [class_ "container"] $ do
      topBar
      div_ [class_ "main"] $ do
        div_ [class_ "sidebar"] $ do
          ul_ [class_ "feed-list"] $ do
            mapM_
              ( \feed -> do
                  li_ [class_ "feed"] $ do
                    with a_ [href_ $ pack $ "/feed/" ++ show (Database.Feed.id feed)] $ toHtml $ title feed
              )
              feeds
        div_ [class_ "items"] $ do
          mapM_
            ( \item -> do
                div_ [class_ "item", class_ (if is_read item then "is-read " else "")] $ do
                  with a_ [href_ $ item_url item, target_ "blank_", onclick_ $ pack ("markAsRead(" ++ show (Database.Item.id item) ++ ")")] $ toHtml $ name item
                  div_ [class_ "item-metadata"] $ do
                    span_ [class_ "item-date"] $ toHtml $ fromMaybe "" $ date_published item
                    span_ [class_ "item-feed"] $ do
                      with a_ [href_ $ pack $ "/feed/" ++ show (feed_id item)] $ toHtml $ feed_title item
            )
            items