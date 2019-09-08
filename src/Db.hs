{-# LANGUAGE OverloadedStrings #-}
module Db where

import           Control.Monad.Trans.Maybe

import           Database.Redis

import qualified Web.Hashids as HID

import Data.ByteString.Char8
import           Data.Text.Encoding
import qualified Data.Text as T
import Data.Maybe
import           Debug.Trace

getDbConn :: IO Connection
getDbConn = checkedConnect defaultConnectInfo

redisInsertScript :: ByteString
redisInsertScript = encodeUtf8 "\
  \local url_id = redis.call('INCR', KEYS[1])\n\
  \redis.call('SET', ARGV[1] .. url_id, ARGV[2])\n\
  \return url_id"

insertUrl :: Connection -> T.Text -> IO (Either Reply Integer)
insertUrl conn url =
  runRedis conn $ eval redisInsertScript ["id_cntr"] ["urls:", encodeUtf8 url]

getUrl :: Connection -> Integer -> IO (Either Reply (Maybe T.Text))
getUrl conn id = do
  result <- runRedis conn $
    get (pack $ "urls:" ++ show id)
  return $ (fmap . fmap) decodeUtf8 result
  

------

hashCtx :: HID.HashidsContext
hashCtx = HID.hashidsSimple "hashy hashy hash"

idToHash :: Integer -> ByteString
idToHash = HID.encode hashCtx . fromInteger

idFromHash :: ByteString -> Maybe Integer
idFromHash = fmap toInteger . listToMaybe . HID.decode hashCtx