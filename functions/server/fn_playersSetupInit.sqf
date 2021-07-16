// fn_playZoneplayersSetupInit.sqf 13:22 PM 13/07/2021

if (!isServer) exitWith {};

waitUntil {!isNil "BRCQC_var_initServerComplete"};
waitUntil {!isNil "BRCQC_mkr_spawnZone"};
waitUntil {!isNil "BRCQC_mkr_blackZone"};
waitUntil {!isNil "BRCQC_mkr_greenZone"};

// get spawn zone players
_playZonePlayers = allUnits select {(isPlayer _x) && (alive _x) && ((_x getVariable ["BRCQC_var_isPlaying",false]) isEqualTo false) && (_x inArea BRCQC_mkr_spawnZone)};
_playZonePlayersNum = count _playZonePlayers;

// shuffle players
_playZonePlayers call BIS_fnc_arrayShuffle;

// apply players functions/variables
_playZonePlayers apply
{
	[0] remoteExec ["closeDialog",_x];
	[false] remoteExec ["openMap",_x];
	[5,[false,false]] remoteExec ["enableChannel",_x];
	[1,["","BLACK OUT",2]] remoteExec ["cutText",_x];
	_x setVariable ["BRCQC_var_isPlaying",true,true];
	_x setVariable ["BRCQC_var_isWinner",false,true];
	{
		BRCQC_deh_keyPress = (findDisplay 46) displayAddEventHandler ['KeyDown',{true}]; // disable keypress
		[] spawn
		{
			while {((player getVariable "BRCQC_var_isPlaying") isEqualTo true)} do
			{
				player allowDamage true;
				uiSleep 0.1;
			};
		};
	} remoteExec ["call",_x];
};

sleep 5;

// teleport players to play zone
_playZoneDegreesStep = 360 / (_playZonePlayersNum + 1);
_step = 0;
{
	_player = _x;
	_playerPos = [markerPos BRCQC_mkr_blackZone,(BRCQC_var_playZoneSize - 100),_step] call BIS_fnc_relPos;
	_playerPos = _playerPos findEmptyPosition [2,25,"C_MAN_1"];
	_player setPos _playerPos;
	_playerDirOri = getDir player;
	_playerDirRel = _player getRelDir (markerPos BRCQC_mkr_blackZone);
	_playerDir = ((_playerDirOri + _playerDirRel) mod 360);
	_player setDir _playerDir;
	_step = _step + _playZoneDegreesStep;
} forEach _playZonePlayers;

sleep 5;

// get initialized players 
_playZonePlayers = allUnits select {(isPlayer _x) && (alive _x) && ((_x getVariable ["BRCQC_var_isPlaying",false]) isEqualTo true) && (_x inArea BRCQC_mkr_greenZone)};
_playZonePlayersNum = ((count _playZonePlayers) - 1);

_playZonePlayersNumText = "";
if (_playZonePlayersNum <= 1) then
{
	_playZonePlayersNumText = "PLAYER";
}
else
{
	_playZonePlayersNumText = "PLAYERS";
};

// display on-screen text
_onScreenMessages =
[
	["WELCOME TO<br/><t color='#FF0000'>BATTLE ROYALE CQC</t>",5],
	[format ["CURRENT ROUND LOCATION IS<br/><t color='#00FF00'>%1 AT %2</t>",BRCQC_var_playZoneLocationText,toUpperANSI worldName],5],
	[format ["YOU ARE COMPETING AGAINST<br/><t color='#FF0000'>%1 OTHER %2</t>",_playZonePlayersNum,_playZonePlayersNumText],5],
	["<t color='#00FF00'>GOOD LUCK!</t>",5]
];
{
	_currentMessage = _x select 0;
	_currentSleep = _x select 1;
	BRCQC_pve_dynamicText = [format ["%1",_currentMessage],0,0.45,_currentSleep,0];
	if (isServer && hasInterface) then {if ((alive player) && (player inArea BRCQC_mkr_greenZone)) then {publicVariableServer "BRCQC_pve_dynamicText"}} else {_playZonePlayers apply {(owner _x) publicVariableClient "BRCQC_pve_dynamicText"}};
	uiSleep _currentSleep;
} forEach _onScreenMessages;

// display on-screen text with beeps
_onScreenMessages =
[
	["5",1],
	["4",1],
	["3",1],
	["2",1],
	["1",1]
];
{
	_currentMessage = _x select 0;
	_currentSleep = _x select 1;
	BRCQC_pve_dynamicText = [format ["%1",_currentMessage],0,0.45,_currentSleep,0];
	if (isServer && hasInterface) then {if ((isPlayer player) && (alive player) && ((player getVariable ["BRCQC_var_isPlaying",false]) isEqualTo true) && (player inArea BRCQC_mkr_greenZone)) then {publicVariableServer "BRCQC_pve_dynamicText"; playSound "beep_target"}} else {_playZonePlayers apply {(owner _x) publicVariableClient "BRCQC_pve_dynamicText"; ["beep_target"] remoteExec ["playSound",_x];}};
	uiSleep _currentSleep;
} forEach _onScreenMessages;

// fade screen back in on clients
_playZonePlayers apply
{
	[1,["","BLACK IN",2]] remoteExec ["cutText",_x];
	{
		(findDisplay 46) displayRemoveEventHandler ['KeyDown',BRCQC_deh_keyPress]; // enable keypress
	} remoteExec ["call",_x];
};

BRCQC_var_playZoneSetupPlayers = false;
