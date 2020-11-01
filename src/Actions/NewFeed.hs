{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE ScopedTypeVariables #-}

module Actions.NewFeed
  ( newFeedPostAction
  , newFeedGetAction
  , importFeedFromUrl
  )
where

import           Controllers.Feed               ( readRemoteFeed )
import           Data.Text                      ( Text )
import           Database.Feed                  ( insertNewFeed )
import           Database.Item                  ( refreshFeedItems )
import           Database.SQLite.Simple         ( Connection )
import           Lucid.Base                     ( renderText )
import           Text.Feed.Query                ( getFeedTitle )
import           Views.NewFeed                  ( newFeedView )
import           Web.Scotty                     ( ActionM
                                                , html
                                                , liftAndCatchIO
                                                , param
                                                , raise
                                                , redirect
                                                )
import           Data.Int                       ( Int64 )

newFeedGetAction :: ActionM ()
newFeedGetAction = html $ renderText newFeedView

newFeedPostAction :: Connection -> ActionM ()
newFeedPostAction conn = do
  feedUrl :: Text  <- param "feed_url"
  feedImportResult <- liftAndCatchIO $ importFeedFromUrl conn feedUrl
  case feedImportResult of
    Nothing -> raise "Not a valid atom/rss feed"
    Just _  -> redirect "/"

importFeedFromUrl :: Connection -> Text -> IO (Maybe Int64)
importFeedFromUrl conn url = do
  maybeFeed <- readRemoteFeed url
  case maybeFeed of
    Nothing   -> return Nothing
    Just feed -> do
      feedId <- insertNewFeed conn (getFeedTitle feed) url
      refreshFeedItems conn $ toInteger feedId
      return $ Just feedId
