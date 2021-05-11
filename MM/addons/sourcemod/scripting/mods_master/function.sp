stock CreateFlag(Float:fPos[3] = {0.0, 0.0, 0.0}, team, bool:bPedestal = false, client = -1, zone_number = -1)
{
	if(zone_number == -1)
	{
		RemoveTeamFlag(team);
	
		if(team == 3 && !sModelFlagCaptureFlag[0][0] || team == 2 && !sModelFlagCaptureFlag[1][0]) return -1;
	
		new entity = CreateEntityByName("prop_dynamic");
		SetEntityModel(entity, team == 3 ? sModelFlagCaptureFlag[0] : sModelFlagCaptureFlag[1]);
	
		//SetEntProp(entity, Prop_Send, "m_clrRender", -1); 
	
		SetEntPropString(entity, Prop_Data, "m_iName", "mods_master");
	
		if(DispatchSpawn(entity))
		{
			if(team == 3) 
			{
				g_EntFlag[0] = entity;
				g_FlagClient[0] = client;

				if(g_FlagColorTeamCaptureFlag == 1)
				{
					SetEntityRenderMode(entity, RENDER_NORMAL);
					SetEntityRenderColor(entity, 0, 0, 255, 0);
				}
			
				if(sFlagAnimIdleCaptureFlag[0][0])
				{
					SetVariantString(sFlagAnimIdleCaptureFlag[0]);
					AcceptEntityInput(entity, "SetAnimation");
					AcceptEntityInput(entity, "TurnOn");
				}
			
				SetEntPropFloat(entity, Prop_Send, "m_flPlaybackRate", g_fFlagAnimSpeedCaptureFlag[0]);
			}
			else
			{
				g_EntFlag[1] = entity;
				g_FlagClient[1] = client;
			
				if(g_FlagColorTeamCaptureFlag == 1)
				{
					SetEntityRenderMode(entity, RENDER_NORMAL);
					SetEntityRenderColor(entity, 255, 0, 0, 0);
				}

				if(sFlagAnimIdleCaptureFlag[1][0])
				{
					SetVariantString(sFlagAnimIdleCaptureFlag[1]);
					AcceptEntityInput(entity, "SetAnimation");
					AcceptEntityInput(entity, "TurnOn");
				}
			
				SetEntPropFloat(entity, Prop_Send, "m_flPlaybackRate", g_fFlagAnimSpeedCaptureFlag[1]);
			}

			SetEntPropVector(entity, Prop_Send, "m_vecMins", Float:{-15.0, -15.0, 0.0});
			SetEntPropVector(entity, Prop_Send, "m_vecMaxs", Float:{15.0, 15.0, 100.0});

			SetEntProp(entity, Prop_Send, "m_usSolidFlags", 12);
			SetEntProp(entity, Prop_Data, "m_nSolidType", 2);
		
			if(client != -1)
			{
				decl Float:fOriginPos[3], Float:fAngles[3], Float:fDirection[3];
			
				GetClientAbsOrigin(client, fOriginPos);
				GetClientAbsAngles(client, fAngles);

				GetAngleVectors(fAngles, fDirection, NULL_VECTOR, NULL_VECTOR);
		
				fOriginPos[0] += fDirection[0] * -10.0;
				fOriginPos[1] += fDirection[1] * -10.0;
			
				TeleportEntity(entity, fOriginPos, NULL_VECTOR, NULL_VECTOR);
			
				SetVariantString("!activator");
				AcceptEntityInput(entity, "SetParent", client);
			
				if(g_FlagGlowCaptureFlag > 0 && g_FlagCapturedGlowCaptureFlag == 1) SetFlagGlow(entity, team);
			}
			else
			{
				TeleportEntity(entity, fPos, g_fFlagAngles, NULL_VECTOR);
		
				SDKHook(entity, SDKHook_StartTouch, OnStartTouch_Flag);
			
				if(g_FlagGlowCaptureFlag > 0) SetFlagGlow(entity, team);
	
				if(bPedestal && (team == 3 && sModelPedestalCaptureFlag[0][0] || team == 2 && sModelPedestalCaptureFlag[1][0]))
				{
					RemoveTeamPedestal(team);
		
					new entity2 = CreateEntityByName("prop_dynamic"); 
					SetEntityModel(entity2, team == 3 ? sModelPedestalCaptureFlag[0] : sModelPedestalCaptureFlag[1]);
			
					SetEntPropString(entity2, Prop_Data, "m_iName", "mods_master");
			
					SetEntProp(entity2, Prop_Send, "m_usSolidFlags", 12);
					SetEntProp(entity2, Prop_Data, "m_nSolidType", 6);
		
					decl Float:fPos2[3];
		
					if(team == 3)
					{
						fPos2[0] += g_fPedestalPosCaptureFlag[0][0] + fPos[0];
						fPos2[1] += g_fPedestalPosCaptureFlag[0][1] + fPos[1];
						fPos2[2] += g_fPedestalPosCaptureFlag[0][2] + fPos[2];
					
						g_EntPedestal[0] = entity2;
					}
					else
					{
						fPos2[0] += g_fPedestalPosCaptureFlag[1][0] + fPos[0];
						fPos2[1] += g_fPedestalPosCaptureFlag[1][1] + fPos[1];
						fPos2[2] += g_fPedestalPosCaptureFlag[1][2] + fPos[2];
					
						g_EntPedestal[1] = entity2;
					}
			
					TeleportEntity(entity2, fPos2, NULL_VECTOR, NULL_VECTOR);  	
				}	
			}
			
			return entity;
		}
	}
	else
	{
		RemoveZoneFlag(zone_number);
	
		if(team == 3 && !sModelFlagConquest[0][0] || team == 2 && !sModelFlagConquest[1][0] || !team && !sModelFlagConquest[2][0]) return -1;
	
		new entity = CreateEntityByName("prop_dynamic");
		SetEntityModel(entity, team == 3 ? sModelFlagConquest[0] : team == 2 ? sModelFlagConquest[1] : sModelFlagConquest[2]);
	
		//SetEntProp(entity, Prop_Send, "m_clrRender", -1);
	
		SetEntPropString(entity, Prop_Data, "m_iName", "mods_master");
	
		if(DispatchSpawn(entity))
		{
			g_EntFlag[zone_number] = entity;
			g_FlagClient[zone_number] = client;
		
			if(team == 3) 
			{
				if(g_FlagColorTeamConquest == 1)
				{
					SetEntityRenderMode(entity, RENDER_NORMAL);
					SetEntityRenderColor(entity, 0, 0, 255, 0);
				}
			
				if(sFlagAnimIdleConquest[0][0])
				{
					SetVariantString(sFlagAnimIdleConquest[0]);
					AcceptEntityInput(entity, "SetAnimation");
					AcceptEntityInput(entity, "TurnOn");
				}
			
				SetEntPropFloat(entity, Prop_Send, "m_flPlaybackRate", g_fFlagAnimSpeedConquest[0]);
			}
			else if(team == 2) 
			{
				if(g_FlagColorTeamConquest == 1)
				{
					SetEntityRenderMode(entity, RENDER_NORMAL);
					SetEntityRenderColor(entity, 255, 0, 0, 0);
				}

				if(sFlagAnimIdleConquest[1][0])
				{
					SetVariantString(sFlagAnimIdleConquest[1]);
					AcceptEntityInput(entity, "SetAnimation");
					AcceptEntityInput(entity, "TurnOn");
				}
			
				SetEntPropFloat(entity, Prop_Send, "m_flPlaybackRate", g_fFlagAnimSpeedConquest[1]);
			}
			else
			{
				if(sFlagAnimIdleConquest[2][0])
				{
					SetVariantString(sFlagAnimIdleConquest[2]);
					AcceptEntityInput(entity, "SetAnimation");
					AcceptEntityInput(entity, "TurnOn");
				}
			
				SetEntPropFloat(entity, Prop_Send, "m_flPlaybackRate", g_fFlagAnimSpeedConquest[2]);
			}

			SetEntPropVector(entity, Prop_Send, "m_vecMins", Float:{-15.0, -15.0, 0.0});
			SetEntPropVector(entity, Prop_Send, "m_vecMaxs", Float:{15.0, 15.0, 100.0});

			SetEntProp(entity, Prop_Send, "m_usSolidFlags", 12);
			SetEntProp(entity, Prop_Data, "m_nSolidType", 2);
		
			if(client != -1)
			{
				decl Float:fOriginPos[3], Float:fAngles[3], Float:fDirection[3];
			
				GetClientAbsOrigin(client, fOriginPos);
				GetClientAbsAngles(client, fAngles);

				GetAngleVectors(fAngles, fDirection, NULL_VECTOR, NULL_VECTOR);
		
				fOriginPos[0] += fDirection[0] * -10.0;
				fOriginPos[1] += fDirection[1] * -10.0;
			
				TeleportEntity(entity, fOriginPos, NULL_VECTOR, NULL_VECTOR);
			
				SetVariantString("!activator");
				AcceptEntityInput(entity, "SetParent", client);
			}
			else
			{
				TeleportEntity(entity, fPos, g_fFlagAngles, NULL_VECTOR);
		
				SDKHook(entity, SDKHook_StartTouch, OnStartTouch_Flag);
			
				if(bPedestal && (team == 3 && sModelPedestalConquest[0][0] || team == 2 && sModelPedestalConquest[1][0] || !team && sModelPedestalConquest[2][0]))
				{
					RemoveZonePedestal(zone_number);
		
					new entity2 = CreateEntityByName("prop_dynamic"); 
					SetEntityModel(entity2, team == 3 ? sModelPedestalConquest[0] : team == 2 ? sModelPedestalConquest[1] : sModelPedestalConquest[2]);
			
					SetEntPropString(entity2, Prop_Data, "m_iName", "mods_master");
			
					SetEntProp(entity2, Prop_Send, "m_usSolidFlags", 12);
					SetEntProp(entity2, Prop_Data, "m_nSolidType", 6);
		
					decl Float:fPos2[3];
		
					if(team == 3)
					{
						fPos2[0] += g_fPedestalPosConquest[0][0] + fPos[0];
						fPos2[1] += g_fPedestalPosConquest[0][1] + fPos[1];
						fPos2[2] += g_fPedestalPosConquest[0][2] + fPos[2];
					}
					else if(team == 2)
					{
						fPos2[0] += g_fPedestalPosConquest[1][0] + fPos[0];
						fPos2[1] += g_fPedestalPosConquest[1][1] + fPos[1];
						fPos2[2] += g_fPedestalPosConquest[1][2] + fPos[2];
					}
					else
					{
						fPos2[0] += g_fPedestalPosConquest[2][0] + fPos[0];
						fPos2[1] += g_fPedestalPosConquest[2][1] + fPos[1];
						fPos2[2] += g_fPedestalPosConquest[2][2] + fPos[2];
					}
			
					g_EntPedestal[zone_number] = entity2;
			
					TeleportEntity(entity2, fPos2, NULL_VECTOR, NULL_VECTOR);  	
				}	
			}
			
			return entity;
		}
	}
	
	return -1;
}

stock CreateZone(const Float:fPos[3], team, zone_number = -1)
{
	if(zone_number == -1) RemoveTeamZoneEntity(team);
	else RemoveZoneOfZoneEntity(zone_number);
	
	new entity = CreateEntityByName("trigger_multiple");
	
	DispatchKeyValue(entity, "targetname", "mods_master");
	DispatchKeyValue(entity, "model", "models/error.mdl");
	
	if(!IsModelPrecached("models/error.mdl")) PrecacheModel("models/error.mdl");
	
	if(DispatchSpawn(entity))
	{
		decl Float:fMins[3], Float:fMaxs[3], Float:fMiddle[3];
	
		CalculateZoneBox(fPos, fMins, fMaxs, zone_number);
	
		SetEntProp(entity, Prop_Data, "m_spawnflags", 64);
		SetEntProp(entity, Prop_Send, "m_nSolidType", 2);
	
		GetMiddleOfABox(fMins, fMaxs, fMiddle);
	
		TeleportEntity(entity, fMiddle, NULL_VECTOR, NULL_VECTOR);
	
		fMins[0] = fMins[0] - fMiddle[0];
		if (fMins[0] > 0.0)
			fMins[0] *= -1.0;
		fMins[1] = fMins[1] - fMiddle[1];
		if (fMins[1] > 0.0)
			fMins[1] *= -1.0;
		fMins[2] = fMins[2] - fMiddle[2];
		if (fMins[2] > 0.0)
			fMins[2] *= -1.0;
	
		fMaxs[0] = fMaxs[0] - fMiddle[0];
		if (fMaxs[0] < 0.0)
			fMaxs[0] *= -1.0;
		fMaxs[1] = fMaxs[1] - fMiddle[1];
		if (fMaxs[1] < 0.0)
			fMaxs[1] *= -1.0;
		fMaxs[2] = fMaxs[2] - fMiddle[2];
		if (fMaxs[2] < 0.0)
			fMaxs[2] *= -1.0;
	
		SetEntPropVector(entity, Prop_Send, "m_vecMins", fMins);
		SetEntPropVector(entity, Prop_Send, "m_vecMaxs", fMaxs);
	
		if(zone_number == -1)
		{
			if(team == 3) g_EntZone[0] = entity;
			else g_EntZone[1] = entity;
		}
		else g_EntZone[zone_number] = entity;
		
		SDKHook(entity, SDKHook_StartTouch, OnStartTouch_Zone);
		SDKHook(entity, SDKHook_EndTouch, OnEndTouch_Zone); 
		
		return entity;
	}
	
	return -1;
}

stock CreateSprite(const Float:fPos[3], team, zone_number)
{
	RemoveZoneSprite(zone_number);
	
	if(!sSpriteZoneConquest[zone_number][team == 3 ? 0:team == 2 ? 1:2][0]) return -1;
	
	new entity = CreateEntityByName("env_sprite");
	
	if(entity == -1) return -1;

	DispatchKeyValue(entity, "targetname", "mods_master");
	DispatchKeyValue(entity, "spawnflags", "1");
	DispatchKeyValue(entity, "scale", sSpriteZoneScaleConquest);
	DispatchKeyValue(entity, "rendermode", "1");
	DispatchKeyValue(entity, "rendercolor", "255 255 255");
	DispatchKeyValue(entity, "model", sSpriteZoneConquest[zone_number][team == 3 ? 0:team == 2 ? 1:2]);
	
	if(DispatchSpawn(entity)) 
	{
		decl Float:fPos1[3];
		
		fPos1[0] = fPos[0];
		fPos1[1] = fPos[1];
		fPos1[2] = fPos[2] + g_fSpriteZonePosConquest;
		
		TeleportEntity(entity, fPos1, NULL_VECTOR, NULL_VECTOR);

		g_EntSprite[zone_number] = entity;
		
		return entity;
	}
	
	return -1;
}

stock SetFlagGlow(entity_flag, team)
{
	RemoveTeamFlagGlow(team);
	
	new entity = CreateFlagModel(entity_flag, team == 3 ? sModelFlagCaptureFlag[0] : sModelFlagCaptureFlag[1]); 
	
	if(entity == -1) return;
	
	new offset = GetEntSendPropOffs(entity, "m_clrGlow");
	
	if(offset == -1) return;
	
	SetEntProp(entity, Prop_Send, "m_bShouldGlow", true, true);
	SetEntProp(entity, Prop_Send, "m_nGlowStyle", 0);
	SetEntPropFloat(entity, Prop_Send, "m_flGlowMaxDist", 10000000.0);
	
	SetEntPropString(entity, Prop_Data, "m_iName", "mods_master");
	
	if(team == 3) 
	{
		SetEntData(entity, offset, 0, _, true);
		SetEntData(entity, offset + 1, 0, _, true);
		SetEntData(entity, offset + 2, 255, _, true);
		
		if(sFlagAnimIdleCaptureFlag[0][0])
		{
			SetVariantString(sFlagAnimIdleCaptureFlag[0]);
			AcceptEntityInput(entity, "SetAnimation");
		}
		
		SetEntPropFloat(entity, Prop_Send, "m_flPlaybackRate", g_fFlagAnimSpeedCaptureFlag[0]);
	
		g_EntFlagGlow[0] = entity;
	}
	else
	{
		SetEntData(entity, offset, 255, _, true);
		SetEntData(entity, offset + 1, 0, _, true);
		SetEntData(entity, offset + 2, 0, _, true);
		
		if(sFlagAnimIdleCaptureFlag[1][0])
		{
			SetVariantString(sFlagAnimIdleCaptureFlag[1]);
			AcceptEntityInput(entity, "SetAnimation");
		}
		
		SetEntPropFloat(entity, Prop_Send, "m_flPlaybackRate", g_fFlagAnimSpeedCaptureFlag[1]);
		
		g_EntFlagGlow[1] = entity;
	}
	
	SetEntData(entity, offset + 3, 50, _, true);
	
	if(g_FlagGlowCaptureFlag == 1) SDKHook(entity, SDKHook_SetTransmit, SetTransmit_FlagGlow); 
}

stock CreateFlagModel(entity_flag, const String:sModel[])
{
	new entity = CreateEntityByName("prop_dynamic_override");
	
	DispatchKeyValue(entity, "model", sModel);
	DispatchKeyValue(entity, "solid", "0");
	
	if(DispatchSpawn(entity))
	{
		SetEntityRenderMode(entity, RENDER_TRANSALPHA);
		SetEntityRenderColor(entity, 255, 255, 255, 0);
	
		SetEntProp(entity, Prop_Send, "m_fEffects", (1 << 0)|(1 << 4)|(1 << 6)|(1 << 9));
		SetVariantString("!activator");
		AcceptEntityInput(entity, "SetParent", entity_flag, entity, 0);
		
		return entity;
	}
	
	return -1;
}

stock TE_SendBeamBoxToClient(client, const Float:uppercorner[3], const Float:bottomcorner[3], ModelIndex, HaloIndex, StartFrame, FrameRate, Float:Life, Float:Width, Float:EndWidth, FadeLength, Float:Amplitude, const Color[4], Speed) 
{
	new Float:pos1[3], Float:pos2[3], Float:pos3[3];
	
	AddVectors(pos1, bottomcorner, pos1); 
	pos1[0] = uppercorner[0];
	
	AddVectors(pos2, bottomcorner, pos2);
	pos2[1] = uppercorner[1];
	
	AddVectors(pos3, uppercorner, pos3);
	pos3[2] = bottomcorner[2];
	
	TE_SetupBeamPoints(pos1, bottomcorner, ModelIndex, HaloIndex, StartFrame, FrameRate, Life, Width, EndWidth, FadeLength, Amplitude, Color, Speed);
	TE_SendToClient(client);
	TE_SetupBeamPoints(pos2, bottomcorner, ModelIndex, HaloIndex, StartFrame, FrameRate, Life, Width, EndWidth, FadeLength, Amplitude, Color, Speed);
	TE_SendToClient(client);
	TE_SetupBeamPoints(pos1, pos3, ModelIndex, HaloIndex, StartFrame, FrameRate, Life, Width, EndWidth, FadeLength, Amplitude, Color, Speed);
	TE_SendToClient(client);
	TE_SetupBeamPoints(pos2, pos3, ModelIndex, HaloIndex, StartFrame, FrameRate, Life, Width, EndWidth, FadeLength, Amplitude, Color, Speed);
	TE_SendToClient(client);
}

stock TE_SendBeamBoxToClientAll(const Float:uppercorner[3], const Float:bottomcorner[3], ModelIndex, HaloIndex, StartFrame, FrameRate, Float:Life, Float:Width, Float:EndWidth, FadeLength, Float:Amplitude, const Color[4], Speed) 
{
	for (new i = 1; i <= MaxClients; i++)
	{
		if(IsClientInGame(i) && !IsFakeClient(i))
			TE_SendBeamBoxToClient(i, uppercorner, bottomcorner, ModelIndex, HaloIndex, StartFrame, FrameRate, Life, Width, EndWidth, FadeLength, Amplitude, Color, Speed);
	}
}

stock CalculateZoneBox(const Float:fPos[3], Float:fPos1[3], Float:fPos2[3], zone_number = -1)
{
	if(zone_number == -1)
	{
		fPos1[0] = fPos[0] - 100.0 * g_fFlagZoneSizeCaptureFlag;
		fPos1[1] = fPos[1] - 100.0 * g_fFlagZoneSizeCaptureFlag;
		fPos1[2] = fPos[2] + 150.0;
	
		fPos2[0] = fPos[0] + 100.0 * g_fFlagZoneSizeCaptureFlag;
		fPos2[1] = fPos[1] + 100.0 * g_fFlagZoneSizeCaptureFlag;
		fPos2[2] = fPos[2] + 5.0;
	}
	else 
	{
		fPos1[0] = fPos[0] - 100.0 * g_fFlagZoneSizeConquest[zone_number];
		fPos1[1] = fPos[1] - 100.0 * g_fFlagZoneSizeConquest[zone_number];
		fPos1[2] = fPos[2] + g_fFlagZoneHeightConquest[zone_number];
	
		fPos2[0] = fPos[0] + 100.0 * g_fFlagZoneSizeConquest[zone_number];
		fPos2[1] = fPos[1] + 100.0 * g_fFlagZoneSizeConquest[zone_number];
		fPos2[2] = fPos[2] + 5.0;
	}
}

bool:CheckStuckZone(const Float:fAimPos[3], zone_number)
{
	KvRewind(kv_zs);
	
	if(!KvJumpToKey(kv_zs, sMap, false)) return false;
	
	decl String:buffer[3], Float:fPos[3];
	
	new bool:bResult = true;
	
	for(new x = 0; x < 4; x++)
	{
		if(x != zone_number) 
		{
			IntToString(x+1, buffer, 3);

			if(KvJumpToKey(kv_zs, buffer, false))
			{
				KvGetVector(kv_zs, "pos", fPos);

				if(GetVectorDistance(fAimPos, fPos) < (200.0 * g_fFlagZoneSizeConquest[zone_number] + 10.0) + (50.0 * KvGetFloat(kv_zs, "size", 1.0))) 
				{
					bResult = false; 
					break;
				}
				
				KvGoBack(kv_zs);
			}
		}
	}
	
	return bResult;
}

bool:IsPlayerConquestFlag(client)
{
	for(new x = 0; x < 4; x++)
	{
		if(g_FlagClient[x] == client) 
			return true;
	}
	
	return false;
}

public bool:FilterCF(ent, mask, any:client) 
{ 
	return client != ent 
	&& ent != g_EntFlag[0] && ent != g_EntFlag[1]
	&& ent != g_EntPedestal[0] && ent != g_EntPedestal[1]; 
}

public bool:FilterConquest(ent, mask, any:client) 
{ 
	return client != ent 
	&& ent != g_EntFlag[0] && ent != g_EntFlag[1] && ent != g_EntFlag[2] && ent != g_EntFlag[3]
	&& ent != g_EntPedestal[0] && ent != g_EntPedestal[1] && ent != g_EntPedestal[2] && ent != g_EntPedestal[3];  
}

GetAimPos(client, Float:fAimPos[3])
{
	decl Float:fEyePosition[3], Float:fEyeAngles[3];
	GetClientEyePosition(client, fEyePosition); 
	GetClientEyeAngles(client, fEyeAngles); 
	TR_TraceRayFilter(fEyePosition, fEyeAngles, MASK_SOLID, RayType_Infinite, g_bEnabledCaptureFlag ? FilterCF:FilterConquest, client); 
	TR_GetEndPosition(fAimPos); 
}

stock GetMiddleOfABox(const Float:fVec1[3], const Float:fVec2[3], Float:buffer[3])
{
	decl Float:fMid[3];
	MakeVectorFromPoints(fVec1, fVec2, fMid);
	fMid[0] = fMid[0] / 2.0;
	fMid[1] = fMid[1] / 2.0;
	fMid[2] = fMid[2] / 2.0;
	AddVectors(fVec1, fMid, buffer);
}

stock RemoveTeamFlag(team)
{
	if(team == 3)
	{
		if(g_EntFlag[0] > 0 && IsValidEntity(g_EntFlag[0])) 
		{
			SDKUnhook(g_EntFlag[0], SDKHook_StartTouch, OnStartTouch_Flag);
			AcceptEntityInput(g_EntFlag[0], "Kill");
		}
		
		g_EntFlag[0] = -1;
	}
	else
	{
		if(g_EntFlag[1] > 0 && IsValidEntity(g_EntFlag[1])) 
		{
			SDKUnhook(g_EntFlag[1], SDKHook_StartTouch, OnStartTouch_Flag);
			AcceptEntityInput(g_EntFlag[1], "Kill");
		}
		
		g_EntFlag[1] = -1;
	}
}

stock RemoveZoneFlag(zone_number)
{
	if(g_EntFlag[zone_number] > 0 && IsValidEntity(g_EntFlag[zone_number])) 
	{	
		SDKUnhook(g_EntFlag[zone_number], SDKHook_StartTouch, OnStartTouch_Flag);
		AcceptEntityInput(g_EntFlag[zone_number], "Kill");
	}
		
	g_EntFlag[zone_number] = -1;
}

stock RemoveTeamPedestal(team)
{
	if(team == 3)
	{
		if(g_EntPedestal[0] > 0 && IsValidEntity(g_EntPedestal[0])) AcceptEntityInput(g_EntPedestal[0], "Kill");
		
		g_EntPedestal[0] = -1;
	}
	else
	{
		if(g_EntPedestal[1] > 0 && IsValidEntity(g_EntPedestal[1])) AcceptEntityInput(g_EntPedestal[1], "Kill");
		
		g_EntPedestal[1] = -1;
	}
}

stock RemoveZonePedestal(zone_number)
{
	if(g_EntPedestal[zone_number] > 0 && IsValidEntity(g_EntPedestal[zone_number])) AcceptEntityInput(g_EntPedestal[zone_number], "Kill");
		
	g_EntPedestal[zone_number] = -1;
}

stock RemoveZoneSprite(zone_number)
{
	if(g_EntSprite[zone_number] > 0 && IsValidEntity(g_EntSprite[zone_number])) AcceptEntityInput(g_EntSprite[zone_number], "Kill");
		
	g_EntSprite[zone_number] = -1;
}

stock RemoveTeamFlagGlow(team)
{
	if(team == 3)
	{
		if(g_EntFlagGlow[0] > 0 && IsValidEntity(g_EntFlagGlow[0]))
		{
			SDKUnhook(g_EntFlagGlow[0], SDKHook_SetTransmit, SetTransmit_FlagGlow); 
			AcceptEntityInput(g_EntFlagGlow[0], "Kill");
		}
		
		g_EntFlagGlow[0] = -1;
	}
	else
	{
		if(g_EntFlagGlow[1] > 0 && IsValidEntity(g_EntFlagGlow[1]))
		{
			SDKUnhook(g_EntFlagGlow[1], SDKHook_SetTransmit, SetTransmit_FlagGlow); 
			AcceptEntityInput(g_EntFlagGlow[1], "Kill");
		}
		
		g_EntFlagGlow[1] = -1;
	}
}

stock RemoveTeamZoneEntity(team)
{
	if(team == 3)
	{
		if(g_EntZone[0] > 0 && IsValidEntity(g_EntZone[0]))
		{
			SDKUnhook(g_EntZone[0], SDKHook_StartTouch, OnStartTouch_Zone);
			SDKUnhook(g_EntZone[0], SDKHook_EndTouch, OnEndTouch_Zone);
			AcceptEntityInput(g_EntZone[0], "Kill");
		}
		
		g_EntZone[0] = -1;
	}
	else
	{
		if(g_EntZone[1] > 0 && IsValidEntity(g_EntZone[1]))
		{
			SDKUnhook(g_EntZone[1], SDKHook_StartTouch, OnStartTouch_Zone);
			SDKUnhook(g_EntZone[1], SDKHook_EndTouch, OnEndTouch_Zone);
			AcceptEntityInput(g_EntZone[1], "Kill");
		}
		
		g_EntZone[1] = -1;
	}
}

stock RemoveZoneOfZoneEntity(zone_number)
{
	if(g_EntZone[zone_number] > 0 && IsValidEntity(g_EntZone[zone_number]))
	{
		SDKUnhook(g_EntZone[zone_number], SDKHook_StartTouch, OnStartTouch_Zone);
		SDKUnhook(g_EntZone[zone_number], SDKHook_EndTouch, OnEndTouch_Zone); 
		AcceptEntityInput(g_EntZone[zone_number], "Kill");
	}
		
	g_EntZone[zone_number] = -1;
}

stock KillAllEntity()
{
	decl String:buffer[20], max_ent;
	
	max_ent = GetMaxEntities();
	for (new i = MaxClients; i < max_ent; i++)
	{
		if(IsValidEntity(i) && GetEntPropString(i, Prop_Data, "m_iName", buffer, 20) && strcmp(buffer, "mods_master", true) == 0) AcceptEntityInput(i, "Kill");
	}
}

stock LoadFiles()
{
	if(sModelFlagCaptureFlag[0][0] && !IsModelPrecached(sModelFlagCaptureFlag[0])) PrecacheModel(sModelFlagCaptureFlag[0]);
	if(sModelFlagCaptureFlag[1][0] && !IsModelPrecached(sModelFlagCaptureFlag[1])) PrecacheModel(sModelFlagCaptureFlag[1]);
	
	if(sModelPedestalCaptureFlag[0][0] && !IsModelPrecached(sModelPedestalCaptureFlag[0])) PrecacheModel(sModelPedestalCaptureFlag[0]);
	if(sModelPedestalCaptureFlag[1][0] && !IsModelPrecached(sModelPedestalCaptureFlag[1])) PrecacheModel(sModelPedestalCaptureFlag[1]);

	if(sModelFlagConquest[0][0] && !IsModelPrecached(sModelFlagConquest[0])) PrecacheModel(sModelFlagConquest[0]);
	if(sModelFlagConquest[1][0] && !IsModelPrecached(sModelFlagConquest[1])) PrecacheModel(sModelFlagConquest[1]);
	if(sModelFlagConquest[2][0] && !IsModelPrecached(sModelFlagConquest[2])) PrecacheModel(sModelFlagConquest[2]);
	
	if(sModelPedestalConquest[0][0] && !IsModelPrecached(sModelPedestalConquest[0])) PrecacheModel(sModelPedestalConquest[0]);
	if(sModelPedestalConquest[1][0] && !IsModelPrecached(sModelPedestalConquest[1])) PrecacheModel(sModelPedestalConquest[1]);
	if(sModelPedestalConquest[2][0] && !IsModelPrecached(sModelPedestalConquest[2])) PrecacheModel(sModelPedestalConquest[2]);

	for(new x = 0; x < 4; x++)
	{
		for(new x2 = 0; x2 < 3; x2++)
		{
			if(sSpriteZoneConquest[x][x2][0] && !IsModelPrecached(sSpriteZoneConquest[x][x2])) PrecacheModel(sSpriteZoneConquest[x][x2]);
		}
	}
}

stock LoadFlags()
{
	g_Flag[0] = ModsMaster_Zone;
	g_Flag[1] = ModsMaster_Zone;

	CreateFlag(g_fFlagPos[0], TEAM_CT, true);
	CreateZone(g_fFlagPos[0], TEAM_CT);
	
	CreateFlag(g_fFlagPos[1], TEAM_T, true);
	CreateZone(g_fFlagPos[1], TEAM_T);
	
	Forward_OnFlagEvent(TEAM_CT, ModsMaster_Spawn);
	Forward_OnFlagEvent(TEAM_T, ModsMaster_Spawn);
}

stock GetAvailableCountPlayers(count_players)
{
	new ct, t;
	
	for(new i = 1, team; i <= MaxClients; i++)
	{
		if(IsClientInGame(i) && (team = GetClientTeam(i)) > 1)
		{
			if(team == 3) ct++;
			else t++;
		}
	}
	
	new min_count_players;
	
	if(ct > t) min_count_players = t;
	else if(ct < t) min_count_players = ct;
	else min_count_players = ct;
	
	if(min_count_players <= count_players)
		count_players = RoundToCeil(float(min_count_players)/2.0);
		
	if(count_players < 1) count_players = 1;
		
	return count_players;
}

stock GetNameZone(String:sNameZone[3], zone_number)
{
	switch(zone_number)
	{
		case 0: sNameZone = "A";
		case 1: sNameZone = "B";
		case 2: sNameZone = "C";
		case 3: sNameZone = "D";
	}
}

stock EndCaptureFlag()
{
	Forward_OnEndGame(); 

	g_bEnabledCaptureFlag = false;
		
	KillTimerDemoCaptureFlagViewer();
	KillTimerDemoConquestViewer();
	KillTimerUpdateBoxAll();
	KillTimerRoundStart();
	KillAllTimerFlagDown();
	KillAllTimerFlagProtect();
	
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
	
	KillAllEntity();
	
	ServerCommand("exec server.cfg");
	ServerCommand("mp_restartgame 1");
}

stock EndConquest()
{
	Forward_OnEndGame();

	g_bEnabledConquest = false;
	
	KillTimerDemoCaptureFlagViewer();
	KillTimerDemoConquestViewer();
	KillTimerUpdateBoxAll();
	KillTimerRoundStart();
	KillAllTimerFlagDown();
	KillAllTimerFlagProtect();
	
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
	
	KillAllEntity();
	
	ServerCommand("exec server.cfg");
	ServerCommand("mp_restartgame 1");
}