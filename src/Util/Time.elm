module Util.Time exposing (secondsToPosix)

import Time exposing (Posix, millisToPosix)


secondsToPosix : Int -> Posix
secondsToPosix s =
    millisToPosix <| s * 1000
