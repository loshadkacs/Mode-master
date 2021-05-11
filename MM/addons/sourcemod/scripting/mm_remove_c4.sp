#pragma semicolon 1
#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <mods_master> 

public Plugin:myinfo = 
{
	name = "[MM] Remove C4",
	author = "KOROVKA", // Plugin by KOROVKA 
	description = "[MM] Remove C4",
	version = "1.0.0"
};

public OnPluginStart()
{
	for (new i = 1; i <= MaxClients; i++)
	{
		if(IsClientInGame(i)) 
			OnClientPutInServer(i);
	}
}

public OnClientPutInServer(client) SDKHook(client, SDKHook_PreThink, OnClientThink);

public OnClientThink(client)
{
	if(!CF_EnabledThisMoment() && !CONQUEST_EnabledThisMoment() || !IsPlayerAlive(client)) return; 
	
	new weapon = GetPlayerWeaponSlot(client, 4);		
	if(weapon != -1) RemovePlayerItem(client, weapon);
}