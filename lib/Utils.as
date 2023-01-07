/**
	Method to get the current player profile. Can be null if not playing a map.
*/
Json::Value@ GetPlayer() {
	Json::Value@ playerData = Json::Object();
	playerData["login"] = GetLocalLogin();
#if TMNEXT
	try {
		string login = GetLocalLogin();

		auto pg = GetApp().CurrentPlayground;

		for (uint i = 0; i < pg.Players.Length; i++) {
			auto player = cast<CGamePlayer>(pg.Players[i]);
				
			if (player.User.Login == login) {
				playerData["club_tag"] = string(player.User.ClubTag);
        		playerData["name"] = string(player.User.Name);
        		playerData["region"] = string(player.User.ZonePath);
				return playerData;
			}
		}
		return null;
	} catch {
		return null;
	}
#elif MP4
	try {
		auto app = cast<CTrackMania>(GetApp());
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