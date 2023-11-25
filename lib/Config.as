[Setting category="Main" name="Enable plugin" description="If disabled, the plugin will not communicate or display anything."]
bool enablePlugin = true;

[Setting category="Main" name="Window visible" description="If plugin is enabled and this is disabled, you will continue to share your map data but plugin will not display anything on screen."]
bool windowVisible = true;

[Setting category="Main" name="Display AT Gap" description="To display the current gap to the author time"]
bool displayATGap = true;

[Setting category="Main" name="Hide on hidden interface"]
bool hideWithIFace = false;

[Setting category="Main" name="Window position"]
vec2 anchor = vec2(0, 170);

[Setting category="Main" name="Lock window position" description="Prevents the window moving when click and drag or when the game window changes size."]
bool lockPosition = false;

[Setting category="Main" name="Font face" description="To avoid a memory issue with loading a large number of fonts, you must reload the plugin for font changes to be applied."]
string fontFace = "";

[Setting category="Main" name="Font size" min=8 max=48 description="To avoid a memory issue with loading a large number of fonts, you must reload the plugin for font changes to be applied."]
int fontSize = 16;

[Setting category="Main" name="Refresh rate (ms)" min=5000 max=60000 description="Duration in milliseconds between each refresh."]
int refreshRate = 10000;

[Setting category="Main" name="API Endpoint" description="Endpoint called to submit and receive players information"]
string baseURL = "https://currentmap.racacax.fr/api/";

[Setting category="Main" name="Access Token" hidden description="Access Token to the API."]
string accessToken = "";

[Setting category="Main" name="Gap To" hidden description="To what time do we display the gap"]
string gapTo = "AT";

[Setting category="Main" name="Favorite Group Id" hidden description="What group is displayed on screen"]
int favoriteGroupId = -1;

[Setting category="Main" name="Favorite Group Name" hidden description="What group is displayed on screen"]
string favoriteGroupName = "-------";