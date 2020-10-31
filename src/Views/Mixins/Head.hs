{-# LANGUAGE OverloadedStrings #-}

module Views.Mixins.Head
  ( pageHead
  )
where

import           Data.Text                      ( Text )
import           Lucid.Base
import           Lucid.Html5

pageHead :: Text -> Html ()
pageHead pageTitle = do
  title_ $ toHtml pageTitle
  link_
    [ href_ "https://fonts.googleapis.com/css2?family=Roboto&display=swap"
    , rel_ "stylesheet"
    ]
  link_ [rel_ "stylesheet", type_ "text/css", href_ "/css/notie.min.css"]
  link_ [rel_ "stylesheet", type_ "text/css", href_ "/css/index.css"]
  script_ ([src_ "/js/notie.min.js"] :: [Attribute]) ("" :: String)
  script_ ([src_ "/js/app.js"] :: [Attribute])       ("" :: String)
