{-# LANGUAGE OverloadedStrings #-}
module Views where

import qualified Text.Blaze.Html5              as H
import           Text.Blaze.Html5               ( (!) )
import           Text.Blaze.Html5.Attributes

import qualified Data.Text.Encoding            as TE
import           Data.ByteString

index :: H.Html
index = H.docTypeHtml $ do
  H.body $ do
    H.form ! method "post" ! action "/shorten" $ do
      H.input ! type_ "text" ! name "url"
      H.input ! type_ "submit"

shortened :: ByteString -> H.Html
shortened hash = H.docTypeHtml $ do
  H.body $ do
    H.div $ do
      "shortened to "
      H.span ! style "color: blue;" $ do
        H.toHtml $ TE.decodeUtf8 $ hash

    H.div $
      H.a ! href "/" $ "another?"

urlNotFound :: H.Html
urlNotFound = H.docTypeHtml $ do
  H.body $ do
    H.div $ do
      "no such shortened url slug :("
  