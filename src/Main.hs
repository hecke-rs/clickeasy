{-# LANGUAGE OverloadedStrings #-}
{-# HLINT ignore "Redundant do" #-}
module Main where

import Web.Scotty

import Network.Wai.Middleware.RequestLogger

import qualified Text.Blaze.Html5 as H
import Text.Blaze.Html5 ((!))
import Text.Blaze.Html5.Attributes
import Text.Blaze.Html.Renderer.Text (renderHtml)

main :: IO ()
main = do
  putStrLn "starting server..."
  scotty 3000 $ do
    middleware logStdoutDev

    get "/" $ do
      html $ renderHtml
        $ H.docTypeHtml $ do
            H.body $ do
              H.form ! method "post"
                     ! action "/shorten" $ do
                H.input ! type_ "text" ! name "url"
                H.input ! type_ "submit"