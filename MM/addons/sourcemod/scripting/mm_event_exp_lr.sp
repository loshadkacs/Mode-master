#pragma semicolon 1
#include <sourcemod>
#include <sdktools>
#include <mods_master> 
#include <lvl_ranks> 

public Plugin:myinfo = 
{
	name = "[MM] Event Exp LR",
	author = "KOROVKA", // Plugin by KOROVKA
	description = "[MM] Event Exp LR",
	version = "1.0.0"
};

#define CONFIG_FILE		"addons/sourcemod/configs/mods_master/modules/event_exp_lr.txt"

new g_CF_EventsExp[3], g_CONQUEST_EventsExp[5];

public OnPluginStart() HookEvent("round_end", Event_RoundEnd, EventHookMode_PostNoCopy);

public OnMapStart()
{
	new Handle:kv = CreateKeyValues("Event Exp LR"); 
	
	if(!FileToKeyValues(kv, CONFIG_FILE)) SetFailState("Конфиг по адресу \"%s\" не найден!", CONFIG_FILE);
	
	if(KvJumpToKey(kv, "Capture Flag", false))
	{
		g_CF_EventsExp[0] = KvGetNum(kv, "captured_exp", -1);
		g_CF_EventsExp[1] = KvGetNum(kv, "delivered_exp", -1);
		g_CF_EventsExp[2] = KvGetNum(kv, "round_win_exp", -1);
	}
	
	KvRewind(kv);
	
	if(KvJumpToKey(kv, "Conquest", false))
	{
		g_CONQUEST_EventsExp[0] = KvGetNum(kv, "full_captured_exp", -1);
		g_CONQUEST_EventsExp[1] = KvGetNum(kv, "zone_captured_exp", -1);
		g_CONQUEST_EventsExp[2] = KvGetNum(kv, "captured_exp", -1);
		g_CONQUEST_EventsExp[3] = KvGetNum(kv, "delivered_exp", -1);
		g_CONQUEST_EventsExp[4] = KvGetNum(kv, "round_win_exp", -1);
	}
	
	CloseHandle(kv);
}

public Event_RoundEnd(Handle:event, const String:name[], bool:dontBroadcast) 
{
	if(!CF_EnabledThisMoment() && !CONQUEST_EnabledThisMoment()) return;

	new winner = GetEventInt(event, "winner", -1);
	
	if(winner > 1)
	{
		new exp = (CF_EnabledThisMoment() ? g_CF_EventsExp[2]:g_CONQUEST_EventsExp[4]);
		
		if(exp > 0)
		{
			for(new i = 1; i <= MaxClients; i++)
			{
				if(IsClientInGame(i) && !IsFakeClient(i) && GetClientTeam(i) == winner)
					LR_ChangeClientValue(i, exp);
			}
		}
	}
}

public MM_OnFlagEvent(team, MM_Type:event, client, disconnect, ZoneName:zone)
{
	if(CF_EnabledThisMoment()) 
	{
		switch(event)
		{
			case ModsMaster_Captured: if(g_CF_EventsExp[0] > 0) LR_ChangeClientValue(client, g_CF_EventsExp[0]);
			case ModsMaster_Delivered: if(g_CF_EventsExp[1] > 0) LR_ChangeClientValue(client, g_CF_EventsExp[1]);
		}
	}
	else if(CONQUEST_EnabledThisMoment()) 
	{
		switch(event)
		{
			case ModsMaster_FullCaptured: if(g_CONQUEST_EventsExp[0] > 0) LR_ChangeClientValue(client, g_CONQUEST_EventsExp[0]);
			case ModsMaster_ZoneCaptured: if(g_CONQUEST_EventsExp[1] > 0) LR_ChangeClientValue(client, g_CONQUEST_EventsExp[1]);
			case ModsMaster_Captured: if(g_CONQUEST_EventsExp[2] > 0) LR_ChangeClientValue(client, g_CONQUEST_EventsExp[2]);
			case ModsMaster_Delivered: if(g_CONQUEST_EventsExp[3] > 0) LR_ChangeClientValue(client, g_CONQUEST_EventsExp[3]);
		}
	}
}