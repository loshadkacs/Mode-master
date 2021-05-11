new Handle:mp_roundtime, Handle:mp_roundtime_defuse, Handle:mp_roundtime_hostage, Handle:mp_maxrounds, Handle:mp_timelimit;

stock LoadConVars()
{
	mp_roundtime = FindConVar("mp_roundtime");
	HookConVarChange(mp_roundtime, OnSettingChanged);
	
	mp_roundtime_defuse = FindConVar("mp_roundtime_defuse");
	HookConVarChange(mp_roundtime_defuse, OnSettingChanged);
	
	mp_roundtime_hostage = FindConVar("mp_roundtime_hostage");
	HookConVarChange(mp_roundtime_hostage, OnSettingChanged); 
	
	mp_maxrounds = FindConVar("mp_maxrounds");
	HookConVarChange(mp_maxrounds, OnSettingChanged); 
	
	mp_timelimit = FindConVar("mp_timelimit");
	HookConVarChange(mp_timelimit, OnSettingChanged);
}

public OnSettingChanged(Handle:convar, String:oldValue[], String:newValue[])
{
	if(g_bEnabledConquest) 
	{
		if(mp_roundtime == convar) SetConVarInt(mp_roundtime, g_RoundTimeConquest, false, false);
		else if(mp_roundtime_defuse == convar) SetConVarInt(mp_roundtime_defuse, g_RoundTimeConquest, false, false);
		else if(mp_roundtime_hostage == convar) SetConVarInt(mp_roundtime_hostage, g_RoundTimeConquest, false, false); 
		return;
	}

	if(!g_bEnabledCaptureFlag) return;

	if(mp_roundtime == convar) SetConVarInt(mp_roundtime, g_RoundTimeCaptureFlag, false, false);
	else if(mp_roundtime_defuse == convar) SetConVarInt(mp_roundtime_defuse, g_RoundTimeCaptureFlag, false, false);
	else if(mp_roundtime_hostage == convar) SetConVarInt(mp_roundtime_hostage, g_RoundTimeCaptureFlag, false, false);
	else if(mp_maxrounds == convar) SetConVarInt(mp_maxrounds, 0, false, false);
	else if(mp_timelimit == convar) SetConVarInt(mp_timelimit, 100, false, false);

}

stock UpdateConVars()
{
	if(g_bEnabledConquest)
	{
		SetConVarInt(mp_roundtime, g_RoundTimeConquest, false, false);
		SetConVarInt(mp_roundtime_defuse, g_RoundTimeConquest, false, false);
		SetConVarInt(mp_roundtime_hostage, g_RoundTimeConquest, false, false);
		return;
	}

	if(g_bEnabledCaptureFlag) 
	{
		SetConVarInt(mp_roundtime, g_RoundTimeCaptureFlag, false, false);
		SetConVarInt(mp_roundtime_defuse, g_RoundTimeCaptureFlag, false, false);
		SetConVarInt(mp_roundtime_hostage, g_RoundTimeCaptureFlag, false, false);
		SetConVarInt(mp_maxrounds, 0, false, false);
		SetConVarInt(mp_timelimit, 100, false, false);
	}
}