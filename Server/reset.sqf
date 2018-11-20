/*
	File: reset.sqf
	Description: Server reset for BRGH
	Created By: PlayerUnknown & Lystic
	Date: 10/20/2014
	Parameters: n/a
	Returns: n/a
	Modified By: soulkobk (2015-11-25)
*/

if(BRMini_GamesPlayed >= BRMini_GamesPlayed_MaxGames) then {
	DIAG_LOG "<RESET>: RESTARTING MISSION";
	["Won"] spawn BIS_fnc_endMissionServer;
} else {

	{_x addScore - (score _x)} forEach playableUnits; // reset all player scores back to 0.

	DIAG_LOG "<RESET>: CLEANING UP MAP";
	call BRGH_fnc_mapCleanup; 
	
	DIAG_LOG "<RESET>: WAITING FOR THREADS";
	if(typename _this == typename []) then {
		{waitUntil{scriptDone _x};} forEach (_this select 0);
		{waitUntil{completedFSM _x};} forEach (_this select 1);
	};
	
	DIAG_LOG "<RESET>: RESETING VARIABLES";
	BRMini_GameStarted = false;
	BRMini_ZoneStarted = false; 
	BRMini_InGame = false;
	BRMini_ServerOn = true;
	
	BRMini_WaitingForPlayers = true;
	publicVariable "BRMini_WaitingForPlayers";
	BRMini_LootSpawned = false;
	publicVariable "BRMini_LootSpawned";
	BRMini_WinnerAnnounce = false;
	publicVariable "BRMini_WinnerAnnounce";
	
	// missionNamespace setVariable ["BRMini_WaitingForPlayers",true];
	// missionNamespace setVariable ["BRMini_LootSpawned",true];
	// missionNamespace setVariable ["BRMini_GameStarted",true];
	// missionNamespace setVariable ["BRMini_WinnerAnnounce",true];
	
	DIAG_LOG "<RESET>: RESTARTING SERVER";
	call BRGH_fnc_mapSetup;
	[] spawn BRGH_fnc_serverStart;
};
