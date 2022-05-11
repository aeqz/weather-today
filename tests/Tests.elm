module Tests exposing (..)

import ArchitectureTest exposing (..)
import Expect as E
import Main exposing (Msg(..))
import Test exposing (Test)
import TestedApp.Main exposing (..)


staticContentDoesNotChange : Test
staticContentDoesNotChange =
    invariantTest "Static content does not change" app <|
        \initialModel _ finalModel ->
            E.equal ( initialModel.apiKey, initialModel.literals, initialModel.defaultBackgroundImage )
                ( finalModel.apiKey, finalModel.literals, finalModel.defaultBackgroundImage )


onlySelectCitySelectsIt : Test
onlySelectCitySelectsIt =
    msgTest "Select city only when selected" app msgFuzzer <|
        \initialModel msg finalModel ->
            case msg of
                SelectCity newCity ->
                    E.equal (Just newCity)
                        (Maybe.map .city finalModel.cityForecast)

                _ ->
                    E.equal (Maybe.map .city initialModel.cityForecast)
                        (Maybe.map .city finalModel.cityForecast)


onlySelectSelectLanguageSelectsIt : Test
onlySelectSelectLanguageSelectsIt =
    msgTest "Select language only when selected" app msgFuzzer <|
        \initialModel msg finalModel ->
            case msg of
                SelectLanguage newLanguage ->
                    E.equal newLanguage finalModel.language

                _ ->
                    E.equal initialModel.language finalModel.language


onlyAdjustTimezoneAdjustsIt : Test
onlyAdjustTimezoneAdjustsIt =
    msgTest "Adjust timezone only when adjusted" app msgFuzzer <|
        \initialModel msg finalModel ->
            case msg of
                AdjustTimeZone newZone ->
                    E.equal newZone finalModel.zone

                _ ->
                    E.equal initialModel.zone finalModel.zone


alwaysSelectedCity : Test
alwaysSelectedCity =
    msgTestWithPrecondition "Once some city is selected, there is always someone selected"
        app
        msgFuzzer
        (\{ cityForecast } -> cityForecast /= Nothing)
    <|
        \_ _ { cityForecast } -> E.notEqual cityForecast Nothing


selectCityClearsForecastOnlyIfNotSelected : Test
selectCityClearsForecastOnlyIfNotSelected =
    msgTest "Select city clears the forecast only when not selected" app selectCityFuzzer <|
        \initialModel msg finalModel ->
            case msg of
                SelectCity newCity ->
                    if Just newCity == Maybe.map .city initialModel.cityForecast then
                        E.equal initialModel finalModel

                    else
                        E.equal Nothing (Maybe.andThen .forecast finalModel.cityForecast)

                _ ->
                    E.fail "Unexpected message"


selectLanguageClearsForecastOnlyIfNotSelected : Test
selectLanguageClearsForecastOnlyIfNotSelected =
    msgTest "Select language clears the forecast only when not selected" app selectLanguageFuzzer <|
        \initialModel msg finalModel ->
            case msg of
                SelectLanguage newLanguage ->
                    if newLanguage == initialModel.language then
                        E.equal initialModel finalModel

                    else
                        E.equal Nothing (Maybe.andThen .forecast finalModel.cityForecast)

                _ ->
                    E.fail "Unexpected message"


setForecastByGotForecast : Test
setForecastByGotForecast =
    msgTest "Set forecast when received and corresponds" app msgFuzzer <|
        \initialModel msg finalModel ->
            case msg of
                GotForecast language city (Ok newForecast) ->
                    if
                        initialModel.language
                            == language
                            && Just city
                            == Maybe.map .city initialModel.cityForecast
                    then
                        E.equal (Just newForecast)
                            (Maybe.andThen .forecast finalModel.cityForecast)

                    else
                        E.pass

                _ ->
                    E.pass


gotForecastDesNothingIfErrorOrOld : Test
gotForecastDesNothingIfErrorOrOld =
    msgTest "Got forecast does nothing if error or corresponds to an old request" app gotForecastFuzzer <|
        \initialModel msg finalModel ->
            case msg of
                GotForecast _ _ (Err _) ->
                    E.equal initialModel finalModel

                GotForecast language city _ ->
                    if
                        initialModel.language
                            == language
                            && Just city
                            == Maybe.map .city initialModel.cityForecast
                    then
                        E.pass

                    else
                        E.equal initialModel finalModel

                _ ->
                    E.fail "Unexpected message"
