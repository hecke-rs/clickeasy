{-# LANGUAGE OverloadedStrings #-}
module Main where

import Web.Scotty
import Network.Wai.Middleware.RequestLogger

main :: IO ()
main = do
  scotty 3000 $ do
    middleware logStdoutDev

    get "/hello" $ do
      text "hello world!"