void setMinWidth(int width) {
	UI::PushStyleVar(UI::StyleVar::ItemSpacing, vec2(0, 0));
	UI::Dummy(vec2(width, 0));
	UI::PopStyleVar();
}

/**
	Method to get the current player profile. Can be null if not connected.
*/
Json::Value@ GetPlayer() {
	Json::Value@ playerData = GetPlayerFromGame();
	if(playerData != null) {
		playerData["login"] = GetLocalLogin();
	}
	return playerData;
}



UI::Font@ font = null;
string loadedFontFace = "";
int loadedFontSize = 0;
void LoadFont() {
	string fontFaceToLoad = fontFace.Length == 0 ? "DroidSans.ttf" : fontFace;
	if(fontFaceToLoad != loadedFontFace || fontSize != loadedFontSize) {
		@font = UI::LoadFont(fontFaceToLoad, fontSize, -1, -1, true, true, true);
		if(font !is null) {
			loadedFontFace = fontFaceToLoad;
			loadedFontSize = fontSize;
		}
	}
}


Json::Value GetMapData() {
    auto map = GetMapFromGame();
    auto pb = GetPersonnalBestFromMap(map);
    Json::Value mapData = Json::Object();
    mapData["map"] = Json::Object();
	mapData["current_pb"] = pb;
    mapData["map"]["uid"] = map.MapInfo.MapUid;
    mapData["map"]["game"] = GAME_ID;
    mapData["map"]["author_time"] = map.MapInfo.TMObjective_AuthorTime;
    mapData["map"]["gold_time"] = map.MapInfo.TMObjective_GoldTime;
    mapData["map"]["silver_time"] = map.MapInfo.TMObjective_SilverTime;
    mapData["map"]["bronze_time"] = map.MapInfo.TMObjective_BronzeTime;
    mapData["map"]["name"] = string(map.MapInfo.Name);
    mapData["map"]["author"] = string(map.MapInfo.AuthorNickName);
    return mapData;
}



bool IsActive() {
    auto app = cast<CTrackMania>(GetApp());
	auto map = GetMapFromGame();
    return windowVisible && map !is null && map.MapInfo.MapUid != "" && app.Editor is null;
}