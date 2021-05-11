public OnClientDisconnect(client)
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
				fOriginPos[2] += g_fFlagDownPosCaptureFlag+50.0;
				CreateFlag(fOriginPos, TEAM_CT);
				CreateTimerFlagDownTeam(true);
				Forward_OnFlagEvent(TEAM_CT, ModsMaster_Down, client, true);
			}
			else 
			{
				g_Flag[0] = ModsMaster_Zone;
				CreateFlag(g_fFlagPos[0], TEAM_CT);
				Forward_OnFlagEvent(TEAM_CT, ModsMaster_Zone, client, true); 
			}
		
			g_FlagClient[0] = -1;
		}
		else if(g_FlagClient[1] == client) 
		{
			if(!g_bZoneClient[client][1]) 
			{
				decl Float:fOriginPos[3];
				GetClientAbsOrigin(client, fOriginPos);
			
				g_Flag[1] = ModsMaster_Down;
				fOriginPos[2] += g_fFlagDownPosCaptureFlag+50.0;
				CreateFlag(fOriginPos, TEAM_T);
				CreateTimerFlagDownTeam(false);
				Forward_OnFlagEvent(TEAM_T, ModsMaster_Down, client, true);
			}
			else 
			{
				g_Flag[1] = ModsMaster_Zone;
				CreateFlag(g_fFlagPos[1], TEAM_T);
				Forward_OnFlagEvent(TEAM_T, ModsMaster_Zone, client, true);
			}
		
			g_FlagClient[1] = -1;
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
					Forward_OnFlagEvent(g_ConquestZoneTeam[x], ModsMaster_Down, client, true, x);
				}
				else 
				{
					GetKvZonePos(fPos, x);
					g_Flag[x] = ModsMaster_Zone;
					CreateFlag(fPos, g_ConquestZoneTeam[x], _, _, x);
					Forward_OnFlagEvent(g_ConquestZoneTeam[x], ModsMaster_Zone, client, true, x); 
				}
					
				g_FlagClient[x] = -1;
					
				break;
			}
		}
	}
	
	g_bZoneClient[client][0] = false;
	g_bZoneClient[client][1] = false;
	
	g_bAdminSayPlayersCount[client] = false;
	g_bAdminSayTime[client] = false;
	
	for(new x = 0; x < 4; x++)
	{
		g_bAdminBox[client][x] = false;
		g_bClientInConquestZone[client][x] = false;
	}
		
	g_bAdminSizeChange[client] = false;
}

public Action:Cmd_ModsMaster(client, args)
{
	if(client > 0)
	{
		if(GetUserFlagBits(client) & ADMFLAG_ROOT) DisplayTopMenuCategory(hTopMenu, mods_master, client);
		else PrintToChat(client, "\x04[Mods Master]\x01 У Вас нет доступа к этой команде!");
	}
	
	return Plugin_Handled;
}

public Action:Cmd_Say(client, args)
{
	if(client > 0)
	{
		if(g_bAdminSayPlayersCount[client])
		{
			decl String:buffer[10];
		
			GetCmdArgString(buffer, 10);
		
			StripQuotes(buffer);
			TrimString(buffer);
		
			if(buffer[0])
			{
				if(strcmp(buffer, "!cancel", false) == 0)
				{
					g_bAdminSayPlayersCount[client] = false;
					PrintToChat(client, "\x04[Mods Master]\x01 Вы отменили установку значения!");
					return Plugin_Handled;
				}
			
				new value = StringToInt(buffer);
		
				if(value > 0 && value <= 32)
				{
					g_ConquestZoneCountPlayers[StringToInt(sAdminZoneNumber[client])-1] = value;

					g_bAdminSayPlayersCount[client] = false;
					
					if(UpdateSaveZone(sAdminZoneNumber[client], _, _, _, _, value)) PrintToChat(client, "\x04[Mods Master]\x01 Значение \x04%d\x01 установлено!", value);
					else PrintToChat(client, "\x04[Mods Master]\x01 Не удалось сохранить настройки!");
					
					CreateConquestSettingsMenu(client);
				}
				else PrintToChat(client, "\x04[Mods Master]\x01 Не корректное число!");
			}
		
			return Plugin_Handled;
		}
		else if(g_bAdminSayTime[client])
		{
			decl String:buffer[10];
		
			GetCmdArgString(buffer, 10);
		
			StripQuotes(buffer);
			TrimString(buffer);
		
			if(buffer[0])
			{
				if(strcmp(buffer, "!cancel", false) == 0)
				{
					g_bAdminSayTime[client] = false;
					PrintToChat(client, "\x04[Mods Master]\x01 Вы отменили установку значения!");
					return Plugin_Handled;
				}
			
				new value = StringToInt(buffer);
		
				if(value > 0 && value <= 600)
				{
					g_ConquestZoneTime[StringToInt(sAdminZoneNumber[client])-1] = value;
				
					g_bAdminSayTime[client] = false;
					
					if(UpdateSaveZone(sAdminZoneNumber[client], _, _, _, _, _, value)) PrintToChat(client, "\x04[Mods Master]\x01 Значение \x04%d\x01 установлено!", value);
					else PrintToChat(client, "\x04[Mods Master]\x01 Не удалось сохранить настройки!");
					
					CreateConquestSettingsMenu(client);
				}
				else PrintToChat(client, "\x04[Mods Master]\x01 Не корректное число!");
			}
			
			return Plugin_Handled;
		}
	}
	
	return Plugin_Continue;
}