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
import Views.Mixins.TopBar (topBar)

itemListGetView :: [FeedData] -> Pagination -> Html ()
itemListGetView feeds pagination = html_ $ do
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
        case previousPaginationItems pagination of
          [] -> span_ [class_ "previous"] ""
          (x : xs) -> span_ [class_ "previous"] $ do
            with a_ [href_ $ pack $ "?page=" ++ show (currentPageCount pagination - 1)] "« Previous"

        case nextPaginationItems pagination of
          [] -> span_ [class_ "next"] ""
          (x : xs) -> span_ [class_ "next"] $ do
            with a_ [href_ $ pack $ "?page=" ++ show (currentPageCount pagination + 1)] "Next »"