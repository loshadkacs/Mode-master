#pragma semicolon 1
#include <sourcemod>
#include <sdktools>
#include <cstrike>
#include <mods_master> 

public Plugin:myinfo = 
{
	name = "[MM] Auto Respawn",
	author = "KOROVKA", // Plugin by KOROVKA
	description = "[MM] Auto Respawn",
	version = "1.0.0"
};

#define RESPAWN_TIMER 3.0 // Спустя сколько секунд после смерти игрок возродится 

public OnPluginStart() 
{
	HookEvent("player_death", Event_PlayerDeath);
	
	AddCommandListener(Cmd_JoinTeam, "jointeam");
}

public Action:Cmd_JoinTeam(client, const String:command[], args) 
{
	if(client < 1 || !CF_EnabledThisMoment() && !CONQUEST_EnabledThisMoment()) return;
	
	decl String:buffer[3];
	GetCmdArgString(buffer, 3);
	new team = StringToInt(buffer);

	if(team > 1 && GetClientTeam(client) <= 1) CreateTimer(RESPAWN_TIMER, TimerRespawn, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE); 
}

public Event_PlayerDeath(Handle:event, const String:name[], bool:dontBroadcast) 
{
	if(!CF_EnabledThisMoment() && !CONQUEST_EnabledThisMoment()) return;

	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	
	if(client && GetClientTeam(client) > 1) CreateTimer(RESPAWN_TIMER, TimerRespawn, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
}

public Action:TimerRespawn(Handle:timer, any:client)
{
	if(!CF_EnabledThisMoment() && !CONQUEST_EnabledThisMoment() || (client = GetClientOfUserId(client)) == 0 || GetClientTeam(client) <= 1 || IsPlayerAlive(client)) return;
	
	CS_RespawnPlayer(client);
}
