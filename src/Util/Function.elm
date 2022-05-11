module Util.Function exposing (on)


on : (b -> b -> c) -> (a -> b) -> a -> a -> c
on b u x y =
    b (u x) (u y)
