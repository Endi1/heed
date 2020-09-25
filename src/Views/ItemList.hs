{-# LANGUAGE OverloadedStrings #-}

module Views.ItemList (itemListGetView) where

import Actions.Types (Pagination (..))
import Data.Maybe (fromMaybe)
import Data.Text (pack)
import Database.Feed (FeedData (..))
import Database.Item (ItemData (..))
import Lucid.Base (Attribute, Html, ToHtml (toHtml), With (with))
import Lucid.Html5
import Views.Mixins.Head (pageHead)
import Views.Mixins.Pagination (paginationView)
import Views.Mixins.TopBar (topBar)

-- TODO Move the ItemList to a mixin and rename this to HomePage
itemListGetView :: [FeedData] -> Pagination -> Bool -> Html ()
itemListGetView feeds pagination showAll = html_ $ do
  head_ $ do
    pageHead "Heed"
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
          div_ [class_ "items-dashboard"] $ do
            if showAll then a_ [href_ "?show_all=false"] "Show only unread items" else a_ [href_ "?show_all=true"] "Show all items"
          mapM_
            ( \item -> do
                div_ [class_ "item", class_ (if is_read item then "is-read " else "")] $ do
                  with a_ [href_ $ item_url item, target_ "blank_", onclick_ $ pack ("markAsRead(" ++ show (Database.Item.id item) ++ ")")] $ toHtml $ name item
                  div_ [class_ "item-metadata"] $ do
                    span_ [class_ "item-date"] $ toHtml $ fromMaybe "" $ date_published item
                    span_ [class_ "item-feed"] $ do
                      with a_ [href_ $ pack $ "/feed/" ++ show (feed_id item)] $ toHtml $ feed_title item
            )
            (currentPaginationItems pagination)
      div_ [class_ "pagination"] $ do
        paginationView pagination showAll