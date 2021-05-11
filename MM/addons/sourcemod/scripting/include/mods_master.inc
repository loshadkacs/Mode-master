// Автор плагина: KOROVKA

enum CF_ConfigParam {
	CaptureFlag_RoundTime,
	CaptureFlag_FlagDownTime,
	CaptureFlag_FlagProtectTime, 
	CaptureFlag_RoundEndTime,
	CaptureFlag_VoteModeTime, 
	CaptureFlag_VoteMapTime
};

enum CONQUEST_ConfigParam {
	Conquest_RoundTime,
	Conquest_FlagDownTime,
	Conquest_FlagProtectTime,
	Conquest_RoundEndTime
};

enum MM_Type {
	ModsMaster_None,
	ModsMaster_Spawn,
	ModsMaster_Zone,
	ModsMaster_Down,
	ModsMaster_Captured,
	ModsMaster_FullCaptured,
	ModsMaster_Delivered,
	ModsMaster_ZoneCaptured 
};

enum ZoneName {
	Conquest_None = -1,
	Conquest_A,
	Conquest_B,
	Conquest_C,
	Conquest_D
};

enum ZoneParam {
	Conquest_Team,
	Conquest_CountPlayers,
	Conquest_Time,
	Conquest_Movable
};

#define TEAM_NEUTRAL 0
#define TEAM_CT 3
#define TEAM_T 2

native bool:CF_EnabledThisMoment(); // Вернет включен ли режим захват флага в данный момент.
native bool:CONQUEST_EnabledThisMoment(); // Вернет включен ли режим захват точек в данный момент.

native bool:CF_ThisMapConfigFlagsPos(String:sMap[]); // Вернет имеется ли данная карта в конфиге с позициями флагов.
native bool:CONQUEST_ThisMapConfigZonesSave(String:sMap[]); // Вернет имеется ли данная карта в конфиге с позициями зон.

native bool:CF_StartGame(); // Запустит режим захват флага.
native bool:CF_EndGame(); // Остановит режим захват флага.

native bool:CONQUEST_StartGame(); // Запустит режим захват точек.
native bool:CONQUEST_EndGame(); // Остановит режим захват точек.

native bool:MM_StartVote(NotMapVote = 0, String:sMapName[] = ""); // Запустит голосование за включение мода на следующей карте, а после запустит голосование за карту. (NotMapVote: Если равен 1, то мод не запустит голосование за карту) (sMapName: Карта выбранная для игры с модом, подстроит список доступных режимов под эту карту)

native MM_Type:CF_GetFlagStatusTeam(team); // Вернет статус флага команды. (Примечание: Может получить любой статус кроме "ModsMaster_Spawn", "ModsMaster_Delivered", "ModsMaster_FullCaptured" и "ModsMaster_ZoneCaptured")
native CF_GetClientFlagCapturedTeam(team); // Вернет индекс игрока захватившего флаг команды. (return: -1 - Флаг не захвачен)
native CF_GetClientZoneTeam(client); // Вернет команду зоны в которой находится игрок. (return: -1 - Игрок не в зоне)
native CF_GetEntityFlag(team); // Вернет индекс флага команды. (return: -1 - Флаг не существует)
native CF_GetEntityPedestal(team); // Вернет индекс пьедестала команды. (return: -1 - Пьедестал не существует)

native MM_Type:CONQUEST_GetFlagStatusZone(ZoneName:zone); // Вернет статус флага из зоны. (Примечание: Может получить любой статус кроме "ModsMaster_Spawn", "ModsMaster_Delivered" и "ModsMaster_ZoneCaptured")
native CONQUEST_GetClientFlagCapturedZone(ZoneName:zone); // Вернет индекс игрока захватившего флаг из зоны. (return: -1 - Флаг не захвачен)
native ZoneName:CONQUEST_GetClientZone(client); // Вернет зону в которой находится игрок. (return: Conquest_None - Игрок не в зоне)
native CONQUEST_GetEntityFlag(ZoneName:zone); // Вернет индекс флага из зоны. (return: -1 - Флаг не существует)
native CONQUEST_GetEntityPedestal(ZoneName:zone); // Вернет индекс пьедестала из зоны. (return: -1 - Пьедестал не существует)

forward MM_OnZoneStartTouch(client, team, ZoneName:zone); // Вызывается при входе в зону.
forward MM_OnZoneEndTouch(client, team, ZoneName:zone); // Вызывается при выходе из зоны.

forward MM_OnFlagDownTime(team, time); // Вызывается раз в секунду когда флаг на земле.
forward MM_OnFlagProtectTime(team, time); // Вызывается раз в секунду когда флаг под защитой.
forward MM_OnRoundTime(time); // Вызывается раз в секунду от начала раунда.

forward MM_OnFlagEvent(team, MM_Type:event, client, disconnect, ZoneName:zone); // Вызывается после одного из событий связанных с флагом. (client: Если игрок причастен к этому событию передаст его индекс) (disconnect: Если равен 1, то значит событие произошло при отключение игрока)

forward MM_OnStartMapModeVote(); // Вызывается при старте голосования за мод на следующей карте.
forward MM_OnStartMapVote(); // Вызывается при старте голосования за следующую карту.

forward CF_OnMapStart(); // Вызывается при старте карты если запущен режим захват флага.
forward CONQUEST_OnMapStart(); // Вызывается при старте карты если запущен режим захват точек.

forward CF_OnStartGame(); // Вызывается при старте режима захват флага.
forward CF_OnEndGame(); // Вызывается при остановке режима захват флага.

forward CONQUEST_OnStartGame(); // Вызывается при старте режима захват точек.
forward CONQUEST_OnEndGame(); // Вызывается при остановке режима захват точек.

native GetCaptureFlagConfigParam(CF_ConfigParam:param); // Вернет значение нужного параметра из конфига.
native GetConquestConfigParam(CONQUEST_ConfigParam:param);

native GetConquestZoneParam(ZoneName:zone, ZoneParam:param); // Вернет значение нужного параметра зоны.

native Handle:CONQUEST_GetKeyValuesZonesSave(); // Вернет клон HANDLE KeyValues где хранятся настроки зон.