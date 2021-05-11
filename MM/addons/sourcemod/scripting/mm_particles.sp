#pragma semicolon 1
#include <sourcemod>
#include <sdktools>
#include <mods_master> 

public Plugin:myinfo = 
{
	name = "[MM] Particles",
	author = "KOROVKA", // Plugin by KOROVKA
	description = "[MM] Particles",
	version = "1.0.0"
};

#define EFFECT_NAME_FLAG 		"vixr_final" // Имя эффекта для флага
#define EFFECT_NAME_PLAYER 		"trail2" // Имя эффекта для игрока
#define PARTICLE_FILE 			"particles/2j.pcf" // Партикль
#define PARTICLE_FLAG_POS_Z  	10.0 // Смещение партикля над флагом по оси Z  

public OnMapStart() PrecacheGeneric(PARTICLE_FILE, true);

public MM_OnFlagEvent(team, MM_Type:event, client, disconnect, ZoneName:zone)
{
	if(!CF_EnabledThisMoment()) return;

	DeleteParticle(team); 
	
	switch(event)
	{
		case ModsMaster_Spawn, ModsMaster_Zone, ModsMaster_Delivered: SpawnParticle(EFFECT_NAME_FLAG, CF_GetEntityFlag(team), team);
		case ModsMaster_Captured: SpawnParticle(EFFECT_NAME_PLAYER, client, team); 
	}
}

stock SpawnParticle(const String:sEffectName[], entity, team)
{
	decl Float:fOrigin[3];
	GetEntPropVector(entity, Prop_Send, "m_vecOrigin", fOrigin);
	
	if(entity > MaxClients) fOrigin[2] += PARTICLE_FLAG_POS_Z;
	
	new particle = CreateEntityByName("info_particle_system");
	DispatchKeyValueVector(particle, "origin", fOrigin);
	DispatchKeyValue(particle, "effect_name", sEffectName);
	DispatchKeyValue(particle, "start_active", "1");
	
	decl String:sTargetName[32];
	FormatEx(sTargetName, 32, "mods_master_%d", team);
	DispatchKeyValue(particle, "targetname", sTargetName);

	if(DispatchSpawn(particle))
	{
		ActivateEntity(particle);
	
		SetVariantString("!activator");
		AcceptEntityInput(particle, "SetParent", entity);
	
		if(entity <= MaxClients) 
		{
			SetVariantString("footmask");
			AcceptEntityInput(particle, "SetParentAttachment", entity);
		}
		
		return particle;
	}

	return -1;
}

stock DeleteParticle(team)
{
	decl String:sTargetName[32];
	FormatEx(sTargetName, 32, "mods_master_%d", team);

	new particle = FindEntityByTargetName(sTargetName, "info_particle_system");
	if(particle > MaxClients) AcceptEntityInput(particle, "Kill");
}

FindEntityByTargetName(const String:sTargetName[], const String:sClassName[])
{
	new String:buffer[32], index = -1;

	while(strcmp(buffer, sTargetName) != 0 && (index = FindEntityByClassname(index, sClassName)) != -1) 
		GetEntPropString(index, Prop_Data, "m_iName", buffer, 32);

	return index;
} 