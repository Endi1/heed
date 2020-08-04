{-# LANGUAGE KindSignatures #-}
{-# LANGUAGE DataKinds #-}
{-# LANGUAGE OverloadedStrings #-}

module Controllers.Item (readRemoteFeedItems) where

import Controllers.RequestHelpers (buildUrl, makeRequestToFeed)
import Data.ByteString.Lazy (fromStrict)
import Data.Foldable (forM_)
import Data.Int
import Data.Maybe (fromJust)
import Data.Text
import Database.SQLite.Simple
import GHC.List (concat)
import Network.HTTP.Req
import Text.Feed.Import (parseFeedSource)
import Text.Feed.Query
import qualified Text.Feed.Types as T (Feed, Item)

readRemoteFeedItems :: Text -> IO [T.Item]
readRemoteFeedItems feedUrl = do
  urlMaybe <- buildUrl feedUrl
  feedResponseBody <- either makeRequestToFeed makeRequestToFeed (fromJust urlMaybe)
  let parseFeedMaybe = parseFeedSource $ fromStrict feedResponseBody
  return $ getFeedItems $ fromJust parseFeedMaybe
