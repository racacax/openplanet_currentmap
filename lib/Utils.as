/**
	Method to get the current player profile. Can be null if not playing a map.
*/
CGamePlayer@ GetPlayer() {
	try {
		string login = GetLocalLogin();

		auto pg = GetApp().CurrentPlayground;

		for (uint i = 0; i < pg.Players.Length; i++) {
			auto player = cast<CGamePlayer>(pg.Players[i]);
				
			if (player.User.Login == login) {
				return player;
			}
		}
		return null;
	} catch {
		return null;
	}
}