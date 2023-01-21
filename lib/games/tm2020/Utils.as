#if TMNEXT
/**
	Method to get the current player profile data from TM2020. Can be null if not connected.
*/
string currentPlayerClubTag = "";
Json::Value@ GetPlayerFromGame() {
  Json::Value@ playerData = Json::Object();
  auto app = cast<CTrackMania>(GetApp());
  try {
    auto playerInfo = app.LoadedCore.ManiaPlanet.LocalPlayerInfo;
    if (playerInfo.ZonePath == "") { // if game not fully loaded, some info such as ClubTag and ZonePath might be missing
      return null;
    }
    playerData["club_tag"] = string(playerInfo.ClubTag);
    if(string(playerInfo.ClubTag) != currentPlayerClubTag && APIClient::loggedIn) { // Login if player changed ClubTag
      AddEvent("login");
    }
    currentPlayerClubTag = string(playerInfo.ClubTag);
    playerData["name"] = string(playerInfo.Name);
    playerData["region"] = string(playerInfo.ZonePath);
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
  auto network = cast<CTrackManiaNetwork> (GetApp().Network);
  if (network.ClientManiaAppPlayground!is null) {
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
    return scoreMgr.Map_GetRecord_v2(userId, map.MapInfo.MapUid, "PersonalBest", "", "TimeAttack", "");
  }
  return -1;
}

#endif