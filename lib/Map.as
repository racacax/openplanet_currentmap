Json::Value getMapData() {
    auto app = cast<CTrackMania>(GetApp());
    auto network = cast<CTrackManiaNetwork>(GetApp().Network);
	
#if TMNEXT||MP4
	auto map = app.RootMap;
#elif TURBO
	auto map = app.Challenge;
#endif
    Json::Value mapData = Json::Object();
    mapData["map"] = Json::Object();
#if TMNEXT
			if(network.ClientManiaAppPlayground !is null) {
				auto userMgr = network.ClientManiaAppPlayground.UserMgr;
				MwId userId;
				if (userMgr.Users.Length > 0) {
					userId = userMgr.Users[0].Id;
				} else {
					userId.Value = uint(-1);
				}
				
				auto scoreMgr = network.ClientManiaAppPlayground.ScoreMgr;
				// from: OpenplanetNext\Extract\Titles\Trackmania\Scripts\Libs\Nadeo\TMNext\TrackMania\Menu\Constants.Script.txt
				// ScopeType can be: "Season", "PersonalBest"
				// GameMode can be: "TimeAttack", "Follow", "ClashTime"
				mapData["current_pb"] = scoreMgr.Map_GetRecord_v2(userId, map.MapInfo.MapUid, "PersonalBest", "", "TimeAttack", "");
			}
#elif TURBO
			if(network.TmRaceRules !is null) {
				auto dataMgr = network.TmRaceRules.DataMgr;
				//dataMgr.RetrieveRecords(map.MapInfo, dataMgr.MenuUserId);
				dataMgr.RetrieveRecordsNoMedals(map.MapInfo.MapUid, dataMgr.MenuUserId);
				yield();
				if(dataMgr.Ready) {
					for(uint i = 0; i < dataMgr.Records.Length; i++) {
						// TODO: identify game mode, and then load arcade or dual-driver best instead? only loads for campaign maps right now
						if(dataMgr.Records[i].GhostName == "Solo_BestGhost") {
							mapData["current_pb"] = dataMgr.Records[i].Time;
							break;
						}
						// this shouldn't loop more than a few times, since each entry is a different record type
					}
				}
			}
#elif MP4
			// don't use network.ClientManiaAppPlayground.ScoreMgr because that always returns -1
			if(network.TmRaceRules !is null && network.TmRaceRules.ScoreMgr !is null) {
				auto scoreMgr = network.TmRaceRules.ScoreMgr;
				// after extensive research, I have concluded that Context must be ""
				mapData["current_pb"] = scoreMgr.Map_GetRecord(network.PlayerInfo.Id, map.MapInfo.MapUid, "");
			} else if(true) { // yes, this overrides the `else` below
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
				
				mapData["current_pb"] = score;
			}
#endif
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