module Main exposing (Model, Msg(..), Wish, Wishlist, main)

import Browser
import Html exposing (Html, button, div, input, text)
import Html.Attributes exposing (placeholder, type_, value)
import Html.Events exposing (onClick, onInput)
import Http
import Json.Decode as Decode exposing (Decoder, field, int, map3, nullable, string)
import Json.Encode as Encode


type alias Model =
    { wishlist : Wishlist
    , newWishContent : String
    , token : Maybe String
    , username : String
    , password : String
    , otherUser : String
    , errorMessage : String
    }


type alias Wishlist =
    { owner : String
    , wishes : List Wish
    }


type alias Wish =
    { id : Int
    , content : String
    , fulfilledBy : Maybe String
    }


initialModel : Model
initialModel =
    { wishlist = { owner = "default", wishes = [] }
    , newWishContent = ""
    , token = Nothing
    , username = ""
    , password = ""
    , otherUser = ""
    , errorMessage = ""
    }


type Msg
    = AddWish
    | UpdateNewWishContent String
    | RemoveWish Int
    | SaveWishlist
    | SaveWishlistResult (Result Http.Error ())
    | UpdateUsername String
    | UpdatePassword String
    | SubmitLogin
    | LoginResult (Result Http.Error String)
    | LoadWishlistResult (Result Http.Error Wishlist)
    | UpdateOtherUser String
    | ViewOtherUserList String
    | LoadOtherUserWishlistResult (Result Http.Error String)
    | FulfillWish Int
    | FulfillWishResponse Int (Result Http.Error ())


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    let
        currentWishlist : Wishlist
        currentWishlist =
            model.wishlist
    in
    case msg of
        UpdateUsername username ->
            ( { model | username = username }, Cmd.none )

        UpdatePassword password ->
            ( { model | password = password }, Cmd.none )

        SubmitLogin ->
            ( model, login model.username model.password )

        LoginResult result ->
            case result of
                Ok token ->
                    ( { model
                        | token = Just token
                        , wishlist = { currentWishlist | owner = model.username }
                      }
                    , loadWishlist (Just token) model.username
                    )

                Err _ ->
                    ( model, Cmd.none )

        LoadWishlistResult result ->
            case result of
                Ok wishlist ->
                    ( { model | wishlist = wishlist }, Cmd.none )

                Err error ->
                    case error of
                        Http.BadStatus statusCode ->
                            if statusCode == 404 then
                                ( { model | wishlist = { owner = model.username, wishes = [] } }, Cmd.none )

                            else
                                ( { model | errorMessage = "Somethinge went wrong." }, Cmd.none )

                        _ ->
                            ( { model | errorMessage = "An error occurred while loading the other user's wishlist." }, Cmd.none )

        AddWish ->
            let
                newWish : Wish
                newWish =
                    { id = 0, content = model.newWishContent, fulfilledBy = Nothing }

                newWishlist : Wishlist
                newWishlist =
                    { currentWishlist | wishes = model.wishlist.wishes ++ [ newWish ] }

                newModel : Model
                newModel =
                    { model | wishlist = newWishlist, newWishContent = "" }
            in
            ( newModel, Cmd.none )

        UpdateNewWishContent newContent ->
            ( { model | newWishContent = newContent }, Cmd.none )

        RemoveWish index ->
            let
                newWishes : List Wish
                newWishes =
                    removeAt index currentWishlist.wishes
            in
            ( { model | wishlist = { currentWishlist | wishes = newWishes } }, Cmd.none )

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
                    ( { model | errorMessage = "Save failed " }, Cmd.none )

        UpdateOtherUser username ->
            ( { model | otherUser = username }, Cmd.none )

        ViewOtherUserList username ->
            ( model, loadOthersWishlist model.token username )

        LoadOtherUserWishlistResult result ->
            case result of
                Ok response ->
                    case Decode.decodeString wishlistDecoder response of
                        Ok wishlist ->
                            ( { model | wishlist = wishlist }, Cmd.none )

                        Err _ ->
                            ( { model | errorMessage = "An error occurred while decoding the wishlist." }, Cmd.none )

                Err error ->
                    case error of
                        Http.BadStatus statusCode ->
                            if statusCode == 404 then
                                ( { model | errorMessage = "The other user '" ++ model.otherUser ++ "' does not have a wishlist yet." }, Cmd.none )

                            else
                                ( { model | errorMessage = "The other user does not have a wishlist yet." }, Cmd.none )

                        _ ->
                            ( { model | errorMessage = "An error occurred while loading the other user's wishlist." }, Cmd.none )

        FulfillWish wishId ->
            let
                newWishlist : List Wish
                newWishlist =
                    List.map
                        (\wish ->
                            if wish.id == wishId then
                                if wish.fulfilledBy == Just model.username then
                                    { wish | fulfilledBy = Nothing }

                                else
                                    { wish | fulfilledBy = Just model.username }

                            else
                                wish
                        )
                        model.wishlist.wishes

                findWish : Wish
                findWish =
                    List.filter
                        (\wish ->
                            wish.id == wishId
                        )
                        newWishlist
                        |> List.head
                        |> Maybe.withDefault { id = 0, content = "", fulfilledBy = Nothing }
            in
            ( { model | wishlist = { currentWishlist | wishes = newWishlist } }
            , savefulfillWish model.token findWish
            )

        FulfillWishResponse wishId result ->
            case result of
                Ok _ ->
                    ( model, Cmd.none )

                Err _ ->
                    ( { model | errorMessage = "Failed to fulfill wish: " ++ String.fromInt wishId }, Cmd.none )


login : String -> String -> Cmd Msg
login username password =
    Http.post
        { url = "/api/login"
        , body = Http.jsonBody <| Encode.object [ ( "username", Encode.string username ), ( "password", Encode.string password ) ]
        , expect = Http.expectJson LoginResult tokenDecoder
        }


loadWishlist : Maybe String -> String -> Cmd Msg
loadWishlist token username =
    Http.request
        { method = "GET"
        , url = "/api/wishlist/" ++ username
        , headers = authHeader token
        , body = Http.emptyBody
        , expect = Http.expectJson LoadWishlistResult wishlistDecoder
        , timeout = Nothing
        , tracker = Nothing
        }


loadOthersWishlist : Maybe String -> String -> Cmd Msg
loadOthersWishlist token username =
    Http.request
        { method = "GET"
        , url = "/api/wishlist/" ++ username
        , headers = authHeader token
        , body = Http.emptyBody
        , expect = Http.expectString LoadOtherUserWishlistResult
        , timeout = Nothing
        , tracker = Nothing
        }


savefulfillWish : Maybe String -> Wish -> Cmd Msg
savefulfillWish token wish =
    Http.request
        { method = "POST"
        , url = "/api/wishes/" ++ String.fromInt wish.id
        , body = Http.jsonBody (encodeWish wish)
        , expect = Http.expectWhatever (FulfillWishResponse wish.id)
        , headers = authHeader token
        , timeout = Nothing
        , tracker = Nothing
        }


authHeader : Maybe String -> List Http.Header
authHeader token =
    case token of
        Just t ->
            [ Http.header "Authorization" ("Bearer " ++ t) ]

        Nothing ->
            []


wishlistDecoder : Decode.Decoder Wishlist
wishlistDecoder =
    Decode.map2 Wishlist
        (Decode.field "owner" Decode.string)
        (Decode.field "wishes" (Decode.list wishDecoder))


wishDecoder : Decoder Wish
wishDecoder =
    map3 Wish
        (field "id" int)
        (field "content" string)
        (field "fulfilledBy" (nullable string))


removeAt : Int -> List a -> List a
removeAt index list =
    List.take index list ++ List.drop (index + 1) list


encodeWish : Wish -> Encode.Value
encodeWish wish =
    Encode.object
        [ ( "content", Encode.string wish.content )
        , ( "fulfilledBy", Maybe.withDefault Encode.null (Maybe.map Encode.string wish.fulfilledBy) )
        ]


encodeWishlist : Wishlist -> Encode.Value
encodeWishlist wishlist =
    Encode.object
        [ ( "owner", Encode.string wishlist.owner )
        , ( "wishes", Encode.list encodeWish wishlist.wishes )
        ]


tokenDecoder : Decode.Decoder String
tokenDecoder =
    Decode.field "token" Decode.string


view : Model -> Html Msg
view model =
    case model.token of
        Nothing ->
            div []
                [ input [ placeholder "Username", onInput UpdateUsername, value model.username ] []
                , input [ placeholder "Password", type_ "password", onInput UpdatePassword, value model.password ] []
                , button [ onClick SubmitLogin ] [ text "Login" ]
                ]

        Just _ ->
            div []
                [ if model.username == model.wishlist.owner then
                    div []
                        [ div []
                            [ text "Your Wishlist" ]
                        , div []
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

                  else
                    div []
                        [ div []
                            [ text (model.otherUser ++ "'s Wishlist") ]
                        , viewWishlist model.wishlist model.username
                        ]
                , input [ placeholder "Other username", value model.otherUser, onInput UpdateOtherUser ] []
                , button [ onClick (ViewOtherUserList model.otherUser) ] [ text "View Other User's Wishlist" ]
                , text model.errorMessage
                ]


viewWishlist : Wishlist -> String -> Html Msg
viewWishlist wishlist username =
    div []
        (List.map
            (\wish ->
                let
                    buttonText : String
                    buttonText =
                        if wish.fulfilledBy == Just username then
                            "Fulfilled"

                        else
                            "Fulfill"
                in
                div []
                    [ text wish.content
                    , button [ onClick (FulfillWish wish.id) ] [ text buttonText ]
                    , div [] [ text <| Maybe.withDefault "" wish.fulfilledBy ]
                    ]
            )
            wishlist.wishes
        )


main : Program () Model Msg
main =
    Browser.element
        { init = \() -> ( initialModel, Cmd.none )
        , view = view
        , update = update
        , subscriptions = \_ -> Sub.none
        }
