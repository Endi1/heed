{-# LANGUAGE DataKinds #-}
module Controllers.RequestHelpers (buildUrl, makeRequestToFeed) where

import Data.Text
import Network.HTTP.Req
import Data.ByteString (ByteString)
import Text.URI (mkURI)


buildUrl :: Text -> IO (Maybe (Either (Url 'Http) (Url 'Https)))
buildUrl u = do
  uri <- mkURI u
  let urlMaybe = useURI uri
  case urlMaybe of
    Nothing -> return Nothing
    Just urlEither -> case urlEither of
      Left url -> return $ Just $ Left $ fst url
      Right url -> return $ Just $ Right $ fst url

makeRequestToFeed :: Url s -> IO ByteString
makeRequestToFeed url = runReq defaultHttpConfig $ do
  bs <- req GET url NoReqBody bsResponse mempty
  return $ responseBody bs