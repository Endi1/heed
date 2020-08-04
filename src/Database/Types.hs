module Database.Types (FeedDB (..), ItemDB (..)) where

import Data.Text
import Database.SQLite.Simple

data FeedDB = FeedDB {title :: Text, feed_url :: Text} deriving (Show)

instance FromRow FeedDB where
  fromRow = FeedDB <$> field <*> field

instance ToRow FeedDB where
  toRow (FeedDB title feed_url) = toRow (title, feed_url)

data ItemDB = ItemDB
  { name :: Maybe Text,
    item_url :: Maybe Text,
    date_published :: Maybe Text,
    author :: Maybe Text,
    feed_id :: Integer,
    summary :: Maybe Text,
    description :: Maybe Text
  }
  deriving (Show)

instance FromRow ItemDB where
  fromRow = ItemDB <$> field <*> field <*> field <*> field <*> field <*> field <*> field

instance ToRow ItemDB where
  toRow (ItemDB name item_url date_published author feed_id summary description) = toRow (name, item_url, date_published, author, feed_id, summary, description)