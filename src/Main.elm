port module Main exposing (ImagePortData, Model, Msg(..), alwaysPrevent, fileContentRead, fileSelected, initialModel, main, onDragOver, onDrop, subscriptions, update, view)

import Browser
import Css exposing (..)
import Html.Styled exposing (Html, button, div, img, input, text)
import Html.Styled.Attributes exposing (..)
import Html.Styled.Events exposing (custom, on, onClick, preventDefaultOn, targetValue)
import Json.Decode as Json


type alias ImagePortData =
    { contents : String
    , fileName : String
    , id : String
    , totalFiles : Int
    }


onDrop : (Json.Value -> msg) -> Html.Styled.Attribute msg
onDrop msg =
    preventDefaultOn "drop" <| Json.map alwaysPrevent (Json.map msg Json.value)


alwaysPrevent : a -> ( a, Bool )
alwaysPrevent x =
    ( x, True )


onDragOver : msg -> Html.Styled.Attribute msg
onDragOver msg =
    preventDefaultOn "dragover" (Json.succeed ( msg, True ))


port fileSelected : { id : String, event : Json.Value } -> Cmd msg


port fileContentRead : (List ImagePortData -> msg) -> Sub msg


type alias Model =
    { count : Int, filesBase64 : List String }


initialModel : String -> ( Model, Cmd msg )
initialModel flag =
    ( { count = 0, filesBase64 = [] }, Cmd.none )


type Msg
    = Increment
    | Decrement
    | HandleDrop Json.Value
    | FileRead (List ImagePortData)
    | DummyMsg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Increment ->
            ( { model | count = model.count + 1 }, Cmd.none )

        Decrement ->
            ( { model | count = model.count - 1 }, Cmd.none )

        HandleDrop string ->
            ( model, fileSelected { id = "dropzone", event = string } )

        FileRead files ->
            let
                fileBase64 =
                    List.map (\x -> x.contents) files
            in
            ( { model | filesBase64 = fileBase64 }, Cmd.none )

        _ ->
            ( model, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions model =
    fileContentRead FileRead


view : Model -> Html Msg
view model =
    div [ css [ position relative, Css.width (px 500), Css.height (px 500) ] ]
        [ input [ css [ Css.width (px 500), Css.height (px 500), opacity (num 0), zIndex (int 2) ], dropzone "true", onDrop HandleDrop, Html.Styled.Attributes.id "dropzone", onDragOver DummyMsg, type_ "file", Html.Styled.Attributes.accept "image/x-png,image/gif,image/jpeg,application/pdf", Html.Styled.Attributes.multiple True ]
            []
        , div [ css [ Css.width (px 500), position absolute, top (px 0), left (px 0), Css.height (px 500), border3 (px 2) dashed (hex "4a4a4a"), displayFlex, alignItems center, justifyContent center, pointerEvents none ] ] [ text "Drop File Here" ]
        , div [] (List.map (\x -> img [ Html.Styled.Attributes.src x, css [ maxWidth (px 80) ] ] []) model.filesBase64)
        ]


main : Program String Model Msg
main =
    Browser.element
        { init = initialModel
        , subscriptions = subscriptions
        , view = view >> Html.Styled.toUnstyled
        , update = update
        }
