{-# LANGUAGE RecordWildCards #-}
{-# LANGUAGE OverloadedStrings #-}
module Scylla.Pretty where

import Control.Monad (mfilter)

import Data.Time.Format
import Data.Time.LocalTime

import Data.List.Split

import Text.PrettyPrint.ANSI.Leijen hiding ((<$>))
import Text.Printf

import qualified Scylla.Types.API         as A
import qualified Scylla.Types.Build       as B
import qualified Scylla.Types.BuildStatus as BS
import qualified Scylla.Types.Org         as O
import qualified Scylla.Types.Log         as L
import qualified Scylla.Types.ShortLog    as S

--getCurrentTimeZone

replace a b = map $ maybe b id . mfilter (/= a) . Just
ppList pp x = vcat $ map pp x

ppBuild x = displayS (renderPretty 0.4 80 (ppBuild' x)) ""
ppBuilds x = displayS (renderPretty 0.4 80 (ppBuilds' x)) ""
ppOrgs x = displayS (renderPretty 0.4 80 (ppList ppOrg' x)) ""
ppShortLog x = displayS (renderPretty 0.4 80 (ppList ppShortLog' x)) ""

statusColor BS.Success  = green
statusColor BS.Failure  = red
statusColor BS.Queue    = blue
statusColor BS.Build    = cyan
statusColor BS.Clone    = magenta
statusColor BS.Checkout = white
statusColor _ = id

ppTime x = string $ formatTime defaultTimeLocale "%F %X" x

ppBuilds' = ppList ppBuild'

ppBuild' B.Build{..} =
  (statusColor status (string $ printf "%5d %8s" id (show status)))
  <+> (yellow $ ppTime createdAt)
  <+> (bold $ green $ string projectName)
  -- <+> ppTime finishedAt
  <> (maybe empty (\x -> hardline <> ppLog' x) log)

ppLog'  = ppList ppLog1'

ppLog1' L.Log{..} =
  -- (blue $ ppTime createdAt)
  -- <+>
  (ppList string (splitOn "\\n" line))

ppOrg' O.Org{..} =
  (string owner)
  <+> (string url)
  <+> "Build count:"
  <+> (string $ printf "%5d" buildCount)

ppShortLog' S.ShortLog{..} =
  (yellow $ ppTime time)
  <+> (string line)
