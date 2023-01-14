namespace GroupSettings {
    bool groupsLoaded = false;
    Json::Value ownedGroups = Json::Array();
    Json::Value selectedGroup = Json::Object();
    Json::Value selectedMember = Json::Object();
    Json::Value playersFound = Json::Array();
    string searchString = "No player found";
    string groupName = "";
    string playerName = "";
    int playerInvitedId = 0;
    void RenderOwnedGroups() {
        UI::Text("List of the groups you created.");
        UI::BeginTable("myGroups", 2, UI::TableFlags::SizingFixedFit);
        UI::TableNextRow();
        UI::TableNextColumn();
        setMinWidth(140);
        groupName = UI::InputText("Group name", groupName);
        UI::TableNextColumn();
        if(UI::Button(" Create") && groupName.Length > 0){
            AddEvent("createGroup");
        }
        UI::TableNextRow();
		UI::TableNextColumn();
        setMinWidth(400);
        if (UI::BeginCombo("My groups", ColoredString(selectedGroup["name"]))) {
            for(uint i=0; i < ownedGroups.Length; i++) {
                if (UI::Selectable(ColoredString(ownedGroups[i]["name"]), int(ownedGroups[i]["id"]) == int(selectedGroup["id"]))) {
                    selectedGroup = ownedGroups[i];
                    playersFound = Json::Array();
                    if(selectedGroup["members"].Length > 0) {
                        selectedMember = selectedGroup["members"][0];
                    } else {
                        selectedMember = Json::Object();
                    }
                }
            }
            UI::EndCombo();
        }
		UI::TableNextColumn();
        if(UI::Button(" Refresh")){
            Log::Warn("Refreshing...");
            AddEvent("fetchGroupsOwned");
        }
        UI::EndTable();
        if(selectedGroup["id"] != 0) {
            UI::PushStyleColor(UI::Col::Button, vec4(1,0,0,1));
            if(UI::Button(" Delete group")){
                AddEvent("deleteGroup");
            }
            UI::PopStyleColor(1);
            UI::BeginTable("groupMembers", 2, UI::TableFlags::SizingFixedFit);
            UI::TableNextRow();
            UI::TableNextColumn();
            if (selectedMember.HasKey("display_name")) {
                setMinWidth(300);
                if(UI::BeginCombo("Members", ColoredString(selectedMember["display_name"]))) {   
                    for(uint i=0; i < selectedGroup["members"].Length; i++) {
                        if (UI::Selectable(ColoredString(selectedGroup["members"][i]["display_name"]), int(selectedGroup["members"][i]["id"]) == int(selectedMember["id"]))) {
                            selectedMember = selectedGroup["members"][i];
                        }
                    }
                    UI::EndCombo();
                }
                UI::TableNextColumn();
                UI::PushStyleColor(UI::Col::Button, vec4(1,0,0,1));
                if(UI::Button(" Kick")){
                    AddEvent("kickPlayer");
                }
                UI::PopStyleColor(1);
            }
            UI::EndTable();
        }
        UI::BeginTable("createGroup", 2, UI::TableFlags::SizingFixedFit);
        if(selectedGroup["id"] != 0) {
            UI::TableNextRow();
            UI::TableNextColumn();
            setMinWidth(140);
            UI::Text("You can invite players to your group by searching below.");
            UI::TableNextRow();
            UI::TableNextColumn();
            playerName = UI::InputText("Search player", playerName);
            UI::TableNextColumn();
            if(UI::Button(" Search") && playerName.Length > 0){
                AddEvent("searchPlayer");
            }
            UI::TableNextRow();
            UI::TableNextColumn();
            UI::BeginTable("searchedPlayers", 2, UI::TableFlags::SizingFixedFit);
            if(playersFound.Length == 0) {
                UI::TableNextRow();
                UI::TableNextColumn();
                UI::Text(searchString);
            } else {
                UI::TableNextRow();
                UI::TableNextColumn();
                UI::Text("Player");
                for(uint i=0; i < playersFound.Length; i++) {
                    UI::TableNextRow();
                    UI::TableNextColumn();
                    UI::Text(ColoredString(playersFound[i]["display_name"]));
                    UI::TableNextColumn();
                    if(UI::Button(" Invite##"+tostring(i))){
                        playerInvitedId = playersFound[i]["id"];
                        AddEvent("invitePlayer");
                        playersFound.Remove(i);
                    }
                }
            }
            UI::EndTable();
        }
        UI::EndTable();
    }

}

namespace JoinedGroupSettings {
    bool groupsLoaded = false;
    Json::Value joinedGroups = Json::Array();
    Json::Value selectedGroup = Json::Object();
    void RenderJoinedGroups() {
        UI::BeginTable("joinedGroups", 2, UI::TableFlags::SizingFixedFit);
        UI::TableNextRow();
		UI::TableNextColumn();
        setMinWidth(400);
        if (UI::BeginCombo("Joined groups", ColoredString(selectedGroup["name"]))) {
            for(uint i=0; i < joinedGroups.Length; i++) {
                if (UI::Selectable(ColoredString(joinedGroups[i]["name"]), int(joinedGroups[i]["id"]) == int(selectedGroup["id"]))) {
                    selectedGroup = joinedGroups[i];
                }
            }
            UI::EndCombo();
        }
		UI::TableNextColumn();
        if(UI::Button(" Refresh")){
            Log::Warn("Refreshing...");
            AddEvent("fetchGroupsJoined");
        }
        UI::EndTable();
        if(selectedGroup["id"] != 0) {
            UI::PushStyleColor(UI::Col::Button, vec4(1,0,0,1));
            if(UI::Button(" Leave group")){
                AddEvent("leaveGroup");
            }
            UI::PopStyleColor(1);
            UI::Text(ColoredString("Owner : " + string(selectedGroup["owner"]["display_name"])));
        }
    }
}

void RenderFavoriteGroup() {
    LoadGroups();
    Json::Value groups = Json::Array();
    auto joinedGroups = Json::Write(JoinedGroupSettings::joinedGroups);
    auto ownedGroups = Json::Write(GroupSettings::ownedGroups);
    if(JoinedGroupSettings::joinedGroups.Length == 0) {
        groups = GroupSettings::ownedGroups;
    } else if(GroupSettings::ownedGroups.Length == 0) {
        groups = JoinedGroupSettings::joinedGroups;
    } else {
        groups = Json::Parse(ownedGroups.SubStr(0, ownedGroups.Length -1) + "," + joinedGroups.SubStr(1));
    }
    if (UI::BeginCombo("Displayed group", ColoredString(favoriteGroupName))) {
            bool favoriteFound = false;
            for(uint i=0; i < groups.Length; i++) {
                if (UI::Selectable(ColoredString(groups[i]["name"]), int(groups[i]["id"]) == favoriteGroupId)) {
                    favoriteGroupId = groups[i]["id"];
                    favoriteGroupName = groups[i]["name"];
                    RefreshDataIfInGame();
                }
                favoriteFound = favoriteFound || int(groups[i]["id"]) == favoriteGroupId;
            }
            if(!favoriteFound) {
                favoriteGroupName = "-------------";
            }
            UI::EndCombo();
    }
    
    if(UI::Button(" Refresh")){
        Log::Warn("Refreshing...");
        AddEvent("fetchGroupsOwned");
        AddEvent("fetchGroupsJoined");
    }
}
void LoadGroups() {
    if(!GroupSettings::groupsLoaded) {
        GroupSettings::groupsLoaded = true;
        AddEvent("fetchGroupsOwned");
    }
    if(!JoinedGroupSettings::groupsLoaded) {
        JoinedGroupSettings::groupsLoaded = true;
        AddEvent("fetchGroupsJoined");
    }
}
[SettingsTab name="Groups" icon="Users"]
void RenderGroupSettings()
{
    if(APIClient::loggedIn) {
        if(!GroupSettings::selectedGroup.HasKey("id")) {
            GroupSettings::selectedGroup["id"] = 0;
            GroupSettings::selectedGroup["name"] = "---------";
        }
        if(!JoinedGroupSettings::selectedGroup.HasKey("id")) {
            JoinedGroupSettings::selectedGroup["id"] = 0;
            JoinedGroupSettings::selectedGroup["name"] = "---------";
        }
        LoadGroups();
        RenderFavoriteGroup();
        if(UI::CollapsingHeader("Owned groups")) {

            GroupSettings::RenderOwnedGroups();
        }
        if(UI::CollapsingHeader("Joined groups")) {
            JoinedGroupSettings::RenderJoinedGroups();
        }
    } else {
        UI::Text(getError(APIClient::errorCode));
    }
}