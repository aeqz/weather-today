module Util.Json exposing (first)

import Json.Decode as D


first : D.Decoder a -> D.Decoder a
first =
    D.list >> D.andThen firstOrFail


firstOrFail : List a -> D.Decoder a
firstOrFail l =
    case l of
        [] ->
            D.fail "No first element"

        h :: _ ->
            D.succeed h
