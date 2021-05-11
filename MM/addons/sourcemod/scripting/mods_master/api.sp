public APLRes:AskPluginLoad2(Handle:myself, bool:late, String:error[], err_max)
{
	CreateNative("CF_EnabledThisMoment", Native_EnabledThisMomentCaptureFlag);
	CreateNative("CONQUEST_EnabledThisMoment", Native_EnabledThisMomentConquest);
	CreateNative("CF_ThisMapConfigFlagsPos", Native_ThisMapConfigFlagsPos);
	CreateNative("CONQUEST_ThisMapConfigZonesSave", Native_ThisMapConfigZonesSave);
	CreateNative("CF_StartGame", Native_StartGameCaptureFlag);
	CreateNative("CF_EndGame", Native_EndGameCaptureFlag);
	CreateNative("CONQUEST_StartGame", Native_StartGameConquest);
	CreateNative("CONQUEST_EndGame", Native_EndGameConquest);
	CreateNative("CF_GetFlagStatusTeam", Native_GetFlagStatusTeamCaptureFlag); 
	CreateNative("CF_GetClientFlagCapturedTeam", Native_GetClientFlagCapturedTeamCaptureFlag);
	CreateNative("CF_GetClientZoneTeam", Native_GetClientZoneTeamCaptureFlag);
	CreateNative("CF_GetEntityFlag", Native_GetEntityFlagCaptureFlag);
	CreateNative("CF_GetEntityPedestal", Native_GetEntityPedestalCaptureFlag); 
	CreateNative("CONQUEST_GetFlagStatusZone", Native_GetFlagStatusZoneConquest);
	CreateNative("CONQUEST_GetClientFlagCapturedZone", Native_GetClientFlagCapturedZoneConquest);
	CreateNative("CONQUEST_GetClientZone", Native_GetClientZoneConquest);
	CreateNative("CONQUEST_GetEntityFlag", Native_GetEntityFlagConquest);
	CreateNative("CONQUEST_GetEntityPedestal", Native_GetEntityPedestalConquest); 
	CreateNative("MM_StartVote", Native_StartVote);
	CreateNative("GetCaptureFlagConfigParam", Native_GetCaptureFlagConfigParam); 
	CreateNative("GetConquestConfigParam", Native_GetConquestConfigParam);
	CreateNative("GetConquestZoneParam", Native_GetConquestZoneParam);
	//CreateNative("GetModsMasterConfigParam", Native_GetModsMasterConfigParam);
	CreateNative("CONQUEST_GetKeyValuesZonesSave", Native_GetKeyValuesZonesSave);
}

public Native_EnabledThisMomentCaptureFlag(Handle:plugin, numParams)
{
	return g_bEnabledCaptureFlag;
}

public Native_EnabledThisMomentConquest(Handle:plugin, numParams)
{
	return g_bEnabledConquest;
}

public Native_ThisMapConfigFlagsPos(Handle:plugin, numParams)
{
	decl String:sMapName[64];
	
	GetNativeString(1, sMapName, 64);
	
	return GetKvMapFlagsPos(sMapName);
}

public Native_ThisMapConfigZonesSave(Handle:plugin, numParams)
{
	decl String:sMapName[64];
	
	GetNativeString(1, sMapName, 64);
	
	return GetKvMapZonesSave(sMapName);
}

public Native_StartGameCaptureFlag(Handle:plugin, numParams)
{
	if(!g_bEnabledCaptureFlag)
	{
		if(g_bEnabledConquest) EndConquest();
	
		g_bEnabledCaptureFlag = true;
		
		g_ScoreTeam[0] = 0;
		g_ScoreTeam[1] = 0;
	
		KillTimerDemoCaptureFlagViewer();	
			
		if(hTimerUpdateBoxAll == INVALID_HANDLE) hTimerUpdateBoxAll = CreateTimer(UPDATE_BOX, TimerUpdateBoxAll, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
		
		UpdateConVars();
		
		LoadConfigFlags(); 
		LoadFlags();
		
		CS_TerminateRound(1.0, CSRoundEnd_Draw, true);
		
		Forward_OnStartGame();
		
		return true;
	}
	
	return false;
}

public Native_EndGameCaptureFlag(Handle:plugin, numParams)
{
	if(g_bEnabledCaptureFlag)
	{
		EndCaptureFlag();
		
		return true;
	}
	
	return false;
}

public Native_StartGameConquest(Handle:plugin, numParams)
{
	if(!g_bEnabledConquest)
	{
		if(g_bEnabledCaptureFlag) EndCaptureFlag();
	
		g_bEnabledConquest = true;
		
		g_ScoreTeam[0] = 0;
		g_ScoreTeam[1] = 0;

		KillTimerDemoConquestViewer();	
			
		if(hTimerUpdateBoxAll == INVALID_HANDLE) hTimerUpdateBoxAll = CreateTimer(UPDATE_BOX, TimerUpdateBoxAll, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
		
		UpdateConVars();
		
		LoadConfigZones();
		LoadZones();
		
		CS_TerminateRound(1.0, CSRoundEnd_Draw, true);
		
		Forward_OnStartGame();
		
		return true;
	}
	
	return false;
}

public Native_EndGameConquest(Handle:plugin, numParams)
{
	if(g_bEnabledConquest)
	{
		EndConquest();
		
		return true;
	}
	
	return false;
}

public Native_GetFlagStatusTeamCaptureFlag(Handle:plugin, numParams)
{
	if(GetNativeCell(1) == 3) return _:g_Flag[0];
	else return _:g_Flag[1];
}

public Native_GetClientFlagCapturedTeamCaptureFlag(Handle:plugin, numParams)
{
	if(GetNativeCell(1) == 3) return g_FlagClient[0];
	else return g_FlagClient[1];
}

public Native_GetClientZoneTeamCaptureFlag(Handle:plugin, numParams)
{
	new client = GetNativeCell(1);
	
	if(client) 
	{
		if(g_bZoneClient[client][0]) return TEAM_CT;
		else if(g_bZoneClient[client][1]) return TEAM_T;
	}
	
	return -1;
}

public Native_GetEntityFlagCaptureFlag(Handle:plugin, numParams)
{
	if(GetNativeCell(1) == 3) return g_EntFlag[0];
	else return g_EntFlag[1];
}

public Native_GetEntityPedestalCaptureFlag(Handle:plugin, numParams)
{
	if(GetNativeCell(1) == 3) return g_EntPedestal[0];
	else return g_EntPedestal[1];
}

public Native_GetFlagStatusZoneConquest(Handle:plugin, numParams)
{
	return _:g_Flag[GetNativeCell(1)];
}

public Native_GetClientFlagCapturedZoneConquest(Handle:plugin, numParams)
{
	return g_FlagClient[GetNativeCell(1)];
}

public Native_GetClientZoneConquest(Handle:plugin, numParams)
{
	new client = GetNativeCell(1);
	
	if(client) 
	{
		if(g_bClientInConquestZone[client][0]) return 0;
		else if(g_bClientInConquestZone[client][1]) return 1;
		else if(g_bClientInConquestZone[client][2]) return 2;
		else if(g_bClientInConquestZone[client][3]) return 3;
	}
	
	return -1;
}

public Native_GetEntityFlagConquest(Handle:plugin, numParams)
{
	return g_EntFlag[GetNativeCell(1)];
}

public Native_GetEntityPedestalConquest(Handle:plugin, numParams)
{
	return g_EntPedestal[GetNativeCell(1)];
}

public Native_StartVote(Handle:plugin, numParams)
{
	g_bNoMapVote = bool:GetNativeCell(1);
	
	decl String:sMapName[64];
	
	GetNativeString(2, sMapName, 64);
	
	if(sMapName[0]) 
	{
		if(GetKvMapFlagsPos(sMapName) && GetKvMapZonesSave(sMapName)) 
			return CreateTimerMapModeVote();
		
		return false;
	}
	
	return CreateTimerMapModeVote();
}

public Native_GetCaptureFlagConfigParam(Handle:plugin, numParams)
{
	new CF_ConfigParam:param = GetNativeCell(1);

	switch(param)
	{	
		case CaptureFlag_RoundTime: return g_RoundTimeCaptureFlag;
		case CaptureFlag_FlagDownTime: return g_FlagDownTimeCaptureFlag;
		case CaptureFlag_FlagProtectTime: return g_FlagProtectTimeCaptureFlag;
		case CaptureFlag_RoundEndTime: return RoundFloat(g_fRoundEndTimeCaptureFlag);
		case CaptureFlag_VoteModeTime: return RoundFloat(g_fVoteModeTime);
		case CaptureFlag_VoteMapTime: return RoundFloat(g_fVoteMapTime);
	}
	
	return -1;
}

public Native_GetConquestConfigParam(Handle:plugin, numParams)
{
	new CONQUEST_ConfigParam:param = GetNativeCell(1);

	switch(param)
	{	
		case Conquest_RoundTime: return g_RoundTimeConquest;
		case Conquest_FlagDownTime: return g_FlagDownTimeConquest;
		case Conquest_FlagProtectTime: return g_FlagProtectTimeConquest;
		case Conquest_RoundEndTime: return RoundFloat(g_fRoundEndTimeConquest);
	}
	
	return -1;
}

public Native_GetConquestZoneParam(Handle:plugin, numParams)
{
	new ZoneParam:param = GetNativeCell(2);

	switch(param)
	{	
		case Conquest_Team: return g_ConquestZoneTeam[GetNativeCell(1)];
		case Conquest_CountPlayers: return g_ConquestZoneCountPlayers[GetNativeCell(1)];
		case Conquest_Time: return g_ConquestZoneTime[GetNativeCell(1)];
		case Conquest_Movable: return g_bConquestFlagMovable[GetNativeCell(1)] ? 1:0;
	}
	
	return -1;
}

/*public Native_GetModsMasterConfigParam(Handle:plugin, numParams)
{
	new ModsMaster_ConfigParam:param = GetNativeCell(1);

	switch(param)
	{	
		case ModsMaster_VoteModeTime: return RoundFloat(g_fVoteModeTime);
		case ModsMaster_VoteMapTime: return RoundFloat(g_fVoteMapTime);
	}
	
	return -1;
}*/

public Native_GetKeyValuesZonesSave(Handle:plugin, numParams)
{
	return _:CloneHandle(kv_zs, plugin);
}

stock Forward_OnZoneStartTouch(client, team, zone_number = -1)
{
	Call_StartForward(g_hMM_OnZoneStartTouch);
	Call_PushCell(client);
	Call_PushCell(team);
	Call_PushCell(zone_number);
	Call_Finish();
}

stock Forward_OnZoneEndTouch(client, team, zone_number = -1)
{
	Call_StartForward(g_hMM_OnZoneEndTouch);
	Call_PushCell(client);
	Call_PushCell(team);
	Call_PushCell(zone_number);
	Call_Finish();
}

stock Forward_OnFlagDownTime(team, time)
{
	Call_StartForward(g_hMM_OnFlagDownTime);
	Call_PushCell(team);
	Call_PushCell(time);
	Call_Finish();
}

stock Forward_OnFlagProtectTime(team, time)
{
	Call_StartForward(g_hMM_OnFlagProtectTime);
	Call_PushCell(team);
	Call_PushCell(time);
	Call_Finish();
}

stock Forward_OnRoundTime(time)
{
	Call_StartForward(g_hMM_OnRoundTime);
	Call_PushCell(time);
	Call_Finish();
}

stock Forward_OnFlagEvent(team, MM_Type:event, client = -1, bool:bDisconnect = false, zone_number = -1)
{
	Call_StartForward(g_hMM_OnFlagEvent);
	Call_PushCell(team);
	Call_PushCell(event);
	Call_PushCell(client);
	Call_PushCell(bDisconnect ? 1:-1);
	Call_PushCell(zone_number);
	Call_Finish();
}

stock Forward_OnStartMapModeVote()
{
	Call_StartForward(g_hMM_OnStartMapModeVote);
	Call_Finish();
}

stock Forward_OnStartMapVote()
{
	Call_StartForward(g_hMM_OnStartMapVote);
	Call_Finish();
}

stock Forward_OnMapStart()
{
	Call_StartForward(g_bEnabledCaptureFlag ? g_hCF_OnMapStart:g_hCONQUEST_OnMapStart);
	Call_Finish();
}

stock Forward_OnStartGame()
{
	Call_StartForward(g_bEnabledCaptureFlag ? g_hCF_OnStartGame:g_hCONQUEST_OnStartGame);
	Call_Finish();
}

stock Forward_OnEndGame()
{
	Call_StartForward(g_bEnabledCaptureFlag ? g_hCF_OnEndGame:g_hCONQUEST_OnEndGame);
	Call_Finish();
}