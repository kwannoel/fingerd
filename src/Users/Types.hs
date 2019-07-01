module Users.Types where

import Control.Exception
import Data.Typeable
import Database.SQLite.Simple hiding (close)
import Database.SQLite.Simple.Types
import Data.Text (Text)

data DuplicateData =
  DuplicateData
  deriving (Eq, Show, Typeable)

instance Exception DuplicateData

data User =
  User {
      userId :: Integer
    , username :: Text
    , shell :: Text
    , homeDirectory :: Text
    , realName :: Text
    , phone :: Text
  } deriving (Eq, Show)

instance FromRow User where
  fromRow = User <$> field
                 <*> field
                 <*> field
                 <*> field
                 <*> field
                 <*> field

instance ToRow User where
  toRow (User id_ username_ shell_ homeDir
              realName_ phone_) =
    toRow (id_, username_, shell_, homeDir,
           realName_, phone_)

type UserRow =
  (Null, Text, Text, Text, Text, Text)

data FingerRequest = GetAll | Get Text | Insert UserRow | FailedRequest
