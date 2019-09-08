{-# LANGUAGE OverloadedStrings #-}
{- HLINT ignore "Redundant do" -}
module Main where

import           Web.Scotty

import           Control.Monad.IO.Class

import           Network.HTTP.Types.Status
import           Network.Wai.Middleware.RequestLogger

import           Text.Blaze.Html.Renderer.Text  ( renderHtml )


import qualified Data.Text.Lazy as L

import           Debug.Trace

import           Db
import qualified Views as V

main :: IO ()
main = do
  putStrLn "connecting to redis..."
  redisConn <- getDbConn

  putStrLn "starting server..."
  scotty 3000 $ do
    middleware logStdoutDev

    get "/" $ do
      html $ renderHtml V.index

    post "/shorten" $ do
      url           <- param "url"
      storageResult <- liftIO $ insertUrl redisConn url

      case storageResult of
        Right id  -> html $ renderHtml $ V.shortened $ idToHash id
        Left  err -> raise $ L.pack $ show err
    
    get "/:hash" $ do
      hash <- param "hash"
      case idFromHash hash of
        Just id -> do
          urlResult <- liftIO $ getUrl redisConn id
          liftIO $ traceIO $ show urlResult

          case urlResult of
            Right url' -> case url' of
              Just url -> redirect $ L.fromStrict url
              Nothing -> do 
                status status404
                html $ renderHtml V.urlNotFound
            Left err -> raise $ L.pack $ show err
        Nothing -> raise "can't dehash id! fuckus :("