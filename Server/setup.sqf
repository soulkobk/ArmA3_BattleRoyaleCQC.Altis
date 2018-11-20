/*
	File: setup.sqf
	Description: Server one-time setup for BRGH
	Created By: PlayerUnknown & Lystic
	Date: 10/20/2014
	Parameters: n/a
	Returns: n/a
*/

BRMini_ZoneStarted = false;
BRMini_InGame = false;
BRMini_ServerOn = true;

BRMini_Winners = [];
BRMini_WinnerScores = [];

BRMini_GamesPlayed = 0;

br_maxFogHeight = 200;
br_maxFogDensity = 0.04;
br_maxFogStrength = 0.1;

call BRGH_fnc_serverConfig;
call BRGH_fnc_playerConfig;
call BRGH_fnc_mapSetup;
// call BRGH_fnc_vehicleHandler; // causes issues with loot spawn script

BRMini_WaitingForPlayers = true;
BRMini_LootSpawned = false;
BRMini_GameStarted = false;
BRMini_WinnerAnnounce = false;

// missionNamespace setVariable ["BRMini_WaitingForPlayers",true];
// missionNamespace setVariable ["BRMini_LootSpawned",true];
// missionNamespace setVariable ["BRMini_GameStarted",true];
// missionNamespace setVariable ["BRMini_WinnerAnnounce",true];

addMissionEventHandler ["PlayerConnected",{ 
	publicVariable "BRMini_WaitingForPlayers";
	publicVariable "BRMini_LootSpawned";
	publicVariable "BRMini_GameStarted";
	publicVariable "BRMini_WinnerAnnounce";
}];

BRMini_RE = compileFinal '
	_script = if(typename _this == "STRING") then {compile _this} else {_this};
	_agent = createAgent ["LOGIC",[0,0,0],[],0,"NONE"];
	_agent addMPEventHandler ["MPKilled",_script];
	_agent setDamage 1;
	deleteVehicle _agent;
';

//--- Fix for BI's getServerVariable server backdoor
"BIS_fnc_getServerVariable_packet" addPublicVariableEventHandler {
	_var = _this select 1;
	_target = _var select 0;
	_variab = _var select 1;
	diag_log format["<HACKS>: %1('%2') just tried to get the variable %3 (hacking?)",name _target, getplayeruid _target, _variab];
};

"BRMini_AddScore" addPublicVariableEventHandler 
{
	_killer = ((_this select 1) select 0);
	_killer addScore 2; // friendly kills are -1, so 2 - 1 = 1 player kill.
};

RUBE_randomCirclePositions = compile preprocessFileLineNumbers "Server\Scripts\fn_randomCirclePositions.sqf";