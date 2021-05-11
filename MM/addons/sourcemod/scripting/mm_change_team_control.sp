#pragma semicolon 1
#include <sourcemod>
#include <sdktools>
#include <mods_master> 

public Plugin:myinfo = 
{
	name = "[MM] Change Team Control",
	author = "KOROVKA", // Plugin by KOROVKA
	description = "[MM] Change Team Control",
	version = "1.0.0"
};

public OnPluginStart() AddCommandListener(Cmd_JoinTeam, "jointeam"); 

public Action:Cmd_JoinTeam(client, const String:command[], args) 
{
	if(client < 1 || !CF_EnabledThisMoment() && !CONQUEST_EnabledThisMoment()) return Plugin_Continue; 
	
	decl String:buffer[3];
	GetCmdArgString(buffer, 3);
	new team = StringToInt(buffer);

	if(team == 1)
	{
		ChangeClientTeam(client, team);
		
		return Plugin_Handled;
	}
	
	if(IsPlayerAlive(client))
	{
		PrintHintText(client, "Вы не можете сменить команду пока живы!");
		
		return Plugin_Handled;
	}
	
	if(team == TEAM_CT) RequestFrame(Frame_JoinToTeamCT, client);
	else RequestFrame(Frame_JoinToTeamT, client);
	
	return Plugin_Handled;
}

public Frame_JoinToTeamCT(client) 
{
	if(IsClientInGame(client)) ChangeClientTeam(client, TEAM_CT);
}

public Frame_JoinToTeamT(client) 
{
	if(IsClientInGame(client)) ChangeClientTeam(client, TEAM_T);
}