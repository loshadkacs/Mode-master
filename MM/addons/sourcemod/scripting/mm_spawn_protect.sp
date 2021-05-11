#pragma semicolon 1
#include <sourcemod>
#include <sdktools>
#include <mods_master> 

public Plugin:myinfo = 
{
	name = "[MM] Spawn Protect",
	author = "KOROVKA", // Plugin by KOROVKA
	description = "[MM] Spawn Protect",
	version = "1.0.0"
};

#define PROTECT_TIMER 3.0 // Сколько секунд после спавна игрок будет неуязвим 

#define DAMAGE_NO		0
#define DAMAGE_YES		2

new Handle:hTimerSpawnProtect[MAXPLAYERS+1];

public OnPluginStart() HookEvent("player_spawn", Event_PlayerSpawn);

public Event_PlayerSpawn(Handle:event, const String:name[], bool:dontBroadcast) 
{
	if(!CF_EnabledThisMoment() && !CONQUEST_EnabledThisMoment()) return;

	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	
	if(client && IsClientInGame(client) && GetClientTeam(client) > 1)
	{
		OnClientDisconnect(client);
		
		hTimerSpawnProtect[client] = CreateTimer(PROTECT_TIMER, TimerOffProtect, client); 
		
		SetEntProp(client, Prop_Data, "m_takedamage", DAMAGE_NO, 1);
	}
}

public Action:TimerOffProtect(Handle:timer, any:client)
{
	hTimerSpawnProtect[client] = INVALID_HANDLE;

	SetEntProp(client, Prop_Data, "m_takedamage", DAMAGE_YES, 1);
}

public OnClientDisconnect(client)
{
	if(hTimerSpawnProtect[client] != INVALID_HANDLE)
	{
		KillTimer(hTimerSpawnProtect[client]);
		hTimerSpawnProtect[client] = INVALID_HANDLE;
	}
}