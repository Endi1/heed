module Settings (dburi, staticlocation) where

import Data.Maybe (fromMaybe)
import Data.Text
import System.Environment

dburi :: IO String
dburi = fromMaybe "/tmp/heed.db" <$> lookupEnv "DBURI"

staticlocation :: IO String
staticlocation = fromMaybe "/home/endi/heed/src/static" <$> lookupEnv "STATICLOCATION"