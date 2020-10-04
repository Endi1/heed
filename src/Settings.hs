module Settings
  ( dburi
  , staticlocation
  )
where

import           Data.Maybe                     ( fromMaybe )
import           System.Environment             ( lookupEnv )

dburi :: IO String
dburi = fromMaybe "/tmp/heed.db" <$> lookupEnv "DBURI"

staticlocation :: IO String
staticlocation =
  fromMaybe "/home/endi/heed/src/static" <$> lookupEnv "STATICLOCATION"
