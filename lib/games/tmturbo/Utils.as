/**
	TODO: Method to get the current player profile in TMTURBO.
*/
#if TMTURBO
Json::Value@ GetPlayerFromGame() {
    return null;
}


CGameCtnChallenge@ GetMapFromGame() {
    auto app = cast<CTrackMania>(GetApp());
    return app.Challenge;
}

Json::Value GetPersonnalBestFromMap(CGameCtnChallenge@ map) {
  auto network = cast<CTrackManiaNetwork> (GetApp().Network);
  if(network.TmRaceRules !is null) {
		auto dataMgr = network.TmRaceRules.DataMgr;
		dataMgr.RetrieveRecordsNoMedals(map.MapInfo.MapUid, dataMgr.MenuUserId);
		yield();
		if(dataMgr.Ready) {
		    for(uint i = 0; i < dataMgr.Records.Length; i++) {
				if(dataMgr.Records[i].GhostName == "Solo_BestGhost") {
					return dataMgr.Records[i].Time;
					break;
				}
			}
		}
	}
    return -1;
}
#endif