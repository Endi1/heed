{-# LANGUAGE DataKinds #-}
{-# LANGUAGE KindSignatures #-}
{-# LANGUAGE OverloadedStrings #-}

module Controllers.Item
  ( readRemoteFeedItems
  )
where

import           Controllers.RequestHelpers     ( buildUrl
                                                , makeRequestToFeed
                                                )
import           Data.ByteString.Lazy           ( fromStrict )
import           Data.Maybe                     ( fromJust )
import           Data.Text                      ( Text )
import           Text.Feed.Import               ( parseFeedSource )
import           Text.Feed.Query                ( getFeedItems )
import qualified Text.Feed.Types               as T
                                                ( Item )

readRemoteFeedItems :: Text -> IO [T.Item]
readRemoteFeedItems feedUrl = do
  urlMaybe         <- buildUrl feedUrl
  feedResponseBody <- either makeRequestToFeed
                             makeRequestToFeed
                             (fromJust urlMaybe)
  let parseFeedMaybe = parseFeedSource $ fromStrict feedResponseBody
  return $ getFeedItems $ fromJust parseFeedMaybe
