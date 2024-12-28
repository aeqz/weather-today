module Main.Forecast exposing
    ( Forecast
    , RequestParameters
    , Weather
    , forecastList
    , getForecast
    )

import Html exposing (Html, div, h1, img, li, p, text, ul)
import Html.Attributes exposing (class, src)
import Html.Lazy exposing (lazy2)
import Http
import Json.Decode as D
import Main.I18n exposing (Language(..))
import String exposing (concat, fromFloat)
import Time exposing (Zone, toDay, toHour)
import Url.Builder as Url
import Util.Function exposing (on)
import Util.Json exposing (first)
import Util.String exposing (capitalize)
import Util.Time exposing (secondsToPosix)



-- MODEL


type alias Forecast =
    List Weather


type alias Weather =
    { unixUtcSeconds : Int
    , iconCode : String
    , description : String
    , temp : Float
    }


sameDay : Zone -> Weather -> Weather -> Bool
sameDay zone =
    on (==) <|
        .unixUtcSeconds
            >> secondsToPosix
            >> toDay zone



-- VIEW


forecastList : Zone -> Forecast -> Html msg
forecastList zone forecast =
    let
        todayForecast =
            case forecast of
                [] ->
                    []

                (h :: _) as f ->
                    List.filter (sameDay zone h) f
    in
    ul [] <|
        List.map (lazy2 weatherCard zone) todayForecast


weatherCard : Zone -> Weather -> Html msg
weatherCard zone { unixUtcSeconds, iconCode, description, temp } =
    let
        formattedHour =
            concat
                [ toHour zone (secondsToPosix unixUtcSeconds)
                    |> String.fromInt
                    |> String.padLeft 2 '0'
                , ":00"
                ]

        formattedTemp =
            concat
                [ String.fromFloat temp
                , " °C"
                ]

        formattedHourDescription =
            concat
                [ formattedHour
                , " • "
                , capitalize description
                ]
    in
    li []
        [ div []
            [ img [ class "icon", src (iconUrl iconCode) ] [] ]
        , div []
            [ p [ class "hour-description" ] [ text formattedHourDescription ]
            , h1 [ class "temp" ] [ text formattedTemp ]
            ]
        ]



-- COMMAND


type alias RequestParameters =
    { apiKey : String
    , language : Language
    , lat : Float
    , lon : Float
    }


iconUrl : String -> String
iconUrl code =
    String.concat
        [ "https://openweathermap.org/img/wn/"
        , code
        , "@2x.png"
        ]


getForecast : RequestParameters -> Cmd (Result Http.Error Forecast)
getForecast { apiKey, language, lat, lon } =
    Http.get
        { url =
            Url.crossOrigin
                "https://api.openweathermap.org"
                [ "data", "2.5", "forecast" ]
                [ Url.string "lat" <| fromFloat lat
                , Url.string "lon" <| fromFloat lon
                , Url.string "appid" apiKey
                , Url.string "units" "metric"
                , Url.string "lang" <| languageApiCode language
                ]
        , expect = Http.expectJson identity forecastDecoder
        }


forecastDecoder : D.Decoder Forecast
forecastDecoder =
    D.field "list" <|
        D.list weatherDecoder


weatherDecoder : D.Decoder Weather
weatherDecoder =
    D.map4
        Weather
        (D.field "dt" <| D.int)
        (D.field "weather" <| first <| D.field "icon" D.string)
        (D.field "weather" <| first <| D.field "description" D.string)
        (D.field "main" <| D.field "temp" <| D.float)


languageApiCode : Language -> String
languageApiCode language =
    case language of
        En ->
            "en"

        Es ->
            "es"
