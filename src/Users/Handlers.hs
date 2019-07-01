{-# LANGUAGE OverloadedStrings #-}

module Users.Handlers where

import Control.Monad (forever)

import Control.Concurrent (forkIO)
import Data.Text.Encoding (encodeUtf8, decodeUtf8)
import Network.Socket hiding (close, recv)
import Network.Socket.ByteString (recv, sendAll)
import Database.SQLite.Simple
import Users.Queries (returnUser, returnUsers, insertUserRow)
import Users.Parse (parseRequestsToQueries)
import Users.Types (FingerRequest(..))

-- add a message parser to a datatype

handleQuery :: Connection
            -> Socket
            -> IO ()
handleQuery dbConn soc = do
  -- We get the incoming query from the client
  msg <- recv soc 1024
  -- note here incoming `msg` requests are suffixed with "\r\n"
  case parseRequestsToQueries msg of
    GetAll -> returnUsers dbConn soc
    Get name -> returnUser dbConn soc name
    Insert userRow -> forkIO (insertUserRow dbConn soc userRow) >> return ()
    FailedRequest -> sendAll soc (encodeUtf8 "Invalid format, request should be \
                                             \in the form of <someText>:<someText>:\
                                             \<someText>..")
    -- in the event of an empty query
--    "\r\n" -> returnUsers dbConn soc
    -- non-empty queries
    -- name ->
    --   returnUser dbConn soc
    --   (decodeUtf8 name)

handleQueries :: Connection
              -> Socket
              -> IO ()
handleQueries dbConn sock = forever $ do
  (soc, _) <- accept sock
  putStrLn "Got connection, handling query"
  handleQuery dbConn soc
  sClose soc


-- Need to figure out how to close Network.Socket.bind
