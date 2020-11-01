{-# LANGUAGE OverloadedStrings #-}

module Views.Settings
  ( settingsView
  )
where

import           Data.Text                      ( append
                                                , pack
                                                )
import           Database.AppSettings           ( AppSettings(..) )
import           Database.Feed                  ( FeedData(..) )
import           Lucid.Base
import           Lucid.Html5
import           Views.Mixins.Head              ( pageHead )
import           Views.Mixins.TopBar            ( topBar )

unchecked_ :: Attribute
unchecked_ = makeAttribute "unchecked" mempty

importFeedList :: Html ()
importFeedList = div_ [class_ "import-feedlist"] $ do
  form_ [action_ "/import-feedlist", method_ "post"] $ do
    textarea_
      [name_ "feedlist", placeholder_ "List of feeds separated by newline"]
      ""
    input_ [class_ "button primary", type_ "submit", value_ "Import"]

generalSettings :: AppSettings -> Html ()
generalSettings appSettings = div_ [class_ "general-settings"] $ do
  form_ [action_ "/settings", method_ "post"] $ do
    div_ [class_ "form-group"] $ do
      input_
        [ type_ "checkbox"
        , name_ "markReadOnNextPage"
        , if markReadOnNextPage appSettings then checked_ else unchecked_
        ]
      label_ [for_ "markReadOnNextPage"]
             "Mark all current page items read on next page"
    input_ [class_ "button primary", type_ "submit", value_ "Save"]

feedManagement :: [FeedData] -> Html ()
feedManagement feeds = ul_ [class_ "feed-list"] $ do
  mapM_
    (\feed -> do
      li_ [class_ "feed"] $ do
        with
            button_
            [ class_ "button danger"
            , onclick_
            $  pack
            $  "deleteFeed("
            ++ show (Database.Feed.id feed)
            ++ ", "
            ++ show (Database.Feed.title feed)
            ++ ")"
            ]
          $ toHtml ("Delete " `append` title feed)
    )
    feeds

settingsView :: AppSettings -> [FeedData] -> Html ()
settingsView appSettings feeds = html_ $ do
  head_ $ do
    pageHead "Heed - Settings"
  body_ $ do
    div_ [class_ "container"] $ do
      topBar
      div_ [class_ "main center"] $ do
        div_ [class_ "settings-container center"] $ do
          h3_ "Manage Feeds"
          feedManagement feeds
          h3_ "General settings"
          generalSettings appSettings
          h3_ "Import feed list"
          importFeedList
