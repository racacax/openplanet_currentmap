/**
    Method to convert ASCII string to lowercase
*/
string lowercase(string _text) {
  for (int i = 0; i < _text.Length; i++) {
    if (_text[i] >= "A"[0] && _text[i] <= "Z"[0])
      _text[i] += 32;                            
  }
  return _text;
}

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