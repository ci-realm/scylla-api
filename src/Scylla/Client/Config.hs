{-# LANGUAGE OverloadedStrings #-}
module Scylla.Client.Config where

import System.Environment
import System.Directory
import System.FilePath.Posix
import System.Exit (exitFailure)

import qualified Data.Text as T
import qualified Data.Text.IO as TIO

import Data.Ini.Config

import Scylla.Client.Types

iniParser = section "scylla-api" $ do
  host <- T.unpack <$> field "host"
  port <- fieldDefOf "port" number 443
  return $ ScyllaCfg host port

parseScyllaCfg :: FilePath -> IO (Either String ScyllaCfg)
parseScyllaCfg fpath = do
  rs <- TIO.readFile fpath
  return $ parseIniFile rs iniParser

-- If SCYLLA_API_CFG env var is set, try parsing config file it is pointing to,
-- return default config otherwise.
envScyllaCfg :: IO (ScyllaCfg)
envScyllaCfg = do
  menv <- lookupEnv "SCYLLA_API_CFG"
  case menv of
    Nothing -> do
      hom <- getHomeDirectory
      let homPth = hom </> ".scylla-api.conf"
      tst <- doesFileExist homPth
      case tst of
        False -> fail "No config found, set SCYLLA_API_CFG env var or create ~/.scylla-api.conf"
        True -> do
          res <- parseScyllaCfg homPth
          case res of
           Left err -> putStrLn ("Unable to parse config: " ++ err) >> exitFailure
           Right cfg -> return cfg
    Just env -> do
      res <- parseScyllaCfg env
      case res of
        Left err -> putStrLn ("Unable to parse config: " ++ err) >> exitFailure
        Right cfg -> return cfg

