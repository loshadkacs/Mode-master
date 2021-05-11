#pragma semicolon 1
#include <sourcemod>
#include <adminmenu>
#include <sdktools>
#include <sdkhooks>
#include <cstrike>
#include <mapchooser>
#include <mods_master>

public Plugin:myinfo = 
{
	name = "Mods Master Core",
	author = "KOROVKA", // Plugin by KOROVKA 
	description = "Mods Master Core",
	version = "2.0.0"
};

#define UPDATE_BOX 1.0

new const ZoneColorCT[4] = {0, 0, 255, 255}, ZoneColorT[4] = {255, 0, 0, 255}, ZoneColorNeutral[4] = {255, 255, 255, 255}; 

new String:sMap[64];

new String:sAdminZoneNumber[MAXPLAYERS+1][3], bool:g_bAdminSayPlayersCount[MAXPLAYERS+1], bool:g_bAdminSayTime[MAXPLAYERS+1], bool:g_bAdminBox[MAXPLAYERS+1][4], bool:g_bAdminSizeChange[MAXPLAYERS+1];

new bool:g_bZoneClient[MAXPLAYERS+1][2]; 

new g_FlagColorTeamCaptureFlag;
new String:sFlagAnimIdleCaptureFlag[2][32], Float:g_fFlagAnimSpeedCaptureFlag[2];
new String:sModelFlagCaptureFlag[2][128];
new String:sModelPedestalCaptureFlag[2][128];
new Float:g_fPedestalPosCaptureFlag[2][3];
new Float:g_fFlagZoneSizeCaptureFlag, Float:g_fFlagDownPosCaptureFlag, g_FlagDownTimeCaptureFlag, g_FlagProtectTimeCaptureFlag, g_FlagGlowCaptureFlag, g_FlagCapturedGlowCaptureFlag;

new g_FlagColorTeamConquest;
new String:sFlagAnimIdleConquest[3][32], Float:g_fFlagAnimSpeedConquest[3];
new String:sModelFlagConquest[3][128];
new String:sModelPedestalConquest[3][128];
new String:sSpriteZoneConquest[4][3][128];
new Float:g_fPedestalPosConquest[3][3];
new Float:g_fFlagDownPosConquest, g_FlagDownTimeConquest, g_FlagProtectTimeConquest;

new g_VoteNoCurrentMap, Float:g_fVoteModeTime, Float:g_fVoteMapTime;
new g_RoundTimeCaptureFlag, Float:g_fRoundEndTimeCaptureFlag;
new g_RoundTimeConquest, Float:g_fRoundEndTimeConquest, Float:g_fSpriteZonePosConquest, String:sSpriteZoneScaleConquest[5];

new Float:g_fFlagZoneSizeConquest[4], Float:g_fFlagZoneHeightConquest[4], g_ConquestZoneTeam[4], g_ConquestZoneCountPlayers[4], g_ConquestZoneTime[4], bool:g_bConquestFlagMovable[4];

new Float:g_fFlagPos[2][3], Float:g_fFlagAngles[3];
new g_EntFlag[4] = {-1, ...}, g_EntPedestal[4] = {-1, ...}, g_EntZone[4] = {-1, ...}, g_EntFlagGlow[2] = {-1, -1}, g_EntSprite[4] = {-1, ...};
new g_FlagClient[4] = {-1, ...};
new MM_Type:g_Flag[4];
new bool:g_bClientInConquestZone[MAXPLAYERS+1][4], g_CurrentProgressConquestZone[4][2];
new bool:g_bZoneFullConquest[4];

new g_CurrentFlagDownTime[4], g_CurrentFlagProtectTime[4];

new bool:g_bRoundEnd, g_CurrentRoundTime;

new bool:g_bVoteNextMapCaptureFlag, bool:g_bVoteNextMapConquest, g_VoteTimerCount, bool:g_bStartMapModeVote, bool:g_bNoMapVote;

new g_ScoreTeam[2];

new g_BeamSprite, g_HaloSprite;

new bool:g_bEnabledCaptureFlag, bool:g_bEnabledConquest;

new Handle:kv_zs;

new Handle:g_hMM_OnZoneStartTouch, Handle:g_hMM_OnZoneEndTouch;
new Handle:g_hMM_OnFlagDownTime, Handle:g_hMM_OnFlagProtectTime, Handle:g_hMM_OnRoundTime;
new Handle:g_hMM_OnFlagEvent;

new Handle:g_hMM_OnStartMapModeVote, Handle:g_hMM_OnStartMapVote;

new Handle:g_hCF_OnMapStart, Handle:g_hCONQUEST_OnMapStart;

new Handle:g_hCF_OnStartGame, Handle:g_hCONQUEST_OnStartGame, Handle:g_hCF_OnEndGame, Handle:g_hCONQUEST_OnEndGame;

#include "mods_master/function.sp"
#include "mods_master/timer.sp"
#include "mods_master/config.sp"
#include "mods_master/menu.sp"
#include "mods_master/vote.sp"
#include "mods_master/hook.sp"
#include "mods_master/player.sp"
#include "mods_master/cvar.sp"
#include "mods_master/api.sp"
#include "mods_master/download.sp"

public OnPluginStart()
{
	new Handle:topmenu;
	if(LibraryExists("adminmenu") && ((topmenu = GetAdminTopMenu()) != INVALID_HANDLE)) OnAdminMenuReady(topmenu);

	CreateVoteMenu();
	
	HookEvent("round_start", Event_RoundStart, EventHookMode_PostNoCopy);
	HookEvent("round_end", Event_RoundEnd, EventHookMode_PostNoCopy);
	HookEvent("player_death", Event_PlayerDeath);
	
	RegConsoleCmd("mm", Cmd_ModsMaster);
	RegConsoleCmd("modsmaster", Cmd_ModsMaster);
	
	RegConsoleCmd("say", Cmd_Say);
	RegConsoleCmd("say_team", Cmd_Say);
	
	LoadConVars();
	
	g_hMM_OnZoneStartTouch = CreateGlobalForward("MM_OnZoneStartTouch", ET_Ignore, Param_Cell, Param_Cell, Param_Cell); 
	g_hMM_OnZoneEndTouch = CreateGlobalForward("MM_OnZoneEndTouch", ET_Ignore, Param_Cell, Param_Cell, Param_Cell);
	g_hMM_OnFlagEvent = CreateGlobalForward("MM_OnFlagEvent", ET_Ignore, Param_Cell, Param_Cell, Param_Cell, Param_Cell, Param_Cell);
	g_hMM_OnFlagDownTime = CreateGlobalForward("MM_OnFlagDownTime", ET_Ignore, Param_Cell, Param_Cell);
	g_hMM_OnFlagProtectTime = CreateGlobalForward("MM_OnFlagProtectTime", ET_Ignore, Param_Cell, Param_Cell);
	g_hMM_OnRoundTime = CreateGlobalForward("MM_OnRoundTime", ET_Ignore, Param_Cell);
	
	g_hMM_OnStartMapModeVote = CreateGlobalForward("MM_OnStartMapModeVote", ET_Ignore);
	g_hMM_OnStartMapVote = CreateGlobalForward("MM_OnStartMapVote", ET_Ignore);
	
	g_hCF_OnMapStart = CreateGlobalForward("CF_OnMapStart", ET_Ignore);
	g_hCONQUEST_OnMapStart = CreateGlobalForward("CONQUEST_OnMapStart", ET_Ignore);
	
	g_hCF_OnStartGame = CreateGlobalForward("CF_OnStartGame", ET_Ignore);
	g_hCONQUEST_OnStartGame = CreateGlobalForward("CONQUEST_OnStartGame", ET_Ignore);
	g_hCF_OnEndGame = CreateGlobalForward("CF_OnEndGame", ET_Ignore);
	g_hCONQUEST_OnEndGame = CreateGlobalForward("CONQUEST_OnEndGame", ET_Ignore);
	
	CreateTimer(1.0, TimerProgressConquestZone, _, TIMER_REPEAT);
	CreateTimer(0.15, TimerUpdateScore, _, TIMER_REPEAT);
}

public OnPluginEnd()
{
	RemoveFromTopMenu(hTopMenu, mods_master);
	
	KillAllEntity();
	
	if(!g_bEnabledCaptureFlag && !g_bEnabledConquest) return;
	
	ServerCommand("mp_restartgame 1"); 
}

public OnMapStart()
{
	g_BeamSprite = PrecacheModel("sprites/laserbeam.vmt");
	g_HaloSprite = PrecacheModel("materials/sprites/halo.vmt");

	LoadDownloadFiles();
	
	GetCurrentMap(sMap, 64);

	g_bRoundEnd = false;
	
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
	
	g_EntFlagGlow[0] = -1;
	g_EntFlagGlow[1] = -1;
	
	g_EntSprite[0] = -1;
	g_EntSprite[1] = -1;
	g_EntSprite[2] = -1;
	g_EntSprite[3] = -1;
	
	g_FlagClient[0] = -1;
	g_FlagClient[1] = -1;
	g_FlagClient[2] = -1;
	g_FlagClient[3] = -1;
	
	g_VoteTimerCount = 0;
	
	g_ScoreTeam[0] = 0;
	g_ScoreTeam[1] = 0;
	
	hTimerFlagDown[0] = INVALID_HANDLE;
	hTimerFlagDown[1] = INVALID_HANDLE;
	hTimerFlagDown[2] = INVALID_HANDLE;
	hTimerFlagDown[3] = INVALID_HANDLE;
	
	hTimerFlagProtect[0] = INVALID_HANDLE;
	hTimerFlagProtect[1] = INVALID_HANDLE;
	hTimerFlagProtect[2] = INVALID_HANDLE;
	hTimerFlagProtect[3] = INVALID_HANDLE;
	
	hTimerDemoCaptureFlagViewer = INVALID_HANDLE;
	hTimerDemoConquestViewer = INVALID_HANDLE;
	
	hTimerUpdateBoxAll = INVALID_HANDLE;
	
	hTimerRoundStart = INVALID_HANDLE;
	
	g_Flag[0] = ModsMaster_None;
	g_Flag[1] = ModsMaster_None;
	g_Flag[2] = ModsMaster_None;
	g_Flag[3] = ModsMaster_None;
	
	if(g_bStartMapModeVote && g_bVoteNextMapCaptureFlag) 
	{
		g_bEnabledCaptureFlag = true;
		CreateTimerRoundStart();
		Forward_OnMapStart();
	}
	else g_bEnabledCaptureFlag = false;
	
	if(g_bStartMapModeVote && g_bVoteNextMapConquest)
	{
		g_bEnabledConquest = true;
		CreateTimerRoundStart();
		Forward_OnMapStart();
	}
	else g_bEnabledConquest = false;
	
	g_bStartMapModeVote = false;
	g_bVoteNextMapCaptureFlag = false;
	g_bVoteNextMapConquest = false;
	g_bNoMapVote = false;
	
	g_fFlagAngles[1] = GetRandomFloat(0.0, 360.0);
	
	LoadConfig();
}