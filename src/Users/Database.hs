{-# LANGUAGE OverloadedStrings #-}

module Users.Database where

import Database.SQLite.Simple
import qualified Database.SQLite.Simple as SQLite
import Users.Types
import Users.Queries
import Database.SQLite.Simple.Types

createDatabase :: IO ()
createDatabase = do
  conn <- open "finger.db"
  execute_ conn createUsers
  execute conn insertUser meRow
  rows <- query_ conn allUsers
  mapM_ print (rows :: [User])
  SQLite.close conn
  where meRow :: UserRow
        meRow =
          (Null, "callen", "/bin/zsh",
           "/home/callen", "Chris Allen",
           "555-123-456")
