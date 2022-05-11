module Main.City exposing (City, Coordinates, selectCity)

import Array exposing (fromList, get)
import Html exposing (Html, option, select, text)
import Html.Attributes exposing (disabled, selected, value)
import Html.Events exposing (on, targetValue)
import Json.Decode as D
import List exposing (indexedMap)
import Main.I18n exposing (I18n, Language, Literals, for)



-- MODEL


type alias Coordinates =
    { lat : Float, lon : Float }


type alias City =
    { backgroundImage : String
    , location : Coordinates
    , name : I18n String
    }



-- VIEW


selectCity : Literals -> Language -> List City -> Maybe City -> Html City
selectCity literals language cities current =
    let
        cityAt i =
            cities |> fromList |> get i

        cityDecoder =
            targetValue |> D.andThen cityFromValue

        cityFromValue v =
            case v |> String.toInt |> Maybe.andThen cityAt of
                Nothing ->
                    D.fail "Invalid index when selecting city"

                Just city ->
                    D.succeed city

        cityOption i city =
            option
                [ value <| String.fromInt i
                , selected <| Just city == current
                ]
                [ city |> .name |> for language |> text ]

        cityPlaceholderOption =
            option
                [ disabled True
                , selected <| current == Nothing
                ]
                [ literals |> for language |> .selectCity |> text ]
    in
    select [ on "change" cityDecoder ] <|
        cityPlaceholderOption
            :: indexedMap cityOption cities
