module TestedApp.Main exposing
    ( adjustTimeZoneFuzzer
    , app
    , gotForecastFuzzer
    , msgFuzzer
    , selectCityFuzzer
    , selectLanguageFuzzer
    )

import ArchitectureTest exposing (TestedApp, TestedModel(..), TestedUpdate(..))
import Fuzz as F exposing (Fuzzer)
import Http exposing (Error(..))
import Main exposing (..)
import Main.City exposing (City, Coordinates)
import Main.Forecast exposing (Forecast, Weather)
import Main.I18n exposing (I18n, Language(..), Literals, languages)
import Time exposing (Zone, customZone, utc)


app : TestedApp Model Msg
app =
    { model = FuzzedModel modelFuzzer
    , update = NormalUpdate update
    , msgFuzzer = msgFuzzer
    , modelToString = Debug.toString
    , msgToString = Debug.toString
    }



-- FUZZ


modelFuzzer : Fuzzer Model
modelFuzzer =
    F.map3
        (\( apiKey, zone, cities ) ( literals, language, defaultBackgroundImage ) cityForecast ->
            { apiKey = apiKey
            , zone = zone
            , cities = cities
            , literals = literals
            , language = language
            , defaultBackgroundImage = defaultBackgroundImage
            , cityForecast = cityForecast
            }
        )
        (F.triple F.string zoneFuzzer (F.list cityFuzzer))
        (F.triple literalsFuzzer languageFuzzer F.string)
    <|
        F.maybe <|
            F.map2
                (\city forecast ->
                    { city = city
                    , forecast = forecast
                    }
                )
                cityFuzzer
            <|
                F.maybe forecastFuzzer


msgFuzzer : Fuzzer Msg
msgFuzzer =
    F.oneOf
        [ adjustTimeZoneFuzzer
        , selectLanguageFuzzer
        , selectCityFuzzer
        , gotForecastFuzzer
        ]


adjustTimeZoneFuzzer : Fuzzer Msg
adjustTimeZoneFuzzer =
    F.map AdjustTimeZone zoneFuzzer


selectLanguageFuzzer : Fuzzer Msg
selectLanguageFuzzer =
    F.map SelectLanguage languageFuzzer


selectCityFuzzer : Fuzzer Msg
selectCityFuzzer =
    F.map SelectCity cityFuzzer


gotForecastFuzzer : Fuzzer Msg
gotForecastFuzzer =
    F.map3 GotForecast languageFuzzer cityFuzzer <|
        F.result errorFuzzer forecastFuzzer


i18nFuzzer : Fuzzer a -> Fuzzer (I18n a)
i18nFuzzer f =
    F.map2
        (\es en ->
            { es = es
            , en = en
            }
        )
        f
        f


forecastFuzzer : Fuzzer Forecast
forecastFuzzer =
    F.list weatherFuzzer


weatherFuzzer : Fuzzer Weather
weatherFuzzer =
    F.map4
        (\unixUtcSeconds iconCode description temp ->
            { unixUtcSeconds = unixUtcSeconds
            , iconCode = iconCode
            , description = description
            , temp = temp
            }
        )
        F.int
        F.string
        F.string
        F.float


errorFuzzer : Fuzzer Error
errorFuzzer =
    F.oneOf
        [ F.map BadUrl F.string
        , F.constant Timeout
        , F.constant NetworkError
        , F.map BadStatus F.int
        , F.map BadBody F.string
        ]


zoneFuzzer : Fuzzer Zone
zoneFuzzer =
    F.oneOf
        [ F.constant utc
        , F.map2 customZone F.int <|
            F.list <|
                F.map2
                    (\start offset ->
                        { start = start
                        , offset = offset
                        }
                    )
                    F.int
                    F.int
        ]


cityFuzzer : Fuzzer City
cityFuzzer =
    F.map3
        (\backgroundImage location name ->
            { backgroundImage = backgroundImage
            , location = location
            , name = name
            }
        )
        F.string
        coordinatesFuzzer
    <|
        i18nFuzzer F.string


coordinatesFuzzer : Fuzzer Coordinates
coordinatesFuzzer =
    F.map2
        (\lat lon ->
            { lat = lat
            , lon = lon
            }
        )
        F.float
        F.float


literalsFuzzer : Fuzzer Literals
literalsFuzzer =
    i18nFuzzer <|
        F.map4
            (\title selectCity welcomeMessage languageName ->
                { title = title
                , selectCity = selectCity
                , welcomeMessage = welcomeMessage
                , languageName = languageName
                }
            )
            F.string
            F.string
            F.string
        <|
            i18nFuzzer F.string


languageFuzzer : Fuzzer Language
languageFuzzer =
    F.oneOf <|
        List.map F.constant <|
            languages
