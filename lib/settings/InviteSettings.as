namespace InvitesSettings {
    bool invitesLoaded = false;
    Json::Value receivedInvites = Json::Array();
    Json::Value sentInvites = Json::Array();
    int selectedInvite = 0;
    void RenderReceivedInvites() {
        UI::BeginTable("receivedInvites", 4, UI::TableFlags::SizingFixedFit);
        UI::TableNextRow();
		UI::TableNextColumn();
        UI::Text("Received invites : ");
		UI::TableNextColumn();
        if(UI::Button(" Refresh")){
            Log::Warn("Refreshing...");
            events.InsertAt(0, "fetchReceivedInvites");
        }
        if(receivedInvites.Length == 0) {
            UI::TableNextRow();
            UI::TableNextColumn();
            UI::Text("No invite received");
        } else {
            UI::TableNextRow();
            UI::TableNextColumn();
            UI::Text("Group");
            UI::TableNextColumn();
            UI::Text("From");
            for(uint i=0; i < receivedInvites.Length; i++) {
                UI::TableNextRow();
                UI::TableNextColumn();
                UI::Text(ColoredString(receivedInvites[i]["group"]["name"]));
                UI::TableNextColumn();
                UI::Text(ColoredString(receivedInvites[i]["from_player"]["display_name"]));
                UI::TableNextColumn();
                UI::PushStyleColor(UI::Col::Button, vec4(0,1,0,1));
                if(UI::Button(" Accept")){
                    selectedInvite = receivedInvites[i]["id"];
                    events.InsertAt(0, "acceptInvite");
                }
                UI::PopStyleColor(1);
                UI::TableNextColumn();
                UI::PushStyleColor(UI::Col::Button, vec4(1,0,0,1));
                if(UI::Button(" Decline")){
                    selectedInvite = receivedInvites[i]["id"];
                    events.InsertAt(0, "declineInvite");
                }
                UI::PopStyleColor(1);
            }
        }
        UI::TableNextRow();
        UI::Text("");
        UI::TableNextRow();
        UI::Text("");
        UI::EndTable();
        
    }

    void RenderSentInvites() {
        UI::BeginTable("sentInvites", 3, UI::TableFlags::SizingFixedFit);
        UI::TableNextRow();
		UI::TableNextColumn();
        UI::Text("Sent invites : ");
		UI::TableNextColumn();
        if(UI::Button(" Refresh")){
            Log::Warn("Refreshing...");
            events.InsertAt(0, "fetchSentInvites");
        }
        if(sentInvites.Length == 0) {
            UI::TableNextRow();
            UI::TableNextColumn();
            UI::Text("No invite sent");
        } else {
            UI::TableNextRow();
            UI::TableNextColumn();
            UI::Text("Group");
            UI::TableNextColumn();
            UI::Text("To");
            for(uint i=0; i < sentInvites.Length; i++) {
                UI::TableNextRow();
                UI::TableNextColumn();
                UI::Text(ColoredString(sentInvites[i]["group"]["name"]));
                UI::TableNextColumn();
                UI::Text(ColoredString(sentInvites[i]["to_player"]["display_name"]));
                UI::TableNextColumn();
                UI::PushStyleColor(UI::Col::Button, vec4(1,0,0,1));
                if(UI::Button(" Delete")){
                    selectedInvite = sentInvites[i]["id"];
                    events.InsertAt(0, "deleteInvite");
                }
                UI::PopStyleColor(1);
            }
        }
        UI::EndTable();
        
    }
}

[SettingsTab name="Invites" icon="Upload"]
void RenderInviteSettings()
{
    if(APIClient::loggedIn) {
        if(!InvitesSettings::invitesLoaded) {
            InvitesSettings::invitesLoaded = true;
            events.InsertAt(0, "fetchReceivedInvites");
            events.InsertAt(0, "fetchSentInvites");
        }
        InvitesSettings::RenderReceivedInvites();
        InvitesSettings::RenderSentInvites();
    } else {
        UI::Text(getError(APIClient::errorCode));
    }
}