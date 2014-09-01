module Fib where

import Foreign.C.Types

foreign export ccall "fib" c_fib :: CInt -> IO CInt

c_fib :: CInt -> IO CInt
c_fib n = return (fromIntegral (fib (fromIntegral n)))

fib :: Int -> Int
fib n = fibs !! n
  where
    fibs = 0 : 1 : zipWith (+) fibs (tail fibs)
