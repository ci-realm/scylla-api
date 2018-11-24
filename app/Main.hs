{-# LANGUAGE OverloadedStrings #-}

import Control.Monad.IO.Class

import Options.Applicative
import Data.Semigroup ((<>))

import Scylla.Client
import Scylla.Client.Websocket
import qualified Scylla.Types.API as A
import Scylla.Pretty

main = do
  p <- execParser opts
  ppCfg <- ppConfRelative

  withScylla $ do
    query p
    x <- recv
    case x of
      Right (A.RBuild x)     -> liftIO . putStrLn $ ppBuild ppCfg x
      Right (A.RBuilds x)    -> liftIO . putStrLn $ ppBuilds ppCfg x
      Right (A.ROrgBuilds x) -> liftIO . putStrLn $ ppBuilds ppCfg x
      Right (A.ROrgs x)      -> liftIO . putStrLn $ ppOrgs ppCfg x
      Right  A.RRestart      -> liftIO . putStrLn $ "Restarted"
      Left err               -> liftIO . fail $ "Error: " ++ err

opts = info (cmdParser <**> helper)
  (fullDesc
  <> progDesc "scylla-api"
  <> header "scylla API client")

parseBuild = A.queryBuild <$> (argument auto (metavar "ID"))
parseRestart = A.queryRestart <$> (argument auto (metavar "ID"))
parseOrgBuilds = A.queryOrganizationBuilds <$> (argument str (metavar "ORGNAME"))

cmdParser = subparser
  (  command "lastBuilds" (info (pure A.queryLastBuilds) (progDesc "Query last builds"))
  <> command "build" (info parseBuild (progDesc "Query build"))
  <> command "organizations" (info (pure A.queryOrganizations) (progDesc "Query organizations"))
  <> command "organizationBuilds" (info parseOrgBuilds (progDesc "Query organization builds"))
  <> command "restart" (info parseRestart (progDesc "Restart builds"))
  )
