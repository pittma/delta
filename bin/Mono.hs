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
