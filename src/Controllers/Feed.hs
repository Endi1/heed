{-# LANGUAGE DataKinds #-}
{-# LANGUAGE OverloadedStrings #-}

module Controllers.Feed
  ( readRemoteFeed
  )
where

import           Controllers.RequestHelpers     ( buildUrl
                                                , makeRequestToFeed
                                                )
import           Data.ByteString.Lazy           ( fromStrict )
import           Data.Text                      ( Text )
import           Text.Feed.Import               ( parseFeedSource )
import           Text.Feed.Types                ( Feed )

readRemoteFeed :: Text -> IO (Maybe Feed)
readRemoteFeed feedUrl = do
  urlMaybe <- buildUrl feedUrl
  case urlMaybe of
    Nothing  -> return Nothing
    Just url -> do
      feedResponseBody <- either makeRequestToFeed makeRequestToFeed url
      return $ parseFeedSource $ fromStrict feedResponseBody
