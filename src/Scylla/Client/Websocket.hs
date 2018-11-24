{-# LANGUAGE FlexibleContexts #-}
module Scylla.Client.Websocket where

import Wuss

import Data.Aeson
import Data.Text (Text, pack)
import Network.WebSockets (Connection, ClientApp, receiveData, sendClose, sendTextData)

import Control.Monad.Reader
import Control.Concurrent

import qualified Scylla.Types.API as A

type Scylla a = ReaderT Connection IO a

withScylla host port code = do
  r <- runSecureClient host port "/socket" (\conn -> do
      ret <- flip runReaderT conn code
      sendClose conn (pack "Bye!")
      return ret
    )
  return r

query :: A.Query -> Scylla ()
query q = do
  conn <- ask
  liftIO $ sendTextData conn $ encode q

recvConn :: Connection -> IO (Either String A.Response)
recvConn conn = do
  msg <- fmap eitherDecode $ receiveData conn
  return msg

recv :: Scylla (Either String A.Response)
recv = do
  conn <- ask
  msg <- liftIO $ recvConn conn
  return msg
