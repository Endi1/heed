{-# LANGUAGE OverloadedStrings #-}

module Views.HomePage (homePageView) where

import Database.Item (ItemData (..))
import Lucid.Base
import Lucid.Html5

homePageView :: [ItemData] -> Html ()
homePageView items = html_ $ do
  head_ $ do
    title_ "Heed"
  body_ $ do
    div_ $ do
      ul_ $
        mapM_
          ( \item -> do
              li_ $ do
                with a_ [href_ $ item_url item] $ toHtml $ name item
          )
          items