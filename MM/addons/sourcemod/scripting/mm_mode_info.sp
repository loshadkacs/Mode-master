#pragma semicolon 1
#include <sourcemod>
#include <sdktools>
#include <mods_master> 

public Plugin:myinfo = 
{
	name = "[MM] Mode Info",
	author = "KOROVKA", // Plugin by KOROVKA
	description = "[MM] Mode Info",
	version = "1.0.0"
};

new g_bTeamSelect[MAXPLAYERS+1];

public OnPluginStart() AddCommandListener(Cmd_JoinTeam, "jointeam"); 

public OnClientPutInServer(client) g_bTeamSelect[client] = false;

public Action:Cmd_JoinTeam(client, const String:command[], args) 
{
	if(client < 1 || !CF_EnabledThisMoment() && !CONQUEST_EnabledThisMoment() || g_bTeamSelect[client]) return;
	
	g_bTeamSelect[client] = true;
	
	CreateTimer(0.5, TimerSendHudMessageClient, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
}

public Action:TimerSendHudMessageClient(Handle:timer, any:client)
{
	if((client = GetClientOfUserId(client)) == 0) return;
	
	if(CF_EnabledThisMoment()) SendHudMessageClient(client, "В данный момент на сервере играется режим захват флага!", "255 255 255");
	else SendHudMessageClient(client, "В данный момент на сервере играется режим захват точек!", "255 255 255");
}

stock SendHudMessageClient(client, const String:sMessage[], const String:sColor[]) 
{
	new game_text = CreateEntityByName("game_text");
	
	if(game_text > 0)
	{
		DispatchKeyValue(game_text, "channel", "5");
		DispatchKeyValue(game_text, "color", sColor);
		DispatchKeyValue(game_text, "color2", "255 255 255");
		DispatchKeyValue(game_text, "effect", "0");
		DispatchKeyValue(game_text, "message", sMessage);
		DispatchKeyValue(game_text, "spawnflags", "0");
		DispatchKeyValueFloat(game_text, "fadein", 1.0);
		DispatchKeyValueFloat(game_text, "fadeout", 1.0);
		DispatchKeyValueFloat(game_text, "fxtime", 3.0);
		DispatchKeyValueFloat(game_text, "holdtime", 5.0);
		DispatchKeyValueFloat(game_text, "x", -1.0);
		DispatchKeyValueFloat(game_text, "y", -0.86);
		
		if(DispatchSpawn(game_text))
		{
			SetVariantString("!activator");
			AcceptEntityInput(game_text, "display", client);
		}
	}
}

public CF_OnStartGame()
{
	for (new i = 1; i <= MaxClients; i++)
	{
		if(IsClientInGame(i)) g_bTeamSelect[i] = true;
	}
}

public CONQUEST_OnStartGame()
{
	for (new i = 1; i <= MaxClients; i++)
	{
		if(IsClientInGame(i)) g_bTeamSelect[i] = true;
	}
}