string PLUGIN_NAME = "CurrentMap";
bool IS_DEV_MODE = true;
Json::Value players = Json::Array();
bool isRunning = false;
bool inError = false;
int timeWidth = 53;
int deltaWidth = 60;
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


/*
	Main loop to submit and fetch data about players (name, club tag, current map, ...)
*/
void Main()
{
	if(accessToken != "") {
		events.InsertAt(0, "login");
	}
	Flags::Init();
	LoadFont();
	while(true) {
		HandleEvents();
	}
}

void Render() {
	try {
		auto app = cast<CTrackMania>(GetApp());
		
#if TMNEXT||MP4
		auto map = app.RootMap;
#elif TURBO
		auto map = app.Challenge;
#endif
		
		if(hideWithIFace && !UI::IsGameUIVisible()) {
			return;
		}
		
		if(windowVisible && map !is null && map.MapInfo.MapUid != "" && app.Editor is null) {
			isRunning = true;
			if(lockPosition) {
				UI::SetNextWindowPos(int(anchor.x), int(anchor.y), UI::Cond::Always);
			} else {
				UI::SetNextWindowPos(int(anchor.x), int(anchor.y), UI::Cond::FirstUseEver);
			}
			
			int windowFlags = UI::WindowFlags::NoTitleBar | UI::WindowFlags::NoCollapse | UI::WindowFlags::AlwaysAutoResize | UI::WindowFlags::NoDocking;
			if (!UI::IsOverlayShown()) {
					windowFlags |= UI::WindowFlags::NoInputs;
			}
			
			UI::PushFont(font);
			
			UI::Begin("Current map", windowFlags);
			
			if(!lockPosition) {
				anchor = UI::GetWindowPos();
			}
			
			bool hasComment = string(map.MapInfo.Comments).Length > 0;
			
			UI::BeginGroup();
			
			int numCols = 3; // name and time columns are always shown
			if(displayATGap) numCols++;
			
			if(UI::BeginTable("table", numCols, UI::TableFlags::SizingFixedFit)) {
					UI::TableNextRow();
					UI::TableNextColumn();
					setMinWidth(0);
					UI::Text(" ");
					
					UI::TableNextColumn();
					setMinWidth(0);
					UI::Text("Player");
					
					UI::TableNextColumn();
					setMinWidth(timeWidth);
					UI::Text("Map");
					if(displayATGap)  {
						UI::TableNextColumn();
						setMinWidth(timeWidth);
						UI::Text("Gap to AT");
					}
					if(!APIClient::loggedIn) {
							UI::TableNextRow();
							UI::TableNextColumn();
							UI::TableNextColumn();
							UI::TextWrapped(ColoredString("$f00You are not logged in. Please check your status in the settings."));
					}
					
					if(inError) {
						UI::TableNextRow();
						UI::TableNextColumn();
						UI::TableNextColumn();
						UI::Text(ColoredString("$f00Error while fetching data"));
					}
					try {
						for (uint i = 0; i < players.Length; i++)
						{		
							string playerName = players[i]["display_name"];
							string mapName = players[i]["current_map"]["name"];
							string atGap = "/";
							if(int(players[i]["current_pb"]) > 0) {
								int gap = int(players[i]["current_pb"]) - int(players[i]["current_map"]["author_time"]);
								if(gap > 0) {
									atGap = "$f00+"; 
								} else {
									atGap = "$0f0-";
								}
								atGap += Time::Format(Math::Abs(gap));
							}

							UI::TableNextRow();
							UI::TableNextColumn();
							setMinWidth(0);
							string region = "";
							if(Json::Write(players[i]["region"]) != "null") {
								region = players[i]["region"];
							}
							UI::Image(Flags::GetFlagByTrackmaniaRegion(region), vec2(fontSize*4/3, fontSize));
							UI::TableNextColumn();
							UI::Text(ColoredString(playerName));
							
							UI::TableNextColumn();
							setMinWidth(timeWidth);
							UI::Text(ColoredString(mapName));
							if(displayATGap) {
								UI::TableNextColumn();
								setMinWidth(timeWidth);
								UI::Text(ColoredString(atGap));
							}
						}
					} catch {
						UI::TableNextRow();
						UI::TableNextColumn();
						UI::TableNextColumn();
						UI::Text(ColoredString("$f00Error while rendering data"));
					}


					UI::EndTable();
			}
			UI::EndGroup();
			
			UI::End();
			UI::PopFont();
		} else {
			isRunning = false;
		}
	} catch {
		Log::Warn("An error occurred while rendering");
	}
}
