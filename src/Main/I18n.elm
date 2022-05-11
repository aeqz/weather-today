module Main.I18n exposing
    ( I18n
    , Language(..)
    , Literals
    , default
    , for
    , languages
    , languagesList
    )

import Html exposing (Html, a, li, text, ul)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)



-- MODEL


type alias I18n a =
    { es : a
    , en : a
    }


type Language
    = Es
    | En


type alias Literals =
    I18n
        { title : String
        , selectCity : String
        , welcomeMessage : String
        , languageName : I18n String
        }


default : Language
default =
    En


languages : List Language
languages =
    [ En, Es ]


for : Language -> I18n a -> a
for l =
    case l of
        Es ->
            .es

        En ->
            .en



-- VIEW


languagesList : Literals -> Language -> Html Language
languagesList literals language =
    ul [] <|
        List.map (languageButton literals language) languages


languageButton : Literals -> Language -> Language -> Html Language
languageButton literals language l =
    li
        []
        [ a
            [ onClick l
            , class <|
                if language == l then
                    "selected"

                else
                    ""
            ]
            [ literals |> for language |> .languageName |> for l |> text ]
        ]
