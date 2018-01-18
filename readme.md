Delta
=====

_A library for running a small, stateful event loop._

__NB: This primarily a practical Haskell learning project that I'll use as a playground for various purposes.  It's not meant to be Actually Used.__

"Delta" because the handler is meant to take a new, desired value alongside the current value, and act accordingly with their _delta_.

```haskell
newtype Handler a = Handler
  { handle :: Event a -> Event a -> Either String a
  }
```

## Currently

A single-threaded event loop is provided by `run`, which takes a source, a handler, and an initial value:

```haskell
run :: Event a -> Source (LoopT a) a -> Handler a -> IO ()
```


### Examples

#### Mono

Mono is an example loop which should only grow, and it returns an error (`Left`) on a delta < 0.

```haskell
module Main where

import Control.Monad.State
import Control.Monad.Trans.Class
import System.IO

import Delta

import Debug.Trace (trace)

monoHandler :: Handler Int
monoHandler =
  Handler $ \(Event curr) (Event now) ->
    let delt = now - curr
    in trace ("delta was: " ++ show delt) (go delt)
  where
    go d
      | d >= 0 = Right d
      | otherwise = Left "error: delt shouldn't be less than zero"

monoSource :: Source (LoopT Int) Int
monoSource =
  Source $ do
    lift $ putStrLn "Enter a value: "
    lift $ putStr "> "
    lift $ hFlush stdout
    val <- lift getLine
    return $ Event $ read val

main :: IO ()
main = run (Event 0) monoSource monoHandler
```
