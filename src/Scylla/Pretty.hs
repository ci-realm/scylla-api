{-# LANGUAGE RecordWildCards #-}
{-# LANGUAGE OverloadedStrings #-}
module Scylla.Pretty where

import Control.Monad (mfilter)

import Data.Time
import Data.Time.Format
import Data.Time.LocalTime

import Data.Default
import Data.List.Split

import Text.PrettyPrint.ANSI.Leijen hiding ((<$>))
import Text.Printf
import Text.Time.Pretty

import qualified Scylla.Types.API         as A
import qualified Scylla.Types.Build       as B
import qualified Scylla.Types.BuildStatus as BS
import qualified Scylla.Types.Org         as O
import qualified Scylla.Types.Log         as L
import qualified Scylla.Types.ShortLog    as S

data PPConf = PPConf {
    timeRenderer :: ZonedTime -> String
  , renderer :: Doc -> SimpleDoc
  }

instance Default PPConf where
  def = PPConf {
    timeRenderer = formatTime defaultTimeLocale "%F %X"
  , renderer = renderPretty 0.4 80
  }

ppConfCompact :: IO PPConf
ppConfCompact =
  return $ def {
    renderer = renderCompact
  }

ppConfRelative = do
  now <- getCurrentTime
  return $ def {
    timeRenderer =  (prettyTimeAuto now) . zonedTimeToUTC
  }

replace a b = map $ maybe b id . mfilter (/= a) . Just
ppList pp x = vcat $ map pp x

ppBuild cfg@PPConf{..} x = displayS (renderer (ppBuild' cfg x)) ""
ppBuilds cfg@PPConf{..} x = displayS (renderer (ppBuilds' cfg x)) ""
ppOrgs cfg@PPConf{..} x = displayS (renderer (ppList ppOrg' x)) ""
ppShortLog cfg@PPConf{..} x = displayS (renderer (ppList ppShortLog' x)) ""

statusColor BS.Success  = green
statusColor BS.Failure  = red
statusColor BS.Queue    = blue
statusColor BS.Build    = cyan
statusColor BS.Clone    = magenta
statusColor BS.Checkout = white

ppTime x = string $ formatTime defaultTimeLocale "%F %X" x

ppTimeRel now zt = string $ prettyTimeAuto now $ zonedTimeToUTC zt

ppBuilds' cfg = ppList (ppBuild' cfg)

ppBuild' PPConf{..} B.Build{..} =
  (statusColor status (string $ printf "%5d %8s" id (show status)))
  <+> (yellow $ string $ timeRenderer createdAt)
  <+> (bold $ green $ string projectName)
  <+> (ppFinished status finishedAt createdAt)
  <>  (maybe empty (\x -> hardline <> ppLog' x) log)
  where
    ppFinished BS.Success end start = ppDiff end start
    ppFinished BS.Failure end start = ppDiff end start
    ppFinished _ _ _ = empty
    ppDiff end start = cyan $ string $ "Duration: " ++ (ppHumanDiff $ round (diffUTCTime (zonedTimeToUTC end) (zonedTimeToUTC start)))

ppHumanDiff x | x > 3600 = (show $ x `div` 3600) ++ "h " ++ (ppHumanDiff $ x `mod` 3600)
ppHumanDiff x | x > 60 = (show $ x `div` 60) ++ "m " ++ (ppHumanDiff $ x `mod` 60)
ppHumanDiff x = show x ++ "s"

ppLog'  = ppList ppLog1'

ppLog1' L.Log{..} =
  -- (blue $ ppTime createdAt)
  -- <+>
  (ppList string (splitOn "\\n" line))

ppOrg' O.Org{..} =
  (red $ string owner)
  <+> (yellow $ string url)
  <+> "Build count:"
  <+> (bold $ green $ string $ printf "%5d" buildCount)

ppShortLog' S.ShortLog{..} =
  (yellow $ ppTime time)
  <+> (string line)
