_minimumPlayers = 2;
_playZoneSize = 500;

_spawnZonePos = [8452,25089,0];
_spawnZoneSize = 50;

_zoneLootMinutes = 4;
_zoneRoundMinutes = 16;
_zoneNumChanges = 8;
_zoneSizeMetersScaling = 35;
_zoneDamageDuration = 10; // SECONDS TO WAIT UNTIL EACH CHECK
_zoneMessageOnScreenDuration = 10; // HOW LONG TO DISPLAY ON SCREEN MESSAGES FOR
_zoneLoopSleep = 1; // MINUMUM SECONDS TO SLEEP PER LOOP

_playerAFKTimeMax = 300; // 300 SECONDS AKA 5 MINUTES BEFORE KICK

/////////////////////////////////////////////////////////////////////////////
// SERVER SIDE VARIABLES
missionNamespace setVariable ["BRCQC_var_minPlayers",_minimumPlayers,false];
missionNamespace setVariable ["BRCQC_var_spawnZonePos",_spawnZonePos,false];
missionNamespace setVariable ["BRCQC_var_spawnZoneSize",_spawnZoneSize,false];
missionNamespace setVariable ["BRCQC_var_playZoneSize",_playZoneSize,false];
missionNamespace setVariable ["BRCQC_var_playZoneLoopText","UNKNOWN",false];
missionNamespace setVariable ["BRCQC_var_playZoneInProgress",false,false];
missionNamespace setVariable ["BRCQC_var_waitingForPlayers",false,false];

missionNameSpace setVariable ["BRCQC_var_zoneLootMinutes",_zoneLootMinutes,false];
missionNameSpace setVariable ["BRCQC_var_zoneRoundMinutes",_zoneRoundMinutes,false];
missionNameSpace setVariable ["BRCQC_var_zoneNumChanges",_zoneNumChanges,false];
missionNameSpace setVariable ["BRCQC_var_zoneSizeMetersScaling",_zoneSizeMetersScaling,false];
missionNameSpace setVariable ["BRCQC_var_zoneDamageDuration",_zoneDamageDuration,false];
missionNameSpace setVariable ["BRCQC_var_zoneMessageOnScreenDuration",_zoneMessageOnScreenDuration,false];
missionNameSpace setVariable ["BRCQC_var_zoneLoopSleep",_zoneLoopSleep,false];

missionNameSpace setVariable ["BRCQC_var_announcingWinner",false,false];
missionNameSpace setVariable ["BRCQC_var_announcingDeaths",false,false];

/////////////////////////////////////////////////////////////////////////////
// CLIENT SIDE VARIABLES
missionNameSpace setVariable ["BRCQC_var_playerAFKTimeMax",_playerAFKTimeMax,true];

[] spawn BRCQC_fnc_serverInit;
[] spawn BRCQC_fnc_markerSetupInit;
[] spawn BRCQC_fnc_objectSetupInit;
[] spawn BRCQC_fnc_restrictInit;
[] spawn BRCQC_fnc_playersInit;

missionNameSpace setVariable ["BRCQC_var_initServerComplete",true,true];
