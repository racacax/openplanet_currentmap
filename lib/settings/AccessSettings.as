namespace AccessSettings {
  bool loaded = false;
  string updatedAccessToken = "";
  Json::Value accountsInfo = Json::Value();
  void RenderAccessToken() {
    UI::BeginTable("accesstoken", 4, UI::TableFlags::SizingFixedFit);
    UI::TableNextRow();
		UI::TableNextColumn();
    UI::Text("Access Token :");
		UI::TableNextColumn();
    UI::Text("########################", 24);
    setMinWidth(180);    
    UI::TableNextColumn();
    if(UI::Button(" Copy")){
        IO::SetClipboard(accessToken);
    }
    UI::EndTable();
  }
  void RenderUpdateAccessToken() {
    if(!APIClient::loggedIn) {
      UI::Text("");
      UI::TextWrapped(getError(APIClient::errorCode));
      if(APIClient::errorCode != "not_in_game") {
        UI::BeginTable("updatetoken", 3, UI::TableFlags::SizingFixedFit);
        UI::TableNextRow();
        UI::TableNextColumn();
        updatedAccessToken = UI::InputText("Access Token", updatedAccessToken);
        UI::TableNextColumn();
        if(UI::Button(" Login")) {
          accessToken = updatedAccessToken;
          events.InsertAt(0, "login");
        }
        UI::EndTable();
      }
    } else {
      UI::Text("You are logged in.");
      UI::Text("Linked accounts :");
      UI::BeginTable("accounts", 3, UI::TableFlags::SizingFixedFit);
      UI::TableNextRow();
      UI::TableNextColumn();
      UI::Text("Login");
      UI::TableNextColumn();
      UI::Text("Name");
      UI::TableNextColumn();
      UI::Text("Game");
      for (uint i = 0; i < accountsInfo.Length; i++) {
				UI::TableNextRow();
        UI::TableNextColumn();
        UI::Text(accountsInfo[i]["login"]);
        UI::TableNextColumn();
        UI::Text(ColoredString(accountsInfo[i]["display_name"]));
        UI::TableNextColumn();
        UI::Text(GAMES[int(accountsInfo[i]["game"])]);
			}
      UI::EndTable();
    }

  }
  [SettingsTab name="Access" icon="SignIn"]
  void RenderSettings()
  {
    RenderAccessToken();
    RenderUpdateAccessToken();
  }
}