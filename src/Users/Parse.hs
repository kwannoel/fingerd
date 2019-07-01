{-# LANGUAGE OverloadedStrings #-}

module Users.Parse where

import Data.Word8 (_colon)
import Data.Text.Encoding (encodeUtf8, decodeUtf8)
import qualified Data.ByteString as BS
import Data.ByteString (ByteString)
import Database.SQLite.Simple.Types
import Users.Types (User(..), FingerRequest(..), UserRow)

formatUser :: User -> ByteString
formatUser (User _ username_ shell_
            homeDir realName_ _) = BS.concat
  ["Login: ", e username_, "\t\t\t\t",
   "Name: ", e realName_, "\n",
   "Directory: ", e homeDir, "\t\t\t",
   "Shell: ", e shell_, "\n"]
  where e = encodeUtf8

splitByColon :: ByteString -> [ByteString]
splitByColon = BS.split _colon

segmentToUser :: [ByteString] -> UserRow
segmentToUser bsList = let wordList = map decodeUtf8 bsList
                       in  (Null, wordList !! 0, wordList !! 1, wordList !! 2,
                            wordList !! 3, wordList !! 4)

parseRequestsToQueries :: ByteString -> FingerRequest
parseRequestsToQueries bs =
  case splitByColon bs of
    "getAll":_ -> GetAll
    "get":xs -> Get $ decodeUtf8 $ xs !! 0
    "insert":xs -> Insert $ segmentToUser xs
    _ -> FailedRequest
