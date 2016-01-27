/*
* 	AdvanceRestart
* 	By Darklord1474
*   Modified by Outlaw11A
*
*   Commands
* 	sm_restart
*	Usage: sm_restart <seconds Between 0 and 120>"
*/

#include <sourcemod>
#include <sdktools>
#define PLUGIN_VERSION "2.0"

new Handle:g_hEnabledChat;
new Handle:g_hEnabledHint;
new Handle:g_hEnabledCenter;
new String:filelocation[255];
new currenttime = 0;
new targettime= 10;
new STOP;
public Plugin:myinfo =
{
	name = "AdvanceRestart",
	author = "Outlaw11A",
	description = "AdvanceRestart",
	version = "2.0",
}

public OnPluginStart()
{
	currenttime = 0;
	targettime = 10;
	filelocation = "buttons/bell1.wav";
	if (FileExists(filelocation)) {
		PrecacheSound(filelocation, true);
	}
	CreateConVar("sm_AdvanceRestart_version", PLUGIN_VERSION, "AdvanceRestart version", FCVAR_PLUGIN|FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY);
	RegAdminCmd("sm_restart", Command_Restart,ADMFLAG_RCON, "Restarts the Server.");
	RegAdminCmd("sm_stoprestart", Command_stopRestart,ADMFLAG_RCON, "Stops the restart");
	g_hEnabledHint = CreateConVar("sm_ar_hintsay", "1", "Sets whether messages are sent to hintsay");
	g_hEnabledChat = CreateConVar("sm_ar_chatsay", "1", "Sets whether messages are sent to chatsay");
	g_hEnabledCenter = CreateConVar("sm_ar_centersay", "1", "Sets whether messages are sent to centersay");
}

public Action:PrintMsg(Handle:timer)
{
	if (STOP == 1) {
		KillTimer(Handle:timer);
		return Plugin_Handled;
	}

	new maxplayers = GetMaxClients();

	if (currenttime == targettime) {

		// force client to retry from superadmin by pRED*
		for(new i = 1; i <= maxplayers; i++) {
		    if (IsClientInGame(i)) {
			    ClientCommand(i, "retry")
			}
		}

		KillTimer(Handle:timer);
		ServerCommand("_restart");
		return Plugin_Handled;

	} else {

		if (GetConVarInt(g_hEnabledHint) >= 1) {
		    PrintHintTextToAll("Restart in %d, !sm_stoprestart to cancel", (targettime-currenttime));
		}

		if (GetConVarInt(g_hEnabledChat) >= 1) {
		    PrintToChatAll("Restart in %d, !sm_stoprestart to cancel", (targettime-currenttime));
		}
		if (GetConVarInt(g_hEnabledCenter) >= 1) {
		    PrintCenterTextAll("%d", (targettime-currenttime));
		}
	}

	currenttime++;
	return Plugin_Continue;

}

public Action:Command_stopRestart(client, args) {
	STOP = 1;
	PrintToChatAll("Server restart stopped.");
	return Plugin_Handled;
}

public Action:Command_Restart(client, args) {
	decl String:sec[32];

	new secs;
	STOP = 0;

	GetCmdArg(1, sec, sizeof(sec));
	secs = StringToInt(sec);

	if (secs < 0 || secs > 120) {
		ReplyToCommand(client, "[SM] Usage: sm_restart <seconds Between 0 and 120> [reason]");
		return Plugin_Handled;
	} else {

	    EmitSoundToAll(filelocation);

		if (GetConVarInt(g_hEnabledHint) >= 1) {
		    PrintHintTextToAll(" - Server is restarting in %d seconds - ", (secs));
		}

		if (GetConVarInt(g_hEnabledChat) >= 1) {
		    PrintToChatAll(" - Server is restarting in %d seconds - ", (secs));
		}

		if (GetConVarInt(g_hEnabledCenter) >= 1) {
            PrintHintTextToAll(" - Server is restarting in %d seconds - ", (secs));
		}

		targettime = secs;
		currenttime = 0;
		CreateTimer(1.0, PrintMsg, _, TIMER_REPEAT);

	}

	return Plugin_Handled;
}