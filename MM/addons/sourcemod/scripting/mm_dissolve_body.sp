#pragma semicolon 1
#include <sourcemod>
#include <sdktools>
#include <mods_master> 

public Plugin:myinfo = 
{
	name = "[MM] Dissolve Body",
	author = "KOROVKA", // Plugin by KOROVKA
	description = "[MM] Dissolve Body",
	version = "1.0.0"
};

#define DISSOLVE_BODY_TIMER 1.5 // Задержка до растворения тела

public OnPluginStart() HookEvent("player_death", Event_PlayerDeath); 

public Event_PlayerDeath(Handle:event, const String:name[], bool:dontBroadcast)
{
	if(!CF_EnabledThisMoment() && !CONQUEST_EnabledThisMoment()) return;

	new client = GetClientOfUserId(GetEventInt(event, "userid"));

	if(client)
	{
		new ragdoll = GetEntPropEnt(client, Prop_Send, "m_hRagdoll");
		if(ragdoll > 0) CreateTimer(DISSOLVE_BODY_TIMER, TimerDissolve, EntIndexToEntRef(ragdoll), TIMER_FLAG_NO_MAPCHANGE);  
	}
}

public Action:TimerDissolve(Handle:timer, any:ragdoll_ref)
{
	new ragdoll = EntRefToEntIndex(ragdoll_ref);
	if(ragdoll > 0 && IsValidEntity(ragdoll))
	{ 
		new ent = CreateEntityByName("env_entity_dissolver");
		if(ent > 0)
		{
			decl String:buffer[10]; 
			FormatEx(buffer, 10, "cf_%d", ragdoll);
			DispatchKeyValue(ragdoll, "targetname", buffer);
			DispatchKeyValue(ent, "target", buffer);
			DispatchKeyValue(ent, "dissolvetype", "1");
			DispatchKeyValue(ent, "magnitude", "15.0");
			AcceptEntityInput(ent, "Dissolve");
			AcceptEntityInput(ent, "Kill");
			
			IgniteEntity(ragdoll, 3.0);
		}
	}
}