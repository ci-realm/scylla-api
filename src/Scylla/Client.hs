module Scylla.Client where

import Control.Concurrent
import Control.Concurrent.STM

import Control.Monad
import Control.Monad.Reader

import Data.Default

import Scylla.Types
import qualified Scylla.Types.API as A

import Scylla.Client.Websocket

import Scylla.Pretty

runScylla :: IO ()
runScylla = withScylla "ci.48.io" 443 $ do
  conn <- ask
  state <- liftIO $ atomically $ newTVar def
  void . liftIO . forkIO . forever $ do
    message <- recvConn conn
    case message of
      Left err -> fail $ "Error decoding: " ++ err
      Right resp -> atomically $ modifyTVar state (updateState resp)

    (atomically $ readTVar state) >>= (\x -> putStrLn $ ppBuilds $ lastBuilds x)

  forever $ do
    query $ A.queryLastBuilds
    query $ A.queryOrganizations
    liftIO $ threadDelay $ 5 * 1000000
