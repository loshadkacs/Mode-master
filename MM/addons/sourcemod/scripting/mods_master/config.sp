#define CONFIG_FILE			"addons/sourcemod/configs/mods_master/settings.txt"
#define CONFIG_FILE_FP		"addons/sourcemod/configs/mods_master/flags_pos.txt"
#define CONFIG_FILE_ZS		"addons/sourcemod/configs/mods_master/zones_save.txt"

stock LoadConfig()
{
	new Handle:kv = CreateKeyValues("Mods Master");
	
	if(!FileToKeyValues(kv, CONFIG_FILE)) 
		SetFailState("Конфиг по адресу \"%s\" не найден!", CONFIG_FILE); 
	
	if(KvJumpToKey(kv, "Settings", false))
	{
		g_VoteNoCurrentMap = KvGetNum(kv, "vote_no_current_map", 0); 
		
		if(KvJumpToKey(kv, "Capture Flag", false))
		{
			g_FlagColorTeamCaptureFlag = KvGetNum(kv, "flag_color_team", 1);
		
			KvGetString(kv, "flag_anim_idle_ct", sFlagAnimIdleCaptureFlag[0], 32, "");
			KvGetString(kv, "flag_anim_idle_t", sFlagAnimIdleCaptureFlag[1], 32, "");
			g_fFlagAnimSpeedCaptureFlag[0] = KvGetFloat(kv, "flag_anim_speed_ct", 1.0);
			g_fFlagAnimSpeedCaptureFlag[1] = KvGetFloat(kv, "flag_anim_speed_t", 1.0); 
		
			KvGetString(kv, "flag_model_ct", sModelFlagCaptureFlag[0], 128, ""); 
			KvGetString(kv, "flag_model_t", sModelFlagCaptureFlag[1], 128, "");

			KvGetVector(kv, "pedestal_pos_ct", g_fPedestalPosCaptureFlag[0], Float:{0.0, 0.0, 0.0});
			KvGetVector(kv, "pedestal_pos_t", g_fPedestalPosCaptureFlag[1], Float:{0.0, 0.0, 0.0});
			KvGetString(kv, "pedestal_model_ct", sModelPedestalCaptureFlag[0], 128, "");
			KvGetString(kv, "pedestal_model_t", sModelPedestalCaptureFlag[1], 128, "");
				
			g_fFlagZoneSizeCaptureFlag = KvGetFloat(kv, "flag_zone_size", 1.0);
			
			g_fFlagDownPosCaptureFlag = KvGetFloat(kv, "flag_down_pos_z", -50.0);
			
			g_FlagDownTimeCaptureFlag = KvGetNum(kv, "flag_down_time", 5);
			g_FlagProtectTimeCaptureFlag = KvGetNum(kv, "flag_protect_time", 10);
			
			g_FlagGlowCaptureFlag = KvGetNum(kv, "flag_glow", 1);
			g_FlagCapturedGlowCaptureFlag = KvGetNum(kv, "flag_captured_glow", 0);
			
			g_RoundTimeCaptureFlag = KvGetNum(kv, "round_time", 10);

			g_fRoundEndTimeCaptureFlag = KvGetFloat(kv, "round_end_time", 5.0);
			
			g_fVoteModeTime = KvGetFloat(kv, "vote_mode_time", 120.0);
			g_fVoteMapTime = KvGetFloat(kv, "vote_map_time", 10.0);
		}
		
		KvGoBack(kv);
		
		if(KvJumpToKey(kv, "Conquest", false))
		{
			g_FlagColorTeamConquest = KvGetNum(kv, "flag_color_team", 1);
		
			KvGetString(kv, "flag_anim_idle_ct", sFlagAnimIdleConquest[0], 32, "");
			KvGetString(kv, "flag_anim_idle_t", sFlagAnimIdleConquest[1], 32, "");
			KvGetString(kv, "flag_anim_idle_neutral", sFlagAnimIdleConquest[2], 32, "");
			g_fFlagAnimSpeedConquest[0] = KvGetFloat(kv, "flag_anim_speed_ct", 1.0);
			g_fFlagAnimSpeedConquest[1] = KvGetFloat(kv, "flag_anim_speed_t", 1.0);
			g_fFlagAnimSpeedConquest[2] = KvGetFloat(kv, "flag_anim_speed_neutral", 1.0);
		
			KvGetString(kv, "flag_model_ct", sModelFlagConquest[0], 128, "");
			KvGetString(kv, "flag_model_t", sModelFlagConquest[1], 128, "");
			KvGetString(kv, "flag_model_neutral", sModelFlagConquest[2], 128, "");

			KvGetVector(kv, "pedestal_pos_ct", g_fPedestalPosConquest[0], Float:{0.0, 0.0, 0.0});
			KvGetVector(kv, "pedestal_pos_t", g_fPedestalPosConquest[1], Float:{0.0, 0.0, 0.0});
			KvGetVector(kv, "pedestal_pos_neutral", g_fPedestalPosConquest[2], Float:{0.0, 0.0, 0.0});
			KvGetString(kv, "pedestal_model_ct", sModelPedestalConquest[0], 128, "");
			KvGetString(kv, "pedestal_model_t", sModelPedestalConquest[1], 128, "");
			KvGetString(kv, "pedestal_model_neutral", sModelPedestalConquest[2], 128, "");

			g_fFlagDownPosConquest = KvGetFloat(kv, "flag_down_pos_z", -50.0);
			
			g_FlagDownTimeConquest = KvGetNum(kv, "flag_down_time", 5);
			g_FlagProtectTimeConquest = KvGetNum(kv, "flag_protect_time", 10);

			g_RoundTimeConquest = KvGetNum(kv, "round_time", 10);

			g_fRoundEndTimeConquest = KvGetFloat(kv, "round_end_time", 5.0);
			
			g_fSpriteZonePosConquest = KvGetFloat(kv, "sprite_zone_pos_z", 50.0);
			
			KvGetString(kv, "sprite_zone_scale", sSpriteZoneScaleConquest, 5, "0.3");
			
			if(KvJumpToKey(kv, "Sprites", false))
			{
				KvGetString(kv, "zone_a_ct", sSpriteZoneConquest[0][0], 128, "");
				KvGetString(kv, "zone_a_t", sSpriteZoneConquest[0][1], 128, "");
				KvGetString(kv, "zone_a_neutral", sSpriteZoneConquest[0][2], 128, "");
				
				KvGetString(kv, "zone_b_ct", sSpriteZoneConquest[1][0], 128, "");
				KvGetString(kv, "zone_b_t", sSpriteZoneConquest[1][1], 128, "");
				KvGetString(kv, "zone_b_neutral", sSpriteZoneConquest[1][2], 128, "");
				
				KvGetString(kv, "zone_c_ct", sSpriteZoneConquest[2][0], 128, "");
				KvGetString(kv, "zone_c_t", sSpriteZoneConquest[2][1], 128, "");
				KvGetString(kv, "zone_c_neutral", sSpriteZoneConquest[2][2], 128, "");
				
				KvGetString(kv, "zone_d_ct", sSpriteZoneConquest[3][0], 128, "");
				KvGetString(kv, "zone_d_t", sSpriteZoneConquest[3][1], 128, "");
				KvGetString(kv, "zone_d_neutral", sSpriteZoneConquest[3][2], 128, "");
			}

			LoadConfigZones();
		}
		
		LoadFiles();
		
		if(!g_bEnabledCaptureFlag && !g_bEnabledConquest)
		{
			new bool:bFlags = GetKvMapFlagsPos(sMap);
			new bool:bZones = GetKvMapZonesSave(sMap); 
		
			if(bFlags && bZones)
			{
				if(GetRandomInt(0, 1)) g_bEnabledCaptureFlag = true;
				else g_bEnabledConquest = true;
				
				CreateTimerRoundStart(); 
				Forward_OnMapStart();
			}
			else if(bFlags) 
			{
				g_bEnabledCaptureFlag = true;
				CreateTimerRoundStart();
				Forward_OnMapStart();
			}
			else if(bZones) 
			{
				g_bEnabledConquest = true;
				CreateTimerRoundStart();
				Forward_OnMapStart();
			}
		}
		
		if(g_bEnabledCaptureFlag) 
		{
			UpdateConVars();
				
			hTimerUpdateBoxAll = CreateTimer(UPDATE_BOX, TimerUpdateBoxAll, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
				
			LoadConfigFlags();
			
			LoadFlags();
		}
		else if(g_bEnabledConquest)
		{
			UpdateConVars();
				
			hTimerUpdateBoxAll = CreateTimer(UPDATE_BOX, TimerUpdateBoxAll, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
			
			LoadZones();
		}
	}		
	
	CloseHandle(kv);
}

stock LoadConfigZones()
{
	if(kv_zs != INVALID_HANDLE) CloseHandle(kv_zs);

	kv_zs = CreateKeyValues("Zones Save");
	
	if(!FileToKeyValues(kv_zs, CONFIG_FILE_ZS)) 
		SetFailState("Конфиг по адресу \"%s\" не найден!", CONFIG_FILE_ZS); 
		
	KvJumpToKey(kv_zs, sMap, true);
}

stock LoadConfigFlags()
{
	new Handle:kv = CreateKeyValues("Flags Pos");
	
	if(!FileToKeyValues(kv, CONFIG_FILE_FP))
		SetFailState("Конфиг по адресу \"%s\" не найден!", CONFIG_FILE_FP); 
	
	if(KvJumpToKey(kv, sMap, false))	
	{
		KvGetVector(kv, "pos_ct", g_fFlagPos[0], Float:{0.0, 0.0, 0.0});
		KvGetVector(kv, "pos_t", g_fFlagPos[1], Float:{0.0, 0.0, 0.0});
	}
	
	CloseHandle(kv);
}

stock LoadZones()
{
	KvRewind(kv_zs);
	if(!KvJumpToKey(kv_zs, sMap, false)) return;

	g_Flag[0] = ModsMaster_None;
	g_Flag[1] = ModsMaster_None;
	g_Flag[2] = ModsMaster_None;
	g_Flag[3] = ModsMaster_None;
	
	new bool:bSectionExists = KvGotoFirstSubKey(kv_zs);
	
	if(!bSectionExists) return;
	
	decl Float:fPos[3], String:buffer[3];
	
	new zone_number;
	
	while(bSectionExists)
	{
		KvGetSectionName(kv_zs, buffer, 3);
	
		zone_number = StringToInt(buffer)-1; 

		KvGetVector(kv_zs, "pos", fPos);
		
		g_fFlagZoneSizeConquest[zone_number] = KvGetFloat(kv_zs, "size", 1.0);
		g_fFlagZoneHeightConquest[zone_number] = KvGetFloat(kv_zs, "height", 150.0);
		
		g_ConquestZoneTeam[zone_number] = KvGetNum(kv_zs, "team", 0);
		g_ConquestZoneCountPlayers[zone_number] = KvGetNum(kv_zs, "count_players", 1);
		g_ConquestZoneTime[zone_number] = KvGetNum(kv_zs, "time", 30);
		g_bConquestFlagMovable[zone_number] = bool:KvGetNum(kv_zs, "movable", 0);
		
		CreateFlag(fPos, g_ConquestZoneTeam[zone_number], true, _, zone_number);
		CreateZone(fPos, g_ConquestZoneTeam[zone_number], zone_number);
		CreateSprite(fPos, g_ConquestZoneTeam[zone_number], zone_number);
	
		g_Flag[zone_number] = ModsMaster_Zone;
	
		Forward_OnFlagEvent(g_ConquestZoneTeam[zone_number], ModsMaster_Spawn, _, _, zone_number);

		bSectionExists = KvGotoNextKey(kv_zs);
	}
}

bool:SaveFlagPos(Float:fPos[3], bool:bTeam)
{
	new Handle:kv = CreateKeyValues("Flags Pos");
	
	if(!FileToKeyValues(kv, CONFIG_FILE_FP))
		SetFailState("Конфиг по адресу \"%s\" не найден!", CONFIG_FILE_FP); 
	
	if(KvJumpToKey(kv, sMap, true))	
	{
		if(bTeam) 
		{
			KvSetVector(kv, "pos_ct", fPos);
			
			g_fFlagPos[0][0] = fPos[0];
			g_fFlagPos[0][1] = fPos[1];
			g_fFlagPos[0][2] = fPos[2];
		}
		else 
		{
			KvSetVector(kv, "pos_t", fPos);
			
			g_fFlagPos[1][0] = fPos[0];
			g_fFlagPos[1][1] = fPos[1];
			g_fFlagPos[1][2] = fPos[2];
		}
		
		KvRewind(kv);
	
		if(KeyValuesToFile(kv, CONFIG_FILE_FP)) 
		{
			CloseHandle(kv);
			return true;
		}
	}
	
	CloseHandle(kv);
	
	return false;
}

bool:SaveZone(Float:fPos[3], String:sZoneNumber[], Float:fSize = 1.0, Float:fHeight = 150.0, team = 0, count_players = 1, time = 30, movable = 0)
{
	if(KvRewind(kv_zs) && KvJumpToKey(kv_zs, sMap, true) && KvJumpToKey(kv_zs, sZoneNumber, true))
	{
		KvSetVector(kv_zs, "pos", fPos);
		KvSetFloat(kv_zs, "size", fSize);
		KvSetFloat(kv_zs, "height", fHeight);
				
		KvSetNum(kv_zs, "team", team);
		KvSetNum(kv_zs, "count_players", count_players);
		KvSetNum(kv_zs, "time", time);
		KvSetNum(kv_zs, "movable", movable);
		
		if(KvRewind(kv_zs) && KeyValuesToFile(kv_zs, CONFIG_FILE_ZS)) return true;
	}
	
	return false;
}

bool:UpdateSaveZone(String:sZoneNumber[], Float:fPos[3] = {0.0, 0.0, 0.0}, Float:fSize = -1.0, Float:fHeight = -1.0, team = -1, count_players = -1, time = -1, movable = -1)
{
	if(KvRewind(kv_zs) && KvJumpToKey(kv_zs, sMap, true) && KvJumpToKey(kv_zs, sZoneNumber, true))
	{
		if(fPos[0] != 0.0 || fPos[1] != 0.0 || fPos[2] != 0.0) KvSetVector(kv_zs, "pos", fPos);
		if(fSize != -1.0) KvSetFloat(kv_zs, "size", fSize);
		if(fHeight != -1.0) KvSetFloat(kv_zs, "height", fHeight);
				
		if(team != -1) KvSetNum(kv_zs, "team", team);
		if(count_players != -1) KvSetNum(kv_zs, "count_players", count_players);
		if(time != -1) KvSetNum(kv_zs, "time", time);
		if(movable != -1) KvSetNum(kv_zs, "movable", movable);
		
		if(KvRewind(kv_zs) && KeyValuesToFile(kv_zs, CONFIG_FILE_ZS)) return true;
	}
	
	return false;
}

bool:DeleteKvZone(String:sZoneNumber[])
{
	if(KvRewind(kv_zs) && KvJumpToKey(kv_zs, sMap, false) && KvJumpToKey(kv_zs, sZoneNumber, false) && KvDeleteThis(kv_zs))
	{
		if(KvRewind(kv_zs) && KvJumpToKey(kv_zs, sMap, false))
		{
			new zone_number = StringToInt(sZoneNumber);
			
			decl String:buffer[3];
			
			new section_zone_number;
			
			new bool:bSectionExists = KvGotoFirstSubKey(kv_zs);
	
			while(bSectionExists)
			{
				KvGetSectionName(kv_zs, buffer, 3);
				
				if(zone_number < (section_zone_number = StringToInt(buffer)))
				{
					IntToString(section_zone_number-1, buffer, 3);
					KvSetSectionName(kv_zs, buffer);
				}	
			
				bSectionExists = KvGotoNextKey(kv_zs);
			}
		}
		
		if(KvRewind(kv_zs) && KeyValuesToFile(kv_zs, CONFIG_FILE_ZS)) 
			return true;
	}

	return false;
}

ArrayList:GetKvMapListToArray()
{
	new ArrayList:MapNominatedArray = CreateArray(ByteCountToCells(64));
	
	GetNominatedMapList(MapNominatedArray);
	
	new Handle:kv;
	
	if(g_bVoteNextMapCaptureFlag) 
	{
		kv = CreateKeyValues("Flags Pos");
	
		if(!FileToKeyValues(kv, CONFIG_FILE_FP)) 
			SetFailState("Конфиг по адресу \"%s\" не найден!", CONFIG_FILE_FP);
	}
	else if(g_bVoteNextMapConquest)
	{
		kv = CreateKeyValues("Zones Save");
	
		if(!FileToKeyValues(kv, CONFIG_FILE_ZS)) 
			SetFailState("Конфиг по адресу \"%s\" не найден!", CONFIG_FILE_ZS);
	}
	
	if(kv != INVALID_HANDLE)
	{
		decl String:sMapName[64];

		new ArrayList:MapArray = CreateArray(ByteCountToCells(64));
	
		new size = GetArraySize(MapNominatedArray);
	
		if(size > 0)
		{
			for (new x = 0; x < size; x++)
			{
				GetArrayString(MapNominatedArray, x, sMapName, 64);
			
				KvRewind(kv);
			
				if(KvJumpToKey(kv, sMapName, false) && FindStringInArray(MapArray, sMapName) == -1) PushArrayString(MapArray, sMapName);
			}
		
			KvRewind(kv);
		}
	
		new bool:bSectionExists = KvGotoFirstSubKey(kv);
	
		while(bSectionExists)
		{
			KvGetSectionName(kv, sMapName, 64);
		
			if(FindStringInArray(MapArray, sMapName) == -1)
			{
				if(g_VoteNoCurrentMap == 1) 
				{
					if(strcmp(sMapName, sMap) != 0) PushArrayString(MapArray, sMapName);
				}
				else PushArrayString(MapArray, sMapName);
			}
	
			bSectionExists = KvGotoNextKey(kv);
		}
	
		CloseHandle(kv);
		
		return MapArray;
	}
	
	return MapNominatedArray;
}

bool:GetKvMapFlagsPos(String:sMapName[])
{
	new Handle:kv = CreateKeyValues("Flags Pos");
	
	if(!FileToKeyValues(kv, CONFIG_FILE_FP))
		SetFailState("Конфиг по адресу \"%s\" не найден!", CONFIG_FILE_FP); 
	
	if(KvJumpToKey(kv, sMapName, false))	
	{
		CloseHandle(kv);
		return true;
	}
	
	CloseHandle(kv);
	
	return false;
}

bool:GetKvMapZonesSave(String:sMapName[])
{
	if(kv_zs == INVALID_HANDLE) 
		return false;

	KvRewind(kv_zs);
	
	if(KvJumpToKey(kv_zs, sMapName, false))	
		return true;
	
	return false;
}

stock GetKvZoneSaveNewSection(String:buffer[3])
{
	new x;
	
	for (x = 1; x <= 4; x++)
	{
		IntToString(x, buffer, 3);
		
		if(KvRewind(kv_zs) && KvJumpToKey(kv_zs, sMap, false) && !KvJumpToKey(kv_zs, buffer, false)) 
			return x;
	}
	
	return -1;
}

bool:GetKvMaxZonesSave()
{
	decl String:buffer[3];

	new bool:bResult;
	
	for (new x = 1; x <= 4; x++)
	{
		KvRewind(kv_zs);
		IntToString(x, buffer, 3);
		
		if(KvJumpToKey(kv_zs, sMap, false)) 
		{
			bResult = true;
		
			if(!KvJumpToKey(kv_zs, buffer, false))
			{
				bResult = false;
				break;
			}
		}
		else break;
	}
	
	return bResult;
}

bool:GetKvZonePos(Float:fPos[3], zone_number)
{
	decl String:buffer[3];

	KvRewind(kv_zs);
	IntToString(zone_number+1, buffer, 3);
		
	if(KvJumpToKey(kv_zs, sMap, false) && KvJumpToKey(kv_zs, buffer, false)) 
	{
		KvGetVector(kv_zs, "pos", fPos);
		
		return true;
	}
	
	return false;
}

bool:GetKvFlagMovable(zone_number)
{
	decl String:buffer[3];

	KvRewind(kv_zs);
	IntToString(zone_number+1, buffer, 3);
		
	if(KvJumpToKey(kv_zs, sMap, false) && KvJumpToKey(kv_zs, buffer, false)) 
		return bool:KvGetNum(kv_zs, "movable", 0);
	
	return false;
}

bool:GetKvAvailableFlagMovable()
{
	if(KvRewind(kv_zs) && KvJumpToKey(kv_zs, sMap, false))
	{
		new bool:bSectionExists = KvGotoFirstSubKey(kv_zs);
	
		if(!bSectionExists) return false;
	
		new bool:bResult;
	
		while(bSectionExists)
		{
			if(KvGetNum(kv_zs, "movable", 0) == 1)
			{
				bResult = true;
				break;
			}
	
			bSectionExists = KvGotoNextKey(kv_zs);
		}
		
		return bResult;
	}
	
	return false;
}