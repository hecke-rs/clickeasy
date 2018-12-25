{-# LANGUAGE OverloadedStrings #-}
{-# HLINT ignore "Redundant do" #-}
module Main where

import           Web.Scotty

import           Control.Monad.IO.Class

import           Network.Wai.Middleware.RequestLogger

import qualified Text.Blaze.Html5              as H
import           Text.Blaze.Html5               ( (!) )
import           Text.Blaze.Html5.Attributes
import           Text.Blaze.Html.Renderer.Text  ( renderHtml )

import qualified Data.Text.Lazy                as LText

import           Debug.Trace

import           Db

indexTemplate :: H.Html
indexTemplate = H.docTypeHtml $ do
  H.body $ do
    H.form ! method "post" ! action "/shorten" $ do
      H.input ! type_ "text" ! name "url"
      H.input ! type_ "submit"

shortenedTemplate :: Integer -> H.Html
shortenedTemplate id = H.docTypeHtml $ do
  H.body $ do
    H.div $ do
      "shortened to "
      H.span ! style "color: red;" $ do
        H.toHtml id
    H.div $
      H.a ! href "/" $ "another?"

main :: IO ()
main = do
  putStrLn "connecting to redis..."
  redisConn <- getDbConn

  putStrLn "starting server..."
  scotty 3000 $ do
    middleware logStdoutDev

    get "/" $ do
      html $ renderHtml indexTemplate

    post "/shorten" $ do
      url           <- param "url"
      storageResult <- liftIO $ insertUrl redisConn url

      case storageResult of
        Right id  -> html $ renderHtml $ shortenedTemplate id
        Left  err -> raise $ LText.pack $ show err
