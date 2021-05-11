new Handle:hTimerRoundStart, Handle:hTimerFlagDown[4], Handle:hTimerFlagProtect[4], Handle:hTimerDemoCaptureFlagViewer, Handle:hTimerDemoConquestViewer, Handle:hTimerUpdateBoxAll;

public Action:TimerUpdateBoxAll(Handle:timer)
{
	decl Float:fPos1[3], Float:fPos2[3];

	if(g_bEnabledCaptureFlag || hTimerDemoCaptureFlagViewer)
	{
		CalculateZoneBox(g_fFlagPos[0], fPos1, fPos2);
	
		TE_SendBeamBoxToClientAll(fPos1, fPos2, g_BeamSprite, g_HaloSprite, 0, 30, UPDATE_BOX, 2.0, 2.0, 2, 1.0, ZoneColorCT, 0);

		CalculateZoneBox(g_fFlagPos[1], fPos1, fPos2);
	
		TE_SendBeamBoxToClientAll(fPos1, fPos2, g_BeamSprite, g_HaloSprite, 0, 30, UPDATE_BOX, 2.0, 2.0, 2, 1.0, ZoneColorT, 0); 
	}
	else if(g_bEnabledConquest || hTimerDemoConquestViewer)
	{
		KvRewind(kv_zs);
		if(!KvJumpToKey(kv_zs, sMap, false)) return;

		new bool:bSectionExists = KvGotoFirstSubKey(kv_zs);
	
		if(!bSectionExists) return;
	
		new zone_number;
	
		decl Float:fPos[3], String:buffer[3];
	
		while(bSectionExists)
		{
			KvGetSectionName(kv_zs, buffer, 3);
		
			zone_number = StringToInt(buffer)-1;
		
			KvGetVector(kv_zs, "pos", fPos);
		
			CalculateZoneBox(fPos, fPos1, fPos2, zone_number);
	
			TE_SendBeamBoxToClientAll(fPos1, fPos2, g_BeamSprite, g_HaloSprite, 0, 30, UPDATE_BOX, 2.0, 2.0, 2, 1.0, g_ConquestZoneTeam[zone_number] == 3 ? ZoneColorCT : g_ConquestZoneTeam[zone_number] == 2 ? ZoneColorT : ZoneColorNeutral, 0);
			
			new Float:pos1[3], Float:pos2[3], Float:pos3[3], Float:pos4[3], Float:pos5[3], Float:pos6[3];
	
			AddVectors(pos1, fPos2, pos1);
			pos1[0] = fPos1[0];
	
			AddVectors(pos2, fPos2, pos2);
			pos2[1] = fPos1[1];
	
			AddVectors(pos3, fPos1, pos3);
			pos3[2] = fPos2[2];

			AddVectors(pos4, fPos2, pos4);
			pos4[2] = fPos1[2];
	
			AddVectors(pos5, fPos1, pos5);
			pos5[0] = fPos2[0];
	
			AddVectors(pos6, fPos1, pos6);
			pos6[1] = fPos2[1];
			
			for(new i = 1; i <= MaxClients; i++)
			{
				if(IsClientInGame(i) && g_bAdminBox[i][zone_number]) 
				{
					TE_SetupBeamPoints(pos5, fPos1, g_BeamSprite, g_HaloSprite, 0, 30, UPDATE_BOX, 2.0, 2.0, 2, 1.0, g_ConquestZoneTeam[zone_number] == 3 ? ZoneColorCT : g_ConquestZoneTeam[zone_number] == 2 ? ZoneColorT : ZoneColorNeutral, 0);
					TE_SendToClient(i);
					
					TE_SetupBeamPoints(pos5, pos4, g_BeamSprite, g_HaloSprite, 0, 30, UPDATE_BOX, 2.0, 2.0, 2, 1.0, g_ConquestZoneTeam[zone_number] == 3 ? ZoneColorCT : g_ConquestZoneTeam[zone_number] == 2 ? ZoneColorT : ZoneColorNeutral, 0);
					TE_SendToClient(i);
					
					TE_SetupBeamPoints(pos6, fPos1, g_BeamSprite, g_HaloSprite, 0, 30, UPDATE_BOX, 2.0, 2.0, 2, 1.0, g_ConquestZoneTeam[zone_number] == 3 ? ZoneColorCT : g_ConquestZoneTeam[zone_number] == 2 ? ZoneColorT : ZoneColorNeutral, 0);
					TE_SendToClient(i);
					
					TE_SetupBeamPoints(pos6, pos4, g_BeamSprite, g_HaloSprite, 0, 30, UPDATE_BOX, 2.0, 2.0, 2, 1.0, g_ConquestZoneTeam[zone_number] == 3 ? ZoneColorCT : g_ConquestZoneTeam[zone_number] == 2 ? ZoneColorT : ZoneColorNeutral, 0);
					TE_SendToClient(i);
					
					TE_SetupBeamPoints(fPos2, pos4, g_BeamSprite, g_HaloSprite, 0, 30, UPDATE_BOX, 2.0, 2.0, 2, 1.0, g_ConquestZoneTeam[zone_number] == 3 ? ZoneColorCT : g_ConquestZoneTeam[zone_number] == 2 ? ZoneColorT : ZoneColorNeutral, 0);
					TE_SendToClient(i);
					
					TE_SetupBeamPoints(pos3, fPos1, g_BeamSprite, g_HaloSprite, 0, 30, UPDATE_BOX, 2.0, 2.0, 2, 1.0, g_ConquestZoneTeam[zone_number] == 3 ? ZoneColorCT : g_ConquestZoneTeam[zone_number] == 2 ? ZoneColorT : ZoneColorNeutral, 0);
					TE_SendToClient(i);

					TE_SetupBeamPoints(pos5, pos2, g_BeamSprite, g_HaloSprite, 0, 30, UPDATE_BOX, 2.0, 2.0, 2, 1.0, g_ConquestZoneTeam[zone_number] == 3 ? ZoneColorCT : g_ConquestZoneTeam[zone_number] == 2 ? ZoneColorT : ZoneColorNeutral, 0);
					TE_SendToClient(i);
					
					TE_SetupBeamPoints(pos6, pos1, g_BeamSprite, g_HaloSprite, 0, 30, UPDATE_BOX, 2.0, 2.0, 2, 1.0, g_ConquestZoneTeam[zone_number] == 3 ? ZoneColorCT : g_ConquestZoneTeam[zone_number] == 2 ? ZoneColorT : ZoneColorNeutral, 0);
					TE_SendToClient(i);
				}
			}
			
			bSectionExists = KvGotoNextKey(kv_zs);
		}
	}
}

stock CreateTimerRoundStart() hTimerRoundStart = CreateTimer(1.0, TimerRoundStart, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);

public Action:TimerRoundStart(Handle:timer) 
{
	g_CurrentRoundTime++;

	if(g_bEnabledCaptureFlag)
	{
		if(g_CurrentRoundTime >= g_RoundTimeCaptureFlag*60) 
		{
			if(g_ScoreTeam[0] == g_ScoreTeam[1]) CS_TerminateRound(g_fRoundEndTimeCaptureFlag, CSRoundEnd_Draw, true);
			else if(g_ScoreTeam[0] > g_ScoreTeam[1]) CS_TerminateRound(g_fRoundEndTimeCaptureFlag, CSRoundEnd_CTWin, true);
			else CS_TerminateRound(g_fRoundEndTimeCaptureFlag, CSRoundEnd_TerroristWin, true);
		}
		else 
		{
			if(g_fVoteModeTime != 0.0 && g_CurrentRoundTime >= (g_RoundTimeCaptureFlag*60)-g_fVoteModeTime) CreateTimerMapModeVote();
		
			Forward_OnRoundTime(g_CurrentRoundTime);
		}
	}
	else if(g_bEnabledConquest)
	{
		new bool:bMovable = GetKvAvailableFlagMovable();
	
		if(g_CurrentRoundTime >= g_RoundTimeConquest*60) 
		{
			if(bMovable)
			{
				new ct, t;
				
				for(new x = 0; x < 4; x++)
				{
					if(g_EntFlag[x] > 0 || g_bZoneFullConquest[x])
					{
						if(g_ConquestZoneTeam[x] == TEAM_CT) ct++;
						else if(g_ConquestZoneTeam[x] == TEAM_T) t++;
					}
				}
				
				if(ct == t) CS_TerminateRound(g_fRoundEndTimeConquest, CSRoundEnd_Draw, true);
				else if(ct > t) 
				{
					g_ScoreTeam[0]++;
					CS_TerminateRound(g_fRoundEndTimeConquest, CSRoundEnd_CTWin, true);
				}
				else 
				{
					g_ScoreTeam[1]++;
					CS_TerminateRound(g_fRoundEndTimeConquest, CSRoundEnd_TerroristWin, true);
				}
			}
			else CS_TerminateRound(g_fRoundEndTimeConquest, CSRoundEnd_Draw, true);
		}
		else 
		{
			if(bMovable)
			{
				new bool:bFullConquest = true; 
			
				for(new x = 0; x < 4; x++)
				{	
					if(g_EntFlag[x] > 0 && !g_bZoneFullConquest[x]) 
					{
						bFullConquest = false;
						break;
					}
				}
			
				if(bFullConquest)
				{
					new ct, t;
				
					for(new x = 0; x < 4; x++)
					{
						if(g_EntFlag[x] > 0 || g_bZoneFullConquest[x])
						{
							if(g_ConquestZoneTeam[x] == TEAM_CT) ct++;
							else if(g_ConquestZoneTeam[x] == TEAM_T) t++;
						}
					}
				
					if(ct == t) CS_TerminateRound(g_fRoundEndTimeConquest, CSRoundEnd_Draw, true);
					else if(ct > t) 
					{
						g_ScoreTeam[0]++;
						CS_TerminateRound(g_fRoundEndTimeConquest, CSRoundEnd_CTWin, true);
					}
					else 
					{
						g_ScoreTeam[1]++;
						CS_TerminateRound(g_fRoundEndTimeConquest, CSRoundEnd_TerroristWin, true);
					}
				}
			}
			else
			{
				new team, bool:bZonesConquest = true;
			
				for(new x = 0; x < 4; x++)
				{
					if(g_EntFlag[x] > 0)
					{
						if(team == 0) team = g_ConquestZoneTeam[x];
						
						if(team == 0 || team != g_ConquestZoneTeam[x])
						{
							bZonesConquest = false;
							break;
						}
					}
				}
				
				if(bZonesConquest)
				{
					if(team == TEAM_CT)
					{
						g_ScoreTeam[0]++;
						CS_TerminateRound(g_fRoundEndTimeConquest, CSRoundEnd_CTWin, true);
					}
					else if(team == TEAM_T)
					{
						g_ScoreTeam[1]++;
						CS_TerminateRound(g_fRoundEndTimeConquest, CSRoundEnd_TerroristWin, true); 
					}
				}
			}
		
			Forward_OnRoundTime(g_CurrentRoundTime);
		}
	}
}

stock KillTimerRoundStart()
{
	if(hTimerRoundStart != INVALID_HANDLE)
	{
		KillTimer(hTimerRoundStart);
		hTimerRoundStart = INVALID_HANDLE;
	}
}

bool:CreateTimerMapModeVote() 
{
	if(!g_bStartMapModeVote)
	{
		g_bStartMapModeVote = true;

		CreateTimer(1.0, TimerMapModeVote, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
		
		return true;
	}
	
	return false;
}

public Action:TimerMapModeVote(Handle:timer)  
{
	if(++g_VoteTimerCount > 5) 
	{
		g_VoteTimerCount = 0;
		StartMapModeVote();
		Forward_OnStartMapModeVote();
		PrintCenterTextAll("Голосование за режим на следующей карте запущено!");
		return Plugin_Stop;
	}
	else PrintCenterTextAll("До старта голосования за режим на следующей карте %d секунд!", 6 - g_VoteTimerCount);
	
	return Plugin_Continue;
}

stock CreateTimerStartMapVote()
{
	if(CanMapChooserStartVote() && EndOfMapVoteEnabled() && !HasEndOfMapVoteFinished())  
	{
		PrintToChatAll("\x04[Mods Master]\x01 Голосование за карту начнется через %1.f секунд!", g_fVoteMapTime+5);
		CreateTimer(g_fVoteMapTime, TimerStartVoteMap, _, TIMER_FLAG_NO_MAPCHANGE);
	}
}

public Action:TimerStartVoteMap(Handle:timer) CreateTimer(1.0, TimerMapVote, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);

public Action:TimerMapVote(Handle:timer)  
{
	if(++g_VoteTimerCount > 5) 
	{
		g_VoteTimerCount = 0;
		if(g_bVoteNextMapCaptureFlag || g_bVoteNextMapConquest) InitiateMapChooserVote(MapChange_RoundEnd, GetKvMapListToArray());
		else InitiateMapChooserVote(MapChange_RoundEnd);
		Forward_OnStartMapVote();
		PrintCenterTextAll("Голосование за следующую карту запущено!");
		return Plugin_Stop;
	}
	else PrintCenterTextAll("До старта голосования за следующую карту %d секунд!", 6 - g_VoteTimerCount);
	
	return Plugin_Continue;
}

stock CreateTimerFlagDownTeam(bool:bTeam)
{
	if(bTeam) 
	{
		g_CurrentFlagDownTime[0] = 0;
		hTimerFlagDown[0] = CreateTimer(1.0, TimerFlagDownTeamCT, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
	}
	else 
	{
		g_CurrentFlagDownTime[1] = 0;
		hTimerFlagDown[1] = CreateTimer(1.0, TimerFlagDownTeamT, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
	}
}

public Action:TimerFlagDownTeamCT(Handle:timer)
{
	g_CurrentFlagDownTime[0]++;

	Forward_OnFlagDownTime(TEAM_CT, g_CurrentFlagDownTime[0]);

	if(g_CurrentFlagDownTime[0] >= g_FlagDownTimeCaptureFlag)
	{
		g_Flag[0] = ModsMaster_Zone;
		CreateFlag(g_fFlagPos[0], TEAM_CT);
		hTimerFlagDown[0] = INVALID_HANDLE;
		Forward_OnFlagEvent(TEAM_CT, ModsMaster_Zone);
		
		return Plugin_Stop;
	}
	
	return Plugin_Continue;
}

public Action:TimerFlagDownTeamT(Handle:timer)
{
	g_CurrentFlagDownTime[1]++;

	Forward_OnFlagDownTime(TEAM_T, g_CurrentFlagDownTime[1]);
	
	if(g_CurrentFlagDownTime[1] >= g_FlagDownTimeCaptureFlag)
	{
		g_Flag[1] = ModsMaster_Zone;
		CreateFlag(g_fFlagPos[1], TEAM_T);
		hTimerFlagDown[1] = INVALID_HANDLE;
		Forward_OnFlagEvent(TEAM_T, ModsMaster_Zone);
		
		return Plugin_Stop;
	}
	
	return Plugin_Continue;
}

stock CreateTimerFlagDown(zone_number)
{
	g_CurrentFlagDownTime[zone_number] = 0;
	hTimerFlagDown[zone_number] = CreateTimer(1.0, TimerFlagDown, zone_number, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
}

public Action:TimerFlagDown(Handle:timer, any:zone_number)
{
	g_CurrentFlagDownTime[zone_number]++;

	Forward_OnFlagDownTime(g_ConquestZoneTeam[zone_number], g_CurrentFlagDownTime[zone_number]);

	if(g_CurrentFlagDownTime[zone_number] >= g_FlagDownTimeConquest)
	{
		decl Float:fPos[3];
		GetKvZonePos(fPos, zone_number);
	
		g_Flag[zone_number] = ModsMaster_Zone;
		CreateFlag(fPos, g_ConquestZoneTeam[zone_number], _, _, zone_number);
		CreateTimerFlagProtect(zone_number);
		hTimerFlagDown[zone_number] = INVALID_HANDLE;
		Forward_OnFlagEvent(g_ConquestZoneTeam[zone_number], ModsMaster_Zone, _, _, zone_number);
		
		return Plugin_Stop;
	}
	
	return Plugin_Continue;
}

stock KillAllTimerFlagDown()
{
	for(new x = 0; x < 4; x++)
		KillTimerFlagDown(x);
}

stock KillTimerFlagDownTeam(bool:bTeam)
{
	if(bTeam)
	{
		if(hTimerFlagDown[0] != INVALID_HANDLE)
		{
			KillTimer(hTimerFlagDown[0]);
			hTimerFlagDown[0] = INVALID_HANDLE;
		}
	}
	else
	{
		if(hTimerFlagDown[1] != INVALID_HANDLE)
		{
			KillTimer(hTimerFlagDown[1]);
			hTimerFlagDown[1] = INVALID_HANDLE;
		}
	}
}

stock KillTimerFlagDown(zone_number)
{
	if(hTimerFlagDown[zone_number] != INVALID_HANDLE)
	{
		KillTimer(hTimerFlagDown[zone_number]);
		hTimerFlagDown[zone_number] = INVALID_HANDLE;
	}
}

stock CreateTimerFlagProtectTeam(bool:bTeam)
{
	if(bTeam) 
	{
		g_CurrentFlagProtectTime[0] = 0;
		hTimerFlagProtect[0] = CreateTimer(1.0, TimerFlagProtectTeamCT, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
	}
	else 
	{
		g_CurrentFlagProtectTime[1] = 0;
		hTimerFlagProtect[1] = CreateTimer(1.0, TimerFlagProtectTeamT, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
	}
}

public Action:TimerFlagProtectTeamCT(Handle:timer)
{
	g_CurrentFlagProtectTime[0]++;

	Forward_OnFlagProtectTime(TEAM_CT, g_CurrentFlagProtectTime[0]);

	if(g_CurrentFlagProtectTime[0] >= g_FlagProtectTimeCaptureFlag)
	{
		hTimerFlagProtect[0] = INVALID_HANDLE;
		return Plugin_Stop;
	}
	
	return Plugin_Continue;
}

public Action:TimerFlagProtectTeamT(Handle:timer)
{
	g_CurrentFlagProtectTime[1]++;

	Forward_OnFlagProtectTime(TEAM_T, g_CurrentFlagProtectTime[1]);
	
	if(g_CurrentFlagProtectTime[1] >= g_FlagProtectTimeCaptureFlag)
	{
		hTimerFlagProtect[1] = INVALID_HANDLE;
		return Plugin_Stop;
	}
	
	return Plugin_Continue;
}

stock CreateTimerFlagProtect(zone_number)
{
	g_CurrentFlagProtectTime[zone_number] = 0;
	hTimerFlagProtect[zone_number] = CreateTimer(1.0, TimerFlagProtect, zone_number, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
}

public Action:TimerFlagProtect(Handle:timer, any:zone_number)
{
	g_CurrentFlagProtectTime[zone_number]++;

	Forward_OnFlagProtectTime(g_ConquestZoneTeam[zone_number], g_CurrentFlagProtectTime[zone_number]);

	if(g_CurrentFlagProtectTime[zone_number] >= g_FlagProtectTimeConquest)
	{
		hTimerFlagProtect[zone_number] = INVALID_HANDLE;
		return Plugin_Stop;
	}
	
	return Plugin_Continue;
}

stock KillAllTimerFlagProtect()
{
	for(new x = 0; x < 4; x++)
	{
		if(hTimerFlagProtect[x] != INVALID_HANDLE)
		{
			KillTimer(hTimerFlagProtect[x]);
			hTimerFlagProtect[x] = INVALID_HANDLE;
		}
	}
}

stock CreateTimerDemoCaptureFlagViewer()
{
	KillTimerDemoCaptureFlagViewer();

	hTimerDemoCaptureFlagViewer = CreateTimer(5.0, TimerDemoCaptureFlagViewer, TIMER_FLAG_NO_MAPCHANGE);
	
	if(hTimerUpdateBoxAll == INVALID_HANDLE) hTimerUpdateBoxAll = CreateTimer(UPDATE_BOX, TimerUpdateBoxAll, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
}

public Action:TimerDemoCaptureFlagViewer(Handle:timer) 
{
	KillAllEntity();
	hTimerDemoCaptureFlagViewer = INVALID_HANDLE;
	
	KillTimerUpdateBoxAll();
	
	g_Flag[0] = ModsMaster_None;
	g_Flag[1] = ModsMaster_None;
	
	g_EntFlag[0] = -1;
	g_EntFlag[1] = -1;
	
	g_EntPedestal[0] = -1;
	g_EntPedestal[1] = -1;
	
	g_EntZone[0] = -1;
	g_EntZone[1] = -1;
	
	g_EntFlagGlow[0] = -1;
	g_EntFlagGlow[1] = -1;
	
	g_FlagClient[0] = -1;
	g_FlagClient[1] = -1;
}

stock CreateTimerDemoConquestViewer(Float:fTimer = 10.0)
{
	KillTimerDemoConquestViewer();

	hTimerDemoConquestViewer = CreateTimer(fTimer, TimerDemoConquestViewer, TIMER_FLAG_NO_MAPCHANGE);
	
	if(hTimerUpdateBoxAll == INVALID_HANDLE) hTimerUpdateBoxAll = CreateTimer(UPDATE_BOX, TimerUpdateBoxAll, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
}

public Action:TimerDemoConquestViewer(Handle:timer) 
{
	KillAllEntity();
	hTimerDemoConquestViewer = INVALID_HANDLE;
	
	KillTimerUpdateBoxAll();
	
	g_Flag[0] = ModsMaster_None;
	g_Flag[1] = ModsMaster_None;
	g_Flag[2] = ModsMaster_None;
	g_Flag[3] = ModsMaster_None;
	
	g_EntFlag[0] = -1;
	g_EntFlag[1] = -1;
	g_EntFlag[2] = -1;
	g_EntFlag[3] = -1;
	
	g_EntPedestal[0] = -1;
	g_EntPedestal[1] = -1;
	g_EntPedestal[2] = -1;
	g_EntPedestal[3] = -1;
	
	g_EntZone[0] = -1;
	g_EntZone[1] = -1;
	g_EntZone[2] = -1;
	g_EntZone[3] = -1;
	
	g_EntSprite[0] = -1;
	g_EntSprite[1] = -1;
	g_EntSprite[2] = -1;
	g_EntSprite[3] = -1;

	g_FlagClient[0] = -1;
	g_FlagClient[1] = -1;
	g_FlagClient[2] = -1;
	g_FlagClient[3] = -1;
}

public Action:TimerProgressConquestZone(Handle:timer)
{
	if(g_bEnabledConquest && !g_bRoundEnd)
	{
		if(KvRewind(kv_zs) && KvJumpToKey(kv_zs, sMap, false))
		{
			new bool:bSectionExists = KvGotoFirstSubKey(kv_zs);
	
			if(bSectionExists)
			{
				new zone_number;
	
				decl String:buffer[3], String:sNameZone[3], Float:fPos[3];
	
				while(bSectionExists)
				{
					KvGetSectionName(kv_zs, buffer, 3);
					
					zone_number = StringToInt(buffer)-1;
				
					GetNameZone(sNameZone, zone_number);

					if(!g_bZoneFullConquest[zone_number])
					{
						new bool:bEnemy, team;
				
						for(new i = 1, new_team; i <= MaxClients; i++)
						{
							if(IsClientInGame(i) && g_bClientInConquestZone[i][zone_number] && IsPlayerAlive(i))
							{
								if(team != (new_team = GetClientTeam(i)) && team != 0)
								{
									if(g_CurrentProgressConquestZone[zone_number][0] > 0) g_CurrentProgressConquestZone[zone_number][0]--;
								
									if(g_CurrentProgressConquestZone[zone_number][1] > 0) g_CurrentProgressConquestZone[zone_number][1]--;

									new time = KvGetNum(kv_zs, "time", 30);
								
									for(i = 1; i <= MaxClients; i++)
									{
										if(IsClientInGame(i) && g_bClientInConquestZone[i][zone_number] && !IsFakeClient(i) && IsPlayerAlive(i) && (team = GetClientTeam(i)) != g_ConquestZoneTeam[zone_number])
											PrintHintText(i, "[Враг в зоне] Прогресс захвата точки %s: %d%", sNameZone, RoundToCeil((float(g_CurrentProgressConquestZone[zone_number][team == 3 ? 0:1])/float(time))*100.0));
									}
								
									bEnemy = true;
								
									break;
								}
						
								team = new_team;
							}
						}
					
						if(!bEnemy)
						{
							new clients[MaxClients+1], players;
			
							for(new i = 1; i <= MaxClients; i++) 
							{
								if(IsClientInGame(i) && g_bClientInConquestZone[i][zone_number] && !IsFakeClient(i) && IsPlayerAlive(i) && GetClientTeam(i) != g_ConquestZoneTeam[zone_number])
									clients[players++] = i;
							}
				
							if(players > 0)
							{
								new count_players = KvGetNum(kv_zs, "count_players", 1);

								count_players = GetAvailableCountPlayers(count_players);

								new time = KvGetNum(kv_zs, "time", 30);
					
								if(players >= count_players)
								{
									g_CurrentProgressConquestZone[zone_number][team == 3 ? 0:1] += (1 + players-count_players);
									if(g_CurrentProgressConquestZone[zone_number][team == 3 ? 1:0] > 0) g_CurrentProgressConquestZone[zone_number][team == 3 ? 1:0]--;
								
									if(g_CurrentProgressConquestZone[zone_number][team == 3 ? 0:1] >= time)
									{
										KvGetVector(kv_zs, "pos", fPos);
									
										g_ConquestZoneTeam[zone_number] = team;
							
										if(g_FlagColorTeamConquest == 1 && g_EntFlag[zone_number] > 0 && IsValidEntity(g_EntFlag[zone_number])) 
										{
											if(team == 3) SetEntityRenderColor(g_EntFlag[zone_number], 0, 0, 255, 0);
											else SetEntityRenderColor(g_EntFlag[zone_number], 255, 0, 0, 0);
										}
										
										for(new x = 0; x < players; x++)	
											PrintHintText(clients[x], "Точка %s захвачена!", sNameZone);

										if(g_Flag[zone_number] == ModsMaster_Captured || g_Flag[zone_number] == ModsMaster_Down)
										{
											CreateFlag(fPos, g_ConquestZoneTeam[zone_number], _, _, zone_number);
											CreateTimerFlagProtect(zone_number);
											g_Flag[zone_number] = ModsMaster_Zone;
										}
							
										CreateZone(fPos, g_ConquestZoneTeam[zone_number], zone_number);
										CreateSprite(fPos, g_ConquestZoneTeam[zone_number], zone_number);
							
										g_CurrentProgressConquestZone[zone_number][0] = 0;
										g_CurrentProgressConquestZone[zone_number][1] = 0;
										
										Forward_OnFlagEvent(g_ConquestZoneTeam[zone_number], ModsMaster_ZoneCaptured, _, _, zone_number); 
									}
									else
									{
										new percent = RoundToCeil((float(g_CurrentProgressConquestZone[zone_number][team == 3 ? 0:1])/float(time))*100.0);
						
										for(new x = 0; x < players; x++)
											PrintHintText(clients[x], "[Идет захват] Прогресс захвата точки %s: %d%", sNameZone, percent);
									}
								}
								else 
								{
									if(g_CurrentProgressConquestZone[zone_number][team == 3 ? 0:1] > 0) g_CurrentProgressConquestZone[zone_number][team == 3 ? 0:1]--;
								
									new percent = RoundToCeil((float(g_CurrentProgressConquestZone[zone_number][team == 3 ? 0:1])/float(time))*100.0);
								
									for(new x = 0; x < players; x++)
										PrintHintText(clients[x], "[Недостаточно игроков] Прогресс захвата точки %s: %d%", sNameZone, percent); 
								}
							}
							else
							{
								if(g_CurrentProgressConquestZone[zone_number][0] > 0) g_CurrentProgressConquestZone[zone_number][0]--;
						
								if(g_CurrentProgressConquestZone[zone_number][1] > 0) g_CurrentProgressConquestZone[zone_number][1]--;
							}
						}
					}
					else
					{
						for(new i = 1; i <= MaxClients; i++)
						{
							if(IsClientInGame(i) && g_bClientInConquestZone[i][zone_number] && !IsFakeClient(i) && IsPlayerAlive(i) && GetClientTeam(i) != g_ConquestZoneTeam[zone_number])
								PrintHintText(i, "Точка %s под полным контролем врага!", sNameZone);
						}
					}
					
					bSectionExists = KvGotoNextKey(kv_zs);
				}
			}
		}
	}
}

public Action:TimerUpdateScore(Handle:timer)
{
	if(g_bEnabledCaptureFlag || g_bEnabledConquest)
	{
		SetTeamScore(TEAM_CT, g_ScoreTeam[0]);
		SetTeamScore(TEAM_T, g_ScoreTeam[1]);
	}
}

stock KillTimerDemoCaptureFlagViewer()
{
	if(hTimerDemoCaptureFlagViewer != INVALID_HANDLE)
	{
		KillTimer(hTimerDemoCaptureFlagViewer);
		hTimerDemoCaptureFlagViewer = INVALID_HANDLE;
	}
}

stock KillTimerDemoConquestViewer()
{
	if(hTimerDemoConquestViewer != INVALID_HANDLE)
	{
		KillTimer(hTimerDemoConquestViewer);
		hTimerDemoConquestViewer = INVALID_HANDLE;
	}
}

stock KillTimerUpdateBoxAll()
{
	if(hTimerUpdateBoxAll != INVALID_HANDLE)
	{
		KillTimer(hTimerUpdateBoxAll);
		hTimerUpdateBoxAll = INVALID_HANDLE;
	}
}