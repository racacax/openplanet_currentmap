#if MP4
/**
	Method to get the current player profile data from MP4. Can be null if not connected.
*/
Json::Value@ GetPlayerFromGame() {
	Json::Value@ playerData = Json::Object();
	playerData["login"] = GetLocalLogin();
	auto app = cast<CTrackMania>(GetApp());
	try {
		playerData["name"] = GetLocalLogin();
		playerData["nickname"] = string(app.CurrentProfile.AccountSettings.NickName);
		auto network = cast<CTrackManiaNetwork>(app.Network);
		string region = string(network.PlayerInfo.ZonePath);
		playerData["region"] = region;
		if(region == "") {
			return null;
		}
		return playerData;
	} catch {
		return null;
	}
}

CGameCtnChallenge@ GetMapFromGame() {
    auto app = cast<CTrackMania>(GetApp());
    return app.RootMap;
}
Json::Value GetPersonnalBestFromMap(CGameCtnChallenge@ map) {
            auto app = cast<CTrackMania>(GetApp());
            auto network = cast<CTrackManiaNetwork>(GetApp().Network);
			// don't use network.ClientManiaAppPlayground.ScoreMgr because that always returns -1
			if(network.TmRaceRules !is null && network.TmRaceRules.ScoreMgr !is null) {
				auto scoreMgr = network.TmRaceRules.ScoreMgr;
				// after extensive research, I have concluded that Context must be ""
				return scoreMgr.Map_GetRecord(network.PlayerInfo.Id, map.MapInfo.MapUid, "");
			} else { // yes, this overrides the `else` below
				int score = -1;
				
				// when playing on a server, TmRaceRules.ScoreMgr is unfortunately inaccessible
				if(app.CurrentProfile !is null && app.CurrentProfile.AccountSettings !is null) {
					// this is using *saved replays* to load the PB; if the replay has been deleted (or never saved), it won't appear
					for(uint i = 0; i < app.ReplayRecordInfos.Length; i++) {
						if(app.ReplayRecordInfos[i] !is null
							 && app.ReplayRecordInfos[i].MapUid == map.MapInfo.MapUid
							 && app.ReplayRecordInfos[i].PlayerLogin == app.CurrentProfile.AccountSettings.OnlineLogin) {
							print('hey ' + tostring(i));
							auto record = app.ReplayRecordInfos[i];
							if(score < 0 || record.BestTime < uint(score)) {
								score = int(record.BestTime);
							}
						}
						// to prevent lag spikes when updating medals, scan at most 256 per tick
						if(i & 0xff == 0xff) { yield(); }
					}
				}
				
				/* this is session-best, check this as well */
				if(app.CurrentPlayground !is null
						&& app.CurrentPlayground.GameTerminals.Length > 0
						&& cast<CTrackManiaPlayer>(app.CurrentPlayground.GameTerminals[0].GUIPlayer) !is null
						&& cast<CTrackManiaPlayer>(app.CurrentPlayground.GameTerminals[0].GUIPlayer).Score !is null) {
					int sessScore = int(cast<CTrackManiaPlayer>(app.CurrentPlayground.GameTerminals[0].GUIPlayer).Score.BestTime);
					if(sessScore > 0 && (score < 0 || sessScore < score)) {
						score = sessScore;
					}
				}
				
				return score;
			}
}
#endif