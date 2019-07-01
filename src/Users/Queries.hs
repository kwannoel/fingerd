{-# LANGUAGE QuasiQuotes #-}
{-# LANGUAGE OverloadedStrings #-}

module Users.Queries where

import Control.Exception
import Data.List (intersperse)
import Data.Text (Text)
import Text.RawString.QQ
import Data.Text.Encoding

import Database.SQLite.Simple hiding (close)
import Network.Socket hiding (close, recv)
import Network.Socket.ByteString (sendAll)

import qualified Data.Text as T
import Users.Types
import Users.Parse

createUsers :: Query
createUsers = [r|
CREATE TABLE IF NOT EXISTS users
  (id INTEGER PRIMARY KEY AUTOINCREMENT,
   username TEXT UNIQUE,
   shell TEXT, homeDirectory TEXT,
   realName TEXT, phone TEXT)
|]

insertUser :: Query
insertUser =
  "INSERT INTO users\
  \ Values (?, ?, ?, ?, ?, ?)"

modifyUser :: Query
modifyUser = [r|
UPDATE users
  SET username = ?, shell = ?, homeDirectory = ?,
      realName = ?, phone = ?
  WHERE id = ?"
|]

allUsers :: Query
allUsers =
  "SELECT * from users"

getUserQuery :: Query
getUserQuery =
  "SELECT * from users where username = ?"

-- Higher query level functions

getUser :: Connection -> Text -> IO (Maybe User)
getUser conn username_ = do
  results <-
    query conn getUserQuery (Only username_)
  case results of
    [] -> return Nothing
    [user] -> return $ Just user
    _ -> throwIO DuplicateData

returnUsers :: Connection
            -> Socket
            -> IO ()
returnUsers dbConn soc = do
  rows <- query_ dbConn allUsers
  let usernames = map username rows
      newlineSeparated =
        T.concat $
        intersperse "\n" usernames
  sendAll soc (encodeUtf8 newlineSeparated)

returnUser :: Connection
           -> Socket
           -> Text
           -> IO ()
returnUser dbConn soc username_ = do
  maybeUser <-
    getUser dbConn (T.strip username_)
  case maybeUser of
    Nothing -> do
      putStrLn
        ("Couldn't find matching user\
         \ for username: "
        ++ show username_)
      return ()
    Just user ->
      sendAll soc (formatUser user)

insertUserRow :: Connection
           -> Socket
           -> UserRow
           -> IO ()
insertUserRow dbConn soc userRow = do
  execute dbConn insertUser userRow
  sendAll soc (encodeUtf8 "Successful insertion of new user")
