module Scylla.Client where

import Control.Concurrent
import Control.Concurrent.STM

import Control.Monad
import Control.Monad.Reader

import Data.Default

import Scylla.Types
import qualified Scylla.Types.API as A
import Scylla.Client.Websocket

liveClientExample = do
  (state, updates, queries) <- initScylla
  void . forkIO . forever $ do
    up <- atomically $ readTChan updates
    print up

  runScylla state updates queries

initScylla :: IO ((TVar ScyllaState, TChan ScyllaState, TChan A.Query))
initScylla = atomically $ (,,) <$> newTVar def <*> newTChan <*> newTChan

runScylla :: TVar ScyllaState -> TChan ScyllaState -> TChan A.Query -> IO ()
runScylla state updates queries = do
  withScylla $ do
    conn <- ask
    void . liftIO . forkIO . forever $ do
      message <- recvConn conn
      case message of
        Left err -> fail $ "Error decoding: " ++ err
        Right resp -> do
          atomically $ do
            oldState <- readTVar state
            let newState = updateState resp oldState

            when (oldState /= newState) $ do
              writeTVar state newState
              writeTChan updates newState

    void . liftIO . forkIO . forever $ do
      q <- atomically $ readTChan queries
      queryConn conn q

    forever $ do
      query $ A.queryLastBuilds
      query $ A.queryOrganizations
      liftIO $ threadDelay $ 5 * 1000000
