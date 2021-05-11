#pragma semicolon 1
#include <sourcemod>
#include <sdktools>
#include <mods_master> 

public Plugin:myinfo = 
{
	name = "[MM] Guns Menu",
	author = "KOROVKA", // Plugin by KOROVKA
	description = "[MM] Guns Menu",
	version = "1.0.0"
};

#define CONFIG_FILE		"addons/sourcemod/configs/mods_master/modules/guns_menu.txt" 

new Handle:kv;

new String:sWeaponName[MAXPLAYERS+1][5][32], String:sDefaultWeaponName[32], g_DefaultWeaponSlot;

public OnPluginStart()
{
	RegConsoleCmd("sm_guns", Cmd_GunsMenu);
	RegConsoleCmd("sm_gunsmenu", Cmd_GunsMenu);
	
	HookEvent("player_spawn", Event_PlayerSpawn); 
}

public OnMapStart()
{
	if(kv != INVALID_HANDLE) CloseHandle(kv);

	kv = CreateKeyValues("Guns Menu");
	
	if(!FileToKeyValues(kv, CONFIG_FILE)) SetFailState("Конфиг по адресу \"%s\" не найден!", CONFIG_FILE);
	
	KvGetString(kv, "default_weapon", sDefaultWeaponName, 32, "");	
	g_DefaultWeaponSlot = KvGetNum(kv, "default_weapon_slot", -1);
}

public Action:CS_OnCSWeaponDrop(client, weapon) 
{
	if(CF_EnabledThisMoment() || CONQUEST_EnabledThisMoment()) return Plugin_Handled;

	return Plugin_Continue;
}

public Event_PlayerSpawn(Handle:event, const String:name[], bool:dontBroadcast) 
{
	if(!CF_EnabledThisMoment() && !CONQUEST_EnabledThisMoment()) return;

	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	
	if(client && GetClientTeam(client) > 1)
	{
		new count;
	
		for(new x = 0; x < 4; x++)
		{
			if(sWeaponName[client][x][0])
			{
				new weapon = GetPlayerWeaponSlot(client, x);
					
				if(weapon != -1) RemovePlayerItem(client, weapon);
					
				GivePlayerItem(client, sWeaponName[client][x]);
				
				count++;
			}
			else if(x == g_DefaultWeaponSlot && sDefaultWeaponName[0])
			{
				new weapon = GetPlayerWeaponSlot(client, g_DefaultWeaponSlot);
					
				if(weapon != -1) RemovePlayerItem(client, weapon);
					
				GivePlayerItem(client, sDefaultWeaponName);
			}
		}
		
		if(count == 0) DisplayGunsMenu(client);
	}
}

public Action:Cmd_GunsMenu(client, args)
{
	if(client > 0) 
	{
		if(CF_EnabledThisMoment()) DisplayGunsMenu(client);
		else PrintToChat(client, "\x04[Guns Menu]\x01 Режим захват флага выключен по этому меню недоступно!");
	}
	
	return Plugin_Handled;
}

DisplayGunsMenu(client)
{
	new Handle:menu = CreateMenu(MenuHandler_GunsMenu);

	SetMenuTitle(menu, "Меню оружия:");
	SetMenuExitBackButton(menu, false);
	
	KvRewind(kv);
	
	new bool:bSectionExists = KvGotoFirstSubKey(kv);
	
	if(!bSectionExists) return;

	decl String:buffer[64];
	
	while(bSectionExists)
	{
		KvGetSectionName(kv, buffer, 64);
		
		AddMenuItem(menu, buffer, buffer);
	
		bSectionExists = KvGotoNextKey(kv);
	}

	DisplayMenu(menu, client, MENU_TIME_FOREVER);
}

public MenuHandler_GunsMenu(Handle:menu, MenuAction:action, param1, param2)
{
	switch(action)
	{
		case MenuAction_Select:
		{
			decl String:sInfo[64];
			GetMenuItem(menu, param2, sInfo, 64);
				
			DisplayGunsMenuCategory(param1, sInfo);
		}
		case MenuAction_End: CloseHandle(menu);
	}
}

DisplayGunsMenuCategory(client, const String:sInfo[])
{
	new Handle:menu = CreateMenu(MenuHandler_GunsMenuCategory);

	SetMenuTitle(menu, "Меню оружия [%s]:", sInfo);
	SetMenuExitBackButton(menu, true);
	
	KvRewind(kv);
	
	if(!KvJumpToKey(kv, sInfo, false)) return;
	
	new bool:bSectionExists = KvGotoFirstSubKey(kv, false);
	
	if(!bSectionExists) return;
	
	decl String:buffer[64];
	
	while(bSectionExists)
	{
		KvGetSectionName(kv, buffer, 64);
		
		if(StrContains(buffer, "slot", true) == -1) AddMenuItem(menu, sInfo, buffer);
	
		bSectionExists = KvGotoNextKey(kv, false);
	}

	DisplayMenu(menu, client, MENU_TIME_FOREVER);
}

public MenuHandler_GunsMenuCategory(Handle:menu, MenuAction:action, param1, param2) 
{
	switch(action)
	{
		case MenuAction_Select:
		{
			decl String:sInfo[64], String:buffer[64], String:strWeaponName[32];
			GetMenuItem(menu, param2, sInfo, 64, _, buffer, 64);
				
			KvRewind(kv);
			
			if(KvJumpToKey(kv, sInfo, false)) 
			{
				new slot = KvGetNum(kv, "slot", -1);
				
				if(slot != -1)
				{
					KvGetString(kv, buffer, strWeaponName, 32);
					
					if(IsPlayerAlive(param1))
					{
						new weapon = GetPlayerWeaponSlot(param1, slot);
					
						if(weapon != -1) RemovePlayerItem(param1, weapon);
					
						GivePlayerItem(param1, strWeaponName);
					}
					
					strcopy(sWeaponName[param1][slot], 32, strWeaponName);
				}
			}
			
			DisplayGunsMenuCategory(param1, sInfo);
		}
		case MenuAction_End: CloseHandle(menu);
		case MenuAction_Cancel: if(param2 == MenuCancel_ExitBack) DisplayGunsMenu(param1);
	}
}

public OnClientDisconnect(client)
{
	sWeaponName[client][0] = "";
	sWeaponName[client][1] = "";
	sWeaponName[client][2] = "";
	sWeaponName[client][3] = "";
	sWeaponName[client][4] = "";
}