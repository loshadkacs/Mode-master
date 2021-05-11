#pragma semicolon 1
#include <sourcemod>
#include <sdktools>
#include <mods_master> 

public Plugin:myinfo = 
{
	name = "[MM] Flag Event Notifier",
	author = "KOROVKA", // Plugin by KOROVKA
	description = "[MM] Flag Event Notifier", 
	version = "1.0.0"
};

#define CONFIG_FILE		"addons/sourcemod/configs/mods_master/modules/flag_event_notifier.txt"

new g_ConfigParams[5];
new String:sConfigOverlays[2][4][100];
new g_MessagesEnemy, Float:g_fTimeOverlay;

new Handle:hTimerOverlay[MAXPLAYERS+1];

public OnMapStart()
{
	new Handle:kv = CreateKeyValues("Flag Event Notifier"); 
	
	if(!FileToKeyValues(kv, CONFIG_FILE)) SetFailState("Конфиг по адресу \"%s\" не найден!", CONFIG_FILE);
	
	g_MessagesEnemy = KvGetNum(kv, "Messages Enemy", 1);
	g_ConfigParams[0] = KvGetNum(kv, "Protect Flag Info", 1);
	
	g_fTimeOverlay = KvGetFloat(kv, "Time Overlay", 2.0);
	
	if(KvJumpToKey(kv, "Flag Zone", false))
	{
		g_ConfigParams[1] = KvGetNum(kv, "text", 1);
		KvGetString(kv, "overlay_ct", sConfigOverlays[0][0], 100, "");
		KvGetString(kv, "overlay_t", sConfigOverlays[1][0], 100, "");
		AddFileOverlay(sConfigOverlays[0][0]);
		AddFileOverlay(sConfigOverlays[1][0]);
	}
	
	KvRewind(kv);
	
	if(KvJumpToKey(kv, "Flag Down", false))
	{
		g_ConfigParams[2] = KvGetNum(kv, "text", 1);
		KvGetString(kv, "overlay_ct", sConfigOverlays[0][1], 100, "");
		KvGetString(kv, "overlay_t", sConfigOverlays[1][1], 100, "");
		AddFileOverlay(sConfigOverlays[0][1]);
		AddFileOverlay(sConfigOverlays[1][1]);
	}
	
	KvRewind(kv);
	
	if(KvJumpToKey(kv, "Flag Captured", false))
	{
		g_ConfigParams[3] = KvGetNum(kv, "text", 1);
		KvGetString(kv, "overlay_ct", sConfigOverlays[0][2], 100, "");
		KvGetString(kv, "overlay_t", sConfigOverlays[1][2], 100, "");
		AddFileOverlay(sConfigOverlays[0][2]);
		AddFileOverlay(sConfigOverlays[1][2]);
	}
	
	KvRewind(kv);
	
	if(KvJumpToKey(kv, "Flag Delivered", false))
	{
		g_ConfigParams[4] = KvGetNum(kv, "text", 1);
		KvGetString(kv, "overlay_ct", sConfigOverlays[0][3], 100, "");
		KvGetString(kv, "overlay_t", sConfigOverlays[1][3], 100, "");
		AddFileOverlay(sConfigOverlays[0][3]);
		AddFileOverlay(sConfigOverlays[1][3]);
	}
	
	CloseHandle(kv);
}

public MM_OnFlagProtectTime(team, time)
{
	if(!CF_EnabledThisMoment() || g_ConfigParams[0] != 1) return;

	decl String:buffer[128];

	FormatEx(buffer, 128, "Флаг команды %s будет под защитой ещё %d секунд!", team == 3 ? "контер-террористов":"террористов", GetCaptureFlagConfigParam(CaptureFlag_FlagProtectTime)-time+1);
	
	for (new i = 1; i <= MaxClients; i++)
	{
		if(IsClientInGame(i) && !IsFakeClient(i) && GetClientTeam(i) != team && team == CF_GetClientZoneTeam(i)) SendHudMessageClient(i, buffer, team == 3 ? "0 0 255":"255 0 0", Float:{-1.0, -0.15}, "4", 1.0);
	}
}

public MM_OnFlagEvent(team, MM_Type:event, client, disconnect, ZoneName:zone)
{
	if(!CF_EnabledThisMoment()) return;

	decl String:buffer[128];

	switch(event)
	{
		case ModsMaster_Zone:
		{
			if(g_ConfigParams[1] == 1)
			{
				FormatEx(buffer, 128, "Флаг команды %s возвращен на базу!", team == 3 ? "контер-террористов":"террористов");
				SendHudMessageAllClient(team, buffer, team == 3 ? "0 0 255":"255 0 0");
				SendOverlayAllClient(team, team == 3 ? sConfigOverlays[0][0]:sConfigOverlays[1][0]);
			}
		}
			
		case ModsMaster_Down:
		{
			if(g_ConfigParams[2] == 1)
			{
				FormatEx(buffer, 128, "Флаг команды %s потерян!", team == 3 ? "контер-террористов":"террористов", client);
				SendHudMessageAllClient(team, buffer, team == 3 ? "0 0 255":"255 0 0");
				SendOverlayAllClient(team, team == 3 ? sConfigOverlays[0][1]:sConfigOverlays[1][1]);
			}
		}
			
		case ModsMaster_Captured:
		{
			if(g_ConfigParams[3] == 1)
			{
				FormatEx(buffer, 128, "Флаг команды %s захвачен!", team == 3 ? "контер-террористов":"террористов");
				SendHudMessageAllClient(team, buffer, team == 3 ? "0 0 255":"255 0 0");
				SendOverlayAllClient(team, team == 3 ? sConfigOverlays[0][2]:sConfigOverlays[1][2]);
			}
		}
			
		case ModsMaster_Delivered:
		{
			if(g_ConfigParams[4] == 1)
			{
				FormatEx(buffer, 128, "Игрок %N доставил флаг %s на базу!", client, team == 3 ? "контер-террористов":"террористов");
				SendHudMessageAllClient(team == 3 ? 2:3, buffer, team == 3 ? "255 0 0":"0 0 255", false);
				
				FormatEx(buffer, 128, "Врагу удалось заполучить флаг команды %s!", team == 3 ? "контер-террористов":"террористов");
				SendHudMessageAllClient(team, buffer, team == 3 ? "0 0 255":"255 0 0", false);
				
				SendOverlayAllClient(team, team == 3 ? sConfigOverlays[0][3]:sConfigOverlays[1][3]);
			}
		}
	}
}

stock SendHudMessageAllClient(team, const String:sMessage[128], const String:sColor[], bool:bDelivered = true)
{
	for (new i = 1; i <= MaxClients; i++)
	{
		if(IsClientInGame(i) && !IsFakeClient(i) && (bDelivered && g_MessagesEnemy == 1 || GetClientTeam(i) == team)) SendHudMessageClient(i, sMessage, sColor);
	}
}

stock SendHudMessageClient(client, const String:sMessage[128], const String:sColor[], Float:fPos[2] = {-1.0, -0.1}, String:sChannel[] = "3", Float:hold_time = 5.0)
{
	new game_text = CreateEntityByName("game_text");
	
	if(game_text > 0)
	{
		DispatchKeyValue(game_text, "channel", sChannel);
		DispatchKeyValue(game_text, "color", sColor);
		DispatchKeyValue(game_text, "color2", "255 255 255");
		DispatchKeyValue(game_text, "effect", "0");
		DispatchKeyValue(game_text, "message", sMessage);
		DispatchKeyValue(game_text, "spawnflags", "0");
		DispatchKeyValueFloat(game_text, "fadein", 1.0);
		DispatchKeyValueFloat(game_text, "fadeout", 1.0);
		DispatchKeyValueFloat(game_text, "fxtime", 3.0);
		DispatchKeyValueFloat(game_text, "holdtime", hold_time);
		DispatchKeyValueFloat(game_text, "x", fPos[0]);
		DispatchKeyValueFloat(game_text, "y", fPos[1]);
		
		if(DispatchSpawn(game_text))
		{
			SetVariantString("!activator");
			AcceptEntityInput(game_text, "display", client);
		}
	}
}

stock SendOverlayAllClient(team, String:sOverlay[])
{
	if(sOverlay[0])
	{
		for (new i = 1; i <= MaxClients; i++)
		{
			if(IsClientInGame(i) && !IsFakeClient(i) && (g_MessagesEnemy == 1 || GetClientTeam(i) == team))
			{
				ClientCommand(i, "r_screenoverlay \"%s\"", sOverlay);
				
				KillTimerOverlay(i);
				
				hTimerOverlay[i] = CreateTimer(g_fTimeOverlay, TimerStopOverlay, i);
			}
		}
	}
}

public Action:TimerStopOverlay(Handle:timer, any:client)
{
	hTimerOverlay[client] = INVALID_HANDLE;
	
	if(IsClientInGame(client)) ClientCommand(client, "r_screenoverlay \"\"");
}

stock AddFileOverlay(String:buffer[])
{
	if(buffer[0])
	{
		decl String:buffer_f[128];
		FormatEx(buffer_f, 128, "materials/%s.vtf", buffer);
		AddFileToDownloadsTable(buffer_f);
		FormatEx(buffer_f, 128, "materials/%s.vmt", buffer);
		AddFileToDownloadsTable(buffer_f);
		FormatEx(buffer_f, 128, "%s.vmt", buffer);
		PrecacheDecal(buffer_f, true);
	}
}

public OnClientDisconnect(client) KillTimerOverlay(client);

stock KillTimerOverlay(client)
{
	if(hTimerOverlay[client] != INVALID_HANDLE)
	{
		KillTimer(hTimerOverlay[client]);
		hTimerOverlay[client] = INVALID_HANDLE;
	}
}