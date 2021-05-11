public OnStartTouch_Flag(entity, client)
{
	if(g_bEnabledCaptureFlag)
	{
		if(hTimerDemoCaptureFlagViewer || g_bRoundEnd || !(1 <= client <= MaxClients) || !IsClientInGame(client))
			return;
	
		if(hTimerFlagProtect[0] == INVALID_HANDLE && g_EntFlag[0] == entity) 
		{
			if(GetClientTeam(client) == TEAM_T) 
			{
				g_Flag[0] = ModsMaster_Captured;
				CreateFlag(g_fFlagPos[0], TEAM_CT, false, client);
				Forward_OnFlagEvent(TEAM_CT, ModsMaster_Captured, client);
			}
			else if(g_Flag[0] != ModsMaster_Zone)
			{
				g_Flag[0] = ModsMaster_Zone;
				CreateFlag(g_fFlagPos[0], TEAM_CT, true);
				Forward_OnFlagEvent(TEAM_CT, ModsMaster_Zone, client); 
			}
		
			KillTimerFlagDownTeam(true);
		}
		else if(hTimerFlagProtect[1] == INVALID_HANDLE && g_EntFlag[1] == entity) 
		{
			if(GetClientTeam(client) == TEAM_CT) 
			{
				g_Flag[1] = ModsMaster_Captured;
				CreateFlag(g_fFlagPos[1], TEAM_T, false, client);
				Forward_OnFlagEvent(TEAM_T, ModsMaster_Captured, client);
			}
			else if(g_Flag[1] != ModsMaster_Zone)
			{
				g_Flag[1] = ModsMaster_Zone;
				CreateFlag(g_fFlagPos[1], TEAM_T, true);
				Forward_OnFlagEvent(TEAM_T, ModsMaster_Zone, client);
			}
		
			KillTimerFlagDownTeam(false);
		}
	}
	else if(g_bEnabledConquest)
	{
		if(g_bRoundEnd || !(1 <= client <= MaxClients) || !IsClientInGame(client)) return;
		
		if(!IsPlayerConquestFlag(client))
		{
			for(new x = 0; x < 4; x++)
			{
				if(g_EntFlag[x] == entity && GetKvFlagMovable(x))
				{
					if(hTimerFlagProtect[x] == INVALID_HANDLE) 
					{
						if(GetClientTeam(client) != g_ConquestZoneTeam[x]) 
						{
							g_Flag[x] = ModsMaster_Captured;
							CreateFlag(_, g_ConquestZoneTeam[x], _, client, x);
							Forward_OnFlagEvent(g_ConquestZoneTeam[x], ModsMaster_Captured, client, _, x);
						}
						else if(g_Flag[x] != ModsMaster_Zone)
						{
							decl Float:fPos[3];
							GetKvZonePos(fPos, x);
							g_Flag[x] = ModsMaster_Zone;
							CreateFlag(fPos, g_ConquestZoneTeam[x], _, _, x);
							CreateTimerFlagProtect(x);
							Forward_OnFlagEvent(g_ConquestZoneTeam[x], ModsMaster_Zone, client, _, x);
						}
			
						KillTimerFlagDown(x);
					}
				
					break;
				}
			}
		}
	}
}

public OnStartTouch_Zone(entity, client)
{
	if(g_bEnabledCaptureFlag)
	{
		if(!(1 <= client <= MaxClients) || !IsClientInGame(client))
			return;
	
		if(g_EntZone[0] == entity)
		{
			g_bZoneClient[client][0] = true;
	
			if(g_FlagClient[1] == client) 
			{
				g_Flag[1] = ModsMaster_Zone;
	
				CreateFlag(g_fFlagPos[1], TEAM_T, true);

				CreateTimerFlagProtectTeam(false);
				g_ScoreTeam[0]++; 
			
				Forward_OnFlagEvent(TEAM_T, ModsMaster_Delivered, client);
			}
		
			Forward_OnZoneStartTouch(client, TEAM_CT);
		}
		else if(g_EntZone[1] == entity)
		{
			g_bZoneClient[client][1] = true;
	
			if(g_FlagClient[0] == client) 
			{
				g_Flag[0] = ModsMaster_Zone;
	
				CreateFlag(g_fFlagPos[0], TEAM_CT, true);
		
				CreateTimerFlagProtectTeam(true);
				g_ScoreTeam[1]++;
			
				Forward_OnFlagEvent(TEAM_CT, ModsMaster_Delivered, client); 
			}
		
			Forward_OnZoneStartTouch(client, TEAM_T);
		}
	}
	else if(g_bEnabledConquest)
	{
		if(!(1 <= client <= MaxClients) || !IsClientInGame(client)) return;
		
		for(new x = 0; x < 4; x++)
		{
			if(g_EntZone[x] == entity)
			{
				g_bClientInConquestZone[client][x] = true;
				
				Forward_OnZoneStartTouch(client, g_ConquestZoneTeam[x], x);
				
				new team = GetClientTeam(client);
				
				if(g_ConquestZoneTeam[x] == team)
				{
					for(x = 0; x < 4; x++)
					{
						if(g_FlagClient[x] == client)
						{
							if(!g_bZoneFullConquest[x])
							{
								if(g_ConquestZoneTeam[x] != team)
								{
									g_ConquestZoneTeam[x] = team;
									g_bZoneFullConquest[x] = true;
								
									decl Float:fPos[3];
				
									GetKvZonePos(fPos, x);
									
									CreateSprite(fPos, g_ConquestZoneTeam[x], x);
									RemoveZoneFlag(x);
									
									decl String:sNameZone[3];
									
									GetNameZone(sNameZone, x);
									
									PrintHintText(g_FlagClient[x], "Точка %s взята под полный контроль!", sNameZone);
									
									g_FlagClient[x] = -1;
									g_Flag[x] = ModsMaster_FullCaptured;
									
									Forward_OnFlagEvent(g_ConquestZoneTeam[x], ModsMaster_FullCaptured, client, _, x);
								}	
							}
					
							break;
						}
					}
				}
				
				break;
			}
		}
	}
}

public OnEndTouch_Zone(entity, client)
{
	if(g_bEnabledCaptureFlag)
	{
		if(!(1 <= client <= MaxClients) || !IsClientInGame(client))
			return;
	
		if(g_EntZone[0] == entity) 
		{
			g_bZoneClient[client][0] = false;
		
			Forward_OnZoneEndTouch(client, TEAM_CT);
		}
		else if(g_EntZone[1] == entity) 
		{
			g_bZoneClient[client][1] = false;
		
			Forward_OnZoneEndTouch(client, TEAM_T);
		}
	}
	else if(g_bEnabledConquest)
	{
		if(!(1 <= client <= MaxClients) || !IsClientInGame(client)) return;
		
		for(new x = 0; x < 4; x++)
		{
			if(g_EntZone[x] == entity)
			{
				g_bClientInConquestZone[client][x] = false;
				
				Forward_OnZoneEndTouch(client, g_ConquestZoneTeam[x], x);
				
				break;
			}
		}
	}
}

public Action:SetTransmit_FlagGlow(entity, client)  
{ 
	new team;
	if((team = GetClientTeam(client)) <= 1 || entity == g_EntFlagGlow[0] && team == TEAM_T || entity == g_EntFlagGlow[1] && team == TEAM_CT) return Plugin_Handled;
	
	return Plugin_Continue; 
}  

public Event_PlayerDeath(Handle:event, const String:name[], bool:dontBroadcast) 
{
	if(!g_bEnabledCaptureFlag && !g_bEnabledConquest) return;

	new client = GetClientOfUserId(GetEventInt(event, "userid"));

	if(client)
	{
		if(g_bEnabledCaptureFlag)
		{
			if(g_FlagClient[0] == client) 
			{
				if(!g_bZoneClient[client][0]) 
				{
					decl Float:fOriginPos[3];
					GetClientAbsOrigin(client, fOriginPos);
					g_Flag[0] = ModsMaster_Down;
					fOriginPos[2] += g_fFlagDownPosCaptureFlag;
					CreateFlag(fOriginPos, TEAM_CT);
					CreateTimerFlagDownTeam(true);
					Forward_OnFlagEvent(TEAM_CT, ModsMaster_Down, client);
				}
				else 
				{
					g_Flag[0] = ModsMaster_Zone;
					CreateFlag(g_fFlagPos[0], TEAM_CT);
					Forward_OnFlagEvent(TEAM_CT, ModsMaster_Zone, client);
				}
			}
			else if(g_FlagClient[1] == client) 
			{
				if(!g_bZoneClient[client][1]) 
				{
					decl Float:fOriginPos[3];
					GetClientAbsOrigin(client, fOriginPos);
					g_Flag[1] = ModsMaster_Down;
					fOriginPos[2] += g_fFlagDownPosCaptureFlag;
					CreateFlag(fOriginPos, TEAM_T);
					CreateTimerFlagDownTeam(false);
					Forward_OnFlagEvent(TEAM_T, ModsMaster_Down, client);
				}
				else 
				{
					g_Flag[1] = ModsMaster_Zone;
					CreateFlag(g_fFlagPos[1], TEAM_T);
					Forward_OnFlagEvent(TEAM_T, ModsMaster_Zone, client); 
				}
			}
		}
		else if(g_bEnabledConquest)
		{
			for(new x = 0; x < 4; x++)
			{
				if(g_FlagClient[x] == client) 
				{
					decl Float:fPos[3];
				
					if(!g_bClientInConquestZone[client][x]) 
					{
						GetClientAbsOrigin(client, fPos);
						g_Flag[1] = ModsMaster_Down;
						fPos[2] += g_fFlagDownPosConquest;
						CreateFlag(fPos, g_ConquestZoneTeam[x], _, _, x);
						CreateTimerFlagDown(x);
						Forward_OnFlagEvent(g_ConquestZoneTeam[x], ModsMaster_Down, client, _, x);
					}
					else 
					{
						GetKvZonePos(fPos, x);
						g_Flag[x] = ModsMaster_Zone;
						CreateFlag(fPos, g_ConquestZoneTeam[x], _, _, x);
						Forward_OnFlagEvent(g_ConquestZoneTeam[x], ModsMaster_Zone, client, _, x); 
					}
					
					break;
				}
			}
		}
	}
}

public Action:CS_OnTerminateRound(&Float:delay, &CSRoundEndReason:reason)  
{
	if(g_bEnabledCaptureFlag || g_bEnabledConquest) return Plugin_Handled;
	
	return Plugin_Continue;
}

public OnMapTimeLeftChanged()
{
	g_ScoreTeam[0] = 0;
	g_ScoreTeam[1] = 0;
}

public Event_RoundStart(Handle:event, const String:name[], bool:dontBroadcast)
{
	KillTimerDemoCaptureFlagViewer();
	KillTimerDemoConquestViewer();

	if(!g_bEnabledCaptureFlag && !g_bEnabledConquest) return;

	if(g_bEnabledCaptureFlag) 
	{
		LoadFlags();
		
		if(g_bRoundEnd)
		{
			if(g_bStartMapModeVote)
			{
				decl String:sMapName[64];
		
				if(GetNextMap(sMapName, 64))
				{
					if(sMapName[0]) ServerCommand("sm_map \"%s\"", sMapName);
				}
			}
		}
	}
	else if(g_bEnabledConquest) 
	{
		LoadZones();
	
		for(new x = 0; x < 4; x++)
		{
			g_CurrentProgressConquestZone[x][0] = 0;
			g_CurrentProgressConquestZone[x][1] = 0;
			
			g_bZoneFullConquest[x] = false;
			
			for(new i = 1; i <= MaxClients; i++)
				g_bClientInConquestZone[i][x] = false;
		}
	}
	
	g_bRoundEnd = false;
	
	g_CurrentRoundTime = 0;
	
	KillTimerRoundStart();
	
	KillAllTimerFlagDown();
	KillAllTimerFlagProtect();
	
	CreateTimerRoundStart();
}

public Event_RoundEnd(Handle:event, const String:name[], bool:dontBroadcast) 
{
	g_bRoundEnd = true;
	
	KillTimerRoundStart();
}