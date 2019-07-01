{-# LANGUAGE OverloadedStrings #-}

module Main where

import Database.SQLite.Simple
       hiding (close)
import qualified Database.SQLite.Simple
       as SQLite
import Network.Socket hiding (close, recv)
import Users.Handlers

main :: IO ()
main = withSocketsDo $ do
  addrInfos <-
    -- What kind of TCP server we are firing up
    getAddrInfo
    (Just (defaultHints
      {addrFlags = [AI_PASSIVE]}))
     -- The port we're listening on
     Nothing (Just "79")
  let serverAddr = head addrInfos
  -- We bind the socket to the address we wanted
  sock <- socket (addrFamily serverAddr)
          Stream defaultProtocol
  bindSocket sock (addrAddress serverAddr)
  listen sock 1
  -- only one connection open at a time
  conn <- open "finger.db"
  handleQueries conn sock
  SQLite.close conn
  sClose sock
