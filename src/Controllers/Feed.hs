{-# LANGUAGE DataKinds #-}
{-# LANGUAGE OverloadedStrings #-}

module Controllers.Feed () where

import Controllers.RequestHelpers (buildUrl, makeRequestToFeed)
import Data.ByteString (ByteString)
import Data.ByteString.Lazy (fromStrict)
import Data.Text
import Data.Foldable (forM_)
import Database.SQLite.Simple
import Network.HTTP.Req
import Text.Feed.Import (parseFeedSource)
import Text.Feed.Query (getFeedTitle)
