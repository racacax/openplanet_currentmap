/**
	Method to get the current player profile. Can be null if not playing a map.
*/
Json::Value@ GetPlayer() {
	Json::Value@ playerData = Json::Object();
	playerData["login"] = GetLocalLogin();
	auto app = cast<CTrackMania>(GetApp());
#if TMNEXT
	try {
		auto playerInfo = app.LoadedCore.ManiaPlanet.LocalPlayerInfo;
		playerData["club_tag"] = string(playerInfo.ClubTag);
        playerData["name"] = string(playerInfo.Name);
        playerData["region"] = string(playerInfo.ZonePath);
		return playerData;
	} catch {
		return null;
	}
#elif MP4
	try {
		playerData["login"] = string(app.CurrentProfile.AccountSettings.OnlineLogin);
		playerData["name"] = string(app.CurrentProfile.AccountSettings.OnlineLogin);
		playerData["nickname"] = string(app.CurrentProfile.AccountSettings.NickName);
		auto network = cast<CTrackManiaNetwork>(app.Network);
		playerData["region"] = string(network.PlayerInfo.ZonePath);
		return playerData;
	} catch {
		return null;
	}
#endif
}

void setMinWidth(int width) {
	UI::PushStyleVar(UI::StyleVar::ItemSpacing, vec2(0, 0));
	UI::Dummy(vec2(width, 0));
	UI::PopStyleVar();
}