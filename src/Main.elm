module Main exposing (Model, Msg(..), Wish, initialModel, main, removeAt, update, view)

import Browser
import Html exposing (Html, button, div, input, text)
import Html.Attributes exposing (placeholder, value)
import Html.Events exposing (onClick, onInput)
import Http
import Json.Encode as Encode


type alias Model =
    { wishlist : Wishlist
    , newWishContent : String
    }


type alias Wishlist =
    { owner : String
    , wishes : List Wish
    }


type alias Wish =
    { content : String }


initialModel : Model
initialModel =
    { wishlist = { owner = "default", wishes = [] }
    , newWishContent = ""
    }


type Msg
    = AddWish
    | UpdateNewWishContent String
    | RemoveWish Int
    | SaveWishlist
    | SaveWishlistResult (Result Http.Error ())


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        AddWish ->
            let
                newWish =
                    { content = model.newWishContent }

                currentWishList =
                    model.wishlist

                newWishlist =
                    { currentWishList | wishes = model.wishlist.wishes ++ [ newWish ] }

                newModel =
                    { model | wishlist = newWishlist, newWishContent = "" }
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
                currentWishList =
                    model.wishlist

                newWishes =
                    removeAt index currentWishList.wishes

                newWishlist =
                    { currentWishList | wishes = newWishes }

                newModel =
                    { model | wishlist = newWishlist }
            in
            ( newModel, Cmd.none )

        SaveWishlist ->
            ( model
            , Http.post
                { url = "/api/save-wishlist"
                , body = Http.jsonBody <| encodeWishlist model.wishlist
                , expect = Http.expectWhatever SaveWishlistResult
                }
            )

        SaveWishlistResult result ->
            case result of
                Ok _ ->
                    ( model, Cmd.none )

                Err _ ->
                    ( model, Cmd.none )


removeAt : Int -> List a -> List a
removeAt index list =
    List.take index list ++ List.drop (index + 1) list


encodeWish : Wish -> Encode.Value
encodeWish wish =
    Encode.object
        [ ( "content", Encode.string wish.content ) ]


encodeWishlist : Wishlist -> Encode.Value
encodeWishlist wishlist =
    Encode.object
        [ ( "owner", Encode.string wishlist.owner )
        , ( "wishes", Encode.list encodeWish wishlist.wishes )
        ]


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
                model.wishlist.wishes
            )
        , input [ placeholder "New wish", onInput UpdateNewWishContent, value model.newWishContent ] []
        , button [ onClick AddWish ] [ text "Add Wish" ]
        , button [ onClick SaveWishlist ] [ text "Save Wishlist" ]
        ]


main : Program () Model Msg
main =
    Browser.element
        { init = \() -> ( initialModel, Cmd.none )
        , view = view
        , update = update
        , subscriptions = \_ -> Sub.none
        }
