new Handle:hTopMenu, TopMenuObject:mods_master;
new Handle:hVoteMenu;

public OnAdminMenuReady(Handle:topmenu)
{
	if(topmenu == hTopMenu) return;

	hTopMenu = topmenu;

	mods_master = AddToTopMenu(hTopMenu, "category_mods_master", TopMenuObject_Category, AdminMenu_CategoryModsMaster, INVALID_TOPMENUOBJECT, "category_mods_master", ADMFLAG_ROOT);
		
	if(mods_master != INVALID_TOPMENUOBJECT) 
	{
		AddToTopMenu(hTopMenu, "mods_master_capture_flag", TopMenuObject_Item, AdminMenu_CaptureFlag, mods_master, "mods_master_capture_flag", ADMFLAG_ROOT);
		AddToTopMenu(hTopMenu, "mods_master_conquest", TopMenuObject_Item, AdminMenu_Conquest, mods_master, "mods_master_conquest", ADMFLAG_ROOT); 
	}
}

public AdminMenu_CategoryModsMaster(Handle:topmenu, TopMenuAction:action, TopMenuObject:object_id, client, String:buffer[], maxlength) 
{
	switch(action)
	{
		case TopMenuAction_DisplayOption: strcopy(buffer, maxlength, "Управление модами");
		case TopMenuAction_DisplayTitle: strcopy(buffer, maxlength, "Управление модами:"); 
	}
}

public AdminMenu_CaptureFlag(Handle:topmenu, TopMenuAction:action, TopMenuObject:object_id, client, String:buffer[], maxlength) 
{
	switch(action)
	{
		case TopMenuAction_DisplayOption: strcopy(buffer, maxlength, "Захват флага");
		case TopMenuAction_SelectOption: CreateCaptureFlagMenu(client);
	}
}

public AdminMenu_Conquest(Handle:topmenu, TopMenuAction:action, TopMenuObject:object_id, client, String:buffer[], maxlength) 
{
	switch(action)
	{
		case TopMenuAction_DisplayOption: strcopy(buffer, maxlength, "Захват точек");
		case TopMenuAction_SelectOption: CreateConquestMenu(client);
	}
}

CreateCaptureFlagMenu(client)
{
	new Handle:menu = CreateMenu(MenuHandler_CaptureFlag);  
	SetMenuTitle(menu, "Управление флагами:");
	
	SetMenuExitBackButton(menu, true);	
	
	AddMenuItem(menu, "", "Установить флаг КТ");	
	AddMenuItem(menu, "", "Установить флаг Т");	
	
	DisplayMenu(menu, client, MENU_TIME_FOREVER);
}

public MenuHandler_CaptureFlag(Handle:menu, MenuAction:action, param1, param2) 
{
	switch(action)
	{
		case MenuAction_Select:
		{	
			if(g_bEnabledConquest)
			{
				CreateCaptureFlagMenu(param1);
				PrintToChat(param1, "\x04[Mods Master]\x01 Действие недоступно пока запущен другой режим!");
				return;
			}
		
			decl Float:fAimPos[3];
			GetAimPos(param1, fAimPos);
		
			if(param2 == 0)
			{
				if(g_bEnabledCaptureFlag && g_EntFlag[1] == -1 || GetVectorDistance(fAimPos, g_fFlagPos[1]) >= 200.0 * g_fFlagZoneSizeCaptureFlag + 10.0)
				{
					if(SaveFlagPos(fAimPos, true)) 
					{
						CreateFlag(fAimPos, TEAM_CT, true);
						CreateZone(fAimPos, TEAM_CT);
					
						if(!g_bEnabledCaptureFlag) 
						{
							CreateFlag(g_fFlagPos[1], TEAM_T, true); 
							CreateZone(g_fFlagPos[1], TEAM_T);
						
							if(hTimerDemoCaptureFlagViewer == INVALID_HANDLE) PrintToChat(param1, "\x04[Mods Master]\x01 Режим захват флага выключен! Флаг успешно сохранен, но пропадет через 5 секунд!");
							CreateTimerDemoCaptureFlagViewer();
						}
						else 
						{
							g_Flag[0] = ModsMaster_Zone;
							Forward_OnFlagEvent(TEAM_CT, ModsMaster_Spawn);
						}
					}
					else PrintToChat(param1, "\x04[Mods Master]\x01 Не удалось сохранить флаг!");
				}
				else PrintToChat(param1, "\x04[Mods Master]\x01 Вы пытаетесь установить флаг слишком близко к флагу другой команды!");
			}
			else
			{
				if(g_bEnabledCaptureFlag && g_EntFlag[0] == -1 || GetVectorDistance(fAimPos, g_fFlagPos[0]) >= 200.0 * g_fFlagZoneSizeCaptureFlag + 10.0)
				{
					if(SaveFlagPos(fAimPos, false)) 
					{
						CreateFlag(fAimPos, TEAM_T, true);
						CreateZone(fAimPos, TEAM_T);
					
						if(!g_bEnabledCaptureFlag) 
						{
							CreateFlag(g_fFlagPos[0], TEAM_CT, true);
							CreateZone(g_fFlagPos[0], TEAM_CT);
						
							if(hTimerDemoCaptureFlagViewer == INVALID_HANDLE) PrintToChat(param1, "\x04[Mods Master]\x01 Режим захват флага выключен! Флаг успешно сохранен, но пропадет через 5 секунд!");
							CreateTimerDemoCaptureFlagViewer();
						}
						else 
						{
							g_Flag[1] = ModsMaster_Zone;
							Forward_OnFlagEvent(TEAM_T, ModsMaster_Spawn);
						}
					}
					else PrintToChat(param1, "\x04[Mods Master]\x01 Не удалось сохранить флаг!");
				}
				else PrintToChat(param1, "\x04[Mods Master]\x01 Вы пытаетесь установить флаг слишком близко к флагу другой команды!");
			}
		
			CreateCaptureFlagMenu(param1);
		}
		case MenuAction_End: CloseHandle(menu); 
		case MenuAction_Cancel: if(param2 == MenuCancel_ExitBack) DisplayTopMenu(hTopMenu, param1, TopMenuPosition_LastCategory);
	}
}

CreateConquestMenu(client)
{
	g_bAdminSayPlayersCount[client] = false;
	g_bAdminSayTime[client] = false;

	new Handle:menu = CreateMenu(MenuHandler_Conquest);  
	SetMenuTitle(menu, "Управление точками:");
	
	SetMenuExitBackButton(menu, true);	
	
	AddMenuItem(menu, "", "Создать", GetKvMaxZonesSave() ? ITEMDRAW_DISABLED:ITEMDRAW_DEFAULT);
	
	if(KvRewind(kv_zs) && KvJumpToKey(kv_zs, sMap, false))
	{
		new bool:bSectionExists = KvGotoFirstSubKey(kv_zs);
	
		if(bSectionExists)
		{
			new count;
	
			while(bSectionExists)
			{
				count++;
			
				switch(count)
				{
					case 1: AddMenuItem(menu, "1", "Точка A");
					case 2: AddMenuItem(menu, "2", "Точка B");
					case 3: AddMenuItem(menu, "3", "Точка C");
					case 4: AddMenuItem(menu, "4", "Точка D");
				}
	
				bSectionExists = KvGotoNextKey(kv_zs);
			}
		}
	}
	
	DisplayMenu(menu, client, MENU_TIME_FOREVER);
}

public MenuHandler_Conquest(Handle:menu, MenuAction:action, param1, param2) 
{
	switch(action)
	{
		case MenuAction_Select:
		{	
			if(g_bEnabledCaptureFlag)
			{
				CreateConquestMenu(param1);
				PrintToChat(param1, "\x04[Mods Master]\x01 Действие недоступно пока запущен другой режим!");
				return;
			}
		
			if(param2 == 0)
			{
				if(!GetKvMaxZonesSave())
				{
					decl Float:fAimPos[3];
					GetAimPos(param1, fAimPos); 
			
					new zone_number = GetKvZoneSaveNewSection(sAdminZoneNumber[param1]);

					if(zone_number != -1)
					{
						g_fFlagZoneSizeConquest[zone_number-1] = 1.0;
						g_fFlagZoneHeightConquest[zone_number-1] = 150.0;
						
						g_ConquestZoneTeam[zone_number-1] = 0;
						g_ConquestZoneCountPlayers[zone_number-1] = 1;
						g_ConquestZoneTime[zone_number-1] = 30;
						g_bConquestFlagMovable[zone_number-1] = false;
						
						if(CheckStuckZone(fAimPos, zone_number-1))
						{
							if(SaveZone(fAimPos, sAdminZoneNumber[param1])) 
							{
								if(g_bEnabledConquest)
								{
									CreateFlag(fAimPos, TEAM_NEUTRAL, true, _, zone_number-1);
									CreateZone(fAimPos, TEAM_NEUTRAL, zone_number-1);
									CreateSprite(fAimPos, TEAM_NEUTRAL, zone_number-1);
									
									g_Flag[zone_number-1] = ModsMaster_Zone;
									Forward_OnFlagEvent(TEAM_NEUTRAL, ModsMaster_Spawn, _, _, zone_number-1);
								}
								else
								{
									LoadZones();
								
									if(hTimerDemoConquestViewer == INVALID_HANDLE) PrintToChat(param1, "\x04[Mods Master]\x01 Режим захват точек выключен! Зона успешно сохранена, но пропадет через 10 секунд!");
									CreateTimerDemoConquestViewer();
								}

								CreateConquestSettingsMenu(param1);
								return;
							}
							else PrintToChat(param1, "\x04[Mods Master]\x01 Не удалось сохранить точку!");
						}
						else PrintToChat(param1, "\x04[Mods Master]\x01 Вы пытаетесь создать точку захвата слишком близко к другой точке!");
					}
				}
			}
			else 
			{
				GetMenuItem(menu, param2, sAdminZoneNumber[param1], 3);
			
				CreateConquestSettingsMenu(param1);
				return;
			}
			
			CreateConquestMenu(param1);
		}
		case MenuAction_End: CloseHandle(menu); 
		case MenuAction_Cancel: if(param2 == MenuCancel_ExitBack) DisplayTopMenu(hTopMenu, param1, TopMenuPosition_LastCategory);
	}
}

CreateConquestSettingsMenu(client)
{
	new Handle:menu = CreateMenu(MenuHandler_ConquestSettings);  
	
	new zone_number = StringToInt(sAdminZoneNumber[client]);
	
	switch(zone_number)
	{
		case 1: SetMenuTitle(menu, "Настройки точки [A]:");
		case 2: SetMenuTitle(menu, "Настройки точки [B]:");
		case 3: SetMenuTitle(menu, "Настройки точки [C]:");
		case 4: SetMenuTitle(menu, "Настройки точки [D]:");
	}
	
	zone_number--;
	
	SetMenuExitBackButton(menu, true);	
	
	decl String:buffer[80];
	
	FormatEx(buffer, 80, "Принадлежит команде: [%s]", g_ConquestZoneTeam[zone_number] == 3 ? "Контер-Террористов":g_ConquestZoneTeam[zone_number] == 2 ? "Террористов":"Нейтральная");

	AddMenuItem(menu, "", buffer);
	
	if(g_ConquestZoneCountPlayers[zone_number] == 1) FormatEx(buffer, 80, "Необходимое количество игроков: [Любое]");
	else FormatEx(buffer, 80, "Необходимое количество игроков: [%d]", g_ConquestZoneCountPlayers[zone_number]);

	AddMenuItem(menu, "", buffer);
	
	FormatEx(buffer, 80, "Время захвата: [%d]", g_ConquestZoneTime[zone_number]);

	AddMenuItem(menu, "", buffer);
	
	FormatEx(buffer, 80, "Переносной флаг: [%s]", g_bConquestFlagMovable[zone_number] ? "Включено":"Выключено");

	AddMenuItem(menu, "", buffer);
	
	AddMenuItem(menu, "", "Настройки размера");
	
	AddMenuItem(menu, "", "Переместить зону");
	
	AddMenuItem(menu, "", "Удалить");	
	
	DisplayMenu(menu, client, MENU_TIME_FOREVER);
}

public MenuHandler_ConquestSettings(Handle:menu, MenuAction:action, param1, param2) 
{
	switch(action)
	{
		case MenuAction_Select:
		{	
			new zone_number = StringToInt(sAdminZoneNumber[param1])-1;
		
			if(param2 == 0)
			{
				if(g_ConquestZoneTeam[zone_number] == 0) 
				{
					g_ConquestZoneTeam[zone_number] = 3;
					
					if(g_FlagColorTeamConquest == 1 && g_EntFlag[zone_number] > 0 && IsValidEntity(g_EntFlag[zone_number])) SetEntityRenderColor(g_EntFlag[zone_number], 0, 0, 255, 0);
				}
				else if(g_ConquestZoneTeam[zone_number] == 3) 
				{
					g_ConquestZoneTeam[zone_number] = 2;
					
					if(g_FlagColorTeamConquest == 1 && g_EntFlag[zone_number] > 0 && IsValidEntity(g_EntFlag[zone_number])) SetEntityRenderColor(g_EntFlag[zone_number], 255, 0, 0, 0);
				}
				else 
				{
					g_ConquestZoneTeam[zone_number] = 0;
					
					if(g_FlagColorTeamConquest == 1 && g_EntFlag[zone_number] > 0 && IsValidEntity(g_EntFlag[zone_number])) SetEntityRenderColor(g_EntFlag[zone_number], 255, 255, 255, 0);
				}
				
				if(UpdateSaveZone(sAdminZoneNumber[param1], _, _, _, g_ConquestZoneTeam[zone_number]))
				{
					if(g_bEnabledConquest || hTimerDemoConquestViewer)
					{
						decl Float:fPos[3];
				
						GetKvZonePos(fPos, zone_number);
				
						CreateSprite(fPos, g_ConquestZoneTeam[zone_number], zone_number);
					}
				}
				else PrintToChat(param1, "\x04[Mods Master]\x01 Не удалось сохранить настройки!");
			}
			else if(param2 == 1)
			{
				g_bAdminSayPlayersCount[param1] = true;
				g_bAdminSayTime[param1] = false;
				
				PrintToChat(param1, "\x04[Mods Master]\x01 Напишите значение в чат! Для отмены используйте \x04!cancel");
			}
			else if(param2 == 2)
			{
				g_bAdminSayPlayersCount[param1] = false;
				g_bAdminSayTime[param1] = true;
				
				PrintToChat(param1, "\x04[Mods Master]\x01 Напишите значение в чат! Для отмены используйте \x04!cancel");
			}
			else if(param2 == 3) 
			{
				g_bConquestFlagMovable[zone_number] = !g_bConquestFlagMovable[zone_number];
				
				if(!UpdateSaveZone(sAdminZoneNumber[param1], _, _, _, _, _, _, g_bConquestFlagMovable[zone_number] ? 1:0))
					PrintToChat(param1, "\x04[Mods Master]\x01 Не удалось сохранить настройки!");
			}
			else if(param2 == 4) 
			{
				if(!g_bEnabledConquest)
				{
					LoadZones();
								
					PrintToChat(param1, "\x04[Mods Master]\x01 Режим захват точек выключен! Редактор размера зоны открыт, но отключится через 60 секунд!");
					CreateTimerDemoConquestViewer(60.0);
				}
			
				g_bAdminBox[param1][zone_number] = true;
				CreateConquestSizeSettingsMenu(param1);
				return;
			}
			else if(param2 == 5)
			{
				decl Float:fAimPos[3];
				GetAimPos(param1, fAimPos);
				
				if(CheckStuckZone(fAimPos, zone_number))
				{
					if(UpdateSaveZone(sAdminZoneNumber[param1], fAimPos))
					{
						if(g_bEnabledConquest)
						{
							CreateFlag(fAimPos, g_ConquestZoneTeam[zone_number], true, _, zone_number);
							CreateZone(fAimPos, g_ConquestZoneTeam[zone_number], zone_number);
							CreateSprite(fAimPos, g_ConquestZoneTeam[zone_number], zone_number);
							
							g_Flag[zone_number] = ModsMaster_Zone;
							Forward_OnFlagEvent(g_ConquestZoneTeam[zone_number], ModsMaster_Spawn, _, _, zone_number);
						}
						else
						{
							LoadZones();
								
							if(hTimerDemoConquestViewer == INVALID_HANDLE) PrintToChat(param1, "\x04[Mods Master]\x01 Режим захват точек выключен! Зона успешно сохранена, но пропадет через 10 секунд!");
							CreateTimerDemoConquestViewer();
						}
					}
					else PrintToChat(param1, "\x04[Mods Master]\x01 Не удалось сохранить позицию точки!");
				}
				else PrintToChat(param1, "\x04[Mods Master]\x01 Вы пытаетесь переместить точку захвата слишком близко к другой точке!");
			}
			else
			{
				if(DeleteKvZone(sAdminZoneNumber[param1])) 
				{
					RemoveZoneFlag(zone_number);
					RemoveZonePedestal(zone_number);
					RemoveZoneOfZoneEntity(zone_number);
					RemoveZoneSprite(zone_number);
					
					for(new x = zone_number; x < 3; x++)
					{
						g_fFlagZoneSizeConquest[x] = g_fFlagZoneSizeConquest[x+1];
						g_fFlagZoneHeightConquest[x] = g_fFlagZoneHeightConquest[x+1];
						
						g_ConquestZoneTeam[x] = g_ConquestZoneTeam[x+1];
						g_ConquestZoneCountPlayers[x] = g_ConquestZoneCountPlayers[x+1];
						g_ConquestZoneTime[x] = g_ConquestZoneTime[x+1];
						g_bConquestFlagMovable[x] = g_bConquestFlagMovable[x+1];

						g_Flag[x] = g_Flag[x+1];
						g_Flag[x+1] = ModsMaster_None;
					
						g_EntFlag[x] = g_EntFlag[x+1];
						g_EntFlag[x+1] = -1;
							
						g_EntPedestal[x] = g_EntPedestal[x+1];
						g_EntPedestal[x+1] = -1;
							
						g_EntZone[x] = g_EntZone[x+1];
						g_EntZone[x+1] = -1;
						
						g_CurrentProgressConquestZone[x][0] = g_CurrentProgressConquestZone[x+1][0];
						g_CurrentProgressConquestZone[x][1] = g_CurrentProgressConquestZone[x+1][1];
						
						g_CurrentProgressConquestZone[x+1][0] = 0;
						g_CurrentProgressConquestZone[x+1][1] = 0;
						
						for(new i = 1; i <= MaxClients; i++)
						{	
							if(IsClientInGame(i))
							{
								g_bClientInConquestZone[i][x] = g_bClientInConquestZone[i][x+1];
								g_bClientInConquestZone[i][x+1] = false;
							}
						}
					}
					
					CreateConquestMenu(param1);
					
					return;
				}
				else PrintToChat(param1, "\x04[Mods Master]\x01 Не удалось удалить точку!");
			}

			CreateConquestSettingsMenu(param1);
		}
		case MenuAction_End: CloseHandle(menu); 
		case MenuAction_Cancel: if(param2 == MenuCancel_ExitBack) CreateConquestMenu(param1);
	}
}

CreateConquestSizeSettingsMenu(client)
{
	if(!g_bEnabledConquest && hTimerDemoConquestViewer == INVALID_HANDLE)
	{
		LoadZones();
								
		PrintToChat(client, "\x04[Mods Master]\x01 Режим захват точек выключен! Редактор размера зоны открыт, но отключится через 60 секунд!");
		CreateTimerDemoConquestViewer(60.0);
	}

	g_bAdminSayPlayersCount[client] = false;
	g_bAdminSayTime[client] = false;

	new Handle:menu = CreateMenu(MenuHandler_ConquestSizeSettings); 

	new zone_number = StringToInt(sAdminZoneNumber[client]);
	
	switch(zone_number)
	{
		case 1: SetMenuTitle(menu, "Настройки размера точки [A]:");
		case 2: SetMenuTitle(menu, "Настройки размера точки [B]:");
		case 3: SetMenuTitle(menu, "Настройки размера точки [C]:");
		case 4: SetMenuTitle(menu, "Настройки размера точки [D]:");
	}
	
	zone_number--;
	
	SetMenuExitBackButton(menu, true);	
	
	decl String:buffer[80];
	
	FormatEx(buffer, 80, "Режим изменения: [%s]", g_bAdminSizeChange[client] ? "Увеличение":"Уменьшение");

	AddMenuItem(menu, "", buffer);
	
	AddMenuItem(menu, "", "Высота");
	
	AddMenuItem(menu, "", "Ширина");
	
	DisplayMenu(menu, client, MENU_TIME_FOREVER);
}

public MenuHandler_ConquestSizeSettings(Handle:menu, MenuAction:action, param1, param2) 
{
	switch(action)
	{
		case MenuAction_Select:
		{	
			if(param2 == 0) g_bAdminSizeChange[param1] = !g_bAdminSizeChange[param1];
			else if(param2 == 1)
			{
				new zone_number = StringToInt(sAdminZoneNumber[param1])-1;
			
				if(g_bAdminSizeChange[param1])  
				{
					g_fFlagZoneHeightConquest[zone_number] += 10.0;
					
					if(g_fFlagZoneHeightConquest[zone_number] > 1000.0) g_fFlagZoneHeightConquest[zone_number] = 1000.0;
				}
				else 
				{
					g_fFlagZoneHeightConquest[zone_number] -= 10.0;
					
					if(g_fFlagZoneHeightConquest[zone_number] < 25.0) g_fFlagZoneHeightConquest[zone_number] = 25.0;
				}
				
				if(UpdateSaveZone(sAdminZoneNumber[param1], _, _, g_fFlagZoneHeightConquest[zone_number]))
				{
					if(KvRewind(kv_zs) && KvJumpToKey(kv_zs, sMap, false) && KvJumpToKey(kv_zs, sAdminZoneNumber[param1], false))
					{
						decl Float:fPos[3];
					
						KvGetVector(kv_zs, "pos", fPos);

						CreateZone(fPos, g_ConquestZoneTeam[zone_number], zone_number);
					}
				}
				else PrintToChat(param1, "\x04[Mods Master]\x01 Не удалось сохранить размер точки!");
			}
			else
			{
				new zone_number = StringToInt(sAdminZoneNumber[param1])-1;
			
				if(g_bAdminSizeChange[param1]) 
				{
					g_fFlagZoneSizeConquest[zone_number] += 0.1;
					
					if(g_fFlagZoneSizeConquest[zone_number] > 10.0) g_fFlagZoneSizeConquest[zone_number] = 10.0;
				}
				else 
				{
					g_fFlagZoneSizeConquest[zone_number] -= 0.1;
					
					if(g_fFlagZoneSizeConquest[zone_number] < 0.5) g_fFlagZoneSizeConquest[zone_number] = 0.5;
				}

				if(UpdateSaveZone(sAdminZoneNumber[param1], _, g_fFlagZoneSizeConquest[zone_number])) 
				{
					if(KvRewind(kv_zs) && KvJumpToKey(kv_zs, sMap, false) && KvJumpToKey(kv_zs, sAdminZoneNumber[param1], false))
					{
						decl Float:fPos[3];
					
						KvGetVector(kv_zs, "pos", fPos);

						CreateZone(fPos, g_ConquestZoneTeam[zone_number], zone_number);
					}
				}
				else PrintToChat(param1, "\x04[Mods Master]\x01 Не удалось сохранить размер точки!");
			}
			
			CreateConquestSizeSettingsMenu(param1);
		}
		case MenuAction_End: CloseHandle(menu); 
		case MenuAction_Cancel: 
		{
			if(param2 == MenuCancel_ExitBack) CreateConquestSettingsMenu(param1);
			
			for(new x = 0; x < 4; x++)
				g_bAdminBox[param1][x] = false;
				
			if(hTimerDemoConquestViewer != INVALID_HANDLE)
			{	
				KillTimerDemoConquestViewer();
				TimerDemoConquestViewer(INVALID_HANDLE); 
			}	
		}
	}
}

stock CreateVoteMenu()
{
	SetMenuTitle(hVoteMenu = CreateMenu(SelectVoteMenu, MenuAction_Select), "С каким режимом будет запущена следующая карта?\n");
	AddMenuItem(hVoteMenu, "", "Захват флага");
	AddMenuItem(hVoteMenu, "", "Захват точек");
	SetMenuExitButton(hVoteMenu, false);
}