#pragma semicolon 1
#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <mods_master> 

public Plugin:myinfo = 
{
	name = "[MM] Regen Health",
	author = "KOROVKA", // Plugin by KOROVKA
	description = "[MM] Regen Health",
	version = "1.0.0"
};

#define RADIUS 150.0 // Радиус вокруг игрока с флагом в котором будет действовать регенерация здоровья
#define TIMER_REGEN 1.0 // Время в секундах между регенерацией здоровья
#define MAX_HP 100 // Максимальное здоровье
#define HP_REGEN 5 // Сколько хп будет добавлятся 

new Handle:hTimerRegenHealth[MAXPLAYERS+1];

public OnPluginStart()
{
	for (new i = 1; i <= MaxClients; i++)
	{
		if(IsClientInGame(i)) OnClientPutInServer(i);
	}
}

public OnClientPutInServer(client) SDKHook(client, SDKHook_SetTransmit, SetTransmit); 

public OnClientDisconnect(client) KillTimerRegenHealth(client);

public SetTransmit(target, client)
{
	if(!CF_EnabledThisMoment() || !(1 <= target <= MaxClients)) return;
	
	if(!IsPlayerAlive(target)) 
	{
		KillTimerRegenHealth(target);
		return;
	}
	
	if(!IsPlayerAlive(client))
	{
		KillTimerRegenHealth(client);
		
		decl Float:pos[3], Float:pos_target[3];
		
		GetClientAbsOrigin(client, pos);
		GetClientAbsOrigin(target, pos_target);

		if(GetDistance(pos, pos_target) <= RADIUS) KillTimerRegenHealth(target);
		
		return;
	}
	
	decl team;
	
	if(GetClientTeam(target) != (team = GetClientTeam(client))) 
	{
		KillTimerRegenHealth(target);
		return;
	}
	
	if(CF_GetClientFlagCapturedTeam(team == 2 ? TEAM_CT:TEAM_T) != client) return;
	
	decl Float:pos[3], Float:pos_target[3];
		
	GetClientAbsOrigin(client, pos);
	GetClientAbsOrigin(target, pos_target);

	if(GetDistance(pos, pos_target) <= RADIUS) 
	{
		if(!hTimerRegenHealth[target]) hTimerRegenHealth[target] = CreateTimer(TIMER_REGEN, TimerRegenHealth, target, TIMER_REPEAT);
	}
	else KillTimerRegenHealth(target);
}

public Action:TimerRegenHealth(Handle:timer, any:client) RegenHealth(client);

stock RegenHealth(client)
{
	new hp = GetClientHealth(client);
	
	if(hp < MAX_HP)
	{
		if(hp + HP_REGEN <= MAX_HP) SetEntityHealth(client, hp + HP_REGEN);
		else SetEntityHealth(client, MAX_HP);
	}
}

stock Float:GetDistance(Float:pos1[3], Float:pos2[3]) return SquareRoot(Pow(pos2[0] - pos1[0], 2.0) + Pow(pos2[1] - pos1[1], 2.0) + Pow(pos2[2] - pos1[2], 2.0));

stock KillTimerRegenHealth(client)
{
	if(hTimerRegenHealth[client] != INVALID_HANDLE)
	{
		KillTimer(hTimerRegenHealth[client]);
		hTimerRegenHealth[client] = INVALID_HANDLE;
	}
}