module Scylla.Client.Types where

data ScyllaCfg = ScyllaCfg {
    scyllaHost  :: String
  , scyllaPort :: Int
  } deriving (Show)
