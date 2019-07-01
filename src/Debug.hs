module Main where

import Control.Monad (forever)
import Network.Socket hiding (recv)
import Network.Socket.ByteString (recv, sendAll)

-- Server set up

logAndEcho :: Socket -> IO ()
logAndEcho sock = forever $ do
  -- accept blocks until client connects
  (soc, _) <- accept sock
  -- soc for accepting a connection for communicating with the client
  printAndKickback soc
  -- client connection (soc) closed, sock not closed, server socket remains open
  sClose soc
  where printAndKickback conn = do
          -- able to receive up to 1024 bytes of text
          msg <- recv conn 1024
          -- prints the text
          print msg
          -- echo back to client
          sendAll conn msg

main :: IO ()
main = withSocketsDo $ do
  addrInfos <- getAddrInfo
               (Just (defaultHints
                  {addrFlags =
                     [AI_PASSIVE]}))
               Nothing (Just "79") -- listening on this port
  let serverAddr = head addrInfos
  sock <- socket (addrFamily serverAddr)
               Stream defaultProtocol
  bind sock (addrAddress serverAddr)
  listen sock 1
  logAndEcho sock
  close sock
