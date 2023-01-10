string PLUGIN_NAME = "CurrentMap";
bool IS_DEV_MODE = true;
Json::Value players = Json::Array();
bool inError = false;
int timeWidth = 53;
int deltaWidth = 60;

/*
	Gap to move window when overflow. Only when overlay displayed
*/
float gapX = 0;


/*
	Main loop to submit and fetch data about players (name, club tag, current map, ...)
*/
void Main()
{
	if(accessToken != "") {
		AddEvent("login");
	}
	Flags::Init();
	LoadFont();
	while(true) {
		HandleEvents();
	}
}

void Render() {
	try {

		if(hideWithIFace && !UI::IsGameUIVisible()) {
			return;
		}
		
		if(IsActive()) {
			if(lockPosition) {
				UI::SetNextWindowPos(int(anchor.x + gapX), int(anchor.y), UI::Cond::Always);
			} else {
				UI::SetNextWindowPos(int(anchor.x + gapX), int(anchor.y), UI::Cond::FirstUseEver);
			}
			
			int windowFlags = UI::WindowFlags::NoTitleBar | UI::WindowFlags::NoCollapse | UI::WindowFlags::AlwaysAutoResize | UI::WindowFlags::NoDocking;
			if (!UI::IsOverlayShown() && players.Length != 0) {
					windowFlags |= UI::WindowFlags::NoInputs;
			}
			
			UI::PushFont(font);
			
			UI::Begin("Current map", windowFlags);
			
			if(!lockPosition) {
				anchor = UI::GetWindowPos();
			}
			
			UI::BeginGroup();
			
			int numCols = 3; // name and time columns are always shown
			if(displayATGap) numCols++;
			
			if(!APIClient::loggedIn) {
				AccessSettings::RenderLoginScreen();
			} else if(inError) {
				UI::Text(ColoredString("$f00Error while fetching data"));
			} else {
				if(UI::IsOverlayShown() && players.Length > 0) {
					UI::BeginTable("groupTable", 2, UI::TableFlags::SizingFixedFit);
					UI::TableNextRow();
					UI::TableNextColumn();
					RenderFavoriteGroup();
					UI::EndTable();
				}
				if(UI::BeginTable("table", numCols, UI::TableFlags::SizingFixedFit)) {
					if(players.Length == 0) {
						UI::TableNextRow();
						UI::TableNextColumn();
						UI::TextWrapped("No data to display, check your displayed group. If you don't have any group, create or join one in the settings (OpenPlanet => Settings => Current Map => Groups).");
						UI::TableNextRow();
						UI::TableNextColumn();
						RenderFavoriteGroup();
					} else {
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
					}
					UI::EndTable();
				}
			}
			UI::EndGroup();
			
			if(UI::IsOverlayShown()) {
				if(UI::GetWindowContentRegionWidth() + anchor.x > Draw::GetWidth()) {
					gapX = Draw::GetWidth() - (UI::GetWindowContentRegionWidth() + anchor.x);
				}
			} else {
				gapX = 0;
			}
			UI::End();
			UI::PopFont();
		}
	} catch {
		Log::Warn("An error occurred while rendering");
	}
}
