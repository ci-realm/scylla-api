{-# LANGUAGE OverloadedStrings #-}

--import Control.Concurrent
--import Control.Concurrent.STM
import Control.Monad.IO.Class

import Scylla.Client
-- TMP
import Scylla.Client.Websocket
import qualified Scylla.Types.API as A

import Scylla.Pretty

main = runScylla

main' = withScylla "ci.48.io" 443 $ do
  query $ A.queryBuild 12
  --x <- recv
  --case x of
  --  Right (A.RBuild b) -> liftIO . putStrLn $ ppBuild b

  --query $ A.queryRestart 17


{-
 - for primitive api
 -
lastBuilds' :: Scylla [B.Build]
lastBuilds' = do
  q <- apiQuery $ Query LastBuilds Nothing
  case q of
    Right (RBuilds bs) -> return bs
    _ -> fail "Expected builds"


build' :: String -> Integer -> Scylla B.Build
build' proj id = do
  q <- apiQuery $ Query Build $ Just $ M.fromList [("id", show id), ("projectName", proj)]
  case q of
    Right (RBuild b) -> return b
    _ -> fail "Expected build"

-- request/response wrapper
apiQuery q = do
  conn <- ask
  liftIO $ sendTextData conn $ encode q
  message <- liftIO $ receiveData conn
  liftIO $ print message
  return $ (eitherDecode message :: Either String Response)
-}
