[Setting name="Window visible" description="To adjust the position of the window, click and drag while the Openplanet overlay is visible."]
bool windowVisible = true;

[Setting name="Display AT Gap" description="To display the current gap to the author time"]
bool displayATGap = true;

[Setting name="Hide on hidden interface"]
bool hideWithIFace = false;

[Setting name="Window position"]
vec2 anchor = vec2(0, 170);

[Setting name="Lock window position" description="Prevents the window moving when click and drag or when the game window changes size."]
bool lockPosition = false;

[Setting name="Font face" description="To avoid a memory issue with loading a large number of fonts, you must reload the plugin for font changes to be applied."]
string fontFace = "";

[Setting name="API Key" description="An API Key (unique identifier) needs to be provided. Put whatever you want as long as it is alphanumerical. Players you want to show need to put the same API Key."]
string apiKey = "";

[Setting name="Font size" min=8 max=48 description="To avoid a memory issue with loading a large number of fonts, you must reload the plugin for font changes to be applied."]
int fontSize = 16;

[Setting name="Refresh rate (ms)" min=5000 max=60000 description="Duration in milliseconds between each refresh."]
int refreshRate = 10000;

[Setting name="API Endpoint" description="Endpoint called to submit and receive players information"]
string playersURL = "https://racacax.gq/trackmania/currentmap/players.php";

string PLUGIN_NAME = "CurrentMap";
bool IS_DEV_MODE = true;
Json::Value players = Json::Value();
auto countries = Json::Value();
bool isRunning = false;


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
void FetchData() {
	while(true) {
		if(isRunning) {
			try {
					auto player = GetPlayer();
					if(player !is null) {
						
						auto network = cast<CTrackManiaNetwork>(GetApp().Network);
						auto userMgr = network.ClientManiaAppPlayground.UserMgr;
						auto map = GetApp().RootMap;
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
						auto personalBest = scoreMgr.Map_GetRecord_v2(userId, map.MapInfo.MapUid, "PersonalBest", "", "TimeAttack", "");
						string clubTag = "";
						if(player.User.ClubTag !is null) {
							clubTag = player.User.ClubTag;
						}
						players = API::PostAsync(playersURL, '{"apiKey":"'+apiKey+'","personalBest":'+personalBest+',"authorTime":'+map.TMObjective_AuthorTime+',"tag":"'+clubTag+'","login":"'+player.User.Login+'","player":"'+player.User.Name+'","flag":"'+player.User.ZonePath+'","map":"'+GetApp().RootMap.MapName+'"}');
						sleep(refreshRate);
					} else {
						sleep(500);
					}
				
			} catch {
				Log::Warn("An error occurred while fetching data");
				sleep(500);
			}
		} else {
			sleep(500);
		}
	}
}

void Main()
{
	Flags::Init();
	LoadFont();
	FetchData(); // Main function
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
					if(apiKey == "") {
							UI::TableNextRow();
							UI::TableNextColumn();
							UI::TableNextColumn();
							UI::Text(ColoredString("$f00API Key missing"));
					}
					try {
						for (uint i = 0; i < players.Length; i++)
						{		
							string playerName = players[i]["player"];
							string mapName = players[i]["map"];
							string clubTag = players[i]["tag"];
							string atGap = players[i]["atGap"];

							UI::TableNextRow();
							UI::TableNextColumn();
							setMinWidth(0);
							UI::Image(Flags::GetFlagByTrackmaniaRegion(players[i]["flag"]), vec2(fontSize*4/3, fontSize));
							UI::TableNextColumn();
							if(clubTag.Length > 0) {
								playerName = "["+ColoredString(clubTag+"$fff")+"] "+playerName;
							}
							UI::Text(playerName);
							
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
						//Log::Warn("Error displaying infos");
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



void setMinWidth(int width) {
	UI::PushStyleVar(UI::StyleVar::ItemSpacing, vec2(0, 0));
	UI::Dummy(vec2(width, 0));
	UI::PopStyleVar();
}
