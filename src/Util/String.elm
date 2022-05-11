module Util.String exposing (capitalize)


capitalize : String -> String
capitalize s =
    case String.toList s of
        [] ->
            ""

        h :: t ->
            String.fromList <|
                Char.toUpper h
                    :: t
