{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE RecordWildCards #-}
module Scylla.Client.Websocket where

import Wuss

import Data.Aeson
import Data.Text (Text, pack)
import Network.WebSockets (Connection, ClientApp, receiveData, sendClose, sendTextData)

import Control.Monad.Reader
import Control.Concurrent

import Scylla.Client.Types
import Scylla.Client.Config
import qualified Scylla.Types.API as A

type Scylla a = ReaderT Connection IO a

withScylla code = do
  cfg <- envScyllaCfg
  withScylla' cfg code

withScylla' ScyllaCfg{..} code = do
  r <- runSecureClient scyllaHost (fromIntegral scyllaPort) "/socket" (\conn -> do
      ret <- flip runReaderT conn code
      sendClose conn (pack "Bye!")
      return ret
    )
  return r

query :: A.Query -> Scylla ()
query q = do
  conn <- ask
  liftIO $ sendTextData conn $ encode q

recv :: Scylla (Either String A.Response)
recv = do
  conn <- ask
  msg <- liftIO $ recvConn conn
  return msg

queryConn :: Connection -> A.Query -> IO ()
queryConn conn q = do
  liftIO $ sendTextData conn $ encode q

recvConn :: Connection -> IO (Either String A.Response)
recvConn conn = do
  msg <- fmap eitherDecode $ receiveData conn
  return msg
