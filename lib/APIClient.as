namespace APIClient {

    bool loggedIn = false;
    string errorCode = "not_logged";
    /**
        Method to login to the API. Will automaticly register if player doesn't have a token.
        Return Cases :
            - Login successful : {"connected": true, "registered": false, error: ""}
            - Registration successful : {"connected": true, "registered": true, "accessToken":"ABCD", error: ""}
            - Registration unsuccessful : {"connected": false, "registered": false, error: "account_exists"}
            - Login unsuccessful : {"connected": false, "registered": false, error: "wrong_token_or_account"}
    */
    Json::Value Login(Json::Value player) {
        return API::PostFromApiAsync(baseURL + "login/", Json::Write(player));
    }

    /**
        Method to get groups current player has joined
        Return :
            [
                {
                    "id": 1,
                    "name": "$f00My cool $0f0group",
                    "owner" : {"displayName":"[TMA] racacax"},
                    "members": [{"displayName":"GearIssueTM"}] // doesn't contain owner
                }
            ]
    */
    Json::Value GetGroupsJoined() {
        return API::GetFromApiAsync(baseURL + "groups_joined/");
    }

    
    /**
        Method to get groups current player has created
        Return :
            [
                {
                    "id": 1,
                    "name": "$f00My cool $0f0group",
                    "members": [{"id":3,"displayName":"GearIssueTM"}]  // doesn't contain owner
                }
            ]
    */
    Json::Value GetGroupsOwned() {
        return API::GetFromApiAsync(baseURL + "groups_owned/");
    }

    /**
        Method to create a new group
        Return :
            {
                "id": 1,
                "name": "$f00My cool $0f0group"
            }
    */
    Json::Value CreateGroup(const string &in groupName) {
        Json::Value data = Json::Object();
        data["name"] = groupName;
        return API::PostFromApiAsync(baseURL + "groups_owned/", Json::Write(data));
    }

    
    /**
        Method to quit a group
        Return : true | false
    */
    Json::Value QuitGroup(int groupId) {
        Json::Value data = Json::Object();
        data["id"] = groupId;
        return API::DeleteFromApiAsync(baseURL + "groups_joined/", Json::Write(data));
    }

    /**
        Method to delete a group current player has created
        Return : true | false
    */
    Json::Value DeleteGroup(int groupId) {
        Json::Value data = Json::Object();
        data["id"] = groupId;
        return API::DeleteFromApiAsync(baseURL + "groups_owned/", Json::Write(data));
    }

    /**
        Method to get invites other players have sent to the current players
        Return :
        [
            {
                "groupId":1,
                "groupName":"Sheesh",
                "from":{"displayName": "[TMA] racacax"},
                "members":[{"displayName":"GearIssueTM"}]  // doesn't contain owner
            }
        ]
    */
    Json::Value GetMyInvites() {
        return API::GetFromApiAsync(baseURL + "received_invites/");
    }

    /**
        Method to get invites current player has sent but other players haven't responded
        Return :
        [
            {
                "groupId":1,
                "groupName":"Sheesh",
                "playersInvited":[{"displayName": "[TMA] racacax"}, {"displayName": "GearIssueTM"}]
            }
        ]
    */
    Json::Value GetPendingInvites() {
        return API::GetFromApiAsync(baseURL + "sent_invites/");
    }

    /**
        Method to answer positively or negatively to a group request
        Return :  true | false
    */
   Json::Value AnswerInvites(bool accept, int inviteId) {
        Json::Value data = Json::Object();
        data["id"] = inviteId;
        if(accept) {
            return API::PostFromApiAsync(baseURL + "received_invites/", Json::Write(data));
        } else {
            return API::DeleteFromApiAsync(baseURL + "received_invites/", Json::Write(data));
        }
    }

    /**
        Method to send an invite to a player
        {
            "id": 1,
            "groupId":2,
            "playerDisplayName":"[TMA] racacax"
        }
    */
    Json::Value CreateInvite(int playerId, int groupId) {
        Json::Value data = Json::Object();
        data["id"] = groupId;
        data["player_id"] = playerId;
        return API::PostFromApiAsync(baseURL + "sent_invites/", Json::Write(data));
    }

    /**
        Method to delete a group current player has created
        Return : true | false
    */
    Json::Value DeleteInvite(int inviteId) {
        Json::Value data = Json::Object();
        data["id"] = inviteId;
        return API::DeleteFromApiAsync(baseURL + "sent_invites/", Json::Write(data));
    }

    /**
        Method to remove a player from a group
        {
            "success": true
        }
    */
    Json::Value RemovePlayerFromGroup(int playerId, int groupId) {
        Json::Value data = Json::Object();
        data["group_id"] = groupId;
        data["player_id"] = playerId;
        return API::DeleteFromApiAsync(baseURL + "remove_player_from_group/", Json::Write(data));
    }

    /**
        Main method to submit current map info and retrieve data about selected group
        [
            {
                "playerName":"racacax",
                "gameId":0
                "mapName":"My Cool Map",
                "mapUid": "Uiiid",
                "atGap": "+1.556",
                "playerClubTag":"jjk",
                "playerRegion":"World|Europe|Sweden"
            }
        ]
    */
    Json::Value SubmitInfoAndRetrieveGroupData(Json::Value data, int groupId) {
        data["group_id"] = groupId;
        return API::PostFromApiAsync(baseURL + "main_loop/", Json::Write(data));
    }

    
    /**
        Find a player by name (minimum 3 char. Result limit = 10)
        Result : [
            {"displayName":"[TMA] racacax", "id":1},
            {"displayName":"GearIssueTM", "id":3}
        ]
    */
    Json::Value FindPlayerByNameForGoup(const string &in playerName, int groupId) {
        Json::Value data = Json::Object();
        data["group_id"] = groupId;
        data["player_name"] = playerName;
        return API::PostFromApiAsync(baseURL + "find_player/", Json::Write(data));
    }
    

}