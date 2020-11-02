{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE OverloadedStrings #-}
module Actions.ExportFeedList
  ( exportFeedListGetAction
  )
where

import qualified Data.Text.Lazy                as L
import           Data.Text                      ( Text
                                                , append
                                                )
import           Database.SQLite.Simple         ( Connection )
import           Web.Scotty                     ( ActionM
                                                , liftAndCatchIO
                                                , text
                                                , setHeader
                                                , redirect
                                                )
import           Database.Feed                  ( getAllFeeds
                                                , FeedData(feed_url)
                                                )


exportFeedListGetAction :: Connection -> ActionM ()
exportFeedListGetAction conn = do
  feeds <- liftAndCatchIO $ getAllFeeds conn
  let feedUrls :: [Text] = Prelude.map feed_url feeds
  setHeader "Content-Disposition" "attachment; filename=\"feeds.txt\""
  text $ L.fromStrict $ concatTexts feedUrls
 where
  concatTexts :: [Text] -> Text
  concatTexts []       = ""
  concatTexts (t : ts) = t `append` "\n" `append` concatTexts ts
