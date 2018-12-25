{-# LANGUAGE OverloadedStrings #-}
module Db where

import           Control.Monad.Trans.Maybe

import           Database.Redis
import           Data.ByteString.Char8


getDbConn :: IO Connection
getDbConn = checkedConnect defaultConnectInfo


redisInsertScript :: ByteString
redisInsertScript = pack "\
  \local url_id = redis.call('INCR', KEYS[1])\n\
  \redis.call('SET', ARGV[1] .. url_id, ARGV[2])\n\
  \return url_id"

insertUrl :: Connection -> String -> IO (Either Reply Integer)
insertUrl conn url =
  runRedis conn $ do
    eval redisInsertScript ["id_cntr"] ["urls:", pack url]