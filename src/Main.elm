module Main exposing (..)

import Browser exposing (Document)
import Html exposing (Html, div, p, text)
import Html.Attributes exposing (id, style)
import Html.Lazy exposing (lazy, lazy2, lazy4)
import Http exposing (Error)
import Main.City exposing (City, selectCity)
import Main.Forecast exposing (Forecast, forecastList, getForecast)
import Main.I18n exposing (Language(..), Literals, default, for, languagesList)
import String exposing (concat)
import Task
import Time exposing (Zone, here, utc)



-- MAIN


main : Program Flags Model Msg
main =
    Browser.document
        { init = init
        , subscriptions = subscriptions
        , update = update
        , view = view
        }



-- MODEL


type alias Flags =
    { apiKey : String
    , cities : List City
    , literals : Literals
    , defaultBackgroundImage : String
    }


type alias Model =
    { apiKey : String
    , zone : Time.Zone
    , cities : List City
    , literals : Literals
    , language : Language
    , defaultBackgroundImage : String
    , cityForecast : Maybe CityForecast
    }


type alias CityForecast =
    { city : City
    , forecast : Maybe Forecast
    }


init : Flags -> ( Model, Cmd Msg )
init { apiKey, cities, literals, defaultBackgroundImage } =
    ( { apiKey = apiKey
      , zone = utc
      , cities = cities
      , literals = literals
      , language = default
      , cityForecast = Nothing
      , defaultBackgroundImage = defaultBackgroundImage
      }
    , Task.perform AdjustTimeZone here
    )


title : Model -> String
title { literals, language } =
    literals |> for language |> .title


isCitySelected : City -> Model -> Bool
isCitySelected city { cityForecast } =
    Just city == Maybe.map .city cityForecast


isLanguageSelected : Language -> Model -> Bool
isLanguageSelected l { language } =
    l == language


backgroundImage : Model -> String
backgroundImage { cityForecast, defaultBackgroundImage } =
    case cityForecast of
        Nothing ->
            defaultBackgroundImage

        Just { city } ->
            city.backgroundImage


selectedCity : Model -> Maybe City
selectedCity { cityForecast } =
    Maybe.map .city cityForecast


forecastOrEmpty : Model -> Forecast
forecastOrEmpty { cityForecast } =
    cityForecast
        |> Maybe.andThen .forecast
        |> Maybe.withDefault []



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none



-- UPDATE


type Msg
    = AdjustTimeZone Zone
    | SelectLanguage Language
    | SelectCity City
    | GotForecast Language City (Result Error Forecast)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        AdjustTimeZone zone ->
            ( { model | zone = zone }, Cmd.none )

        SelectLanguage language ->
            if isLanguageSelected language model then
                ( model, Cmd.none )

            else
                case model.cityForecast of
                    Nothing ->
                        ( { model | language = language }, Cmd.none )

                    Just { city } ->
                        ( { model
                            | language = language
                            , cityForecast =
                                Just
                                    { city = city
                                    , forecast = Nothing
                                    }
                          }
                        , Cmd.map (GotForecast language city)
                            (getForecast
                                { apiKey = model.apiKey
                                , language = language
                                , lat = city.location.lat
                                , lon = city.location.lon
                                }
                            )
                        )

        SelectCity city ->
            if isCitySelected city model then
                ( model, Cmd.none )

            else
                ( { model
                    | cityForecast =
                        Just
                            { city = city
                            , forecast = Nothing
                            }
                  }
                , Cmd.map (GotForecast model.language city)
                    (getForecast
                        { apiKey = model.apiKey
                        , language = model.language
                        , lat = city.location.lat
                        , lon = city.location.lon
                        }
                    )
                )

        GotForecast language city response ->
            if
                isLanguageSelected language model
                    && isCitySelected city model
            then
                case response of
                    Err _ ->
                        ( model, Cmd.none )

                    Ok forecast ->
                        ( { model
                            | cityForecast =
                                Just
                                    { city = city
                                    , forecast = Just forecast
                                    }
                          }
                        , Cmd.none
                        )

            else
                ( model, Cmd.none )



-- VIEW


view : Model -> Document Msg
view ({ literals, language, cities, zone, cityForecast } as model) =
    { title = title model
    , body =
        [ lazy background <| backgroundImage model
        , div []
            [ div [ id "header" ]
                [ div [] []
                , div [ id "city-select" ]
                    [ Html.map SelectCity <|
                        lazy4 selectCity literals language cities <|
                            selectedCity model
                    ]
                , div [ id "language-list" ]
                    [ Html.map SelectLanguage <|
                        lazy2 languagesList literals language
                    ]
                ]
            , div [ id "content" ]
                [ lazy2 welcome (cityForecast == Nothing) <|
                    .welcomeMessage <|
                        for language literals
                , div [ id "forecast-list" ]
                    [ lazy2 forecastList zone <|
                        forecastOrEmpty model
                    ]
                ]
            ]
        ]
    }


background : String -> Html msg
background url =
    div
        [ id "background"
        , style "background-image" <|
            concat [ "url('", url, "')" ]
        ]
        []


welcome : Bool -> String -> Html msg
welcome showing message =
    if showing then
        div
            [ id "welcome" ]
            [ div [] [ p [] [ text message ] ] ]

    else
        div [] []
