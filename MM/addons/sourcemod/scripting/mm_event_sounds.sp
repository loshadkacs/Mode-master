#pragma semicolon 1
#include <sourcemod>
#include <sdktools>
#include <mods_master> 

public Plugin:myinfo = 
{
	name = "[MM] Event Sounds",
	author = "KOROVKA", // Plugin by KOROVKA
	description = "[MM] Event Sounds",
	version = "1.0.0"
};

#define CONFIG_FILE		"addons/sourcemod/configs/mods_master/modules/event_sounds.txt"

new String:sCapturedSounds[4][128], String:sLostSounds[4][128];

public OnMapStart()
{
	new Handle:kv = CreateKeyValues("Event Sounds"); 
	
	if(!FileToKeyValues(kv, CONFIG_FILE)) SetFailState("Конфиг по адресу \"%s\" не найден!", CONFIG_FILE);
	
	if(KvJumpToKey(kv, "Conquest", false))
	{
		if(KvJumpToKey(kv, "A", false))
		{
			KvGetString(kv, "captured_sound", sCapturedSounds[0], 128, ""); 
			KvGetString(kv, "lost_sound", sLostSounds[0], 128, "");
			
			if(sCapturedSounds[0][0] && !IsSoundPrecached(sCapturedSounds[0]))
				PrecacheSound(sCapturedSounds[0]);
				
			if(sLostSounds[0][0] && !IsSoundPrecached(sLostSounds[0])) 
				PrecacheSound(sLostSounds[0]);
		}
		
		KvGoBack(kv);
		
		if(KvJumpToKey(kv, "B", false))
		{
			KvGetString(kv, "captured_sound", sCapturedSounds[1], 128, "");
			KvGetString(kv, "lost_sound", sLostSounds[1], 128, "");
			
			if(sCapturedSounds[1][0] && !IsSoundPrecached(sCapturedSounds[1]))
				PrecacheSound(sCapturedSounds[1]);
				
			if(sLostSounds[1][0] && !IsSoundPrecached(sLostSounds[1]))
				PrecacheSound(sLostSounds[1]);
		}
		
		KvGoBack(kv);
		
		if(KvJumpToKey(kv, "C", false))
		{
			KvGetString(kv, "captured_sound", sCapturedSounds[2], 128, ""); 
			KvGetString(kv, "lost_sound", sLostSounds[2], 128, "");
			
			if(sCapturedSounds[2][0] && !IsSoundPrecached(sCapturedSounds[2]))
				PrecacheSound(sCapturedSounds[2]);
				
			if(sLostSounds[2][0] && !IsSoundPrecached(sLostSounds[2]))
				PrecacheSound(sLostSounds[2]);
		}
		
		KvGoBack(kv);
		
		if(KvJumpToKey(kv, "D", false))
		{
			KvGetString(kv, "captured_sound", sCapturedSounds[3], 128, "");
			KvGetString(kv, "lost_sound", sLostSounds[3], 128, "");
			
			if(sCapturedSounds[3][0] && !IsSoundPrecached(sCapturedSounds[3])) 
				PrecacheSound(sCapturedSounds[3]);
				
			if(sLostSounds[3][0] && !IsSoundPrecached(sLostSounds[3]))
				PrecacheSound(sLostSounds[3]);
		}
	}
	
	CloseHandle(kv);
}

public MM_OnFlagEvent(team, MM_Type:event, client, disconnect, ZoneName:zone)
{
	if(!CONQUEST_EnabledThisMoment()) return;

	if(zone != Conquest_None && (event == ModsMaster_ZoneCaptured || event == ModsMaster_FullCaptured))
	{
		EmitSoundToTeam(team, sCapturedSounds[zone == Conquest_A ? 0:zone == Conquest_B ? 1:zone == Conquest_C ? 2:3]); 
		EmitSoundToTeam(team == 3 ? 2:3, sLostSounds[zone == Conquest_A ? 0:zone == Conquest_B ? 1:zone == Conquest_C ? 2:3]);
	}
}

stock EmitSoundToTeam(team, const String:sSound[])
{
	for(new i = 1; i <= MaxClients; i++)
	{
		if(IsClientInGame(i) && !IsFakeClient(i) && GetClientTeam(i) == team)
			ClientCommand(i, "play \"%s\"", sSound);
	}
}