{-# LANGUAGE OverloadedStrings #-}

module Views.Mixins.Pagination
  ( paginationView
  )
where

import           Actions.Types                  ( Pagination(..) )
import           Data.Text                      ( Text
                                                , pack
                                                )
import           Lucid.Base
import           Lucid.Html5

paginationView :: Pagination -> Bool -> Html ()
paginationView pagination showAll = do
  case previousPaginationItems pagination of
    []       -> span_ [class_ "previous"] ""
    (x : xs) -> span_ [class_ "previous"] $ do
      with a_
           [href_ $ pageLinkReference (currentPageCount pagination - 1)]
           "« Previous"

  case nextPaginationItems pagination of
    []       -> span_ [class_ "next"] ""
    (x : xs) -> span_ [class_ "next"] $ do
      with a_
           [href_ $ pageLinkReference (currentPageCount pagination + 1)]
           "Next »"
 where
  showAllQueryString = if showAll then "&show_all=true" else ""

  pageLinkReference :: Int -> Text
  pageLinkReference pageCount =
    pack $ "?page=" ++ show pageCount ++ showAllQueryString
