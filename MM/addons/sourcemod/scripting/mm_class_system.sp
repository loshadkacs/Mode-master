#pragma semicolon 1
#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <cstrike>
#include <dhooks>
#include <mods_master> 

public Plugin:myinfo = 
{
	name = "[MM] Class System",
	author = "KOROVKA", // Plugin by KOROVKA
	description = "[MM] Class System",
	version = "1.0.2"
};

enum VIP_ToggleState
{
	DISABLED = 0,		// Выключено
	ENABLED,			// Включено
	NO_ACCESS			// Нет доступа
}

native bool:VIP_IsClientVIP(client);
native bool:VIP_IsValidFeature(const String:sFeature[]);
native bool:VIP_IsValidVIPGroup(const String:sGroup[]);
native bool:VIP_SetClientFeatureStatus(client, const String:sFeature[], VIP_ToggleState:eStatus, bool:bCallback = true, bool:bSave = false);
native VIP_ToggleState:VIP_GetClientFeatureStatus(client, const String:sFeature[]);
native bool:VIP_GetClientVIPGroup(client, String:sGroup[], maxlength);
native VIP_GiveClientVIP(admin = 0, client, time, const String:sGroup[], bool:bAddToDB = true);
native bool:VIP_RemoveClientVIP2(admin = 0, client, bool:bInDB, bool:bNotify);

#define CONFIG_FILE		"addons/sourcemod/configs/mods_master/modules/class_system.txt"

new Handle:kv;

new Float:g_fTime[MAXPLAYERS+1];
new bool:g_bActivatedClass[MAXPLAYERS+1];

new String:sUseClassIdentifier[MAXPLAYERS+1][32];

new String:sClassModel[MAXPLAYERS+1][2][128], String:sClassModelArm[MAXPLAYERS+1][2][128], g_HealthCount[MAXPLAYERS+1];

new String:sModelAmmoBox[128], Float:g_fMins[3], Float:g_fMaxs[3], g_Rotate, Float:g_fLifeTime;

new Handle:g_hGetMaxClip, Handle:g_hGetMaxReserve;

new Handle:ammo_grenade_limit_default, Handle:ammo_grenade_limit_flashbang, Handle:ammo_grenade_limit_total;

new Handle:hArrayVIPFunctions[MAXPLAYERS+1], Handle:hArrayVIPFunctionsState[MAXPLAYERS+1];
new String:g_sVIPGroup[MAXPLAYERS+1][64];

public APLRes:AskPluginLoad2(Handle:myself, bool:late, String:error[], err_max) 
{
	MarkNativeAsOptional("VIP_IsClientVIP");
	MarkNativeAsOptional("VIP_IsValidFeature");
	MarkNativeAsOptional("VIP_IsValidVIPGroup");
	MarkNativeAsOptional("VIP_SetClientFeatureStatus");
	MarkNativeAsOptional("VIP_GetClientFeatureStatus");
	MarkNativeAsOptional("VIP_GetClientVIPGroup");
	MarkNativeAsOptional("VIP_GiveClientVIP");
	MarkNativeAsOptional("VIP_RemoveClientVIP2");
}

public OnPluginStart()
{
	RegConsoleCmd("sm_class", Cmd_Class);
	RegConsoleCmd("sm_classes", Cmd_Class);
	RegConsoleCmd("class", Cmd_Class);
	RegConsoleCmd("classes", Cmd_Class);
	
	RegConsoleCmd("say", Cmd_Say);
	RegConsoleCmd("say_team", Cmd_Say);
	
	for(new i = 1; i <= MaxClients; i++)
	{
		hArrayVIPFunctions[i] = CreateArray(ByteCountToCells(64));
		hArrayVIPFunctionsState[i] = CreateArray(ByteCountToCells(3));
	}
	
	new Handle:hConfig = LoadGameConfigFile("class-system.gamedata");
	
	if(hConfig == INVALID_HANDLE) SetFailState("Unable to load game config file: class-system.gamedata.txt");
	
	new offset = GameConfGetOffset(hConfig, "GetMaxClip");
	
	if(offset == -1) SetFailState("Unable to find offset 'GetMaxClip' in game data 'class-system.gamedata.txt'");
	
	g_hGetMaxClip = DHookCreate(offset, HookType_Entity, ReturnType_Int, ThisPointer_CBaseEntity, DH_GetMaxClip);
	
	if(g_hGetMaxClip == INVALID_HANDLE) SetFailState("[DHooks] Unable to create hook GetMaxClip");
	
	offset = GameConfGetOffset(hConfig, "GetMaxReserve");
	
	if(offset == -1) SetFailState("Unable to find offset 'GetMaxReserve' in game data 'class-system.gamedata.txt'");
	
	g_hGetMaxReserve = DHookCreate(offset, HookType_Entity, ReturnType_Int, ThisPointer_CBaseEntity, DH_GetMaxReserve);
	
	if(g_hGetMaxReserve == INVALID_HANDLE) SetFailState("[DHooks] Unable to create hook GetMaxReserve");
	
	DHookAddParam(g_hGetMaxReserve, HookParamType_Unknown);
	
	CloseHandle(hConfig);
	
	HookEvent("player_spawn", Event_PlayerSpawn, EventHookMode_Post);
	HookEvent("player_death", Event_PlayerDeath, EventHookMode_Post);
	HookEvent("player_team", Event_PlayerTeam, EventHookMode_Post);
	HookEvent("round_start", Event_RoundStart, EventHookMode_PostNoCopy);
	
	ammo_grenade_limit_default = FindConVar("ammo_grenade_limit_default");
	SetConVarInt(ammo_grenade_limit_default, 0, false, false);
	HookConVarChange(ammo_grenade_limit_default, OnSettingChanged);
	
	ammo_grenade_limit_flashbang = FindConVar("ammo_grenade_limit_flashbang");
	SetConVarInt(ammo_grenade_limit_flashbang, 0, false, false);
	HookConVarChange(ammo_grenade_limit_flashbang, OnSettingChanged);
	
	ammo_grenade_limit_total = FindConVar("ammo_grenade_limit_total");
	SetConVarInt(ammo_grenade_limit_total, 0, false, false);
	HookConVarChange(ammo_grenade_limit_total, OnSettingChanged);
}

public OnPluginEnd()
{
	for(new i = 1; i <= MaxClients; i++)	
	{
		if(IsClientInGame(i) && !IsFakeClient(i)) 
		{
			TakeAccessVIPClient(i);
			SetBackClientVIPFunctions(i);
		}
	}
}

public OnSettingChanged(Handle:convar, String:oldValue[], String:newValue[])
{
	if(ammo_grenade_limit_default == convar) SetConVarInt(ammo_grenade_limit_default, 0, false, false);
	else if(ammo_grenade_limit_flashbang == convar) SetConVarInt(ammo_grenade_limit_flashbang, 0, false, false);
	else if(ammo_grenade_limit_total == convar) SetConVarInt(ammo_grenade_limit_total, 0, false, false);
}

public OnMapStart()
{
	if(kv != INVALID_HANDLE) CloseHandle(kv);

	kv = CreateKeyValues("Class System");
	
	if(!FileToKeyValues(kv, CONFIG_FILE)) 
		SetFailState("Конфиг по адресу \"%s\" не найден!", CONFIG_FILE); 
	
	if(KvJumpToKey(kv, "Ammo Box", false))
	{
		KvGetString(kv, "model", sModelAmmoBox, 128, "");
		KvGetVector(kv, "mins", g_fMins, Float:{-15.0, -15.0, 0.0});
		KvGetVector(kv, "maxs", g_fMaxs, Float:{15.0, 15.0, 20.0});
	
		g_Rotate = KvGetNum(kv, "rotate", 1);
		
		g_fLifeTime = KvGetFloat(kv, "life_time", 60.0);
	}
	
	for(new i = 1; i <= MaxClients; i++)
	{
		ClearArray(hArrayVIPFunctions[i]);
		ClearArray(hArrayVIPFunctionsState[i]);
	}
}

public Action:Cmd_Class(client, args)
{
	if(client > 0) CreateClassesMenu(client);

	return Plugin_Handled;
}

public Action:Cmd_Say(client, args)
{
	decl String:sText[32];

	GetCmdArgString(sText, 32);
	StripQuotes(sText);
	TrimString(sText);
	
	if(StrEqual(sText, "!класс", false) || StrEqual(sText, "!классы", false)) 
		CreateClassesMenu(client);
}

public OnClientDisconnect(client) 
{
	sUseClassIdentifier[client] = "";
	g_fTime[client] = 0.0;
	g_bActivatedClass[client] = false;
	
	ClearArray(hArrayVIPFunctions[client]);
	ClearArray(hArrayVIPFunctionsState[client]);
	
	g_sVIPGroup[client] = "";
}

public Event_PlayerSpawn(Handle:event, const String:name[], bool:dontBroadcast) 
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	
	if(client) 
	{
		if(sUseClassIdentifier[client][0]) CreateTimer(0.15, TimerSpawnSetClass, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
		else if(g_bActivatedClass[client]) ResetClass(client, _, false);
	}
}

public Action:TimerSpawnSetClass(Handle:timer, any:client) 
{
	if((client = GetClientOfUserId(client)) == 0 || !IsPlayerAlive(client) || !sUseClassIdentifier[client][0]) return; 

	SetClass(client);
}

public Event_PlayerDeath(Handle:event, const String:name[], bool:dontBroadcast) 
{
	new victim = GetClientOfUserId(GetEventInt(event, "userid"));
	new attacker = GetClientOfUserId(GetEventInt(event, "attacker"));
	
	if(victim) 
	{
		if(sUseClassIdentifier[victim][0]) ResetClass(victim);
		else if(GetClientCountClassesAccess(victim) > 0) CreateClassesMenu(victim);
	
		if(attacker && sUseClassIdentifier[attacker][0] && victim != attacker && GetClientTeam(victim) != GetClientTeam(attacker))
		{
			KvRewind(kv);
		
			if(KvJumpToKey(kv, sUseClassIdentifier[attacker], false) && KvJumpToKey(kv, "Ammo Box", false))
			{
				new chance = KvGetNum(kv, "chance", 0);
			
				if(chance > 0)
				{
					if(chance >= GetRandomInt(1, 100))
					{
						new ragdoll = GetEntPropEnt(victim, Prop_Send, "m_hRagdoll");
						if(ragdoll > 0 && IsValidEntity(ragdoll)) 
						{
							decl Float:fPos[3];
							
							GetEntPropVector(ragdoll, Prop_Send, "m_vecOrigin", fPos);
							
							fPos[2] += 10.0;
							
							CreateAmmoBox(fPos);
						}
					}
				}
			}
		}
	}
}

stock CreateAmmoBox(const Float:fPos[3])
{
	if(!sModelAmmoBox[0]) return -1;
	
	if(!IsModelPrecached(sModelAmmoBox)) PrecacheModel(sModelAmmoBox);  

	new entity = CreateEntityByName("prop_dynamic_override");
	SetEntityModel(entity, sModelAmmoBox);

	SetEntPropString(entity, Prop_Data, "m_iName", "mods_master");

	if(DispatchSpawn(entity))
	{
		SetEntProp(entity, Prop_Data, "m_nSolidType", 2);
		SetEntProp(entity, Prop_Data, "m_CollisionGroup", 4);
		
		SetEntPropVector(entity, Prop_Send, "m_vecMins", g_fMins);
		SetEntPropVector(entity, Prop_Send, "m_vecMaxs", g_fMaxs);
		
		TeleportEntity(entity, fPos, NULL_VECTOR, NULL_VECTOR);
		
		SDKHook(entity, SDKHook_StartTouch, OnStartTouch);
		
		if(g_Rotate == 1)
		{
			new rotate_ent = CreateRotate(fPos);
		
			if(rotate_ent > 0)
			{
				SetVariantString("!activator");
				AcceptEntityInput(entity, "SetParent", rotate_ent, entity);
			}
		}
		
		CreateTimer(g_fLifeTime, TimerDeleteEntity, EntIndexToEntRef(entity), TIMER_FLAG_NO_MAPCHANGE);
		
		return entity;
	}
	
	return -1;
}

stock CreateRotate(const Float:fPos[3])
{
	new entity = CreateEntityByName("func_rotating");
		
	if(entity < 1) return -1;
	
	DispatchKeyValue(entity, "targetname", "mods_master");
	DispatchKeyValueVector(entity, "origin", fPos);
	DispatchKeyValue(entity, "spawnflags", "64");
	DispatchKeyValue(entity, "friction", "20");
	DispatchKeyValue(entity, "dmg", "0");
	DispatchKeyValue(entity, "solid", "0");
	
	SetEntPropFloat(entity, Prop_Data, "m_flMaxSpeed", 250.0, 0);
		
	if(DispatchSpawn(entity)) 
	{
		AcceptEntityInput(entity, "Start");
		
		CreateTimer(g_fLifeTime, TimerDeleteEntity, EntIndexToEntRef(entity), TIMER_FLAG_NO_MAPCHANGE);
		
		return entity;
	}
	
	return -1;
}

public OnStartTouch(entity, client)
{
	if(!(1 <= client <= MaxClients) || !IsClientInGame(client)) return;
	
	if(sUseClassIdentifier[client][0])
	{
		KvRewind(kv);
		
		if(KvJumpToKey(kv, sUseClassIdentifier[client], false) && KvJumpToKey(kv, "Ammo Box", false))
		{
			new weapon = GetPlayerWeaponSlot(client, 0);
	
			if(weapon != -1)
			{
				new primary_ammo = KvGetNum(kv, "primary_ammo", 10);
			
				if(primary_ammo > 0) 
				{
					SetAmmo(weapon, -1, GetEntProp(weapon, Prop_Send, "m_iPrimaryReserveAmmoCount")+primary_ammo);
					PrintToChat(client, "\x04[Class System]\x01 Вы поулчили \x04%d\x01 патронов для основного оружия!", primary_ammo);
				}
			}
		
			weapon = GetPlayerWeaponSlot(client, 1);
	
			if(weapon != -1)
			{
				new secondary_ammo = KvGetNum(kv, "secondary_ammo", 10);
			
				if(secondary_ammo > 0) 
				{
					SetAmmo(weapon, -1, GetEntProp(weapon, Prop_Send, "m_iPrimaryReserveAmmoCount")+secondary_ammo);
					PrintToChat(client, "\x04[Class System]\x01 Вы поулчили \x04%d\x01 патронов для дополнительного оружия!", secondary_ammo);
				}
			}
		
			AcceptEntityInput(entity, "Kill");
		}
	}
}

public Event_PlayerTeam(Handle:event, const String:name[], bool:dontBroadcast) 
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	
	if(client)
	{
		if(sUseClassIdentifier[client][0])
		{
			KvRewind(kv);
		
			if(KvJumpToKey(kv, sUseClassIdentifier[client], false))
			{
				decl String:sTeam[10];
	
				KvGetString(kv, "team_access", sTeam, 10, "ct:t");
			
				new team = GetEventInt(event, "team");
			
				if(!GetClientTeamAccess(sTeam, team))
				{
					ResetClass(client, true);
					sUseClassIdentifier[client] = "";
			
					if(IsPlayerAlive(client))
					{
						RemoveAllWeapon(client);
			
						GivePlayerItem(client, "weapon_knife");
					}
					else if(GetClientCountClassesAccess(client, team) > 0) CreateClassesMenu(client, team); 
				}
				else RefreshModel(client, team);
			}
		}
		else if(!IsPlayerAlive(client)) 
		{
			new team = GetEventInt(event, "team");
		
			if(GetClientCountClassesAccess(client, team) > 0) CreateClassesMenu(client, team);
		}
	}
}

public Event_RoundStart(Handle:event, const String:name[], bool:dontBroadcast) 
{
	for(new i = 1; i <= MaxClients; i++)
	{
		if(IsClientInGame(i) && sUseClassIdentifier[i][0])
			ResetClass(i);
	}
}

public Action:OnPlayerRunCmd(client, &buttons, &impulse, Float:vel[3], Float:angles[3], &weapon0)
{
	if(!sUseClassIdentifier[client][0] || !IsPlayerAlive(client)) return;
	
	if(buttons & IN_USE)
	{
		new Float:fGetGameTime = GetGameTime(); 
	
		if(g_fTime[client] < fGetGameTime)
		{
			new target = GetAimTarget(client);
			
			if(target > 0)
			{
				decl Float:fPos[3], Float:fPosTarget[3];
			
				GetClientAbsOrigin(client, fPos);
				GetClientAbsOrigin(target, fPosTarget);
			
				if(GetVectorDistance(fPos, fPosTarget) <= 100.0)
				{
					KvRewind(kv);
					
					if(KvJumpToKey(kv, sUseClassIdentifier[client], false))
					{
						if(KvGetNum(kv, "team_health_count", 0) > 0)
						{
							if(g_HealthCount[client] > 0)
							{
								new max_hp_target = GetEntProp(target, Prop_Data, "m_iMaxHealth");
							
								if(GetEntProp(target, Prop_Data, "m_iHealth") < max_hp_target)
								{
									SetEntityHealth(target, max_hp_target);
									g_HealthCount[client]--;
						
									PrintToChat(client, "\x04[Class System]\x01 Вы восстановили здоровье игрока \x04%N\x01! Доступно ещё \x04%d\x01 аптечек!", target, g_HealthCount[client]);
								}
								else PrintHintText(client, "У игрока %N полное здоровье!", target);
							}
							else PrintHintText(client, "Закончились аптечки!");
						}
						else
						{
							new team_give_ammo_count;
					
							if((team_give_ammo_count = KvGetNum(kv, "team_give_ammo_count", 0)) > 0)
							{
								new weapon = GetPlayerWeaponSlot(client, 0);
	
								if(weapon != -1)
								{
									new reserve = GetEntProp(weapon, Prop_Send, "m_iPrimaryReserveAmmoCount");
						
									if(reserve-team_give_ammo_count >= 0)
									{
										new weapon_target = GetPlayerWeaponSlot(target, 0);
							
										if(weapon_target != -1)
										{
											SetAmmo(weapon, -1, reserve-team_give_ammo_count);
											SetAmmo(weapon_target, -1, GetEntProp(weapon_target, Prop_Send, "m_iPrimaryReserveAmmoCount")+team_give_ammo_count);
						
											PrintToChat(client, "\x04[Class System]\x01 Вы отдали \x04%d\x01 патронов игроку \x04%N\x01!", team_give_ammo_count, target);
										}
										else PrintHintText(client, "У игрока %N нет основного оружия!", target);
									}
									else PrintHintText(client, "Недостаточно боеприпасов!");
								}
							}
						}
						
						g_fTime[client] = fGetGameTime + 1.0;
						
						return;
					}
				}
			}

			g_fTime[client] = fGetGameTime + 0.1;
		}
	}
}

CreateClassesMenu(client, team = -1)
{
	new Handle:menu = CreateMenu(MenuHandler_Classes);  
	
	SetMenuTitle(menu, "Система классов:");

	SetMenuExitBackButton(menu, false);
	
	new count;

	KvRewind(kv);

	new bool:bSectionExists = KvGotoFirstSubKey(kv);

	if(bSectionExists)
	{
		if(team == -1) team = GetClientTeam(client);
	
		decl String:sClassIdentifier[32], String:buffer[80];
	
		while(bSectionExists)
		{
			if(CF_EnabledThisMoment() && KvGetNum(kv, "capture_flag", 0) == 1 || CONQUEST_EnabledThisMoment() && KvGetNum(kv, "conquest", 0) == 1)
			{
				KvGetString(kv, "team_access", buffer, 10, "ct:t");
			
				if(GetClientTeamAccess(buffer, team))
				{
					if((KvGetNum(kv, "vip_access", 0) == 0 || CanTestFeatures() && GetFeatureStatus(FeatureType_Native, "VIP_IsClientVIP") == FeatureStatus_Available && VIP_IsClientVIP(client))
					&& (KvGetString(kv, "flags_access", buffer, 32, "") && (!buffer[0] || GetUserFlagBits(client) & ReadFlagString(buffer)))) 
					{
						KvGetSectionName(kv, sClassIdentifier, 32);
	
						KvGetString(kv, "name", buffer, 64, "Unknown name");
	
						FormatEx(buffer, 80, "%s [%s]", buffer, strcmp(sClassIdentifier, sUseClassIdentifier[client], true) == 0 ? "X":" ");
	
						new count_class = KvGetNum(kv, "count_class", -1);
	
						if(count_class != -1 && GetUserAdmin(client) == INVALID_ADMIN_ID && (CanTestFeatures() && GetFeatureStatus(FeatureType_Native, "VIP_IsClientVIP") != FeatureStatus_Available || !VIP_IsClientVIP(client)) && (!sUseClassIdentifier[client][0] || strcmp(sClassIdentifier, sUseClassIdentifier[client], true) != 0)) AddMenuItem(menu, sClassIdentifier, buffer, GetCountPlayersClass(sClassIdentifier) >= count_class ? ITEMDRAW_DISABLED:ITEMDRAW_DEFAULT);	
						else AddMenuItem(menu, sClassIdentifier, buffer);

						count++;
					}
				}
			}
		
			bSectionExists = KvGotoNextKey(kv);
		}
	}
	
	if(count == 0) AddMenuItem(menu, "", "Нет доступных классов!", ITEMDRAW_DISABLED);	
	
	DisplayMenu(menu, client, MENU_TIME_FOREVER);
}

public MenuHandler_Classes(Handle:menu, MenuAction:action, param1, param2) 
{
	switch(action)
	{
		case MenuAction_Select:
		{	
			decl String:sInfo[32];
			
			GetMenuItem(menu, param2, sInfo, 32);
			
			if(strcmp(sUseClassIdentifier[param1], sInfo, true) == 0) 
			{
				sUseClassIdentifier[param1] = "";
			
				if(!IsPlayerAlive(param1))
					ResetClass(param1);
			}
			else
			{
				if(!g_bActivatedClass[param1] || !IsPlayerAlive(param1))
				{
					strcopy(sUseClassIdentifier[param1], 32, sInfo);
				
					ResetClass(param1);
					SetClass(param1);
				}
				else strcopy(sUseClassIdentifier[param1], 32, sInfo);
				
				return;
			}
			
			CreateClassesMenu(param1);
		}
		case MenuAction_End: CloseHandle(menu); 
	}
}

stock SetClass(client)
{
	RemoveAllWeapon(client);

	CreateTimer(0.05, TimerSetClass, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE); 
}

public Action:TimerSetClass(Handle:timer, any:client) 
{
	if((client = GetClientOfUserId(client)) == 0 || !IsPlayerAlive(client) || !sUseClassIdentifier[client][0]) return; 
	
	g_bActivatedClass[client] = true;

	KvRewind(kv);
	
	if(KvJumpToKey(kv, sUseClassIdentifier[client], false))
	{
		new hp = KvGetNum(kv, "hp", -1);
		
		if(hp != -1)
		{
			SetEntProp(client, Prop_Send, "m_iHealth", hp);
			SetEntProp(client, Prop_Data, "m_iMaxHealth", hp);
		}
		
		new armor = KvGetNum(kv, "armor", -1);
		
		if(armor != -1) SetEntProp(client, Prop_Send, "m_ArmorValue", armor);
		
		new Float:fSpeed = KvGetFloat(kv, "speed", -1.0);
		
		if(fSpeed != -1.0) SetEntPropFloat(client, Prop_Send, "m_flLaggedMovementValue", fSpeed);

		decl String:buffer[1024];

		if(CanTestFeatures() && GetFeatureStatus(FeatureType_Native, "VIP_IsClientVIP") == FeatureStatus_Available)
		{
			if(!VIP_IsClientVIP(client) && GetFeatureStatus(FeatureType_Native, "VIP_IsValidVIPGroup") == FeatureStatus_Available && GetFeatureStatus(FeatureType_Native, "VIP_GiveClientVIP") == FeatureStatus_Available)
			{
				KvGetString(kv, "vip_group", g_sVIPGroup[client], 64, "");
					
				if(g_sVIPGroup[client][0])
				{
					if(VIP_IsValidVIPGroup(g_sVIPGroup[client])) VIP_GiveClientVIP(0, client, 0, g_sVIPGroup[client], false);
					else g_sVIPGroup[client] = "";
				}
			}
		
			if(VIP_IsClientVIP(client) && GetFeatureStatus(FeatureType_Native, "VIP_IsValidFeature") == FeatureStatus_Available && GetFeatureStatus(FeatureType_Native, "VIP_GetClientFeatureStatus") == FeatureStatus_Available && GetFeatureStatus(FeatureType_Native, "VIP_SetClientFeatureStatus") == FeatureStatus_Available)
			{
				KvGetString(kv, "vip_functions", buffer, 1024, "");
				
				if(buffer[0])
				{
					decl String:sFunction[32][64];
					
					new count_functions = ExplodeString(buffer, ",", sFunction, 32, 64);
					
					for(new x = 0; x < count_functions; x++)
					{
						if(VIP_IsValidFeature(sFunction[x])) 
						{
							PushArrayString(hArrayVIPFunctions[client], sFunction[x]); 
							PushArrayCell(hArrayVIPFunctionsState[client], VIP_GetClientFeatureStatus(client, sFunction[x])); 
						}
					}
							
					new size = GetArraySize(hArrayVIPFunctions[client]);
					
					if(size > 0)
					{
						for(new x = 0; x < size; x++)
						{
							GetArrayString(hArrayVIPFunctions[client], x, sFunction[0], 64);

							if(GetArrayCell(hArrayVIPFunctionsState[client], x) == NO_ACCESS) 
								VIP_SetClientFeatureStatus(client, sFunction[0], ENABLED);
						}
					}
				}
			}
		}

		KvGetString(kv, "model_ct", sClassModel[client][0], 128, "");
		KvGetString(kv, "model_t", sClassModel[client][1], 128, "");

		new team = GetClientTeam(client);
		
		if(sClassModel[client][0][0]) 
		{
			if(!IsModelPrecached(sClassModel[client][0])) PrecacheModel(sClassModel[client][0]);
			
			if(team == 3) SetEntityModel(client, sClassModel[client][0]);
		}
		
		if(sClassModel[client][1][0]) 
		{
			if(!IsModelPrecached(sClassModel[client][1])) PrecacheModel(sClassModel[client][1]);
			
			if(team == 2) SetEntityModel(client, sClassModel[client][1]);
		}
	
		KvGetString(kv, "model_arm_ct", sClassModelArm[client][0], 128, "models/weapons/ct_arms.mdl");
		KvGetString(kv, "model_arm_t", sClassModelArm[client][1], 128, "models/weapons/t_arms.mdl");
	
		if(sClassModelArm[client][0][0]) 
		{
			if(!IsModelPrecached(sClassModelArm[client][0])) PrecacheModel(sClassModelArm[client][0]);
			
			if(team == 3) SetEntPropString(client, Prop_Send, "m_szArmsModel", sClassModelArm[client][0]);
		}
		
		if(sClassModelArm[client][1][0]) 
		{
			if(!IsModelPrecached(sClassModelArm[client][1])) PrecacheModel(sClassModelArm[client][1]);
			
			if(team == 2) SetEntPropString(client, Prop_Send, "m_szArmsModel", sClassModelArm[client][1]);
		}
	
		g_HealthCount[client] = KvGetNum(kv, "team_health_count", 0);
	
		if(KvJumpToKey(kv, "Weapons", false))
		{
			decl String:sWeaponName[10][32];
		
			KvGetString(kv, "give", buffer, 128, "knife");
			
			new count_item = ExplodeString(buffer, ":", sWeaponName, 10, 32);
		
			new bool:bExist;
		
			for(new x = 0, weapon; x < count_item; x++)
			{
				bExist = KvJumpToKey(kv, sWeaponName[x], false);
		
				Format(sWeaponName[x], 32, "weapon_%s", sWeaponName[x]);

				if((weapon = GivePlayerItem(client, sWeaponName[x])) > 0) EquipPlayerWeapon(client, weapon); 
				
				if(bExist)
				{
					if(weapon > 0)
					{
						new clip = KvGetNum(kv, "clip", -1);
						new reserve = KvGetNum(kv, "reserve", -1);

						if(clip != -1 || reserve != -1)
						{
							new Handle:hDataPack = CreateDataPack();
							WritePackCell(hDataPack, EntIndexToEntRef(weapon));
							WritePackCell(hDataPack, clip);
							WritePackCell(hDataPack, reserve);	

							CreateTimer(0.01, TimerSetAmmo, hDataPack, TIMER_DATA_HNDL_CLOSE);
			
							if(clip != -1) DHookEntity(g_hGetMaxClip, true, weapon);
							if(reserve != -1) DHookEntity(g_hGetMaxReserve, true, weapon);
						}
						else
						{
							new count = KvGetNum(kv, "count", -1);
					
							if(count != -1)
							{
								new ammotype;

								if(StrContains(sWeaponName[x], "hegrenade", false) != -1) ammotype = 14;	
								else if(StrContains(sWeaponName[x], "flashbang", false) != -1) ammotype = 15;	
								else if(StrContains(sWeaponName[x], "smokegrenade", false) != -1) ammotype = 16;	
								else if(StrContains(sWeaponName[x], "molotov", false) != -1) ammotype = 17;	
								else if(StrContains(sWeaponName[x], "decoy", false) != -1) ammotype = 18;	
						
								if(ammotype > 0) SetWeaponPlayerAmmo(client, ammotype, count);
							}
						}
					}
					
					KvGoBack(kv);
				}
			}
		
			SDKHook(client, SDKHook_WeaponCanUse, WeaponCanUse);
		}
	}
}

public MRESReturn:DH_GetMaxClip(weapon, Handle:hReturn)
{
	new owner = GetEntPropEnt(weapon, Prop_Send, "m_hOwnerEntity");

	if((1 <= owner <= MaxClients) && sUseClassIdentifier[owner][0])
	{
		KvRewind(kv);
		
		if(KvJumpToKey(kv, sUseClassIdentifier[owner], false) && KvJumpToKey(kv, "Weapons", false))
		{
			new bool:bSectionExists = KvGotoFirstSubKey(kv);
	
			if(bSectionExists)
			{
				decl String:sWeaponName[32], String:buffer[32];
				
				while(bSectionExists)
				{
					KvGetSectionName(kv, sWeaponName, 32);

					Format(sWeaponName, 32, "weapon_%s", sWeaponName);

					GetEdictClassname(weapon, buffer, 32);
						
					if(strcmp(sWeaponName, buffer, true) == 0)
					{
						new clip = KvGetNum(kv, "clip", -1);

						if(clip != -1)
						{
							DHookSetReturn(hReturn, clip);
							return MRES_Supercede;
						}
					}
				
					bSectionExists = KvGotoNextKey(kv);
				}
			}
		}
	}
	
	return MRES_Ignored;
}

public MRESReturn:DH_GetMaxReserve(weapon, Handle:hReturn)
{
	new owner = GetEntPropEnt(weapon, Prop_Send, "m_hOwnerEntity");

	if((1 <= owner <= MaxClients) && sUseClassIdentifier[owner][0])
	{
		KvRewind(kv);
		
		if(KvJumpToKey(kv, sUseClassIdentifier[owner], false) && KvJumpToKey(kv, "Weapons", false))
		{
			new bool:bSectionExists = KvGotoFirstSubKey(kv);
	
			if(bSectionExists)
			{
				decl String:sWeaponName[32], String:buffer[32];
			
				while(bSectionExists)
				{
					KvGetSectionName(kv, sWeaponName, 32);

					Format(sWeaponName, 32, "weapon_%s", sWeaponName);

					GetEdictClassname(weapon, buffer, 32);
						
					if(strcmp(sWeaponName, buffer, true) == 0)
					{
						new reserve = KvGetNum(kv, "reserve", -1);

						if(reserve != -1)
						{
							DHookSetReturn(hReturn, reserve);
							return MRES_Supercede;
						}
					}
				
					bSectionExists = KvGotoNextKey(kv);
				}
			}
		}
	}
	
	return MRES_Ignored;
}

public Action:WeaponCanUse(client, weapon) 
{
	if(weapon != -1) return Plugin_Handled;
	
	return Plugin_Continue;
}

public Action:CS_OnCSWeaponDrop(client, weapon)
{
	if(sUseClassIdentifier[client][0]) return Plugin_Handled;

	return Plugin_Continue;
}

public Action:CS_OnBuyCommand(client, const String:sWeaponName[])
{
	if(sUseClassIdentifier[client][0]) return Plugin_Handled;

	return Plugin_Continue;
}

stock ResetClass(client, bool:bUpdateModel = false, bool:bResetParams = true)
{
	SDKUnhook(client, SDKHook_WeaponCanUse, WeaponCanUse); 
	
	g_bActivatedClass[client] = false;
	
	TakeAccessVIPClient(client);
	SetBackClientVIPFunctions(client);
	
	ClearArray(hArrayVIPFunctions[client]);
	ClearArray(hArrayVIPFunctionsState[client]);

	if(IsPlayerAlive(client))
	{
		if(bResetParams)
		{
			SetEntProp(client, Prop_Send, "m_iHealth", 100);
			SetEntProp(client, Prop_Data, "m_iMaxHealth", 100);
			
			SetEntProp(client, Prop_Send, "m_ArmorValue", 0);
			
			SetEntPropFloat(client, Prop_Send, "m_flLaggedMovementValue", 1.0);
		}
		
		if(bUpdateModel) CreateTimer(0.05, TimerUpdateModel, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
	}
}

stock RefreshModel(client, team)
{
	if(IsPlayerAlive(client))
	{
		if(sClassModel[client][team == 3 ? 0:1][0]) SetEntityModel(client, sClassModel[client][team == 3 ? 0:1]);
		else CreateTimer(0.05, TimerUpdateModel, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
		
		if(sClassModelArm[client][team == 3 ? 0:1][0]) SetEntPropString(client, Prop_Send, "m_szArmsModel", sClassModelArm[client][team == 3 ? 0:1]);
	}
}

public Action:TimerUpdateModel(Handle:timer, any:client)
{
	if((client = GetClientOfUserId(client)) == 0 || !IsPlayerAlive(client)) return;
	
	CS_UpdateClientModel(client);
}

public Action:TimerSetAmmo(Handle:timer, any:hDataPack)
{
	ResetPack(hDataPack);

	new weapon = EntRefToEntIndex(ReadPackCell(hDataPack));
	
	if(weapon > 0)
	{
		new clip = ReadPackCell(hDataPack);
		new reserve = ReadPackCell(hDataPack);
		
		SetAmmo(weapon, clip, reserve);
	}
}

stock SetAmmo(weapon, clip, reserve)
{
	if(clip != -1) SetEntProp(weapon, Prop_Send, "m_iClip1", clip);
	if(reserve != -1) SetEntProp(weapon, Prop_Send, "m_iPrimaryReserveAmmoCount", reserve);
}

stock SetWeaponPlayerAmmo(client, ammotype, ammo)
{
	SetEntData(client, FindDataMapInfo(client, "m_iAmmo") + (ammotype * 4), ammo);
}

stock GetCountPlayersClass(String:sClassIdentifier[])
{
	new players;

	for(new i = 1; i <= MaxClients; i++)
	{
		if(IsClientInGame(i) && !IsFakeClient(i) && strcmp(sClassIdentifier, sUseClassIdentifier[i], true) == 0)
			players++;
	}
	
	return players;
}

stock GetClientCountClassesAccess(client, team = -1)
{
	new count;

	KvRewind(kv);

	new bool:bSectionExists = KvGotoFirstSubKey(kv);

	if(bSectionExists)
	{
		if(team == -1) team = GetClientTeam(client);
	
		decl String:buffer[32];

		while(bSectionExists)
		{
			if(CF_EnabledThisMoment() && KvGetNum(kv, "capture_flag", 0) == 1 || CONQUEST_EnabledThisMoment() && KvGetNum(kv, "conquest", 0) == 1)
			{
				KvGetString(kv, "team_access", buffer, 10, "ct:t");
			
				if(GetClientTeamAccess(buffer, team))
				{
					if((KvGetNum(kv, "vip_access", 0) == 0 || CanTestFeatures() && GetFeatureStatus(FeatureType_Native, "VIP_IsClientVIP") == FeatureStatus_Available && VIP_IsClientVIP(client))
					&& (KvGetString(kv, "flags_access", buffer, 32, "") && (!buffer[0] || GetUserFlagBits(client) & ReadFlagString(buffer)))) count++;
				}
			}
		
			bSectionExists = KvGotoNextKey(kv);
		}
	}
	
	return count;
}

stock bool:GetClientTeamAccess(const String:sTeam[], team)
{
	new String:buffer[2][5];
	
	ExplodeString(sTeam, ":", buffer, 2, 5);
	
	switch(team)
	{
		case 3: if(strcmp(buffer[0], "ct", false) == 0 || strcmp(buffer[1], "ct", false) == 0) return true;
		case 2: if(strcmp(buffer[0], "t", false) == 0 || strcmp(buffer[1], "t", false) == 0) return true;
	}
	
	return false;
}

stock SetBackClientVIPFunctions(client)
{
	new size = GetArraySize(hArrayVIPFunctions[client]);
				
	if(size > 0)
	{
		if(CanTestFeatures() && GetFeatureStatus(FeatureType_Native, "VIP_IsClientVIP") == FeatureStatus_Available && GetFeatureStatus(FeatureType_Native, "VIP_SetClientFeatureStatus") == FeatureStatus_Available)
		{
			if(VIP_IsClientVIP(client))
			{
				decl String:sFunction[64];
						
				for(new x = 0; x < size; x++)
				{
					GetArrayString(hArrayVIPFunctions[client], x, sFunction, 64);
						
					VIP_SetClientFeatureStatus(client, sFunction, GetArrayCell(hArrayVIPFunctionsState[client], x));
				}
			}
		}
	}
}

stock TakeAccessVIPClient(client)
{
	if(g_sVIPGroup[client][0])
	{
		if(CanTestFeatures() && GetFeatureStatus(FeatureType_Native, "VIP_IsClientVIP") == FeatureStatus_Available && GetFeatureStatus(FeatureType_Native, "VIP_GetClientVIPGroup") == FeatureStatus_Available && GetFeatureStatus(FeatureType_Native, "VIP_RemoveClientVIP2") == FeatureStatus_Available)
		{
			if(VIP_IsClientVIP(client))
			{
				decl String:sGroup[64];
				
				if(VIP_GetClientVIPGroup(client, sGroup, 64) && strcmp(sGroup, g_sVIPGroup[client], true) == 0)
					VIP_RemoveClientVIP2(0, client, false, false);
			}
		}
		
		g_sVIPGroup[client] = "";
	}
}

stock RemoveAllWeapon(client)
{
	for (new slot = 0, weapon; slot <= 4; slot++)
	{
		if((weapon = GetPlayerWeaponSlot(client, slot)) != -1)
		{
			SetEntPropEnt(weapon, Prop_Send, "m_hOwnerEntity", client);
						
			CS_DropWeapon(client, weapon, false);
			AcceptEntityInput(weapon, "Kill");
				
			if(slot == 2 || slot == 3) for (new x = 0; x <= 5; x++)  
			{
				if((weapon = GetPlayerWeaponSlot(client, slot)) != -1)  
				{
					SetEntPropEnt(weapon, Prop_Send, "m_hOwnerEntity", client);
						
					CS_DropWeapon(client, weapon, false); 
					AcceptEntityInput(weapon, "Kill");
				}
				else break;
			}
		}
	}
}

public Action:TimerDeleteEntity(Handle:timer, any:ref_ent)
{
	new entity = EntRefToEntIndex(ref_ent);
	
	if(entity > 0) AcceptEntityInput(entity, "Kill");
}

public CF_OnEndGame() EndGame();

public CONQUEST_OnEndGame() EndGame();

stock EndGame()
{
	for(new i = 1; i <= MaxClients; i++)
	{
		if(IsClientInGame(i) && !IsFakeClient(i) && sUseClassIdentifier[i][0])
		{
			ResetClass(i, true);
			RemoveAllWeapon(i);
			
			sUseClassIdentifier[i] = "";
			
			GivePlayerItem(i, "weapon_knife");
		}
	}
}

stock GetAimTarget(client)
{
	decl Float:fEyePosition[3], Float:fEyeAngles[3];
	GetClientEyePosition(client, fEyePosition); 
	GetClientEyeAngles(client, fEyeAngles); 
	TR_TraceRayFilter(fEyePosition, fEyeAngles, MASK_SOLID, RayType_Infinite, FilterPlayers, client);  
	
	return TR_GetEntityIndex();
}

public bool:FilterPlayers(entity, mask, any:client) 
{ 
	return entity <= MaxClients && entity != client && GetClientTeam(client) == GetClientTeam(entity); 
}