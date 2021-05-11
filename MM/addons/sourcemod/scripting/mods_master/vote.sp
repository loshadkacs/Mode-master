stock StartMapModeVote()
{
	decl players[MaxClients];
	new total;
	for(new i = 1; i <= MaxClients; ++i)
	{
		if(IsClientInGame(i) && !IsFakeClient(i)) players[total++] = i;
	}

	if(total > 0) VoteMenu(hVoteMenu, players, total, 15);
}

public SelectVoteMenu(Handle:menu, MenuAction:action, param1, param2)   
{
	switch(action)
	{
		case MenuAction_VoteEnd:
		{
			if(param1 == 0)
			{
				g_bVoteNextMapCaptureFlag = true;
				g_bVoteNextMapConquest = false;
				
				PrintToChatAll("\x04[Mods Master]\x01 На следующей карте будет установлен режим захват флага!");  
			}
			else
			{
				g_bVoteNextMapCaptureFlag = false;
				g_bVoteNextMapConquest = true;
				
				PrintToChatAll("\x04[Mods Master]\x01 На следующей карте будет установлен режим захват точек!");
			}
		
			if(!g_bNoMapVote) CreateTimerStartMapVote();
		}
		case MenuAction_VoteCancel: 
		{
			g_bVoteNextMapCaptureFlag = false;
			g_bVoteNextMapConquest = false;
			
			PrintToChatAll("\x04[Mods Master]\x01 На следующей карте будет установлен случайный режим!");
			
			if(!g_bNoMapVote) CreateTimerStartMapVote();
		}
		case MenuAction_Select:
		{
			if(param2 == 0) PrintToChatAll("\x04[Mods Master]\x01 Игрок \x04%N\x01 проголосовал за режим захват флага!", param1);
			else PrintToChatAll("\x04[Mods Master]\x01 Игрок \x04%N\x01 проголосовал за режим захват точек!", param1);
		}
	}
}