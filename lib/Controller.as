array<string> events = {};
int64 lastChecked = 0;

void CheckPlayer() {
	auto player = GetPlayer();
	if(player !is null) {
		APIClient::errorCode = "not_logged";
	} else {
		APIClient::errorCode = "player_null";
	}
}
void Login() {
    auto player = GetPlayer();
	if(player !is null) {
		auto result = APIClient::Login(player);
		APIClient::loggedIn = result["connected"];
		bool registered = result["registered"];
		if(APIClient::loggedIn && registered) {
			accessToken = result["auth_key"];
		} else {
			APIClient::errorCode = result["error"];
		}
		if(APIClient::loggedIn) {
			AccessSettings::accountsInfo = result["accounts"];
		}
	} else {
		APIClient::errorCode = "player_null";
		if(accessToken != "") {
			events.InsertAt(0, "login");
		}
	}
}

void FetchGroupsOwned() {
	GroupSettings::selectedMember = Json::Object();
	GroupSettings::ownedGroups = APIClient::GetGroupsOwned();
	GroupSettings::playersFound = Json::Array();
	if(GroupSettings::ownedGroups.Length > 0) {
		GroupSettings::selectedGroup = GroupSettings::ownedGroups[0];
		if(GroupSettings::selectedGroup["members"].Length > 0) {
			GroupSettings::selectedMember = GroupSettings::selectedGroup["members"][0];
		}
	} else {
		GroupSettings::selectedGroup["id"] = 0;
        GroupSettings::selectedGroup["name"] = "---------";
	}
}
void FetchGroupsJoined() {
	JoinedGroupSettings::joinedGroups = APIClient::GetGroupsJoined();
	if(JoinedGroupSettings::joinedGroups.Length > 0) {
		JoinedGroupSettings::selectedGroup = JoinedGroupSettings::joinedGroups[0];
	} else {
		JoinedGroupSettings::selectedGroup["id"] = 0;
        JoinedGroupSettings::selectedGroup["name"] = "---------";
	}
}

void FetchReceivedInvites() {
	InvitesSettings::receivedInvites = APIClient::GetMyInvites();
}

void AcceptInvite() {
	APIClient::AnswerInvites(true, InvitesSettings::selectedInvite);
	Log::Succeed("Invite accepted.");
	events.InsertAt(0, "fetchReceivedInvites");
}
void DeclineInvite() {
	APIClient::AnswerInvites(false, InvitesSettings::selectedInvite);
	Log::Succeed("Invite declined.");
	events.InsertAt(0, "fetchReceivedInvites");
}
void DeleteInvite() {
	APIClient::DeleteInvite(InvitesSettings::selectedInvite);
	Log::Succeed("Invite deleted.");
	events.InsertAt(0, "fetchSentInvites");
}

void FetchSentInvites() {
	InvitesSettings::sentInvites = APIClient::GetPendingInvites();
}


void LeaveGroup() {
	APIClient::QuitGroup(JoinedGroupSettings::selectedGroup["id"]);
	events.InsertAt(0, "fetchGroupsJoined");
	Log::Succeed("Group left.");
}

void CreateGroup() {
	APIClient::CreateGroup(GroupSettings::groupName);
	GroupSettings::groupName = "";
	events.InsertAt(0, "fetchGroupsOwned");
	Log::Succeed("Group created.");
}

void SearchPlayer() {
	string previousStr = GroupSettings::searchString;
	GroupSettings::searchString = "Searching...";
	GroupSettings::playersFound = APIClient::FindPlayerByNameForGoup(GroupSettings::playerName, GroupSettings::selectedGroup["id"]);
	GroupSettings::searchString = previousStr;
}

void DeleteGroup() {
	APIClient::DeleteGroup(GroupSettings::selectedGroup["id"]);
	events.InsertAt(0, "fetchGroupsOwned");
	Log::Succeed("Group deleted.");
}

void KickPlayer() {
	APIClient::RemovePlayerFromGroup(GroupSettings::selectedMember["id"], GroupSettings::selectedGroup["id"]);
	events.InsertAt(0, "fetchGroupsOwned");
	Log::Succeed("Player kicked.");
}

void InvitePlayer() {
	APIClient::CreateInvite(GroupSettings::playerInvitedId, GroupSettings::selectedGroup["id"]);
	Log::Succeed("Player invited.");
}

void FetchData() {
	if(isRunning) {
		lastChecked = Time::get_Now();
		try {
				auto player = GetPlayer();
				if(player !is null) {
					Json::Value mapInfo = getMapData();
					players = APIClient::SubmitInfoAndRetrieveGroupData(mapInfo, favoriteGroupId);
				} else {
					lastChecked = 0;
				}
				inError = false;
				
		} catch {
			inError = true;
		}
	}
}


void HandleEvents() {
    for( int n = events.Length -1; n >= 0; n-- ) {
        auto event = events[n];
        events.RemoveAt(n);
		if(event == "login") {
            Login();
        } else if(event == "fetchGroupsOwned") {
			FetchGroupsOwned();
		} else if(event == "createGroup") {
			CreateGroup();
		} else if(event == "deleteGroup") {
			DeleteGroup();
		} else if(event == "searchPlayer") {
			SearchPlayer();
		} else if(event == "invitePlayer") {
			InvitePlayer();
		} else if(event == "kickPlayer") {
			KickPlayer();
		} else if(event == "fetchGroupsJoined") {
			FetchGroupsJoined();
		} else if(event == "leaveGroup") {
			LeaveGroup();
		} else if(event == "fetchReceivedInvites") {
			FetchReceivedInvites();
		} else if(event == "fetchSentInvites") {
			FetchSentInvites();
		} else if(event == "acceptInvite") {
			AcceptInvite();
		} else if(event == "declineInvite") {
			DeclineInvite();
		} else if(event == "deleteInvite") {
			DeleteInvite();
		}
    }
	if(Time::get_Now() - lastChecked > refreshRate) {
		if(APIClient::loggedIn && enablePlugin) {
			FetchData();
		}
	}
	if(!APIClient::loggedIn) {
		CheckPlayer();
	}
    sleep(500);
}