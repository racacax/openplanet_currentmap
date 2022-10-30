namespace Flags {
    UI::Texture@ world = null;
    dictionary flagsId = {};
    dictionary regionToCountryCode = {};
    array<UI::Texture@> flags = {};
    auto countries = Json::Value();

    void Init() {
        countries = API::GetAsync('https://raw.githubusercontent.com/lukes/ISO-3166-Countries-with-Regional-Codes/master/all/all.json');
        flags.Resize(countries.Length);
        for (uint i = 0; i < countries.Length; i++) {
			string countryIso = countries[i]["alpha-2"];
			flagsId.Set(countryIso, i);
        }
    }

    /**
        Method to get the texture of the United Nations flag. Used if no suitable country found for a player.
    */
    UI::Texture@ GetWorldFlag() {
        if(world is null) {
            @world = UI::LoadTexture("assets/flags/world.png");
        }
        return world;
    }

    /**
        Method to get the texture of a country flag by its ISO-3166 Alpha 2 code 
        See : https://fr.wikipedia.org/wiki/ISO_3166-1_alpha-2
    */
    UI::Texture@ GetFlagByISOAlpha2(const string &in countryIso) {
        try {
            if(flagsId.Exists(countryIso)) {
                int flagId = int(flagsId[countryIso]);
                if(flags[flagId] == null) {
                    @flags[flagId] = UI::LoadTexture("assets/flags/" + countryIso.ToLower() + ".png");
                }
                return flags[flagId];
            }
            return GetWorldFlag(); // return United Nations flag if country not found
        } catch {
            return GetWorldFlag(); // return United Nations flag in case of error
        }
    }

    /**
        Method to get the texture of a country flag by a Trackmania Region (example : World|Europe|Sweden)s
    */
    UI::Texture@ GetFlagByTrackmaniaRegion(const string &in region) {
        array<string> flagSplited = region.Split("|");
		string countryIso = "";
        if(flagSplited.Length > 2) {  
            if(!regionToCountryCode.Exists(flagSplited[2])) {
                for (uint i = 0; i < countries.Length; i++) {
                    if(countries[i]["name"] == flagSplited[2]) {
                        countryIso = countries[i]["alpha-2"];
                        regionToCountryCode.Set(flagSplited[2], countryIso);
                    }
                }
                if(!regionToCountryCode.Exists(flagSplited[2])) {
                    regionToCountryCode.Set(flagSplited[2], ""); // If country not found, we ignore it to prevent useless loops for next renders
                }
            } else {
                countryIso = string(regionToCountryCode[flagSplited[2]]);
            }
        }
		return GetFlagByISOAlpha2(countryIso);
    }
}