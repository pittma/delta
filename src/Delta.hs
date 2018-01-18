module Delta where

import Control.Monad
import Control.Monad.State
import Control.Monad.Trans.Class

newtype Event a =
  Event a
  deriving (Show)

type LoopT a = StateT (Event a) IO

newtype Source m a = Source
  { yield :: m (Event a)
  }

newtype Handler a = Handler
  { handle :: Event a -> Event a -> Either String a
  }

run :: Event a -> Source (LoopT a) a -> Handler a -> IO ()
run init src hndlr = do
  runStateT
    (forever $ do
       curr <- get
       ev <- yield src
       case handle hndlr curr ev of
         (Left err) -> lift $ putStrLn err
         (Right _) -> put ev)
    init
  putStrLn "exiting"
