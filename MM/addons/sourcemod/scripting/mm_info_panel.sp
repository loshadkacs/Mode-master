#pragma semicolon 1
#include <sourcemod>
#include <sdktools>
#include <mods_master> 

public Plugin:myinfo = 
{
	name = "[MM] Info Panel",
	author = "KOROVKA", // Plugin by KOROVKA
	description = "[MM] Info Panel",
	version = "1.0.0"
};

new g_GameText[MAXPLAYERS+1];

public OnPluginStart() CreateTimer(0.1, TimerUpdate, _, TIMER_REPEAT); 

public OnCientDisconnect(client) g_GameText[client] = 0;

public Action:TimerUpdate(Handle:timer)
{
	if(CF_EnabledThisMoment())
	{
		new MM_Type:Flag[2];
	
		Flag[0] = CF_GetFlagStatusTeam(3);
		Flag[1] = CF_GetFlagStatusTeam(2);
		
		if(Flag[0] == ModsMaster_None || Flag[1] == ModsMaster_None) return; 
		
		decl String:buffer[128];
		FormatEx(buffer, 128, "[Флаг КТ: %s | Флаг Т: %s]", Flag[0] == ModsMaster_Zone ? "В зоне":Flag[0] == ModsMaster_Down ? "Потерян":Flag[0] == ModsMaster_Captured ? "Захвачен":"Ошибка", Flag[1] == ModsMaster_Zone ? "В зоне":Flag[1] == ModsMaster_Down ? "Потерян":Flag[1] == ModsMaster_Captured ? "Захвачен":"Ошибка");
	
		for(new i = 1; i <= MaxClients; i++)
		{
			if(IsClientInGame(i) && !IsFakeClient(i))
				SendHudMessageClient(i, buffer, "255 255 255");
		}
	}
	else if(CONQUEST_EnabledThisMoment())
	{
		new ZoneTeam[4];
	
		ZoneTeam[0] = GetConquestZoneParam(Conquest_A, Conquest_Team);
		ZoneTeam[1] = GetConquestZoneParam(Conquest_B, Conquest_Team); 
		ZoneTeam[2] = GetConquestZoneParam(Conquest_C, Conquest_Team); 
		ZoneTeam[3] = GetConquestZoneParam(Conquest_D, Conquest_Team);
		
		new count;
		
		decl String:buffer[128];
		
		FormatEx(buffer, 128, "[");
				
		if(CONQUEST_GetFlagStatusZone(Conquest_A) != ModsMaster_None)
		{
			FormatEx(buffer, 128, "%sA: %s", buffer, ZoneTeam[0] == 0 ? "Н":ZoneTeam[0] == 3 ? "КТ":"Т");
			count++;
		}
		
		if(CONQUEST_GetFlagStatusZone(Conquest_B) != ModsMaster_None)
		{
			FormatEx(buffer, 128, "%s | B: %s", buffer, ZoneTeam[1] == 0 ? "Н":ZoneTeam[1] == 3 ? "КТ":"Т");
			count++;
		}
	
		if(CONQUEST_GetFlagStatusZone(Conquest_C) != ModsMaster_None)
		{
			FormatEx(buffer, 128, "%s | C: %s", buffer, ZoneTeam[2] == 0 ? "Н":ZoneTeam[2] == 3 ? "КТ":"Т");
			count++;
		}
	
		if(CONQUEST_GetFlagStatusZone(Conquest_D) != ModsMaster_None)
		{
			FormatEx(buffer, 128, "%s | D: %s", buffer, ZoneTeam[3] == 0 ? "Н":ZoneTeam[3] == 3 ? "КТ":"Т");
			count++;
		}
	
		FormatEx(buffer, 128, "%s]", buffer);
	
		if(count > 0)
		{
			for(new i = 1; i <= MaxClients; i++)
			{
				if(IsClientInGame(i) && !IsFakeClient(i))
					SendHudMessageClient(i, buffer, "255 255 255");
			}
		}
	}
}

stock SendHudMessageClient(client, const String:sMessage[], const String:sColor[]) 
{
	if(g_GameText[client] > 0 && IsValidEntity(g_GameText[client])) AcceptEntityInput(g_GameText[client], "Kill");

	g_GameText[client] = CreateEntityByName("game_text");
	
	if(g_GameText[client] > 0)
	{
		DispatchKeyValue(g_GameText[client], "channel", "2");
		DispatchKeyValue(g_GameText[client], "color", sColor);
		DispatchKeyValue(g_GameText[client], "color2", "255 255 255");
		DispatchKeyValue(g_GameText[client], "effect", "0");
		DispatchKeyValue(g_GameText[client], "message", sMessage);
		DispatchKeyValue(g_GameText[client], "spawnflags", "0");
		DispatchKeyValueFloat(g_GameText[client], "fadein", 0.0);
		DispatchKeyValueFloat(g_GameText[client], "fadeout", 0.0);
		DispatchKeyValueFloat(g_GameText[client], "fxtime", 0.0);
		DispatchKeyValueFloat(g_GameText[client], "holdtime", 0.15);
		DispatchKeyValueFloat(g_GameText[client], "x", -1.0);
		DispatchKeyValueFloat(g_GameText[client], "y", -0.89);
		
		if(DispatchSpawn(g_GameText[client]))
		{
			SetVariantString("!activator");
			AcceptEntityInput(g_GameText[client], "display", client);
		}
	}
}