module Database.Conn
  ( getConn
  )
where

import           Database.SQLite.Simple         ( open
                                                , Connection
                                                )
import           Settings                       ( dburi )

getConn :: IO Connection
getConn = open =<< dburi
