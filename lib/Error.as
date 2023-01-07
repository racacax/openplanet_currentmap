dictionary errors = {
    {"account_exists", "An account already exists with your Uplay login. Update the access token below."
        " If you forgot it, you can reset it by clicking here : http://example.com"},
    {"wrong_token_or_account", "Current token is either wrong or linked to another account."
        " If you forgot it, you can reset it by clicking here : http://example.com"},
    {"not_logged", "You currently don't have an account. Please press Login to automatically register."
    " If you already have an account for the plugin on another Trackmania game, you can copy/paste your "
    "Access Token from the other game plugin below."},
    {"not_in_game", "You need to be on a map to be able to register/login."},
    {"invite_exists", "You already sent an invite to this player."}
};

string getError(const string &in key) {
    if(errors.Exists(key)) {
        return string(errors[key]);
    } else {
        return "Unexpected error. Try again later. (Error : " + key +")";
    }
}