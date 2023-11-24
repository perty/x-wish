module Main exposing (Model, Msg(..), Wish, initialModel, main, removeAt, update, view)

import Browser
import Html exposing (Html, button, div, input, text)
import Html.Attributes exposing (placeholder, value)
import Html.Events exposing (onClick, onInput)


type alias Wish =
    { content : String
    , fulfilledBy : Maybe String
    }


type alias Model =
    { wishes : List Wish
    , newWishContent : String
    }


type Msg
    = AddWish
    | UpdateNewWishContent String
    | RemoveWish Int
    | SaveWishlist


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        AddWish ->
            let
                newWish =
                    { content = model.newWishContent, fulfilledBy = Nothing }

                newModel =
                    { model | wishes = model.wishes ++ [ newWish ], newWishContent = "" }
            in
            ( newModel, Cmd.none )

        UpdateNewWishContent newContent ->
            let
                newModel =
                    { model | newWishContent = newContent }
            in
            ( newModel, Cmd.none )

        RemoveWish index ->
            let
                newModel =
                    { model | wishes = removeAt index model.wishes }
            in
            ( newModel, Cmd.none )

        SaveWishlist ->
            -- Here you would save the wishlist to the database.
            -- This is a placeholder implementation.
            ( model, Cmd.none )


removeAt : Int -> List a -> List a
removeAt index list =
    List.take index list ++ List.drop (index + 1) list


main : Program () Model Msg
main =
    Browser.element
        { init = \() -> ( initialModel, Cmd.none )
        , view = view
        , update = update
        , subscriptions = \_ -> Sub.none
        }


initialModel : Model
initialModel =
    { wishes = []
    , newWishContent = ""
    }


view : Model -> Html Msg
view model =
    div []
        [ div []
            (List.indexedMap
                (\index wish ->
                    div []
                        [ text wish.content
                        , button [ onClick (RemoveWish index) ] [ text "Remove" ]
                        ]
                )
                model.wishes
            )
        , input [ placeholder "New wish", onInput UpdateNewWishContent, value model.newWishContent ] []
        , button [ onClick AddWish ] [ text "Add Wish" ]
        , button [ onClick SaveWishlist ] [ text "Save Wishlist" ]
        ]
