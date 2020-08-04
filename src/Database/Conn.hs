module Database.Conn (getConn) where

import Database.SQLite.Simple

import Settings (dburi)

getConn :: IO Connection
getConn = open dburi